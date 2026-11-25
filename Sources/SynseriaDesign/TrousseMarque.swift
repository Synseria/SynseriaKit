// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
import SwiftUI

// La marque et le verre : le signe Synseria, le gabarit d'À propos, le verre et sa teinte dessous.

// MARK: - Le signe et l'À propos

/// Le signe Synseria : l'emblème de l'app et le mot « synseria » à côté (« syn » en encre,
/// « seria » en encre secondaire), jamais dans le rond. L'emblème vient de `marque/`, posé dans
/// les ressources de l'app ; Outfit n'est pas embarquée : le mot prend la police arrondie du système.
public struct SigneSynseria: View {
    public let embleme: Image
    public var hauteur: CGFloat = Jetons.espace5

    public init(embleme: Image, hauteur: CGFloat = Jetons.espace5) {
        self.embleme = embleme
        self.hauteur = hauteur
    }
    @Environment(\.couleursSynseria) private var c

    public var body: some View {
        HStack(spacing: hauteur * 0.3) {
            embleme.resizable().scaledToFit().frame(width: hauteur, height: hauteur)
            Self.mot(taille: hauteur * 0.56, couleurs: c)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Synseria")
    }

    /// Le mot seul, la seule façon de l'écrire.
    public static func mot(taille: CGFloat, couleurs c: Jetons.Couleurs) -> Text {
        let syn = Text("syn").foregroundStyle(c.encre.couleur)
        let seria = Text("seria").foregroundStyle(c.encre2.couleur)
        return Text("\(syn)\(seria)").font(.system(size: taille, weight: .semibold, design: .rounded))
    }
}

/// « À propos » (`.apropos`), une colonne centrée de `largeur-apropos` : l'icône de l'app (celle
/// du Dock ; l'emblème est la marque de l'éditeur), son nom, « by » et le signe, puis sa ligne — la
/// version entière, ou l'état de la mise à jour et son geste.
public struct GabaritAPropos<Ligne: View>: View {
    public let icone: Image
    public let nom: String
    public let embleme: Image
    @ViewBuilder public var ligne: Ligne

    public init(icone: Image, nom: String, embleme: Image, @ViewBuilder ligne: () -> Ligne) {
        self.icone = icone
        self.nom = nom
        self.embleme = embleme
        self.ligne = ligne()
    }
    @Environment(\.couleursSynseria) private var c

    public var body: some View {
        VStack(spacing: Jetons.espace5) {
            VStack(spacing: Jetons.espace2) {
                icone.resizable().scaledToFit()
                    .frame(width: Jetons.espace7 * 2, height: Jetons.espace7 * 2)
                    .accessibilityHidden(true)
                Text(nom).font(Jetons.typoTitrePage.font).foregroundStyle(c.encre.couleur)
                HStack(alignment: .center, spacing: Jetons.espace2) {
                    Text("by").font(Jetons.typoMeta.font).foregroundStyle(c.encre2.couleur)
                    SigneSynseria(embleme: embleme)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("by Synseria")
            }
            ligne
        }
        .padding(Jetons.espace6)
        .frame(width: Jetons.largeurApropos)
    }
}

/// La ligne d'un À propos sans mise à jour : la version entière, en méta, sélectionnable.
public struct LigneDeVersion: View {
    public let texte: String

    public init(texte: String) {
        self.texte = texte
    }
    @Environment(\.couleursSynseria) private var c

    public var body: some View {
        Text(texte)
            .font(Jetons.typoMeta.font)
            .foregroundStyle(c.encre2.couleur)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
    }
}

// MARK: - Le verre

/// Ce que porte un verre, et l'opacité de sa teinte — la seule mesure. **La même, focus ou pas** :
/// le fond reste du verre, jamais plus opaque sans le clavier. Ce qui prend le clavier (une
/// fenêtre, et les flottants qu'on tape : palette, overlay, panneau, bloc-notes) : le verre franc
/// de la fenêtre (`verre-opacite-focus`), le bureau flouté se voit, le texte long reste sur ses
/// plaques. Ce qui ne prend jamais le clavier (une carte de réunion) : `verre-opacite-flottant`.
/// « Réduire la transparence » et « Augmenter le contraste » refusent le verre : la page pleine.
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

    /// Les options du Mac qui refusent le verre.
    public static func refuse(transparenceReduite: Bool, contraste: ColorSchemeContrast) -> Bool {
        transparenceReduite || contraste == .increased
    }
}

#if os(macOS)
/// Le verre d'une surface flottante (Liquid Glass, `.regular`) et sa teinte **dessous**, à `rayon`
/// près, posé en fond, sous le contenu. Le système efface la `tintColor` d'un verre hors fenêtre
/// clé (il la remplace par ce qui est derrière à peine éclairci) : aucun verre n'en a, la teinte
/// est une couche à nous, que le verre floute comme le reste, toujours montrée ; au-dessus, elle
/// couvrirait son reflet, qui reste au système. Refusé : la page pleine et son filet. Le verre
/// d'une fenêtre n'est pas celui-ci (`VueDuVerreTeinte`).
public struct VerreTeinte: View {
    public var rayon: CGFloat = 0
    public var usage: UsageDuVerre = .clavier

    public init(rayon: CGFloat = 0, usage: UsageDuVerre = .clavier) {
        self.rayon = rayon
        self.usage = usage
    }
    @Environment(\.couleursSynseria) private var c
    @Environment(\.accessibilityReduceTransparency) private var transparenceReduite
    @Environment(\.colorSchemeContrast) private var contraste

    public var body: some View {
        if UsageDuVerre.refuse(transparenceReduite: transparenceReduite, contraste: contraste) {
            let forme = RoundedRectangle(cornerRadius: rayon, style: .circular)
            forme.fill(c.fondFenetre.couleur)
                .overlay { forme.strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet) }
                .allowsHitTesting(false)
        } else {
            Hote(rayon: rayon, teinte: usage.teinte(c))
        }
    }

    private struct Hote: NSViewRepresentable {
        let rayon: CGFloat
        let teinte: Jetons.RVB

        func makeNSView(context _: Context) -> VueDuVerreTeinte { VueDuVerreTeinte(rayon: rayon, teinte: teinte) }

        func updateNSView(_ vue: VueDuVerreTeinte, context _: Context) { vue.accorder(rayon: rayon, teinte: teinte) }
    }
}

/// Le verre d'une fenêtre (teinte `UsageDuVerre.clavier`), posé par l'app sous l'hôte SwiftUI : frère
/// du contenu, juste dessous, dans le cadre de la fenêtre (sous-vue de l'hôte, il passerait devant
/// ce qu'il dessine). La teinte, puis le verre ; ne prend aucun clic. Il ne lit pas les options du
/// Mac : verre refusé, l'app le retire et peint la page pleine (sans filet : une fenêtre a son bord).
public final class VueDuVerreTeinte: NSView {
    public let verre: NSGlassEffectView = VerreSansClic()
    public let teinte = TeinteSousLeVerre()

    public init(rayon: CGFloat = 0, teinte couleur: Jetons.RVB) {
        super.init(frame: .zero)
        for vue in [teinte, verre] as [NSView] {
            vue.frame = bounds
            vue.autoresizingMask = [.width, .height]
            addSubview(vue)
        }
        accorder(rayon: rayon, teinte: couleur)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { nil }

    public override func hitTest(_: NSPoint) -> NSView? { nil }

    /// Écrit seulement ce qui change : une barre les reçoit à chaque image d'une animation.
    public func accorder(rayon: CGFloat, teinte couleur: Jetons.RVB) {
        if verre.cornerRadius != rayon { verre.cornerRadius = rayon }
        Self.accorder(verre)
        teinte.rayon = rayon
        teinte.couleur = couleur
    }

    /// Les réglages publics d'un verre, la seule source — aussi pour celui que le système donne à
    /// une barre latérale, dont le bord se fond ainsi dans le reste : `.regular` (`.clear` laisse
    /// lire net ce qui est derrière), jamais de `tintColor`.
    public static func accorder(_ verre: NSGlassEffectView) {
        if verre.style != .regular { verre.style = .regular }
        if verre.tintColor != nil { verre.tintColor = nil }
    }

    private final class VerreSansClic: NSGlassEffectView {
        override func hitTest(_: NSPoint) -> NSView? { nil }
    }

    /// La teinte, à l'arrondi du verre qu'elle double.
    public final class TeinteSousLeVerre: NSView {
        public var couleur: Jetons.RVB? { didSet { if couleur != oldValue { needsDisplay = true } } }
        public var rayon: CGFloat = 0 { didSet { if rayon != oldValue { needsDisplay = true } } }

        public override func hitTest(_: NSPoint) -> NSView? { nil }

        public override func draw(_: NSRect) {
            guard let couleur else { return }
            NSColor(couleur.couleur).setFill()
            NSBezierPath(roundedRect: bounds, xRadius: rayon, yRadius: rayon).fill()
        }
    }
}
#endif
