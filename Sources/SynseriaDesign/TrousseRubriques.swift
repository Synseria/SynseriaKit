// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
import SwiftUI

// Ce qui range une page : état vide, carte, dépliable, formulaire de réglages en sections.

// MARK: - État vide

/// Un état vide (`.vide`) : son symbole dans un rond du fond du choix, son titre et, s'il y a un
/// geste, son bouton bordé — jamais une phrase qui explique. À la place de
/// `ContentUnavailableView`, qui met son titre en gras et ajoute une description.
public struct EtatVide<Actions: View>: View {
    public let titre: String
    public let symbole: String
    public var ton: Ton?
    public let actions: Actions
    @Environment(\.couleursSynseria) private var c

    public init(_ titre: String, symbole: String, ton: Ton? = nil, @ViewBuilder actions: () -> Actions) {
        (self.titre, self.symbole, self.ton, self.actions) = (titre, symbole, ton, actions())
    }

    public var body: some View {
        VStack(spacing: Jetons.espace3) {
            Image(systemName: symbole)
                .font(.system(size: Jetons.espace5))
                .foregroundStyle((ton?.rvb(c) ?? c.accentTexte).couleur)
                .frame(width: Jetons.hauteurRangee * 1.5, height: Jetons.hauteurRangee * 1.5)
                .background((ton.map { $0.rvb(c).voile(Jetons.Parametres.tauxSelection / 100) } ?? c.selection).couleur, in: .circle)
            Text(titre)
                .font(Jetons.typoTitreCarte.font)
                .foregroundStyle(c.encre.couleur)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            actions
                .buttonStyle(BoutonBorde())
                .padding(.top, Jetons.espace1)
        }
        .padding(Jetons.espace5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension EtatVide where Actions == EmptyView {
    public init(_ titre: String, symbole: String, ton: Ton? = nil) {
        self.init(titre, symbole: symbole, ton: ton) { EmptyView() }
    }
}

// MARK: - Le dépliable

/// L'en-tête d'un dépliable (`.rpl`) : le chevron et son libellé ne font qu'un bouton — un clic sur
/// le libellé ouvre aussi, pas seulement sur la flèche. Le seul dessin d'un dépliable : celui des
/// `DisclosureGroup` (`.rubriqueRepliable`) et des rangées repliées faites main.
public struct EnTeteRepliable<Libelle: View>: View {
    public let deplie: Bool
    public let basculer: () -> Void
    @ViewBuilder public var libelle: Libelle

    public init(deplie: Bool, basculer: @escaping () -> Void, @ViewBuilder libelle: () -> Libelle) {
        self.deplie = deplie
        self.basculer = basculer
        self.libelle = libelle()
    }
    @Environment(\.couleursSynseria) private var c

    public var body: some View {
        Button(action: basculer) {
            HStack(spacing: Jetons.espace2) {
                Image(systemName: deplie ? "chevron.down" : "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.semibold)
                    .foregroundStyle(c.encre3.couleur)
                    .frame(width: Jetons.diametreMini, height: Jetons.diametreMini)
                libelle
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .curseurDeClic(true)
        .accessibilityAddTraits(deplie ? .isSelected : [])
    }
}

/// Le style des `DisclosureGroup` : l'en-tête commun, le contenu aligné sur le libellé. Posé à la
/// racine de chaque hôte : le style du système n'ouvre qu'au clic sur la flèche.
public struct RubriqueRepliable: DisclosureGroupStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            EnTeteRepliable(deplie: configuration.isExpanded, basculer: { configuration.isExpanded.toggle() }) {
                configuration.label
            }
            if configuration.isExpanded {
                configuration.content
                    .padding(.leading, Jetons.diametreMini + Jetons.espace2)
            }
        }
    }
}

extension DisclosureGroupStyle where Self == RubriqueRepliable {
    public static var rubriqueRepliable: RubriqueRepliable { RubriqueRepliable() }
}

// MARK: - Le formulaire de réglages

/// Un volet de réglages (`.sc`) : des sections à cartes, serrées — le `Form` groupé de macOS a des
/// rangées de 40 pt et des sections que rien ne règle. `enBas` : appelé quand le défilement
/// approche du bas, pour une liste par pages.
public struct FormulaireCompact<Contenu: View>: View {
    public var enBas: (() -> Void)?
    public var contenu: Contenu

    public init(enBas: (() -> Void)? = nil, @ViewBuilder contenu: () -> Contenu) {
        self.enBas = enBas
        self.contenu = contenu()
    }

    /// L'air autour des cartes, le padding de la plaque des réglages (`.sw .main`).
    public static var marge: CGFloat { Jetons.espace5 }

    /// La marge avant le bas qui demande la suite : la page arrive avant qu'on y bute.
    private static var avance: CGFloat { 400 }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Jetons.espace3) { contenu }
                .padding(Self.marge)
        }
        .contentMargins(.vertical, 0, for: .scrollContent)
        .onScrollGeometryChange(for: Bool.self) { geometrie in
            geometrie.contentOffset.y + geometrie.containerSize.height >= geometrie.contentSize.height - Self.avance
        } action: { _, presDuBas in
            if presDuBas { enBas?() }
        }
    }
}

/// Une section : son titre (l'explication en infobulle, jamais dessous) et, à sa droite, le geste qui
/// vaut pour toute la section (`entete`), puis une carte dont chaque vue est une rangée, séparée de
/// la suivante par un filet. `paresseux` : une longue liste ne bâtit que les rangées qui paraissent
/// (dans un défilement : `FormulaireCompact`).
public struct SectionCompacte<Contenu: View, Entete: View>: View {
    public var titre: String?
    public var aide: String?
    public var paresseux: Bool
    public var contenu: Contenu
    public var entete: Entete
    @Environment(\.couleursSynseria) private var c

    public init(titre: String? = nil, aide: String? = nil, paresseux: Bool = false,
         @ViewBuilder contenu: () -> Contenu, @ViewBuilder entete: () -> Entete) {
        (self.titre, self.aide, self.paresseux) = (titre, aide, paresseux)
        (self.contenu, self.entete) = (contenu(), entete())
    }

    public var body: some View {
        let forme = RoundedRectangle(cornerRadius: Jetons.rayon2, style: .circular)
        VStack(alignment: .leading, spacing: Jetons.espace1) {
            if titre != nil || Entete.self != EmptyView.self {
                HStack(spacing: Jetons.espace2) {
                    if let titre {
                        Text(titre)
                            .font(Jetons.typoTitreCarte.font)
                            .foregroundStyle(c.encre2.couleur)
                            .help(aide ?? "")
                    }
                    Spacer(minLength: Jetons.espace3)
                    entete
                }
                .padding(.leading, Jetons.espace1)
            }
            Group {
                if paresseux { LazyVStack(spacing: 0) { rangees } } else { VStack(spacing: 0) { rangees } }
            }
            .background(c.carte.couleur, in: forme)
            .overlay { forme.strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet) }
            .clipShape(forme)
        }
    }

    /// Chaque vue, une rangée : `hauteur-rangee` − `espace-2` au moins, `espace-3` de côté. Le filet
    /// se pose au-dessus de chaque rangée sauf la première, sans compter les rangées : les énumérer
    /// les bâtirait toutes, même dans la pile paresseuse.
    private var rangees: some View {
        Group(subviews: contenu) { vues in
            let premiere = vues.first?.id
            ForEach(vues) { vue in
                VStack(spacing: 0) {
                    if vue.id != premiere { Rectangle().fill(c.filet.couleur).frame(height: Jetons.epaisseurFilet) }
                    vue
                        .frame(maxWidth: .infinity, minHeight: Jetons.hauteurRangee - Jetons.espace2, alignment: .leading)
                        .padding(.horizontal, Jetons.espace3)
                        .padding(.vertical, Jetons.espace1)
                }
            }
        }
    }
}

extension SectionCompacte where Entete == EmptyView {
    public init(titre: String? = nil, aide: String? = nil, paresseux: Bool = false, @ViewBuilder contenu: () -> Contenu) {
        self.init(titre: titre, aide: aide, paresseux: paresseux, contenu: contenu) { EmptyView() }
    }
}

/// Une rangée « libellé … contrôle » : le libellé à gauche (son aide en infobulle), le contrôle à
/// droite, à sa taille.
public struct RangeeReglage<Controle: View>: View {
    public let titre: String
    public var aide: String?
    /// Faux quand le contrôle porte un libellé à lui (« ☐ Régler ») : sinon, le titre de la
    /// rangée le dit déjà, et celui du contrôle se tait.
    public var libellesCaches = true
    @ViewBuilder public var controle: Controle

    public init(titre: String, aide: String? = nil, libellesCaches: Bool = true, @ViewBuilder controle: () -> Controle) {
        self.titre = titre
        self.aide = aide
        self.libellesCaches = libellesCaches
        self.controle = controle()
    }
    @Environment(\.couleursSynseria) private var c

    public var body: some View {
        HStack {
            Text(titre).font(Jetons.typoCorps.font).foregroundStyle(c.encre.couleur).help(aide ?? "")
            Spacer(minLength: Jetons.espace3)
            Group {
                if libellesCaches { controle.labelsHidden() } else { controle }
            }
            .fixedSize()
        }
    }
}

/// Le bouton « supprimer » d'une rangée de réglages : la corbeille en encre secondaire, `danger` au
/// survol. Sur macOS, `.onDelete` dans un `Form` n'offre ni geste ni bouton.
public struct BoutonSupprimer: View {
    public let aide: String
    public let action: () -> Void

    public init(aide: String, action: @escaping () -> Void) {
        self.aide = aide
        self.action = action
    }
    @State private var survole = false
    @Environment(\.couleursSynseria) private var c

    public var body: some View {
        Button(role: .destructive, action: action) {
            Image(systemName: "trash")
                .font(.system(size: Jetons.tailleIcone))
                .foregroundStyle((survole ? c.danger : c.encre2).couleur)
        }
        .buttonStyle(.plain)
        .onHover { survole = $0 }
        .curseurDeClic(true)
        .help(aide)
        .accessibilityLabel(aide)
    }
}

// MARK: - La carte

/// Une carte (`.carte`) : la plaque, son filet, `rayon-2`, `espace-4` d'air. Bordure, jamais d'ombre.
/// Choisie, le contour du choix (l'encre secondaire, au trait d'état).
public struct Carte: ViewModifier {
    public var marge: CGFloat = Jetons.espace4
    public var choisie = false

    public init(marge: CGFloat = Jetons.espace4, choisie: Bool = false) {
        self.marge = marge
        self.choisie = choisie
    }
    @Environment(\.couleursSynseria) private var c

    public func body(content: Content) -> some View {
        let forme = RoundedRectangle(cornerRadius: Jetons.rayon2, style: .circular)
        content
            .padding(marge)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(c.carte.couleur, in: forme)
            .overlay {
                forme.strokeBorder((choisie ? c.encre2 : c.filet).couleur,
                                   lineWidth: choisie ? Jetons.epaisseurFocus : Jetons.epaisseurFilet)
            }
    }
}

extension View {
    public func carte(marge: CGFloat = Jetons.espace4, choisie: Bool = false) -> some View {
        modifier(Carte(marge: marge, choisie: choisie))
    }
}
