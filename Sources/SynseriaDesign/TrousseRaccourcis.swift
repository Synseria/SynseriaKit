// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
import SwiftUI

// L'enregistreur de raccourci de la trousse et l'écoute du clavier qu'il arme : un seul champ à l'écoute.

#if os(macOS)

/// Un champ qui enregistre une combinaison de touches (`.enr`). Un clic l'arme ; la frappe suivante
/// que `lire` accepte devient le raccourci ; ⌫ l'efface, ⎋ ou un clic ailleurs renoncent. Au repos, ses touches comme
/// partout (`ToucheDeClavier`) ; sans raccourci, un tiret. Un seul champ de l'app écoute à la fois :
/// en armer un désarme l'autre (`Titulaire.duClavier`). L'app garde son type de raccourci :
/// `lire` le tire d'une frappe (nil : refusée, l'écoute continue), `touches` le dessine.
public struct EnregistreurDeRaccourci<Valeur: Equatable>: View {
    @Binding public var valeur: Valeur?
    public let touches: (Valeur) -> [String]
    public let lire: (NSEvent) -> Valeur?
    /// Ce que dit le champ armé (« Tape le raccourci »), et sans raccourci, pour VoiceOver (« Aucun »).
    public let invite: String
    public let aucun: String
    @State private var arme: Bool
    @Environment(\.couleursSynseria) private var c

    /// `armeAuDepart` : le champ naît à l'écoute (on arrive pour changer ce raccourci).
    public init(valeur: Binding<Valeur?>, touches: @escaping (Valeur) -> [String], lire: @escaping (NSEvent) -> Valeur?,
         invite: String, aucun: String, armeAuDepart: Bool = false) {
        (_valeur, self.touches, self.lire, self.invite, self.aucun) = (valeur, touches, lire, invite, aucun)
        _arme = State(initialValue: armeAuDepart)
    }

    public var body: some View {
        Button { arme.toggle() } label: {
            if !arme, let valeur {
                HStack(spacing: Jetons.espace1) {
                    ForEach(Array(touches(valeur).enumerated()), id: \.offset) { _, touche in ToucheDeClavier(touche: touche) }
                }
                .fixedSize()
                .accessibilityLabel(touches(valeur).joined())
            } else {
                let forme = RoundedRectangle(cornerRadius: Jetons.rayon1, style: .circular)
                Text(arme ? invite : "—")
                    .font(Jetons.typoMeta.font)
                    .foregroundStyle(c.encre2.couleur)
                    .padding(.horizontal, Jetons.espace2)
                    .frame(minWidth: Jetons.largeurNav * 0.4, minHeight: Jetons.diametreRond)
                    .background(c.plaque.couleur, in: forme)
                    .overlay { forme.strokeBorder((arme ? c.accent : c.filet).couleur, lineWidth: Jetons.epaisseurFilet) }
                    .accessibilityLabel(arme ? invite : aucun)
            }
        }
        .buttonStyle(.plain)
        .contentShape(.rect)
        .curseurDeClic(true)
        .background(EcouteDuClavier(arme: $arme, lire: lire) { valeur = $0 })
        // Un clic ailleurs renonce, comme ⎋.
        .quitteAuClicAilleurs(arme) { arme = false }
    }
}

/// Le moniteur local de frappe, vivant tant que le champ est armé : il ne voit que les touches de
/// l'app, et ne mord que pour son champ vu (sa fenêtre clé, ni caché ni effacé) — sinon il se
/// désarme et laisse passer la touche. Démonté armé, il se retire : il avalait toutes les frappes.
public struct EcouteDuClavier<Valeur>: NSViewRepresentable {
    @Binding public var arme: Bool
    public let lire: (NSEvent) -> Valeur?
    public let capturer: (Valeur?) -> Void

    public init(arme: Binding<Bool>, lire: @escaping (NSEvent) -> Valeur?, capturer: @escaping (Valeur?) -> Void) {
        self._arme = arme
        self.lire = lire
        self.capturer = capturer
    }

    public func makeNSView(context _: Context) -> NSView { NSView() }

    public func updateNSView(_ vue: NSView, context: Context) {
        context.coordinator.regler(arme: arme, vue: vue, lire: lire, capturer: { capturer($0); arme = false }) { arme = false }
    }

    public func makeCoordinator() -> Coordinateur { Coordinateur() }

    public static func dismantleNSView(_: NSView, coordinator: Coordinateur) { coordinator.arreter() }

    /// Ce que devient une frappe reçue armé.
    public enum Issue: Equatable {
        /// Le champ n'est pas vu : il se désarme, la touche suit son chemin.
        case ailleurs
        /// ⎋ : le champ renonce, la touche s'arrête là.
        case renoncer
        /// ⌫ ou ⌦ : le raccourci s'efface.
        case effacer
        /// Le reste : `lire` dit si c'est un raccourci.
        case lire
    }

    /// Par le caractère, jamais par la position de la touche : ⎋ et ⌫ se lisent sur toute disposition.
    public static func issue(vu: Bool, modificateurs: NSEvent.ModifierFlags, caracteres: String?) -> Issue {
        guard vu else { return .ailleurs }
        let nus = modificateurs.intersection(.deviceIndependentFlagsMask).subtracting([.numericPad, .function, .capsLock]).isEmpty
        switch (nus, caracteres) {
        case (true, "\u{1b}"): return .renoncer
        case (true, "\u{7f}"), (true, "\u{f728}"): return .effacer
        default: return .lire
        }
    }

    @MainActor
    public final class Coordinateur {
        private var moniteur: Any?
        private weak var vue: NSView?
        private var lire: (NSEvent) -> Valeur? = { _ in nil }
        private var capturer: (Valeur?) -> Void = { _ in }
        private var renoncer: () -> Void = {}
        /// Un autre champ a pris le clavier pendant que celui-ci restait armé : il ne le reprend
        /// pas avant d'avoir été désarmé, même si sa liaison n'a pas encore suivi.
        private var paroleRendue = false

        /// Vrai tant que le moniteur est posé.
        public var ecoute: Bool { moniteur != nil }

        public func regler(arme: Bool, vue: NSView, lire: @escaping (NSEvent) -> Valeur?,
                    capturer: @escaping (Valeur?) -> Void, renoncer: @escaping () -> Void) {
            (self.vue, self.lire, self.capturer, self.renoncer) = (vue, lire, capturer, renoncer)
            guard arme else {
                paroleRendue = false
                return arreter()
            }
            guard moniteur == nil, !paroleRendue else { return }
            Titulaire.duClavier.prendre(self) { [weak self] in self?.rendreLaParole() }
            moniteur = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] evenement in
                MainActor.assumeIsolated { self?.avaler(evenement) ?? false } ? nil : evenement
            }
        }

        /// Vrai : la frappe est pour le champ, elle ne va pas plus loin.
        public func avaler(_ evenement: NSEvent) -> Bool {
            // Une page gardée montée mais effacée (un ancêtre à l'opacité nulle) ne se voit pas non plus.
            let vu = vue.map { vue in
                guard let fenetre = vue.window else { return false }
                return evenement.window === fenetre && fenetre.isKeyWindow && !vue.isHiddenOrHasHiddenAncestor
                    && !sequence(first: vue, next: \.superview).contains { $0.alphaValue == 0 }
            } ?? false
            switch Self.issueDe(evenement, vu: vu) {
            case .ailleurs:
                renoncer()
                return false
            case .renoncer: renoncer()
            case .effacer: capturer(nil)
            case .lire: if let valeur = lire(evenement) { capturer(valeur) }
            }
            return true
        }

        private static func issueDe(_ evenement: NSEvent, vu: Bool) -> Issue {
            EcouteDuClavier.issue(vu: vu, modificateurs: evenement.modifierFlags,
                                  caracteres: vu ? evenement.charactersIgnoringModifiers : nil)
        }

        public func arreter() {
            Titulaire.duClavier.lacher(self)
            guard let moniteur else { return }
            NSEvent.removeMonitor(moniteur)
            self.moniteur = nil
        }

        /// Un autre champ s'arme : le moniteur part tout de suite, la liaison suit après la mise à
        /// jour en cours (l'écrire pendant celle de l'autre champ est interdit).
        private func rendreLaParole() {
            paroleRendue = true
            arreter()
            let renoncer = renoncer
            Task { @MainActor in renoncer() }
        }
    }
}

/// Un seul titulaire dans l'app : le prendre le retire à celui qui l'avait (`rendre`), sinon les deux
/// le garderaient — la frappe suivante irait aux deux champs, deux listes resteraient ouvertes et
/// allumées, l'hôte n'en montrant qu'une.
@MainActor
public final class Titulaire {
    /// Le champ qui écoute le clavier pour un raccourci (`EcouteDuClavier`).
    public static let duClavier = Titulaire()
    /// Le contrôle dont la liste est ouverte (`PriseDeLaListe`) : en ouvrir une ferme l'autre.
    public static let deLaListe = Titulaire()
    private(set) weak var titulaire: AnyObject?
    private var rendre: (() -> Void)?

    public func prendre(_ qui: AnyObject, rendre: @escaping () -> Void) {
        if titulaire !== qui, let ancien = self.rendre {
            self.rendre = nil
            ancien()
        }
        (titulaire, self.rendre) = (qui, rendre)
    }

    /// Ne rend la place que si `qui` l'a : un contrôle qui disparaît ne coupe pas celui d'un autre.
    public func lacher(_ qui: AnyObject) {
        guard titulaire === qui else { return }
        (titulaire, rendre) = (nil, nil)
    }
}
#endif
