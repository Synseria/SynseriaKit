// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
import SwiftUI

// La trousse (`K` de reference/gabarit.html) en SwiftUI, ses fondations : les couleurs posées dans
// l'environnement, les états imposés aux captures, le curseur de clic et l'anneau de focus communs,
// la typo posée avec son interligne et le coin dans un coin.
// Les contrôles ne lisent que `Jetons` et ces couleurs ; libellés et actions viennent de l'appelant.

extension EnvironmentValues {
    /// Les couleurs du thème courant. Chaque racine de l'app les pose (`themeSynseria`,
    /// `couleursSynseria`) : une racine oubliée se dessine au thème de la marque, en clair, quelle
    /// que soit l'apparence (la trousse ne connaît pas le thème de l'app).
    @Entry public var couleursSynseria: Jetons.Couleurs = Jetons.couleursParDefaut
    /// Le survol, la pression et le focus imposés à un contrôle (une capture n'a ni souris ni
    /// clavier) ; nil : la souris et le clavier.
    @Entry public var etatImpose: EtatImpose?
    /// Le texte imposé aux champs à suggestions : leur liste ouverte, filtrée par lui (une capture
    /// n'a pas de clavier) ; nil : la frappe.
    @Entry public var saisieImposee: String?
    /// Une racine pose l'hôte des listes (`hoteDesSuggestions`) : un champ à suggestions y ouvre la sienne.
    @Entry public var hoteDesSuggestions = false
}

extension Jetons {
    public static let couleursParDefaut = Nuancier.couleurs(themeDeLaMarque, systemeSombre: false)
}

/// Le survol, la pression et le focus imposés à un contrôle de la trousse.
public struct EtatImpose: Hashable, Sendable {
    public var survole = false
    public var presse = false
    public var focus = false

    public init(survole: Bool = false, presse: Bool = false, focus: Bool = false) {
        self.survole = survole
        self.presse = presse
        self.focus = focus
    }
}

extension View {
    /// La main au survol de ce qui se clique (`cursor:pointer` de la trousse) ; grisé, rien
    /// (`pointer-events:none`). iOS n'a pas de pointeur à changer.
    @ViewBuilder public func curseurDeClic(_ actif: Bool) -> some View {
        #if os(macOS)
        pointerStyle(actif ? .link : nil)
        #else
        self
        #endif
    }

    /// L'anneau du focus clavier de la trousse (`anneau-focus`) : un trait d'accent d'`epaisseur-focus`,
    /// à `decalage-focus` hors de la forme, comme `outline` ; celui du système est retiré, sinon deux
    /// anneaux se superposent.
    public func anneauDeFocus<Forme: InsettableShape>(_ forme: Forme, visible: Bool) -> some View {
        modifier(AnneauDeFocus(forme: forme, visible: visible))
    }
}

private struct AnneauDeFocus<Forme: InsettableShape>: ViewModifier {
    let forme: Forme
    let visible: Bool
    @Environment(\.couleursSynseria) private var c

    func body(content: Content) -> some View {
        content
            .overlay {
                if visible {
                    forme.inset(by: -(Jetons.decalageFocus + Jetons.epaisseurFocus))
                        .strokeBorder(c.accent.couleur, lineWidth: Jetons.epaisseurFocus)
                }
            }
            .focusEffectDisabled()
    }
}

extension View {
    /// Pose les couleurs d'un thème ; s'il suit le système, à la clarté retenue pour l'apparence.
    /// L'app impose l'apparence de ses fenêtres (`Theme.sombreImpose`), sinon un thème fixé sombre
    /// garderait des contrôles du système clairs.
    public func themeSynseria(_ theme: Jetons.Theme) -> some View {
        modifier(ThemeSynseria(theme: theme))
    }

    /// Pose des couleurs déjà calculées (une app qui les garde en cache).
    public func couleursSynseria(_ couleurs: Jetons.Couleurs) -> some View {
        environment(\.couleursSynseria, couleurs)
    }
}

private struct ThemeSynseria: ViewModifier {
    let theme: Jetons.Theme
    @Environment(\.colorScheme) private var apparence

    func body(content: Content) -> some View {
        content.environment(\.couleursSynseria, Jetons.Nuancier.couleurs(theme, systemeSombre: apparence == .dark))
    }
}

extension Jetons.Couleurs {
    /// La piste d'un interrupteur éteint (`.tg`) : l'encre mêlée à la plaque, plus au survol.
    public func piste(survolee: Bool) -> Jetons.RVB {
        Jetons.Octets.melange(Jetons.Octets(plaque.hex), Jetons.Octets(encre.hex),
                              survolee ? Jetons.pisteSurvol : Jetons.pisteRepos).rvb
    }
}

// MARK: - La typo et les coins

extension Jetons {
    /// Un coin dans un coin : l'extérieur moins le padding qui les sépare, jamais négatif — deux
    /// rayons égaux l'un dans l'autre font un filet plus épais aux angles.
    public static func rayonInterieur(_ exterieur: CGFloat, padding: CGFloat) -> CGFloat { max(0, exterieur - padding) }
}

extension Jetons.Typo {
    /// L'interligne du système pour cette taille, mesuré sur la police dessinée : SwiftUI n'en pose
    /// que l'écart (`lineSpacing`), que `View.typo` ajoute.
    @MainActor public var ecart: CGFloat {
        #if os(macOS)
        let poids: NSFont.Weight = switch graisse {
        case 700: .bold
        case 600: .semibold
        case 500: .medium
        default: .regular
        }
        let base = NSFont.systemFont(ofSize: taille, weight: poids)
        let dessin: NSFontDescriptor.SystemDesign = police == .code ? .monospaced : .rounded
        let dessinee = base.fontDescriptor.withDesign(dessin).flatMap { NSFont(descriptor: $0, size: taille) } ?? base
        #else
        let poids: UIFont.Weight = switch graisse {
        case 700: .bold
        case 600: .semibold
        case 500: .medium
        default: .regular
        }
        let base = UIFont.systemFont(ofSize: taille, weight: poids)
        let dessin: UIFontDescriptor.SystemDesign = police == .code ? .monospaced : .rounded
        let dessinee = base.fontDescriptor.withDesign(dessin).map { UIFont(descriptor: $0, size: taille) } ?? base
        #endif
        return max(0, interligne - (dessinee.ascender - dessinee.descender + dessinee.leading).rounded(.up))
    }
}

extension View {
    /// La police d'une typo du SDS et son interligne.
    @MainActor public func typo(_ typo: Jetons.Typo) -> some View {
        font(typo.font).lineSpacing(typo.ecart)
    }
}
