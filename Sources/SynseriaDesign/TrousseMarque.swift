// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
import SwiftUI

// La marque : le signe Synseria et le gabarit d'À propos.

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

/// « À propos » (`.apropos`), une fenêtre à part de `largeur-apropos`, ouverte par le menu de l'app :
/// l'icône de l'app (celle du Dock ; l'emblème est la marque de l'éditeur), son nom, « by » et le
/// signe, puis sa ligne — la version entière (`LigneDeVersion`), ou la version et « Rechercher »
/// dessous (`LigneDeMiseAJour(disposition: .colonne)`). Le haut laisse la rangée des feux (`.fen-apropos
/// .bar`), la fenêtre en `fullSizeContentView`.
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
        .padding([.horizontal, .bottom], Jetons.espace6)
        .padding(.top, Jetons.espace3 * 2 + Jetons.diametreMini)
        .frame(width: Jetons.largeurApropos)
        .ignoresSafeArea(.container, edges: .top)
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
