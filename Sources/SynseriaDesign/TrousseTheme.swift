// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
import SwiftUI

// Réglages ▸ Thème : l'aperçu d'une fenêtre (deux, claire et sombre, quand le thème suit le système),
// puis Couleur, Fond (Accordé) et Clarté (Système), chacun son curseur. Le même gabarit que la
// section « Thème » de la page de référence (`K.fenetreTheme`) ; tout s'applique en direct.

#if os(macOS)
/// Les mots de l'écran et de son aperçu : ceux du SDS, ceux de la page de référence ; l'app ne les
/// remplace que pour les traduire.
public struct LibellesDuTheme {
    public typealias D = Jetons.LibellesParDefaut
    public var systeme = D.systeme, clarte = D.clarte, couleur = D.couleur
    public var accorde = D.accorde, fond = D.fond, clair = D.clair, sombre = D.sombre, apercu = D.apercu
    public var rechercher = D.rechercher, accueil = D.accueil, recents = D.recents, collections = D.collections
    public var travail = D.travail, projets = D.projets, archives = D.archives, personnel = D.personnel, creer = D.creer
    public var progression = D.progression, mesure = D.mesure, succes = D.succes, alerte = D.alerte, erreur = D.erreur
    public var vignette = D.vignette, sousTitre = D.sousTitre, elementChoisi = D.elementChoisi, aujourdhui = D.aujourdhui
    public var element = D.element, etiquette = D.etiquette, elementFini = D.elementFini, hier = D.hier, lien = D.lien
    public var actionChercher = D.actionChercher, actionChoisie = D.actionChoisie, actionAutre = D.actionAutre
    public var remplacer = D.remplacer, copier = D.copier, annuler = D.annuler
    public var marque = Jetons.Marque.nom
    public var nomDuCran: (Jetons.CranDeClarte) -> String = { $0.nom }
    public var nomDuFond: (Jetons.CranDeFond) -> String = { $0.nom }

    public init(systeme: String = D.systeme,
                clarte: String = D.clarte,
                couleur: String = D.couleur,
                accorde: String = D.accorde,
                fond: String = D.fond,
                clair: String = D.clair,
                sombre: String = D.sombre,
                apercu: String = D.apercu,
                rechercher: String = D.rechercher,
                accueil: String = D.accueil,
                recents: String = D.recents,
                collections: String = D.collections,
                travail: String = D.travail,
                projets: String = D.projets,
                archives: String = D.archives,
                personnel: String = D.personnel,
                creer: String = D.creer,
                progression: String = D.progression,
                mesure: String = D.mesure,
                succes: String = D.succes,
                alerte: String = D.alerte,
                erreur: String = D.erreur,
                vignette: String = D.vignette,
                sousTitre: String = D.sousTitre,
                elementChoisi: String = D.elementChoisi,
                aujourdhui: String = D.aujourdhui,
                element: String = D.element,
                etiquette: String = D.etiquette,
                elementFini: String = D.elementFini,
                hier: String = D.hier,
                lien: String = D.lien,
                actionChercher: String = D.actionChercher,
                actionChoisie: String = D.actionChoisie,
                actionAutre: String = D.actionAutre,
                remplacer: String = D.remplacer,
                copier: String = D.copier,
                annuler: String = D.annuler,
                marque: String = Jetons.Marque.nom,
                nomDuCran: @escaping (Jetons.CranDeClarte) -> String = { $0.nom },
                nomDuFond: @escaping (Jetons.CranDeFond) -> String = { $0.nom }) {
        self.systeme = systeme
        self.clarte = clarte
        self.couleur = couleur
        self.accorde = accorde
        self.fond = fond
        self.clair = clair
        self.sombre = sombre
        self.apercu = apercu
        self.rechercher = rechercher
        self.accueil = accueil
        self.recents = recents
        self.collections = collections
        self.travail = travail
        self.projets = projets
        self.archives = archives
        self.personnel = personnel
        self.creer = creer
        self.progression = progression
        self.mesure = mesure
        self.succes = succes
        self.alerte = alerte
        self.erreur = erreur
        self.vignette = vignette
        self.sousTitre = sousTitre
        self.elementChoisi = elementChoisi
        self.aujourdhui = aujourdhui
        self.element = element
        self.etiquette = etiquette
        self.elementFini = elementFini
        self.hier = hier
        self.lien = lien
        self.actionChercher = actionChercher
        self.actionChoisie = actionChoisie
        self.actionAutre = actionAutre
        self.remplacer = remplacer
        self.copier = copier
        self.annuler = annuler
        self.marque = marque
        self.nomDuCran = nomDuCran
        self.nomDuFond = nomDuFond
    }
}

/// Réglages ▸ Thème. Le thème se lie à l'app, qui l'enregistre et impose l'apparence de ses fenêtres
/// (`Theme.sombreImpose`) ; avec le système, le curseur de clarté ne règle que la moitié de
/// l'apparence du moment, l'autre estompée.
public struct ReglagesDuTheme: View {
    @Binding public var theme: Jetons.Theme
    public var libelles = LibellesDuTheme()

    public init(theme: Binding<Jetons.Theme>, libelles: LibellesDuTheme = LibellesDuTheme()) {
        self._theme = theme
        self.libelles = libelles
    }
    @Environment(\.colorScheme) private var schema

    private var systemeSombre: Bool { schema == .dark }

    public var body: some View {
        FormulaireCompact {
            ApercusDuTheme(theme: theme, libelles: libelles)
            SectionCompacte {
                RangeeACurseur(titre: libelles.couleur) { curseurDeCouleur }
                // Accordé, le curseur du fond montre le fond qui suit la couleur, estompé ; désaccordé, il est libre.
                RangeeACurseur(titre: libelles.fond, option: (libelles.accorde, accorde)) { curseurDeFond }
                RangeeACurseur(titre: libelles.clarte, option: (libelles.systeme, suivre)) { curseurDeClarte }
            }
        }
    }

    // MARK: Les interrupteurs

    /// Cesser de suivre le système garde la clarté qu'on voit.
    private var suivre: Binding<Bool> {
        Binding(get: { theme.suivreLeSysteme }, set: { suivre in
            guard suivre != theme.suivreLeSysteme else { return }
            if !suivre { theme.clarte = theme.clarte(systemeSombre: systemeSombre) }
            theme.suivreLeSysteme = suivre
        })
    }

    /// Décocher le fond accordé part du fond qu'on voit.
    private var accorde: Binding<Bool> {
        Binding(get: { theme.fond == .accorde }, set: { accorde in
            let fond: Jetons.Fond = accorde ? .accorde : .teinte(theme.teinteDuFond)
            if theme.fond != fond { theme.fond = fond }
        })
    }

    // MARK: Les curseurs

    private var curseurDeClarte: some View {
        let fin = Jetons.Nuancier.finDeLaClarte, fond = theme.teinteDuFond
        let valeur = theme.clarte(systemeSombre: systemeSombre)
        let crans = Jetons.CranDeClarte.allCases
        return CurseurACrans(
            valeur: valeur, fin: fin,
            degrade: Jetons.Parametres.Clarte.ancres.map { (Jetons.Nuancier.fondDeFenetre(fond: fond, clarte: Int($0[0])).rvb.couleur, Int($0[0])) },
            pouce: Jetons.Nuancier.fondDeFenetre(fond: fond, clarte: valeur).rvb.couleur,
            crans: crans.map { ($0.position, libelles.nomDuCran($0)) } + [(0, nil), (fin, nil)],
            aimants: crans.map(\.position) + [Int(Jetons.Parametres.Clarte.bascule)],
            bornes: theme.bornes(systemeSombre: systemeSombre), libelle: libelles.clarte,
            valeurLue: crans.first { $0.position == valeur }.map(libelles.nomDuCran) ?? "\(valeur)") { position in
            var nouveau = theme
            nouveau.poserClarte(position, systemeSombre: systemeSombre)
            if nouveau != theme { theme = nouveau }
        }
    }

    private var curseurDeCouleur: some View {
        CurseurACrans(
            valeur: theme.teinte, fin: Self.finDesTeintes, degrade: Self.spectre { Jetons.Nuancier.accent($0) },
            pouce: Jetons.Nuancier.accent(theme.teinte).rvb.couleur,
            crans: [(Jetons.Marque.teinte, libelles.marque)], aimants: [Jetons.Marque.teinte],
            libelle: libelles.couleur, valeurLue: "\(theme.teinte)°") { teinte in
            if theme.teinte != teinte { theme.teinte = teinte }
        }
    }

    private var curseurDeFond: some View {
        let crans = Jetons.CranDeFond.allCases, teinte = theme.teinteDuFond
        return CurseurACrans(
            valeur: teinte, fin: Self.finDesTeintes, degrade: Self.spectre(Self.teinteDeFond),
            pouce: Self.teinteDeFond(teinte).rvb.couleur,
            crans: crans.map { ($0.teinte, libelles.nomDuFond($0)) }, aimants: crans.map(\.teinte),
            libelle: libelles.fond, actif: theme.fond != .accorde,
            valeurLue: crans.first { $0.teinte == teinte }.map(libelles.nomDuFond) ?? "\(teinte)°") { nouvelle in
            if theme.fond != .teinte(nouvelle) { theme.fond = .teinte(nouvelle) }
        }
    }

    /// La course d'une teinte : 0…359°, 360 revenant à 0.
    public static var finDesTeintes: Int { 359 }

    /// Un fond, dans le dégradé du curseur de fond : clair et un peu teinté, pour se voir.
    public static func teinteDeFond(_ teinte: Int) -> Jetons.Octets {
        let f = Jetons.Parametres.Curseurs.fond
        return Jetons.Oklch.couleur(f[0], f[1], Double(teinte))
    }

    /// Le dégradé d'un curseur de teinte, de `Curseurs.pas` en `Curseurs.pas` degrés, 360 compris.
    public static func spectre(_ couleur: (Int) -> Jetons.Octets) -> [(Color, Int)] {
        stride(from: 0, through: 360, by: Int(Jetons.Parametres.Curseurs.pas)).map {
            (couleur($0 % 360).rvb.couleur, $0 * finDesTeintes / 360)
        }
    }
}

/// Une rangée à curseur (`.tete-rang` de la page) : le titre à gauche, à droite son option (un petit
/// interrupteur libellé), puis le curseur sur toute la largeur — ses crans ont la place d'écrire leur nom.
private struct RangeeACurseur<Curseur: View>: View {
    let titre: String
    var option: (libelle: String, valeur: Binding<Bool>)?
    @ViewBuilder var curseur: Curseur
    @Environment(\.couleursSynseria) private var c

    var body: some View {
        VStack(alignment: .leading, spacing: Jetons.espace1) {
            HStack(spacing: Jetons.espace3) {
                Text(titre).font(Jetons.typoCorps.font).foregroundStyle(c.encre.couleur)
                Spacer(minLength: Jetons.espace3)
                if let option {
                    Toggle(option.libelle, isOn: option.valeur)
                        .toggleStyle(.petitInterrupteur)
                        .foregroundStyle(c.encre2.couleur)
                        .fixedSize()
                }
            }
            curseur
        }
        .padding(.vertical, Jetons.espace1)
    }
}

// MARK: - Le curseur à crans

/// Un curseur sur un dégradé, de 0 à `fin` : des crans (un repère, leur nom dessous ; un clic sur le
/// nom y mène), des aimants qui attirent le pouce à moins de `Curseurs.aimant` de la course, et des
/// bornes hors desquelles la piste s'estompe. Un seul arrêt de Tab : ← → d'un centième (⇧ : d'un
/// dixième).
public struct CurseurACrans: View {
    public let valeur: Int
    public let fin: Int
    /// (couleur, position) de chaque arrêt du dégradé.
    public let degrade: [(Color, Int)]
    public let pouce: Color
    public let crans: [(position: Int, nom: String?)]
    public let aimants: [Int]
    public var bornes: ClosedRange<Int>?
    public let libelle: String
    /// Inactif, il montre sa valeur estompé, sans geste (le fond accordé suit la couleur).
    public var actif = true
    public let valeurLue: String
    public let poser: (Int) -> Void

    public init(valeur: Int, fin: Int, degrade: [(Color, Int)], pouce: Color, crans: [(position: Int, nom: String?)], aimants: [Int], bornes: ClosedRange<Int>? = nil, libelle: String, actif: Bool = true, valeurLue: String, poser: @escaping (Int) -> Void) {
        self.valeur = valeur
        self.fin = fin
        self.degrade = degrade
        self.pouce = pouce
        self.crans = crans
        self.aimants = aimants
        self.bornes = bornes
        self.libelle = libelle
        self.actif = actif
        self.valeurLue = valeurLue
        self.poser = poser
    }

    @FocusState private var focalise: Bool
    @Environment(\.couleursSynseria) private var c

    private static let diametre = Jetons.diametreRond
    private var limites: ClosedRange<Int> { bornes ?? 0...fin }

    /// La position posée pour un geste : ramenée dans les bornes, puis attirée par l'aimant le plus
    /// proche qui y tient.
    public static func position(_ voulue: Int, fin: Int, aimants: [Int], bornes: ClosedRange<Int>) -> Int {
        let aimant = Int((Jetons.Parametres.Curseurs.aimant * Double(fin)).rounded())
        let p = min(bornes.upperBound, max(bornes.lowerBound, voulue))
        return Jetons.Nuancier.aimanter(p, aimants.filter(bornes.contains), aimant: aimant)
    }

    private func poserAu(_ voulue: Int) {
        let p = Self.position(voulue, fin: fin, aimants: aimants, bornes: limites)
        if p != valeur { poser(p) }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Jetons.espace1) {
            piste
            NomsDesCrans(espacement: Jetons.espace2) {
                ForEach(crans.indices, id: \.self) { i in
                    if let nom = crans[i].nom {
                        let permis = limites.contains(crans[i].position)
                        Button { poserAu(crans[i].position) } label: {
                            Text(nom)
                                .font(Jetons.typoMicro.font)
                                .foregroundStyle((crans[i].position == valeur ? c.encre : c.encre2).couleur)
                                .fixedSize()
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .disabled(!permis)
                        .opacity(permis ? 1 : Jetons.opaciteDesactive)
                        .curseurDeClic(permis)
                        .layoutValue(key: PartDeLaCourse.self, value: Double(crans[i].position) / Double(fin))
                    }
                }
            }
            .padding(.horizontal, Self.diametre / 2)
        }
        .disabled(!actif)
        .allowsHitTesting(actif)
        // le grisé d'un tout, comme `opacity` en CSS
        .compositingGroup()
        .opacity(actif ? 1 : Jetons.opaciteDesactive)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(libelle)
        .accessibilityValue(valeurLue)
        .accessibilityAdjustableAction { sens in poserAu(valeur + (sens == .increment ? pas : -pas)) }
    }

    private var pas: Int { max(1, fin / 100) }

    private var piste: some View {
        GeometryReader { cadre in
            let course = max(1, cadre.size.width - Self.diametre)
            let x = { (p: Int) in Self.diametre / 2 + CGFloat(p) / CGFloat(fin) * course }
            let retrait = Self.diametre / 2 - Jetons.espace2
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LinearGradient(stops: degrade.map { .init(color: $0.0, location: CGFloat($0.1) / CGFloat(fin)) },
                                         startPoint: .leading, endPoint: .trailing))
                    .overlay { Capsule().strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet) }
                    .frame(height: Jetons.espace3)
                    .padding(.horizontal, retrait)
                // Hors des bornes, la piste s'estompe : la moitié de l'autre apparence.
                if limites != 0...fin {
                    let (debut, bout) = limites.lowerBound == 0 ? (x(limites.upperBound), cadre.size.width - retrait) : (retrait, x(limites.lowerBound))
                    Rectangle()
                        .fill(c.plaque.couleur.opacity(1 - Jetons.opaciteDesactive))
                        .frame(width: max(0, bout - debut), height: Jetons.espace3)
                        .offset(x: debut)
                }
                ForEach(crans.indices, id: \.self) { i in
                    Capsule()
                        .fill(c.encre3.couleur)
                        .frame(width: Jetons.epaisseurFocus, height: Jetons.espace2)
                        .offset(x: x(crans[i].position) - Jetons.epaisseurFocus / 2, y: Jetons.espace3)
                }
                Circle()
                    .fill(pouce)
                    .overlay { Circle().strokeBorder(c.plaque.couleur, lineWidth: Jetons.epaisseurFocus) }
                    .overlay { Circle().strokeBorder(c.encre3.couleur, lineWidth: Jetons.epaisseurFilet) }
                    .frame(width: Self.diametre, height: Self.diametre)
                    .anneauDeFocus(Circle(), visible: focalise)
                    .offset(x: x(valeur) - Self.diametre / 2)
            }
            .frame(maxHeight: .infinity)
            .contentShape(.rect)
            .gesture(DragGesture(minimumDistance: 0).onChanged { geste in
                poserAu(Int(((geste.location.x - Self.diametre / 2) / course * CGFloat(fin)).rounded()))
            })
        }
        .frame(height: Jetons.hauteurControle)
        .focusable(interactions: .activate)
        .focused($focalise)
        .focusEffectDisabled()
        .curseurDeClic(actif)
        .onKeyPress(keys: [.leftArrow, .rightArrow]) { touche in
            let saut = touche.modifiers.contains(.shift) ? pas * 10 : pas
            poserAu(valeur + (touche.key == .leftArrow ? -saut : saut))
            return .handled
        }
    }
}

/// La place d'un nom de cran sur la course, de 0 à 1.
private struct PartDeLaCourse: LayoutValueKey {
    static let defaultValue = 0.0
}

/// Les noms des crans, chacun centré sous son repère et tenu dans la largeur ; deux noms qui se
/// chevaucheraient passent sur une ligne de plus : rien n'est tronqué ni serré.
public struct NomsDesCrans: Layout {
    public let espacement: CGFloat

    public init(espacement: CGFloat) {
        self.espacement = espacement
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let largeur = proposal.width ?? subviews.reduce(0) { $0 + $1.sizeThatFits(.unspecified).width + espacement }
        let lignes = Set(Self.placer(largeur: largeur, largeurs: subviews.map { $0.sizeThatFits(.unspecified).width },
                                     parts: subviews.map { $0[PartDeLaCourse.self] }, espacement: espacement).map(\.ligne)).count
        return CGSize(width: largeur, height: CGFloat(lignes) * hauteur(subviews))
    }

    public func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let places = Self.placer(largeur: bounds.width, largeurs: subviews.map { $0.sizeThatFits(.unspecified).width },
                                 parts: subviews.map { $0[PartDeLaCourse.self] }, espacement: espacement)
        for (vue, place) in zip(subviews, places) {
            vue.place(at: CGPoint(x: bounds.minX + place.x, y: bounds.minY + CGFloat(place.ligne) * hauteur(subviews)), proposal: .unspecified)
        }
    }

    private func hauteur(_ subviews: Subviews) -> CGFloat { subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }

    /// Le bord gauche et la ligne de chaque nom : centré sur sa part de la course, ramené dans la
    /// largeur, sur la première ligne où il ne touche pas son voisin.
    public static func placer(largeur: CGFloat, largeurs: [CGFloat], parts: [Double], espacement: CGFloat) -> [(x: CGFloat, ligne: Int)] {
        var fins: [CGFloat] = []
        return zip(largeurs, parts).map { w, part in
            let x = min(max(0, part * largeur - w / 2), max(0, largeur - w))
            let ligne = fins.firstIndex { $0 + espacement <= x } ?? fins.count
            if ligne == fins.count { fins.append(x + w) } else { fins[ligne] = x + w }
            return (x, ligne)
        }
    }
}

// MARK: - L'aperçu

/// Le bureau, puis la fenêtre du thème — deux, claire et sombre, quand le thème suit le système : côte
/// à côte, l'une sous l'autre seulement sous `Apercu.empilerSous`. L'aperçu a une hauteur fixe
/// (`Apercu.zone`) : chaque fenêtre est dessinée à la taille de son canevas puis mise à l'échelle
/// entière, jamais tassée. Un dessin : rien ne s'y clique.
public struct ApercusDuTheme: View {
    public let theme: Jetons.Theme
    public let libelles: LibellesDuTheme

    public init(theme: Jetons.Theme, libelles: LibellesDuTheme) {
        self.theme = theme
        self.libelles = libelles
    }
    private typealias A = Jetons.Parametres.Apercu

    private var fenetres: [(nom: String?, couleurs: Jetons.Couleurs)] {
        theme.suivreLeSysteme
            ? [(libelles.clair, Jetons.Nuancier.couleurs(theme, systemeSombre: false)),
               (libelles.sombre, Jetons.Nuancier.couleurs(theme, systemeSombre: true))]
            : [(nil, Jetons.Nuancier.couleurs(theme, systemeSombre: false))]
    }

    public var body: some View {
        let liste = fenetres
        ViewThatFits(in: .horizontal) {
            zone(liste, empilee: false).frame(minWidth: liste.count > 1 ? A.empilerSous : 0)
            zone(liste, empilee: true)
        }
        .background { BureauDApercu() }
        .clipShape(.rect(cornerRadius: Jetons.rayon3))
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(libelles.apercu)
    }

    /// Les fenêtres côte à côte ou l'une sous l'autre, chacune à l'échelle qui la fait tenir dans sa
    /// part de la zone, son nom au-dessus (à sa taille : il se lit).
    private func zone(_ liste: [(nom: String?, couleurs: Jetons.Couleurs)], empilee: Bool) -> some View {
        let n = CGFloat(liste.count), marge = Jetons.espace4, ecart = Jetons.espace4
        let nom = liste.contains { $0.nom != nil } ? Jetons.typoMicro.interligne + Jetons.espace1 : 0
        return GeometryReader { cadre in
            let largeur = empilee ? cadre.size.width - 2 * marge : (cadre.size.width - 2 * marge - ecart * (n - 1)) / n
            let hauteur = (empilee ? (cadre.size.height - 2 * marge - ecart * (n - 1)) / n : cadre.size.height - 2 * marge) - nom
            let echelle = max(0, min(1, largeur / A.canevas[0], hauteur / A.canevas[1]))
            let pile = empilee ? AnyLayout(VStackLayout(spacing: ecart)) : AnyLayout(HStackLayout(alignment: .top, spacing: ecart))
            pile {
                ForEach(liste.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: Jetons.espace1) {
                        if let titre = liste[i].nom { Etiquette(texte: titre, c: liste[i].couleurs) }
                        ApercuDuTheme(c: liste[i].couleurs, libelles: libelles)
                            .frame(width: A.canevas[0], height: A.canevas[1], alignment: .top)
                            .scaleEffect(echelle, anchor: .topLeading)
                            .frame(width: A.canevas[0] * echelle, height: A.canevas[1] * echelle, alignment: .topLeading)
                    }
                }
            }
            .frame(width: cadre.size.width, height: cadre.size.height)
        }
        .frame(height: empilee ? A.zone * n : A.zone)
    }
}

/// Le nom d'un aperçu, « Clair » ou « Sombre », sur sa pastille.
private struct Etiquette: View {
    let texte: String
    let c: Jetons.Couleurs

    var body: some View {
        Text(texte).font(Jetons.typoMicro.font).foregroundStyle(c.encre.couleur)
            .padding(.horizontal, Jetons.espace2)
            .background(c.plaque.couleur, in: .capsule)
    }
}

/// Le bureau derrière l'aperçu : un dégradé en biais, des taches rondes.
private struct BureauDApercu: View {
    typealias A = Jetons.Parametres.Apercu

    var body: some View {
        GeometryReader { cadre in
            let (w, h) = (cadre.size.width, cadre.size.height)
            ZStack {
                LinearGradient(colors: A.degrade.map(\.couleur), startPoint: .topLeading, endPoint: .bottomTrailing)
                ForEach(A.taches.indices, id: \.self) { i in
                    let t = A.taches[i], (x, y) = (t.centre[0], t.centre[1])
                    // le rayon jusqu'au coin le plus loin, comme `farthest-corner` en CSS
                    let r = ((max(x, 1 - x) * w) * (max(x, 1 - x) * w) + (max(y, 1 - y) * h) * (max(y, 1 - y) * h)).squareRoot()
                    RadialGradient(stops: [.init(color: t.couleur.couleur, location: 0),
                                           .init(color: t.couleur.couleur, location: t.rayon[0] / t.rayon[1]),
                                           .init(color: t.couleur.couleur.opacity(0), location: 1)],
                                   center: UnitPoint(x: x, y: y), startRadius: 0, endRadius: r * t.rayon[1])
                }
            }
        }
    }
}

/// Une fenêtre (`.fen` de la page) : en verre sur le bureau, sa barre, son menu, une grande carte
/// pleine, puis la palette sous la fenêtre, alignée à droite.
private struct ApercuDuTheme: View {
    let c: Jetons.Couleurs
    let libelles: LibellesDuTheme

    private var verre: Int { c.sombre ? 1 : 0 }

    var body: some View {
        VStack(alignment: .trailing, spacing: Jetons.espace3) {
            fenetre
            palette.frame(maxWidth: Jetons.largeurApropos)
        }
        .environment(\.colorScheme, c.sombre ? .dark : .light)
        .couleursSynseria(c)
    }

    private var fenetre: some View {
        let forme = RoundedRectangle(cornerRadius: Jetons.rayon2, style: .continuous)
        return VStack(spacing: 0) {
            BarreDApercu(c: c, libelles: libelles)
                .background(c.fondFenetre.couleur.opacity(Jetons.Parametres.Apercu.barre[verre]))
                .overlay(alignment: .bottom) { Rectangle().fill(c.filet.couleur).frame(height: Jetons.epaisseurFilet / 2) }
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 0) {
                    MenuDApercu(c: c, libelles: libelles)
                        .frame(width: Jetons.largeurNav - Jetons.espace6)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .background(c.fondFenetre.couleur.opacity(Jetons.Parametres.Apercu.menu[verre]))
                    CarteDApercu(c: c, libelles: libelles).frame(minWidth: Jetons.largeurNav + Jetons.espace7)
                }
                CarteDApercu(c: c, libelles: libelles)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .background(c.fondFenetre.couleur.opacity(Jetons.Parametres.Apercu.page[verre]))
        .background(.ultraThinMaterial)
        .clipShape(forme)
        .overlay { forme.strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet / 2) }
    }

    /// La palette (`.overlay` de la page) : un champ, deux actions, les touches.
    private var palette: some View {
        let forme = RoundedRectangle(cornerRadius: Jetons.rayon3, style: .continuous)
        return VStack(alignment: .leading, spacing: Jetons.espace2) {
            Text(libelles.actionChercher)
                .font(Jetons.typoMeta.font).foregroundStyle(c.encre3.couleur)
                .padding(.horizontal, Jetons.espace2)
                .frame(maxWidth: .infinity, minHeight: Jetons.hauteurCase, alignment: .leading)
                .background(c.fondTeinte.couleur, in: .rect(cornerRadius: Jetons.rayon1))
                .overlay { RoundedRectangle(cornerRadius: Jetons.rayon1).strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet / 2) }
            LigneDApercu(texte: libelles.actionChoisie, choisie: true, point: c.accent)
            LigneDApercu(texte: libelles.actionAutre, choisie: false, point: c.encre3)
            Rectangle().fill(c.filet.couleur).frame(height: Jetons.epaisseurFilet / 2)
            HStack(spacing: Jetons.espace3) {
                touche("⏎", libelles.remplacer)
                touche("⌘C", libelles.copier)
                touche("⎋", libelles.annuler)
            }
        }
        .padding(Jetons.espace3)
        .background(c.plaque.couleur.opacity(Jetons.Parametres.Apercu.overlay))
        .background(.ultraThinMaterial)
        .clipShape(forme)
        .overlay { forme.strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet / 2) }
    }

    private func touche(_ touche: String, _ geste: String) -> some View {
        HStack(spacing: Jetons.espace1) {
            Text(verbatim: touche).foregroundStyle(c.encre2.couleur)
            Text(geste).foregroundStyle(c.encre3.couleur)
        }
        .font(Jetons.typoMicro.font)
        .fixedSize()
    }
}

/// La barre (`.barre`) : les feux, la recherche centrée et son raccourci.
private struct BarreDApercu: View {
    let c: Jetons.Couleurs
    let libelles: LibellesDuTheme
    private typealias A = Jetons.Parametres.Apercu

    var body: some View {
        ZStack {
            HStack(spacing: Jetons.espace2) {
                ForEach(A.feux.indices, id: \.self) { i in
                    Circle().fill(A.feux[i].couleur).frame(width: Jetons.diametreMini, height: Jetons.diametreMini)
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: Jetons.espace1) {
                Image(systemName: "magnifyingglass").font(Jetons.typoMicro.font)
                Text(libelles.rechercher).font(Jetons.typoMeta.font).lineLimit(1).fixedSize()
                Spacer(minLength: Jetons.espace2)
                Text(verbatim: "⌘K").font(Jetons.typoMicro.font).fixedSize()
                    .padding(.horizontal, Jetons.espace1)
                    .overlay { RoundedRectangle(cornerRadius: Jetons.rayon0).strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet / 2) }
            }
            .foregroundStyle(c.encre3.couleur)
            .padding(.horizontal, Jetons.espace2)
            .frame(maxWidth: Jetons.largeurNav + Jetons.espace7, minHeight: Jetons.hauteurCase)
            .background(c.fondTeinte.couleur, in: .capsule)
            .overlay { Capsule().strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet / 2) }
            // centrée sur la barre, la recherche laisse aux feux leur place de part et d'autre
            .padding(.horizontal, (Jetons.diametreMini + Jetons.espace2) * CGFloat(A.feux.count))
        }
        .padding(.horizontal, Jetons.espace3)
        .padding(.vertical, Jetons.espace2)
    }
}

/// Le menu (`.menu`) : Accueil choisi, Récents et son compte, la rubrique Collections avec Travail
/// déplié (Projets, Archives), puis Personnel.
private struct MenuDApercu: View {
    let c: Jetons.Couleurs
    let libelles: LibellesDuTheme

    var body: some View {
        VStack(alignment: .leading, spacing: Jetons.epaisseurFocus) {
            entree(libelles.accueil, choisie: true)
            entree(libelles.recents, compte: 12)
            Text(libelles.collections)
                .font(Jetons.typoMicro.font).foregroundStyle(c.encre3.couleur)
                .padding(.horizontal, Jetons.espace2).padding(.top, Jetons.espace2)
            entree(libelles.travail, compte: 5, chevron: true)
            entree(libelles.projets, retrait: true)
            entree(libelles.archives, retrait: true)
            entree(libelles.personnel, compte: 3, chevron: false)
        }
        .padding(Jetons.espace2)
    }

    private func entree(_ titre: String, choisie: Bool = false, compte: Int? = nil, chevron: Bool? = nil, retrait: Bool = false) -> some View {
        HStack(spacing: Jetons.espace2) {
            if let chevron {
                Image(systemName: "chevron.right")
                    .font(Jetons.typoMicro.font).foregroundStyle(c.encre3.couleur)
                    .rotationEffect(.degrees(chevron ? 90 : 0))
            }
            RoundedRectangle(cornerRadius: Jetons.rayon0)
                .strokeBorder((choisie ? c.accentTexte : c.encre2).couleur, lineWidth: Jetons.epaisseurFocus)
                .frame(width: Jetons.diametreMini, height: Jetons.diametreMini)
            Text(titre).font(choisie ? Jetons.typoTitreCarte.font : Jetons.typoCorps.font)
                .foregroundStyle(c.encre.couleur).lineLimit(1).fixedSize()
            Spacer(minLength: 0)
            if let compte { Text(verbatim: "\(compte)").font(Jetons.typoMeta.font).foregroundStyle(c.encre3.couleur) }
        }
        .padding(.leading, retrait ? Jetons.espace5 + Jetons.espace1 : Jetons.espace2)
        .padding(.trailing, Jetons.espace2)
        .frame(minHeight: Jetons.hauteurCase)
        .background(choisie ? c.selection.couleur : .clear, in: .rect(cornerRadius: Jetons.rayon1))
    }
}

/// La grande carte (`.carte.grande`), à `espace-1` du bord : le titre et Créer, la tuile de mesure
/// (64 %, sa jauge, succès, alerte, erreur) et une vignette, trois lignes, un lien et un interrupteur.
private struct CarteDApercu: View {
    let c: Jetons.Couleurs
    let libelles: LibellesDuTheme

    var body: some View {
        VStack(alignment: .leading, spacing: Jetons.espace3) {
            HStack(spacing: Jetons.espace2) {
                Text(libelles.accueil).font(Jetons.typoSection.font).foregroundStyle(c.encre.couleur)
                Spacer(minLength: Jetons.espace2)
                Text(libelles.creer).font(Jetons.typoMeta.font).foregroundStyle(c.texteSurAccent.couleur).fixedSize()
                    .padding(.horizontal, Jetons.espace3).frame(minHeight: Jetons.hauteurCase)
                    .background(c.accent.couleur, in: .capsule)
            }
            // les deux tuiles côte à côte, l'une sous l'autre quand leurs mots n'y tiennent plus
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: Jetons.espace2) { tuiles }
                VStack(spacing: Jetons.espace2) { tuiles }
            }
            VStack(spacing: Jetons.epaisseurFocus) {
                LigneDApercu(texte: libelles.elementChoisi, choisie: true, fin: libelles.aujourdhui)
                LigneDApercu(texte: libelles.element, choisie: false, puce: libelles.etiquette)
                LigneDApercu(texte: libelles.elementFini, choisie: false, fin: libelles.hier, finie: true)
            }
            Spacer(minLength: 0)
            Rectangle().fill(c.filet.couleur).frame(height: Jetons.epaisseurFilet / 2)
            HStack {
                Text(libelles.lien).font(Jetons.typoCorps.font).foregroundStyle(c.accentTexte.couleur)
                Spacer(minLength: Jetons.espace2)
                Toggle(libelles.lien, isOn: .constant(true)).toggleStyle(.interrupteur).labelsHidden()
            }
        }
        .padding(Jetons.espace4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(c.plaque.couleur.opacity(Jetons.opacitePlaque), in: .rect(cornerRadius: Jetons.rayon2))
        .overlay { RoundedRectangle(cornerRadius: Jetons.rayon2).strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet / 2) }
        .padding(Jetons.espace1)
    }

    @ViewBuilder private var tuiles: some View {
        tuile {
            Text(libelles.progression).font(Jetons.typoMeta.font).foregroundStyle(c.encre2.couleur)
            Text(libelles.mesure).font(Jetons.typoSection.font).foregroundStyle(c.encre.couleur)
            JaugeDApercu(c: c)
            SemantiquesDApercu(c: c, libelles: libelles)
        }
        tuile {
            RoundedRectangle(cornerRadius: Jetons.rayon1)
                .fill(LinearGradient(colors: [c.selection.couleur, c.filet.couleur], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: Jetons.hauteurRangee)
            Text(libelles.vignette).font(Jetons.typoTitreCarte.font).foregroundStyle(c.encre.couleur).fixedSize()
            Text(libelles.sousTitre).font(Jetons.typoMeta.font).foregroundStyle(c.encre3.couleur).fixedSize()
        }
    }

    private func tuile<Contenu: View>(@ViewBuilder _ contenu: () -> Contenu) -> some View {
        VStack(alignment: .leading, spacing: Jetons.espace1, content: contenu)
            .padding(.horizontal, Jetons.espace3).padding(.vertical, Jetons.espace2)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(c.fondTeinte.couleur, in: .rect(cornerRadius: Jetons.rayon2))
            .overlay { RoundedRectangle(cornerRadius: Jetons.rayon2).strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet / 2) }
    }
}

/// La jauge de la tuile : sa piste, et la mesure en accent, toujours dans la tuile.
private struct JaugeDApercu: View {
    let c: Jetons.Couleurs

    var body: some View {
        GeometryReader { cadre in
            Capsule().fill(c.selection.couleur)
                .overlay(alignment: .leading) { Capsule().fill(c.accent.couleur).frame(width: cadre.size.width * Self.mesure) }
        }
        .frame(height: Jetons.hauteurPiste)
    }

    /// La mesure de l'aperçu, celle que dit son libellé (64 %).
    private static let mesure = 0.64
}

/// Succès, alerte, erreur, chacun son point : ils passent à la ligne plutôt que se serrer.
private struct SemantiquesDApercu: View {
    let c: Jetons.Couleurs
    let libelles: LibellesDuTheme

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Jetons.espace2) { contenu }
            VStack(alignment: .leading, spacing: 0) { contenu }
        }
    }

    @ViewBuilder private var contenu: some View {
        signe(libelles.succes, c.succes)
        signe(libelles.alerte, c.avertissement)
        signe(libelles.erreur, c.danger)
    }

    private func signe(_ texte: String, _ couleur: Jetons.RVB) -> some View {
        HStack(spacing: Jetons.espace1) {
            Circle().fill(couleur.couleur).frame(width: Jetons.espace2, height: Jetons.espace2)
            Text(texte)
        }
        .font(Jetons.typoMicro.font).foregroundStyle(couleur.couleur).fixedSize()
    }
}

/// Une ligne de liste (`.ligne`) : sa case, son texte, à droite une date ou une étiquette ; choisie,
/// le fond du choix ; finie, la case pleine et le texte barré. `point` : une action de la palette.
private struct LigneDApercu: View {
    let texte: String
    let choisie: Bool
    var fin: String?
    var puce: String?
    var finie = false
    var point: Jetons.RVB?
    @Environment(\.couleursSynseria) private var c

    var body: some View {
        HStack(spacing: Jetons.espace2) {
            if let point {
                Circle().fill(point.couleur).frame(width: Jetons.espace2, height: Jetons.espace2)
            } else if finie {
                Circle().fill(c.accent.couleur).frame(width: Jetons.diametreMini, height: Jetons.diametreMini)
            } else {
                Circle().strokeBorder(c.encre3.couleur, lineWidth: Jetons.epaisseurFocus).frame(width: Jetons.diametreMini, height: Jetons.diametreMini)
            }
            // à la ligne plutôt que tronqué
            Text(texte).font(Jetons.typoCorps.font).strikethrough(finie)
                .foregroundStyle((finie ? c.encre2 : c.encre).couleur)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Jetons.espace2)
            if let fin { Text(fin).font(Jetons.typoMeta.font).foregroundStyle(c.encre3.couleur).fixedSize() }
            if let puce {
                Text(puce).font(Jetons.typoMicro.font).foregroundStyle(c.accentTexte.couleur).fixedSize()
                    .padding(.horizontal, Jetons.espace2)
                    .background(c.selection.couleur, in: .capsule)
            }
        }
        .padding(.horizontal, Jetons.espace2)
        .frame(minHeight: Jetons.hauteurControle)
        .background(choisie ? c.selection.couleur : .clear, in: .rect(cornerRadius: Jetons.rayon1))
    }
}
#endif
