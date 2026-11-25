// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
import SwiftUI

// Le verre : Liquid Glass (`NSGlassEffectView`) `.regular`, une teinte à nous juste dessous, la même
// focus ou pas. Une fenêtre n'en pose qu'un, derrière tout son contenu (`VerreDeLaFenetre`) ; une
// surface flottante a le sien, à son arrondi (`VerreTeinte`). `cacheDisplay` ne peint pas le verre :
// il se juge en vrai.

/// Ce que porte un verre, et l'opacité de sa teinte. **La même, focus ou pas** : le fond reste du
/// verre, jamais plus opaque sans le clavier. Ce qui prend le clavier (une fenêtre, et les flottants
/// qu'on tape : palette, overlay, panneau, bloc-notes) : le verre franc de la fenêtre
/// (`verre-opacite-focus`), le bureau flouté se voit, le texte long reste sur ses plaques. Ce qui ne
/// prend jamais le clavier (une carte de réunion) : `verre-opacite-flottant`. « Réduire la
/// transparence » et « Augmenter le contraste » refusent le verre : la page pleine.
public enum UsageDuVerre: Hashable, Sendable {
    case clavier, inerte

    public func opacite(verreRefuse: Bool = false) -> Double {
        if verreRefuse { return 1 }
        switch self {
        case .clavier: return Jetons.verreOpaciteFocus
        case .inerte: return Jetons.verreOpaciteFlottant
        }
    }

    /// La teinte sous le verre : la page du thème à l'opacité de l'usage.
    public func teinte(_ c: Jetons.Couleurs, verreRefuse: Bool = false) -> Jetons.RVB {
        c.fondFenetre.voile(opacite(verreRefuse: verreRefuse))
    }

    /// Les options du Mac qui refusent le verre — la seule règle (`LisibiliteDuSysteme` la lit).
    public static func refuse(transparenceReduite: Bool, contraste: ColorSchemeContrast) -> Bool {
        transparenceReduite || contraste == .increased
    }
}

#if os(macOS)
/// Ce que l'utilisateur a demandé au Mac pour lire l'écran, relu à chaque changement : le verre
/// refusé, fenêtres et surfaces flottantes prennent leurs fonds pleins, sans exception — un texte
/// posé sur le verre n'a aucun fond à lui. Hors d'une vue (une fenêtre AppKit qui pose son verre),
/// l'environnement SwiftUI n'est pas là : c'est la source commune.
@Observable @MainActor
public final class LisibiliteDuSysteme {
    public static let shared = LisibiliteDuSysteme()

    public private(set) var verreRefuse = false
    @ObservationIgnored private var observateur: NSObjectProtocol?

    private init() {
        relire()
        // La boucle principale : la fermeture s'exécute sur le main actor. Le singleton vit
        // autant que l'app, l'observateur aussi.
        observateur = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification, object: nil, queue: .main
        ) { _ in
            MainActor.assumeIsolated { LisibiliteDuSysteme.shared.relire() }
        }
    }

    private func relire() {
        let espace = NSWorkspace.shared
        poser(reduireLaTransparence: espace.accessibilityDisplayShouldReduceTransparency,
              augmenterLeContraste: espace.accessibilityDisplayShouldIncreaseContrast)
    }

    /// Le seul point qui écrit `verreRefuse` : les options du Mac, ou celles d'un test.
    public func poser(reduireLaTransparence: Bool, augmenterLeContraste: Bool) {
        let refuse = UsageDuVerre.refuse(transparenceReduite: reduireLaTransparence,
                                         contraste: augmenterLeContraste ? .increased : .standard)
        if refuse != verreRefuse { verreRefuse = refuse }
    }
}

/// Le verre d'une surface flottante (overlay, palette, panneau, carte de réunion), à `rayon` près,
/// posé en fond, sous le contenu : la forme est celle du verre lui-même (un `clipShape` SwiftUI ne
/// la suit pas), sa teinte dessous (`VerreDeLaFenetre.VerreFlottant`). Teinte : celle de l'usage,
/// sur les couleurs de l'environnement, ou une couleur que l'app calcule (dynamique, clair et sombre
/// au dessin). Verre refusé (`LisibiliteDuSysteme`) : la page pleine et son filet.
public struct VerreTeinte: View {
    public var rayon: CGFloat
    private let teinte: Teinte

    private enum Teinte {
        case usage(UsageDuVerre)
        case couleur(NSColor)
    }

    public init(rayon: CGFloat = 0, usage: UsageDuVerre = .clavier) {
        self.rayon = rayon
        teinte = .usage(usage)
    }

    public init(rayon: CGFloat = 0, teinte couleur: NSColor) {
        self.rayon = rayon
        teinte = .couleur(couleur)
    }

    @Environment(\.couleursSynseria) private var c

    public var body: some View {
        if LisibiliteDuSysteme.shared.verreRefuse {
            let forme = RoundedRectangle(cornerRadius: rayon)
            forme.fill(c.fondFenetre.couleur)
                .overlay { forme.strokeBorder(c.filet.couleur.opacity(Jetons.opaciteFilet), lineWidth: Jetons.epaisseurFilet) }
                .allowsHitTesting(false)
        } else {
            Hote(rayon: rayon, teinte: couleur)
        }
    }

    private var couleur: NSColor {
        switch teinte {
        case .usage(let usage): NSColor(usage.teinte(c).couleur)
        case .couleur(let couleur): couleur
        }
    }

    private struct Hote: NSViewRepresentable {
        let rayon: CGFloat
        let teinte: NSColor

        func makeNSView(context _: Context) -> VerreDeLaFenetre.VerreFlottant {
            VerreDeLaFenetre.VerreFlottant(rayon: rayon, teinte: teinte)
        }

        func updateNSView(_ vue: VerreDeLaFenetre.VerreFlottant, context _: Context) { vue.accorder(rayon: rayon, teinte: teinte) }
    }
}

/// Le verre unique d'une fenêtre : frère de son contenu, juste dessous, d'un bord à l'autre, barre de
/// titre comprise, sa teinte juste sous lui. Posé et retiré par la fenêtre elle-même, jamais par une
/// colonne : il ne bouge ni ne se refait quand une barre latérale s'ouvre ou se ferme. Verre refusé,
/// l'app le retire et peint la page pleine (sans filet : une fenêtre a son bord).
@MainActor
public enum VerreDeLaFenetre {
    public static let identifiant = NSUserInterfaceItemIdentifier("Synseria.VerreDeLaFenetre")
    public static let identifiantDeLaTeinte = NSUserInterfaceItemIdentifier("Synseria.TeinteSousLeVerre")

    /// Le verre posé dans `fenetre`, s'il y est.
    public static func verre(dans fenetre: NSWindow) -> NSView? {
        fenetre.contentView?.superview?.subviews.first { $0.identifier == identifiant }
    }

    /// La teinte posée sous le verre de `fenetre`, s'il y est.
    public static func teinte(dans fenetre: NSWindow) -> NSView? {
        fenetre.contentView?.superview?.subviews.first { $0.identifier == identifiantDeLaTeinte }
    }

    /// Frère du contenu, juste dessous, dans le cadre de la fenêtre : sous-vue de l'hôte SwiftUI, il
    /// passait devant ce que l'hôte dessine dans sa propre couche (la fenêtre entière floutée). À
    /// rappeler quand la fenêtre change de contenu ou de thème : il se remet en place et prend la teinte.
    public static func poser(dans fenetre: NSWindow, teinte couleur: NSColor) {
        guard let contenu = fenetre.contentView, let cadre = contenu.superview else { return }
        if let verre = verre(dans: fenetre) {
            (verre as? NSGlassEffectView).map { accorder($0) }
            // Le cadre qui range ses vues après coup (`NSWindow(contentViewController:)`) met
            // celles qu'il ne connaît pas au-dessus de tout : le verre revient juste sous le
            // contenu, sa teinte sous lui, au passage suivant. Les deux se vérifient : la teinte
            // seule remontée couvrirait le contenu.
            let sousLeVerre = teinte(dans: fenetre)
            let vues = cadre.subviews
            let enPlace = { (vue: NSView?, ecart: Int) in
                vue == nil || vues.firstIndex(of: contenu).map { $0 >= ecart && vues[$0 - ecart] === vue } == true
            }
            if vues.contains(contenu), !enPlace(verre, 1) || !enPlace(sousLeVerre, 2) {
                cadre.addSubview(verre, positioned: .below, relativeTo: contenu)
                sousLeVerre.map { cadre.addSubview($0, positioned: .below, relativeTo: verre) }
            }
            (sousLeVerre as? TeinteSousLeVerre)?.couleur = couleur
            return
        }
        let verre = vue(rayon: 0)
        verre.identifier = identifiant
        verre.frame = cadre.bounds
        verre.autoresizingMask = [.width, .height]
        cadre.addSubview(verre, positioned: .below, relativeTo: contenu)
        let sousLeVerre = TeinteSousLeVerre(frame: cadre.bounds)
        sousLeVerre.identifier = identifiantDeLaTeinte
        sousLeVerre.autoresizingMask = [.width, .height]
        sousLeVerre.couleur = couleur
        cadre.addSubview(sousLeVerre, positioned: .below, relativeTo: verre)
    }

    public static func retirer(de fenetre: NSWindow) {
        verre(dans: fenetre)?.removeFromSuperview()
        teinte(dans: fenetre)?.removeFromSuperview()
    }

    /// `.regular`, sans clic. Jamais interactif (`effectIsInteractive`, macOS 27) : le verre est sous
    /// les contrôles et ne reçoit aucun événement, le reflet n'y répondrait pas.
    public static func vue(rayon: CGFloat) -> NSGlassEffectView {
        let vue = VerreSansClic()
        accorder(vue)
        vue.cornerRadius = rayon
        return vue
    }

    /// Les réglages publics d'un verre, la seule source : celui de la fenêtre, d'une surface
    /// flottante, et celui que le système donne à une barre latérale, dont le bord se fond ainsi dans
    /// le reste. `.regular` : `.clear` sans teinte laisse lire net ce qui est derrière et dédouble le
    /// contenu au bord. **Jamais de `tintColor`** : le système l'efface quand la fenêtre n'est pas clé
    /// (il la remplace par ce qui est derrière à peine éclairci) — la fenêtre changeait de densité
    /// avec le focus ; la teinte est une couche à nous (`TeinteSousLeVerre`). Écrits seulement s'ils
    /// changent : une barre les reçoit à chaque image d'une animation.
    public static func accorder(_ verre: NSGlassEffectView) {
        if verre.style != .regular { verre.style = .regular }
        if verre.tintColor != nil { verre.tintColor = nil }
    }

    /// Le verre ne prend aucun clic : ce qui est posé dessus les reçoit, la fenêtre se tire par son fond.
    private final class VerreSansClic: NSGlassEffectView {
        override func hitTest(_: NSPoint) -> NSView? { nil }
    }

    /// Le verre d'une surface flottante et sa teinte juste dessous — l'ordre du verre de la fenêtre,
    /// à `rayon` près. Ne prend aucun clic.
    public final class VerreFlottant: NSView {
        public let verre: NSGlassEffectView
        public let teinte: TeinteSousLeVerre

        public init(rayon: CGFloat, teinte couleur: NSColor) {
            verre = VerreDeLaFenetre.vue(rayon: rayon)
            teinte = TeinteSousLeVerre(frame: .zero)
            super.init(frame: .zero)
            for vue in [teinte, verre] as [NSView] {
                vue.autoresizingMask = [.width, .height]
                addSubview(vue)
            }
            accorder(rayon: rayon, teinte: couleur)
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) { nil }

        public override func hitTest(_: NSPoint) -> NSView? { nil }

        public func accorder(rayon: CGFloat, teinte couleur: NSColor) {
            if verre.cornerRadius != rayon { verre.cornerRadius = rayon }
            VerreDeLaFenetre.accorder(verre)
            teinte.rayon = rayon
            teinte.couleur = couleur
        }
    }

    /// La teinte sous le verre, toujours montrée : le verre la floute comme ce qui est derrière la
    /// fenêtre ; au-dessus, elle couvrirait son reflet, qui reste au système. Une couleur dynamique
    /// (clair et sombre au dessin) se compare par identité : la même instance ne redessine rien.
    public final class TeinteSousLeVerre: NSView {
        public var couleur: NSColor? { didSet { if couleur !== oldValue { needsDisplay = true } } }
        /// L'arrondi du verre qu'elle double (une surface flottante) ; 0 pour une fenêtre.
        public var rayon: CGFloat = 0 { didSet { if rayon != oldValue { needsDisplay = true } } }

        public override func hitTest(_: NSPoint) -> NSView? { nil }

        public override func draw(_: NSRect) {
            guard let couleur else { return }
            couleur.setFill()
            NSBezierPath(roundedRect: bounds, xRadius: rayon, yRadius: rayon).fill()
        }
    }
}
#endif
