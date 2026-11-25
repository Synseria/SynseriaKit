// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
import SwiftUI

// Les choix de la trousse : interrupteur, case ronde et radio, segmentés, onglets ronds, puces, barre
// des onglets de réglages. Un groupe est un seul arrêt de Tab ; les flèches déplacent le choix.

// MARK: - L'interrupteur

/// L'interrupteur de la trousse (`.tg`) : une pilule de `largeur-interrupteur` × `hauteur-case`, le
/// pouce de `diametre-rond` ; actif, plein `accent`. Le pouce s'allonge sous le doigt.
public struct Interrupteur: ToggleStyle {
    /// Le libellé après l'interrupteur, sinon avant, comme le système.
    public var libelleApres = false
    /// Le petit (`.tg.petit`) : celui d'une option posée à droite d'un titre, le libellé en méta.
    public var petit = false

    public init(libelleApres: Bool = false, petit: Bool = false) {
        self.libelleApres = libelleApres
        self.petit = petit
    }

    public func makeBody(configuration: Configuration) -> some View {
        CorpsDeLInterrupteur(configuration: configuration, libelleApres: libelleApres, petit: petit)
    }
}

extension ToggleStyle where Self == Interrupteur {
    public static var interrupteur: Interrupteur { Interrupteur() }
    public static var petitInterrupteur: Interrupteur { Interrupteur(petit: true) }
}

private struct CorpsDeLInterrupteur: View {
    let configuration: ToggleStyleConfiguration
    let libelleApres: Bool
    let petit: Bool
    @Environment(\.isEnabled) private var actif
    @Environment(\.labelsVisibility) private var libelles

    var body: some View {
        HStack(spacing: petit ? Jetons.espace2 : Jetons.espace3) {
            if libelles != .hidden, !libelleApres { configuration.label }
            // Un bouton : Tab et espace comme l'interrupteur du système, l'anneau de la trousse ; un
            // clic relâché hors de la piste ne bascule rien.
            Button { configuration.isOn.toggle() } label: { EmptyView() }
                .buttonStyle(PisteDInterrupteur(allume: configuration.isOn, petit: petit))
                .focusEffectDisabled()
                .accessibilityRepresentation { Toggle(isOn: configuration.$isOn) { configuration.label } }
            if libelles != .hidden, libelleApres { configuration.label }
        }
        .font((petit ? Jetons.typoMeta : Jetons.typoCorps).font)
        // Le grisé d'un tout, comme `opacity` en CSS : sans groupe, chaque couche pâlit sur l'autre.
        .compositingGroup()
        .opacity(actif ? 1 : Jetons.opaciteDesactive)
    }
}

private struct PisteDInterrupteur: ButtonStyle {
    let allume: Bool
    let petit: Bool

    func makeBody(configuration: Configuration) -> some View { Corps(allume: allume, petit: petit, appuye: configuration.isPressed) }

    private struct Corps: View {
        let allume: Bool
        let petit: Bool
        let appuye: Bool
        @Environment(\.isEnabled) private var actif
        @Environment(\.isFocused) private var focalise
        @Environment(\.etatImpose) private var impose
        @Environment(\.couleursSynseria) private var c
        @State private var survoleALaSouris = false

        /// La piste (deux fois sa hauteur de long : le pouce y court d'une hauteur) et le pouce ; le
        /// jeu du pouce : la piste moins le pouce, de part et d'autre.
        private var hauteur: CGFloat { petit ? Jetons.diametreRond : Jetons.hauteurCase }
        private var pouce: CGFloat { petit ? Jetons.diametrePouce : Jetons.diametreRond }
        private var jeu: CGFloat { (hauteur - pouce) / 2 }

        // Grisé, rien ne réagit (`pointer-events:none`).
        private var presse: Bool { actif && (impose?.presse ?? appuye) }
        private var survole: Bool { actif && (impose?.survole ?? survoleALaSouris) }

        var body: some View {
            let allonge = presse ? Jetons.espace1 : 0
            Capsule()
                .fill(fond.couleur)
                .frame(width: hauteur * 2, height: hauteur)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Jetons.Parametres.pouceInterrupteur.rvb.couleur)
                        .frame(width: pouce + allonge, height: pouce)
                        .padding(.leading, jeu)
                        .offset(x: allume ? hauteur - allonge : 0)
                }
                .anneauDeFocus(Capsule(), visible: actif && (impose?.focus ?? focalise))
                .contentShape(.capsule)
                .onHover { survoleALaSouris = $0 }
                .curseurDeClic(actif)
                .animation(Jetons.courbeSortie.animation(Jetons.dureeNormale), value: allume)
                .animation(Jetons.courbeStandard.animation(Jetons.dureeRapide), value: presse)
        }

        private var fond: Jetons.RVB {
            if allume { return survole ? c.accentSurvol : c.accent }
            return c.piste(survolee: survole)
        }
    }
}

// MARK: - Le segmenté

/// Le segmenté à libellés (`.sg`) : une pilule sur la fenêtre et son filet, des crans de
/// `hauteur-case`, le choisi sur le fond du choix, l'accent en texte. Un seul arrêt de Tab, les
/// flèches déplacent le choix.
public struct SegmenteTexte<Valeur: Hashable>: View {
    public let titre: String
    public let options: [(valeur: Valeur, libelle: String)]
    @Binding public var selection: Valeur

    public init(titre: String, options: [(valeur: Valeur, libelle: String)], selection: Binding<Valeur>) {
        self.titre = titre
        self.options = options
        self._selection = selection
    }
    @Environment(\.couleursSynseria) private var c
    @FocusState private var focalise: Bool

    public var body: some View {
        HStack(spacing: Jetons.espace1) {
            ForEach(options, id: \.valeur) { option in
                let choisi = option.valeur == selection
                Button(option.libelle) { selection = option.valeur }
                    .buttonStyle(CranDeSegment(choisi: choisi, anneau: choisi && focalise))
                    .focusable(false)
                    .accessibilityAddTraits(option.valeur == selection ? .isSelected : [])
            }
        }
        // Le filet entoure l'air du segmenté, il ne le mange pas (`.sg` : bordure, puis padding).
        .padding(Jetons.espace1 + Jetons.epaisseurFilet)
        .background(c.fondFenetre.couleur, in: .capsule)
        .overlay { Capsule().strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet) }
        // L'anneau entoure le cran choisi, que les flèches déplacent (`.sg button:focus-visible`).
        .focusable(interactions: .activate)
        .focused($focalise)
        .focusEffectDisabled()
        .onKeyPress(.leftArrow) { deplacer(-1) }
        .onKeyPress(.rightArrow) { deplacer(1) }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(titre)
    }

    private func deplacer(_ pas: Int) -> KeyPress.Result {
        guard let index = options.firstIndex(where: { $0.valeur == selection }),
              options.indices.contains(index + pas) else { return .handled }
        selection = options[index + pas].valeur
        return .handled
    }
}

private struct CranDeSegment: ButtonStyle {
    let choisi: Bool
    /// Le segmenté a le focus : l'anneau sur le cran choisi.
    let anneau: Bool

    func makeBody(configuration: Configuration) -> some View { Corps(configuration: configuration, choisi: choisi, anneau: anneau) }

    private struct Corps: View {
        let configuration: ButtonStyleConfiguration
        let choisi: Bool
        let anneau: Bool
        @Environment(\.isEnabled) private var actif
        @Environment(\.etatImpose) private var impose
        @Environment(\.couleursSynseria) private var c
        @State private var survoleALaSouris = false

        // Grisé, rien ne réagit (`pointer-events:none`).
        private var survole: Bool { actif && (impose?.survole ?? survoleALaSouris) }
        private var presse: Bool { actif && (impose?.presse ?? configuration.isPressed) }

        var body: some View {
            configuration.label
                .font(Jetons.typoCorps.font)
                .fixedSize()
                .foregroundStyle((choisi ? c.accentTexte : survole || presse ? c.encre : c.encre2).couleur)
                .padding(.horizontal, Jetons.espace3)
                .frame(height: Jetons.hauteurCase)
                .background(fond, in: .capsule)
                .anneauDeFocus(Capsule(), visible: actif && choisi && (impose?.focus ?? anneau))
                .contentShape(.capsule)
                // Le grisé d'un tout, comme `opacity` en CSS : sans groupe, chaque couche pâlit sur l'autre.
                .compositingGroup()
                .opacity(actif ? 1 : Jetons.opaciteDesactive)
                .onHover { survoleALaSouris = $0 }
                .curseurDeClic(actif)
                .animation(Jetons.courbeStandard.animation(Jetons.dureeRapide), value: survole)
        }

        private var fond: Color {
            if choisi || presse { return c.selection.couleur }
            return survole ? c.survol.couleur : .clear
        }
    }
}

// MARK: - Les onglets ronds

/// Un choix parmi quelques icônes (`.tab`) : des ronds de `hauteur-controle`, le choisi plein
/// `accent`. Grisé, un onglet garde sa place et rien n'y paraît choisi. Un seul arrêt de Tab.
public struct SegmentePlat<Valeur: Hashable>: View {
    public struct Option {
        public let valeur: Valeur
        public let titre: String
        public let symbole: String
        public var aide: String?
        public var disponible = true

        public init(valeur: Valeur, titre: String, symbole: String, aide: String? = nil, disponible: Bool = true) {
            (self.valeur, self.titre, self.symbole, self.aide, self.disponible) = (valeur, titre, symbole, aide, disponible)
        }
    }

    public let titre: String
    public let options: [Option]
    @Binding public var selection: Valeur

    public init(titre: String, options: [Option], selection: Binding<Valeur>) {
        self.titre = titre
        self.options = options
        self._selection = selection
    }
    @FocusState private var focalise: Bool

    public var body: some View {
        HStack(spacing: Jetons.espace1) {
            ForEach(options, id: \.valeur) { option in
                let choisie = option.disponible && option.valeur == selection
                Button { selection = option.valeur } label: {
                    Label(option.titre, systemImage: option.symbole)
                }
                .buttonStyle(OngletRond(choisi: choisie, anneau: choisie && focalise))
                .focusable(false)
                .disabled(!option.disponible)
                .help(option.aide ?? option.titre)
                .accessibilityAddTraits(choisie ? .isSelected : [])
            }
        }
        // ←→ déplacent le cran choisi lui-même, qui porte l'anneau ; au clic, le champ en cours
        // garde le clavier.
        .focusable(interactions: .activate)
        .focused($focalise)
        .focusEffectDisabled()
        .onKeyPress(.leftArrow) { deplacer(-1) }
        .onKeyPress(.rightArrow) { deplacer(1) }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(titre)
    }

    private func deplacer(_ pas: Int) -> KeyPress.Result {
        let disponibles = options.filter(\.disponible)
        guard let index = disponibles.firstIndex(where: { $0.valeur == selection }) else { return .ignored }
        let suivant = index + pas
        if disponibles.indices.contains(suivant) { selection = disponibles[suivant].valeur }
        return .handled
    }
}

/// Un onglet rond : plein `accent` choisi, l'encre secondaire sinon, le voile de l'encre au survol et
/// à la pression (`.tab`).
private struct OngletRond: ButtonStyle {
    let choisi: Bool
    /// Les onglets ont le focus : l'anneau sur l'onglet choisi.
    let anneau: Bool

    func makeBody(configuration: Configuration) -> some View { Corps(configuration: configuration, choisi: choisi, anneau: anneau) }

    private struct Corps: View {
        let configuration: ButtonStyleConfiguration
        let choisi: Bool
        let anneau: Bool
        @Environment(\.isEnabled) private var actif
        @Environment(\.etatImpose) private var impose
        @Environment(\.couleursSynseria) private var c
        @State private var survoleALaSouris = false

        // Grisé, rien ne réagit (`pointer-events:none`).
        private var survole: Bool { actif && (impose?.survole ?? survoleALaSouris) }
        private var presse: Bool { actif && (impose?.presse ?? configuration.isPressed) }

        var body: some View {
            configuration.label
                .labelStyle(.iconOnly)
                .font(.system(size: Jetons.tailleIcone))
                .foregroundStyle((choisi ? c.texteSurAccent : survole || presse ? c.encre : c.encre2).couleur)
                .frame(width: Jetons.hauteurControle, height: Jetons.hauteurControle)
                .background(fond.couleur, in: .circle)
                .anneauDeFocus(Circle(), visible: actif && choisi && (impose?.focus ?? anneau))
                .contentShape(.circle)
                .scaleEffect(presse ? Jetons.echellePressee : 1)
                // Le grisé d'un tout, comme `opacity` en CSS : sans groupe, chaque couche pâlit sur l'autre.
                .compositingGroup()
                .opacity(actif ? 1 : Jetons.opaciteDesactive)
                .onHover { survoleALaSouris = $0 }
                .curseurDeClic(actif)
                .animation(Jetons.courbeStandard.animation(Jetons.dureeRapide), value: survole)
        }

        private var fond: Jetons.RVB {
            if choisi { return presse ? c.accentPresse : c.accent }
            if presse { return c.rvb(.voileDePression) }
            return survole ? c.rvb(.voileDeSurvol) : c.encre.voile(0)
        }
    }
}

// MARK: - Case ronde et radio

/// La coche de la trousse (`.ck svg`) : le trait de « M5.5 12.5l4.2 4.2L18.5 7.8 » sur 24, à 3,2.
private struct Coche: Shape {
    func path(in rect: CGRect) -> Path {
        let k = rect.width / 24
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + 5.5 * k, y: rect.minY + 12.5 * k))
        p.addLine(to: CGPoint(x: rect.minX + 9.7 * k, y: rect.minY + 16.7 * k))
        p.addLine(to: CGPoint(x: rect.minX + 18.5 * k, y: rect.minY + 7.8 * k))
        return p.strokedPath(StrokeStyle(lineWidth: 3.2 * k, lineCap: .round, lineJoin: .round))
    }
}

/// La case ronde (`.ck`) et la radio (`.rd`) : un rond de `diametre-rond` au trait d'`encre-3` ;
/// cochée, pleine `accent` (la coche ; la radio, un anneau de la plaque). Le libellé après.
public struct CaseRonde: ToggleStyle {
    /// Une radio : le choix d'un groupe, pas une case qu'on coche.
    public var radio = false

    public init(radio: Bool = false) {
        self.radio = radio
    }

    public func makeBody(configuration: Configuration) -> some View { CorpsDeLaCase(configuration: configuration, radio: radio) }
}

private struct CorpsDeLaCase: View {
    let configuration: ToggleStyleConfiguration
    let radio: Bool
    @Environment(\.labelsVisibility) private var libelles

    var body: some View {
        HStack(spacing: Jetons.espace2) {
            Button { configuration.isOn.toggle() } label: { EmptyView() }
                .buttonStyle(RondACocher(coche: configuration.isOn, radio: radio))
                .focusEffectDisabled()
                .accessibilityRepresentation { Toggle(isOn: configuration.$isOn) { configuration.label } }
            if libelles != .hidden { configuration.label.font(Jetons.typoCorps.font) }
        }
    }
}

extension ToggleStyle where Self == CaseRonde {
    public static var caseRonde: CaseRonde { CaseRonde() }
    public static var radio: CaseRonde { CaseRonde(radio: true) }
}

private struct RondACocher: ButtonStyle {
    let coche: Bool
    let radio: Bool

    func makeBody(configuration: Configuration) -> some View {
        ReactionDeCase(diametre: Jetons.diametreRond, cochee: coche, appuye: configuration.isPressed) { survole, presse in
            Dessin(coche: coche, radio: radio, survole: survole, presse: presse)
        }
    }

    private struct Dessin: View {
        let coche: Bool
        let radio: Bool
        let survole: Bool
        let presse: Bool
        @Environment(\.couleursSynseria) private var c
        /// Le trait du rond (`.ck` : 2 px).
        private static let trait: CGFloat = 2

        var body: some View {
            let plein = presse ? c.accentPresse : survole ? c.accentSurvol : c.accent
            let bord = coche ? plein : survole || presse ? c.encre2 : c.encre3
            ZStack {
                // Non cochée, rien dedans : le halo, dessous, en fait un seul disque.
                Circle().fill((coche ? plein : c.encre.voile(0)).couleur)
                if coche && radio {
                    Circle().inset(by: Self.trait).strokeBorder(c.plaque.couleur, lineWidth: Jetons.espace1)
                }
                Circle().strokeBorder(bord.couleur, lineWidth: Self.trait)
                if coche && !radio {
                    Coche().fill(c.texteSurAccent.couleur).frame(width: Jetons.diametreMini, height: Jetons.diametreMini)
                }
            }
            .frame(width: Jetons.diametreRond, height: Jetons.diametreRond)
        }
    }
}

/// Ce qui réagit dans toute case ronde qui se coche (`.ck`, `.rd`, `.rond`), une seule règle : comme
/// un bouton-icône, la main, au survol puis sous le doigt un halo de `hauteur-controle`, le voile de
/// l'encre (`survol` se perdrait dans une rangée survolée), qui ne pousse rien ; la pression la
/// rétrécit ; l'anneau du focus. Toute la case prend le clic, son centre compris.
private struct ReactionDeCase<Dessin: View>: View {
    let diametre: CGFloat
    let cochee: Bool
    let appuye: Bool
    @ViewBuilder let dessin: (_ survole: Bool, _ presse: Bool) -> Dessin
    @Environment(\.isEnabled) private var actif
    @Environment(\.isFocused) private var focalise
    @Environment(\.etatImpose) private var impose
    @Environment(\.couleursSynseria) private var c
    @State private var survoleALaSouris = false

    /// Le halo déborde de la case d'autant tout autour : `hauteur-controle` autour de `diametre-rond`.
    private static var debord: CGFloat { (Jetons.hauteurControle - Jetons.diametreRond) / 2 }

    private var presse: Bool { actif && (impose?.presse ?? appuye) }
    private var survole: Bool { actif && (impose?.survole ?? survoleALaSouris) }

    var body: some View {
        let halo = diametre + 2 * Self.debord
        dessin(survole, presse)
            .background {
                if survole || presse {
                    Circle().fill(c.rvb(presse ? .voileDePression : .voileDeSurvol).couleur).frame(width: halo, height: halo)
                }
            }
            .anneauDeFocus(Circle(), visible: actif && (impose?.focus ?? focalise))
            .contentShape(.circle)
            .scaleEffect(presse ? Jetons.echellePressee : 1)
            .compositingGroup()
            .opacity(actif ? 1 : Jetons.opaciteDesactive)
            .onHover { survoleALaSouris = $0 }
            .curseurDeClic(actif)
            .animation(Jetons.courbeStandard.animation(Jetons.dureeRapide), value: [cochee, survole, presse])
    }
}

// MARK: - La case d'une tâche

/// La case ronde d'une tâche (`.rond`), le dessin seul : un rond de `diametre-rond` (`diametre-mini`
/// en mini) au trait d'`encre-3`, pointillé pour ce qui ne se compte pas ; cochée, pleine `accent` et
/// la coche. Inerte (un pas fait, un calage) : ce qui se coche passe par `.caseDeTache`.
public struct CaseDeTache: View {
    public let cochee: Bool
    public var pointillee = false
    public var mini = false
    fileprivate var survolee = false
    fileprivate var pressee = false
    @Environment(\.couleursSynseria) private var c

    public init(cochee: Bool, pointillee: Bool = false, mini: Bool = false) {
        self.cochee = cochee
        self.pointillee = pointillee
        self.mini = mini
    }

    /// Le trait du rond (`.rond` : 2 px) ; le pointillé, son pas (le masque de `.rond.pt`).
    public static let trait: CGFloat = 2
    public static let pas: [CGFloat] = [2, 4]
    public var diametre: CGFloat { mini ? Jetons.diametreMini : Jetons.diametreRond }

    public var body: some View {
        let reagit = survolee || pressee
        let plein = pressee ? c.accentPresse : survolee ? c.accentSurvol : c.accent
        let bord = cochee ? plein : reagit ? c.encre2 : c.encre3
        ZStack {
            // Non cochée, rien dedans : le halo du bouton, dessous, en fait un seul disque.
            Circle().fill((cochee ? plein : c.encre.voile(0)).couleur)
            if cochee {
                // La coche de `.rond.ok svg` : `diametre-mini`, le tiers de moins en mini (8 sur 12).
                let coche = mini ? Jetons.diametreMini * 2 / 3 : Jetons.diametreMini
                Coche().fill(c.texteSurAccent.couleur).frame(width: coche, height: coche)
            } else {
                Circle().strokeBorder(bord.couleur, style: StrokeStyle(lineWidth: Self.trait, dash: pointillee ? Self.pas : []))
            }
        }
        .frame(width: diametre, height: diametre)
    }
}

/// La case d'une tâche qui se coche : elle réagit comme toute case ronde (`ReactionDeCase`).
/// L'étiquette du bouton n'est pas dessinée : `Button(action:) { EmptyView() }`.
public struct BoutonDeCase: ButtonStyle {
    public let cochee: Bool
    public var pointillee = false
    public var mini = false

    public init(cochee: Bool, pointillee: Bool = false, mini: Bool = false) {
        self.cochee = cochee
        self.pointillee = pointillee
        self.mini = mini
    }

    public func makeBody(configuration: Configuration) -> some View {
        let dessin = CaseDeTache(cochee: cochee, pointillee: pointillee, mini: mini)
        return ReactionDeCase(diametre: dessin.diametre, cochee: cochee, appuye: configuration.isPressed) { survole, presse in
            var reagit = dessin
            reagit.survolee = survole
            reagit.pressee = presse
            return reagit
        }
    }
}

extension ButtonStyle where Self == BoutonDeCase {
    public static func caseDeTache(cochee: Bool, pointillee: Bool = false, mini: Bool = false) -> BoutonDeCase {
        BoutonDeCase(cochee: cochee, pointillee: pointillee, mini: mini)
    }
}

// MARK: - Les puces

/// Des puces qui passent à la ligne quand la rangée est pleine (les filtres d'une palette, un
/// tiroir). Le calcul des places est pur (`placer`) : la mise en page n'en est que l'application.
public struct RangeeDePuces: Layout {
    public var espacement: CGFloat = Jetons.espace2
    public var interligne: CGFloat = Jetons.espace2

    public init(espacement: CGFloat = Jetons.espace2, interligne: CGFloat = Jetons.espace2) {
        self.espacement = espacement
        self.interligne = interligne
    }

    public struct Placement: Equatable {
        public var origines: [CGPoint]
        public var taille: CGSize

        public init(origines: [CGPoint], taille: CGSize) {
            self.origines = origines
            self.taille = taille
        }
    }

    /// Chaque puce à la suite de la précédente ; celle qui dépasserait `largeur` ouvre une ligne (une
    /// puce plus large que la ligne y tient seule). Les puces d'une ligne sont centrées sur sa hauteur.
    public static func placer(_ tailles: [CGSize], largeur: CGFloat, espacement: CGFloat, interligne: CGFloat) -> Placement {
        var lignes: [[Int]] = []
        var x: CGFloat = 0
        for (i, taille) in tailles.enumerated() {
            if lignes.isEmpty || (x > 0 && x + taille.width > largeur + 0.5) {
                lignes.append([])
                x = 0
            }
            lignes[lignes.count - 1].append(i)
            x += taille.width + espacement
        }
        var origines = Array(repeating: CGPoint.zero, count: tailles.count)
        var y: CGFloat = 0
        var largeurUtile: CGFloat = 0
        for ligne in lignes {
            let hauteur = ligne.map { tailles[$0].height }.max() ?? 0
            var x: CGFloat = 0
            for i in ligne {
                origines[i] = CGPoint(x: x, y: y + (hauteur - tailles[i].height) / 2)
                x += tailles[i].width + espacement
            }
            largeurUtile = max(largeurUtile, x - espacement)
            y += hauteur + interligne
        }
        return Placement(origines: origines, taille: CGSize(width: largeurUtile, height: lignes.isEmpty ? 0 : y - interligne))
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let tailles = subviews.map { $0.sizeThatFits(.unspecified) }
        return Self.placer(tailles, largeur: proposal.width ?? .infinity, espacement: espacement, interligne: interligne).taille
    }

    public func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let tailles = subviews.map { $0.sizeThatFits(.unspecified) }
        let placement = Self.placer(tailles, largeur: bounds.width, espacement: espacement, interligne: interligne)
        for (vue, (origine, taille)) in zip(subviews, zip(placement.origines, tailles)) {
            vue.place(at: CGPoint(x: bounds.minX + origine.x, y: bounds.minY + origine.y), proposal: ProposedViewSize(taille))
        }
    }
}

/// Une puce (`.puce`) : un filtre, une capsule discrète en méta. Choisie, le fond du choix et une
/// coche, sans liseré ; désignée au clavier, le seul liseré de la rangée — dans la capsule, pas
/// autour, la rangée garde son air.
public struct Puce: View {
    public let libelle: String
    public var symbole: String?
    public var choisie = false
    /// Celle que les flèches désignent : Espace la prend.
    public var auClavier = false

    public init(libelle: String, symbole: String? = nil, choisie: Bool = false, auClavier: Bool = false) {
        self.libelle = libelle
        self.symbole = symbole
        self.choisie = choisie
        self.auClavier = auClavier
    }
    @Environment(\.couleursSynseria) private var c

    public var body: some View {
        HStack(spacing: Jetons.espace1) {
            if choisie { Image(systemName: "checkmark").imageScale(.small) }
            if let symbole { Image(systemName: symbole).imageScale(.small) }
            Text(libelle).lineLimit(1)
        }
        .font(Jetons.typoMeta.font)
        .foregroundStyle((choisie ? c.encre : c.encre2).couleur)
        .padding(.horizontal, Jetons.espace2)
        .padding(.vertical, Jetons.espace1)
        .background((choisie ? c.selection : c.survol).couleur, in: .capsule)
        .overlay { if auClavier { Capsule().strokeBorder(c.accent.couleur, lineWidth: Jetons.epaisseurFocus) } }
        .contentShape(.capsule)
        .curseurDeClic(true)
    }
}

// MARK: - La barre des onglets de réglages

/// Les onglets d'une fenêtre de réglages (`.stab`) : l'icône et le nom en micro dessous, sans cadre,
/// le choisi sur le fond du choix et l'accent en texte. Pas de titre de page : les onglets disent où
/// l'on est. Ceux de l'app d'abord, puis un filet, puis les communs (`communs`) ; un seul arrêt de
/// Tab, ←→ passent d'un onglet au suivant, filet compris.
///
/// Dans la fenêtre commune, cette barre est dans l'en-tête (`EnTeteDesReglages`, `.sw .bar`) : la
/// fenêtre en `fullSizeContentView` + `titlebarAppearsTransparent`, titre caché, l'en-tête ancré au
/// sommet du contenu, d'un bord à l'autre, en ignorant la safe-area du titre — jamais poussé sous
/// la rangée des feux. Règle complète : « La fenêtre Réglages (.sw) monte sous la barre de titre »,
/// section 7 de la référence.
public struct BarreDesOnglets<Valeur: Hashable>: View {
    public struct Onglet {
        public let valeur: Valeur
        public let libelle: String
        public let symbole: String

        public init(valeur: Valeur, libelle: String, symbole: String) {
            self.valeur = valeur
            self.libelle = libelle
            self.symbole = symbole
        }
    }

    public let onglets: [Onglet]
    public let communs: [Onglet]
    @Binding public var selection: Valeur

    public init(onglets: [Onglet], communs: [Onglet] = [], selection: Binding<Valeur>) {
        self.onglets = onglets
        self.communs = communs
        self._selection = selection
    }
    @Environment(\.couleursSynseria) private var c

    private var tous: [Onglet] { onglets + communs }

    public var body: some View {
        HStack(spacing: Jetons.espace1) {
            ForEach(onglets, id: \.valeur) { onglet in
                BoutonDOnglet(onglet: onglet, choisi: onglet.valeur == selection) { selection = onglet.valeur }
            }
            if !onglets.isEmpty, !communs.isEmpty {
                // `.stabs-filet` : le filet entre les deux groupes, à `espace-2` de chacun et des bords.
                Rectangle().fill(c.filet.couleur)
                    .frame(width: Jetons.epaisseurFilet)
                    .padding(.vertical, Jetons.espace2)
                    .padding(.horizontal, Jetons.espace2 - Jetons.espace1)
                    .accessibilityHidden(true)
            }
            ForEach(communs, id: \.valeur) { onglet in
                BoutonDOnglet(onglet: onglet, choisi: onglet.valeur == selection) { selection = onglet.valeur }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        // `.sw .bar` : le haut à hauteur des boutons de la fenêtre.
        .padding(.top, Jetons.espace3)
        .padding(.bottom, Jetons.espace2)
        .frame(maxWidth: .infinity)
        .focusable(interactions: .activate)
        .focusEffectDisabled()
        .onKeyPress(.leftArrow) { deplacer(-1) }
        .onKeyPress(.rightArrow) { deplacer(1) }
    }

    private func deplacer(_ pas: Int) -> KeyPress.Result {
        let tous = tous
        guard let rang = tous.firstIndex(where: { $0.valeur == selection }), tous.indices.contains(rang + pas) else { return .handled }
        selection = tous[rang + pas].valeur
        return .handled
    }

    private struct BoutonDOnglet: View {
        let onglet: Onglet
        let choisi: Bool
        let choisir: () -> Void
        @State private var survole = false
        @Environment(\.couleursSynseria) private var c

        var body: some View {
            Button(action: choisir) {
                // La moitié de `largeur-nav`, l'icône sur `espace-5`, le nom en micro.
                VStack(spacing: Jetons.espace1) {
                    Image(systemName: onglet.symbole)
                        .font(.system(size: Jetons.espace5 * 3 / 4))
                        .frame(height: Jetons.espace5)
                    Text(onglet.libelle).font(Jetons.typoMicro.font).lineLimit(1).fixedSize()
                }
                .foregroundStyle((choisi ? c.accentTexte : c.encre2).couleur)
                .padding([.horizontal, .top], Jetons.espace1)
                .padding(.bottom, Jetons.espace2)
                .frame(width: Jetons.largeurNav / 2)
                .background((choisi ? c.selection : survole ? c.survol : c.survol.voile(0)).couleur,
                            in: .rect(cornerRadius: Jetons.rayon2, style: .circular))
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .focusable(false)
            .onHover { survole = $0 }
            .curseurDeClic(true)
            .accessibilityLabel(onglet.libelle)
            .accessibilityAddTraits(choisi ? [.isButton, .isSelected] : .isButton)
        }
    }
}
