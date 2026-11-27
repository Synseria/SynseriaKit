// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
import SwiftUI

// La fenêtre de réglages commune aux apps : l'en-tête en verre et ses onglets (Général et Thème,
// puis ceux de l'app, en une rangée), le volet sur sa plaque, Réglages ▸ Général commun et la ligne de mise à
// jour, celle de Général comme celle d'À propos. Les données viennent de l'app, par valeurs et closures.

#if os(macOS)
import ServiceManagement

// MARK: - La fenêtre

/// Un onglet de la fenêtre commune : les communs, puis ceux de l'app, toujours dans cet ordre.
public enum OngletDesReglages<Propre: Hashable>: Hashable {
    case propre(Propre)
    case general
    case theme
}

/// La fenêtre AppKit des réglages : sans titre affiché (les onglets disent où l'on est ; le nom reste
/// pour le menu Fenêtre et VoiceOver), le contenu monte sous la barre de titre, la même taille pour
/// tous les onglets — une taille par onglet la redimensionnait à chaque changement. Le verre se pose
/// par `VerreDeLaFenetre.poser`, avec la teinte du thème de l'app.
@MainActor
public enum FenetreDeReglages {
    public static let taille = CGSize(width: Jetons.largeurReglages, height: Jetons.hauteurReglages)

    /// La fenêtre autour de `contenu` (un `NSHostingController` de `CadreDesReglages`, en
    /// `sizingOptions = []` : le volet suit la fenêtre, jamais l'inverse). Le délégué passe avant le
    /// contenu : SwiftUI demande la pile d'annulation dès qu'il entre dans la fenêtre.
    public static func batir(_ contenu: NSViewController, titre: String, delegue: NSWindowDelegate? = nil,
                             taille: CGSize = taille) -> NSWindow {
        let fenetre = NSWindow(contentRect: NSRect(origin: .zero, size: taille),
                               styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: true)
        fenetre.title = titre
        fenetre.titleVisibility = .hidden
        fenetre.titlebarAppearsTransparent = true
        fenetre.delegate = delegue
        fenetre.contentViewController = contenu
        fenetre.setContentSize(taille)
        return fenetre
    }

    /// `voulue` bornée à la place utile d'un écran (sans le Dock ni la barre des menus), barre de titre
    /// comprise : sur un petit écran, le bas passait sous le Dock.
    public static func taille(de fenetre: NSWindow, dans visible: NSRect, voulue: CGSize = taille) -> CGSize {
        let chrome = fenetre.frameRect(forContentRect: .zero).size
        return CGSize(width: min(voulue.width, visible.width - chrome.width), height: min(voulue.height, visible.height - chrome.height))
    }

    /// Le cadre retenu (`frameAutosaveName`) rend aussi une taille, peut-être d'un écran plus grand :
    /// la fenêtre reprend la sienne, son bord haut ne bouge pas, et elle tient dans la place utile.
    public static func garderLaTaille(de fenetre: NSWindow, dans visible: NSRect, voulue: CGSize = taille) {
        var cadre = fenetre.frameRect(forContentRect: NSRect(origin: .zero, size: taille(de: fenetre, dans: visible, voulue: voulue)))
        cadre.origin = NSPoint(x: fenetre.frame.minX, y: min(fenetre.frame.maxY, visible.maxY) - cadre.height)
        cadre.origin.y = max(cadre.minY, visible.minY)
        cadre.origin.x = min(max(cadre.minX, visible.minX), visible.maxX - cadre.width)
        guard cadre != fenetre.frame else { return }
        fenetre.setFrame(cadre, display: false)
    }
}

/// Le contenu de la fenêtre de réglages (`.sw`) : l'en-tête et ses onglets, puis le volet choisi sur
/// la plaque. Général et Thème d'abord, que la trousse nomme et range elle-même, puis les onglets de
/// l'app, en une seule rangée : ce qui vaut pour l'app entière ouvre la liste, comme sur macOS. Général se donne entier (`ReglagesGeneraux`), Thème est `ReglagesDuTheme` ; un
/// volet de l'app prend toute la plaque et règle sa largeur. Les mots sont ceux de la langue où l'app
/// s'affiche, qu'elle seule connaît (`LibellesDesReglages.langue(_:)`) : la trousse ne la devine pas.
public struct CadreDesReglages<Propre: Hashable, General: View, Volet: View>: View {
    public let propres: [BarreDesOnglets<Propre>.Onglet]
    @Binding public var selection: OngletDesReglages<Propre>
    @Binding public var theme: Jetons.Theme
    public var libelles: Jetons.LibellesDesReglages
    public var libellesDuTheme: LibellesDuTheme
    /// La largeur de Général, centré sur la plaque (`.sc` : `largeur-colonne` de l'app) : un
    /// formulaire serré lit mal étiré. Thème prend toute la largeur.
    public var colonne: CGFloat
    public let general: General
    public let volet: (Propre) -> Volet
    /// Les volets déjà ouverts, gardés : changer d'onglet ne les refait pas, chacun garde son
    /// défilement et son état ; un volet refait perdait son défilement sous le clic.
    @State private var ouverts: [OngletDesReglages<Propre>] = []

    public init(propres: [BarreDesOnglets<Propre>.Onglet], selection: Binding<OngletDesReglages<Propre>>,
                theme: Binding<Jetons.Theme>, libelles: Jetons.LibellesDesReglages,
                libellesDuTheme: LibellesDuTheme = LibellesDuTheme(), colonne: CGFloat,
                @ViewBuilder general: () -> General, @ViewBuilder volet: @escaping (Propre) -> Volet) {
        self.propres = propres
        self._selection = selection
        self._theme = theme
        self.libelles = libelles
        self.libellesDuTheme = libellesDuTheme
        self.colonne = colonne
        self.general = general()
        self.volet = volet
    }

    /// Les communs : leur nom, leur symbole et leur place ne se règlent pas.
    public static func communs(_ libelles: Jetons.LibellesDesReglages) -> [BarreDesOnglets<OngletDesReglages<Propre>>.Onglet] {
        [.init(valeur: .general, libelle: libelles.general, symbole: "list.bullet"),
         .init(valeur: .theme, libelle: libelles.theme, symbole: "sun.max")]
    }

    public var body: some View {
        VStack(spacing: 0) {
            EnTeteDesReglages {
                BarreDesOnglets(onglets: Self.communs(libelles)
                                    + propres.map { .init(valeur: .propre($0.valeur), libelle: $0.libelle, symbole: $0.symbole) },
                                selection: $selection)
            }
            contenu
                .font(Jetons.typoCorps.font)
                // Un bouton sans style à lui est le secondaire de la trousse, jamais celui du système.
                .buttonStyle(BoutonBorde())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(PlaqueDuVolet())
        }
        .hoteDesSuggestions()
        .ignoresSafeArea(.container, edges: .top)
    }

    /// Les volets gardés : ceux déjà ouverts, dans l'ordre d'ouverture, plus le choisi ; un onglet
    /// propre que l'app ne montre plus (un module coupé) est oublié.
    public static func gardes(_ ouverts: [OngletDesReglages<Propre>], choisi: OngletDesReglages<Propre>,
                              propres: [Propre]) -> [OngletDesReglages<Propre>] {
        (ouverts + (ouverts.contains(choisi) ? [] : [choisi])).filter {
            if case .propre(let propre) = $0 { return propres.contains(propre) }
            return true
        }
    }

    private var contenu: some View {
        let gardes = Self.gardes(ouverts, choisi: selection, propres: propres.map(\.valeur))
        return ZStack {
            ForEach(gardes, id: \.self) { onglet in
                let montre = onglet == selection
                // Caché, un volet reste bâti mais ne prend ni clic, ni focus, ni VoiceOver.
                volet(de: onglet)
                    .opacity(montre ? 1 : 0)
                    .allowsHitTesting(montre)
                    .disabled(!montre)
                    .accessibilityHidden(!montre)
            }
        }
        .onChange(of: gardes, initial: true) { _, nouveaux in ouverts = nouveaux }
    }

    @ViewBuilder private func volet(de onglet: OngletDesReglages<Propre>) -> some View {
        switch onglet {
        case .general: general.frame(maxWidth: colonne)
        case .theme: ReglagesDuTheme(theme: $theme, libelles: libellesDuTheme)
        case .propre(let propre): volet(propre)
        }
    }
}

/// L'en-tête des réglages (`.sw .bar`) : d'un bord à l'autre, barre de titre comprise, un verre plus
/// couvrant que la fenêtre (`verre-opacite-entete`) et un filet dessous ; les onglets dégagés des feux
/// (leur rangée et leurs écarts), centrés dans le reste. Le verre est toujours là ; plein seulement
/// quand le Mac le refuse.
private struct EnTeteDesReglages<Barre: View>: View {
    @ViewBuilder var barre: Barre
    @Environment(\.couleursSynseria) private var c

    /// Les trois feux, `espace-4` de chaque côté et `espace-2` entre eux.
    private static var feux: CGFloat { Jetons.espace4 * 2 + Jetons.diametreMini * 3 + Jetons.espace2 * 2 }

    var body: some View {
        let refuse = LisibiliteDuSysteme.shared.verreRefuse
        barre
            .padding(.leading, Self.feux)
            .padding(.trailing, Jetons.espace4)
            .background(c.fondFenetre.voile(refuse ? 1 : Jetons.verreOpaciteEntete).couleur)
            .overlay(alignment: .bottom) { Rectangle().fill(c.filet.couleur).frame(height: Jetons.epaisseurFilet) }
    }
}

/// La plaque d'un volet (`.sw .main`) : pleine (`opacite-plaque` sur le verre), bordée, `rayon-3`,
/// à `espace-2` de l'en-tête et des bords — le formulaire y met son air (`FormulaireCompact.marge`).
private struct PlaqueDuVolet: ViewModifier {
    @Environment(\.couleursSynseria) private var c

    func body(content: Content) -> some View {
        let forme = RoundedRectangle(cornerRadius: Jetons.rayon3, style: .circular)
        let refuse = LisibiliteDuSysteme.shared.verreRefuse
        content
            .scrollContentBackground(.hidden)
            .background(c.plaque.couleur.opacity(refuse ? 1 : Jetons.opacitePlaque))
            .clipShape(forme)
            .overlay { forme.strokeBorder(c.filet.couleur, lineWidth: Jetons.epaisseurFilet) }
            .padding(Jetons.espace2)
    }
}

// MARK: - Réglages ▸ Général

/// La langue de l'utilisateur, si l'app en a une à régler : nil, celle du système.
public struct LangueDesReglages {
    public var langue: Binding<String?>
    /// (code enregistré, libellé), dans l'ordre de la liste ; « Langue du système » vient en tête.
    public var langues: [(code: String, libelle: String)]
    /// Ce que la langue règle dans l'app (en infobulle).
    public var aide: String?

    public init(langue: Binding<String?>, langues: [(code: String, libelle: String)], aide: String? = nil) {
        self.langue = langue
        self.langues = langues
        self.aide = aide
    }
}

/// Le partage des statistiques d'utilisation (`Telemetrie` de SynseriaKit, côté app) et ce qui part,
/// tel quel.
public struct StatistiquesDesReglages {
    public var partager: Binding<Bool>
    public var dernierEnvoi: Date?
    /// Ce que l'app compte et ce qu'elle n'envoie jamais (en infobulle).
    public var aide: String?
    /// Le dernier rapport accepté, en JSON.
    public var dernierRapport: String?
    /// Le prochain envoi, en JSON, calculé à l'ouverture de « Voir les données ».
    public var prochainEnvoi: () -> String?

    public init(partager: Binding<Bool>, dernierEnvoi: Date?, aide: String? = nil, dernierRapport: String? = nil,
                prochainEnvoi: @escaping () -> String?) {
        self.partager = partager
        self.dernierEnvoi = dernierEnvoi
        self.aide = aide
        self.dernierRapport = dernierRapport
        self.prochainEnvoi = prochainEnvoi
    }
}

/// Où en est la mise à jour (`SuiviDeMiseAJour.Etat` de SynseriaKit, traduit par l'app).
public enum EtatDeLaMiseAJour: Equatable, Sendable {
    case repos
    case recherche
    case aJour
    case telechargement(version: String)
    /// Prête à poser : « Installer » relance ; ses notes (Markdown) derrière « Nouveautés ».
    case prete(version: String, notes: String)
    /// Un échec, ou une version que ce Mac ne peut pas prendre : les mots de l'app.
    case echec(String)

    public var occupee: Bool {
        switch self {
        case .recherche, .telechargement: true
        default: false
        }
    }
}

/// La mise à jour de l'app : son canal, sa version, son état et ses gestes.
public struct MiseAJourDesReglages {
    public var version: String
    public var beta: Binding<Bool>
    public var etat: EtatDeLaMiseAJour
    public var rechercher: () -> Void
    public var installer: () -> Void

    public init(version: String, beta: Binding<Bool>, etat: EtatDeLaMiseAJour,
                rechercher: @escaping () -> Void, installer: @escaping () -> Void) {
        self.version = version
        self.beta = beta
        self.etat = etat
        self.rechercher = rechercher
        self.installer = installer
    }
}

/// Réglages ▸ Général, commun : Ouvrir avec la session et Ma langue, puis ce que l'app ajoute
/// (`rangees` dans cette première section, `sections` après elle), puis Statistiques d'utilisation
/// et Mise à jour. Une section sans données (nil) n'est pas montrée.
public struct ReglagesGeneraux<Rangees: View, Sections: View>: View {
    public var nomDeLApp: String
    public var libelles: Jetons.LibellesDesReglages
    /// L'aide d'« Ouvrir avec la session » ; nil : la commune, au nom de l'app.
    public var aideDeLOuverture: String?
    public var langue: LangueDesReglages?
    public var statistiques: StatistiquesDesReglages?
    public var miseAJour: MiseAJourDesReglages?
    public let rangees: Rangees
    public let sections: Sections

    public init(nomDeLApp: String, libelles: Jetons.LibellesDesReglages, aideDeLOuverture: String? = nil,
                langue: LangueDesReglages? = nil, statistiques: StatistiquesDesReglages? = nil, miseAJour: MiseAJourDesReglages? = nil,
                @ViewBuilder rangees: () -> Rangees, @ViewBuilder sections: () -> Sections) {
        self.nomDeLApp = nomDeLApp
        self.libelles = libelles
        self.aideDeLOuverture = aideDeLOuverture
        self.langue = langue
        self.statistiques = statistiques
        self.miseAJour = miseAJour
        self.rangees = rangees()
        self.sections = sections()
    }

    public var body: some View {
        FormulaireCompact {
            SectionCompacte {
                RangeeDOuverture(libelles: libelles,
                                 aide: aideDeLOuverture ?? libelles.ouvertureAide.replacingOccurrences(of: "%@", with: nomDeLApp))
                if let langue {
                    RangeeReglage(titre: libelles.maLangue, aide: langue.aide) {
                        SelecteurEnListe(libelles.maLangue,
                                         selection: Binding(get: { langue.langue.wrappedValue ?? "" },
                                                            set: { langue.langue.wrappedValue = $0.isEmpty ? nil : $0 }),
                                         options: [("", libelles.langueDuSysteme)] + langue.langues.map { ($0.code, $0.libelle) },
                                         rechercher: libelles.rechercherUneLangue)
                    }
                }
                rangees
            }
            sections
            if let statistiques { SectionDesStatistiques(statistiques: statistiques, libelles: libelles) }
            if let miseAJour { SectionDeMiseAJour(miseAJour: miseAJour, libelles: libelles) }
        }
    }
}

extension ReglagesGeneraux where Rangees == EmptyView {
    public init(nomDeLApp: String, libelles: Jetons.LibellesDesReglages, aideDeLOuverture: String? = nil,
                langue: LangueDesReglages? = nil, statistiques: StatistiquesDesReglages? = nil, miseAJour: MiseAJourDesReglages? = nil,
                @ViewBuilder sections: () -> Sections) {
        self.init(nomDeLApp: nomDeLApp, libelles: libelles, aideDeLOuverture: aideDeLOuverture, langue: langue,
                  statistiques: statistiques, miseAJour: miseAJour, rangees: { EmptyView() }, sections: sections)
    }
}

extension ReglagesGeneraux where Rangees == EmptyView, Sections == EmptyView {
    public init(nomDeLApp: String, libelles: Jetons.LibellesDesReglages, aideDeLOuverture: String? = nil,
                langue: LangueDesReglages? = nil, statistiques: StatistiquesDesReglages? = nil, miseAJour: MiseAJourDesReglages? = nil) {
        self.init(nomDeLApp: nomDeLApp, libelles: libelles, aideDeLOuverture: aideDeLOuverture, langue: langue,
                  statistiques: statistiques, miseAJour: miseAJour, rangees: { EmptyView() }, sections: { EmptyView() })
    }
}

/// Ouvrir l'app avec la session. **Le système est la seule source** (`SMAppService`) : rien n'est
/// retenu dans les préférences, l'utilisateur peut le changer dans Réglages Système ▸ Général ▸
/// Ouverture — une copie à nous mentirait alors.
@MainActor
public enum OuvertureALaSession {
    public enum Etat: Equatable, Sendable {
        case inactive, active
        /// Inscrite, mais Réglages Système attendent l'accord de l'utilisateur.
        case aApprouver
    }

    /// Lu hors du fil principal : `status` est un aller-retour synchrone avec le gestionnaire de
    /// services, une vingtaine de millisecondes.
    public nonisolated static func lire() async -> Etat {
        await Task.detached { etat(SMAppService.mainApp.status) }.value
    }

    /// En attente d'approbation, l'interrupteur reste allumé : la demande est faite, seul l'accord
    /// manque. Introuvable (`.notFound`) vaut éteint.
    public nonisolated static func etat(_ statut: SMAppService.Status) -> Etat {
        switch statut {
        case .enabled: .active
        case .requiresApproval: .aApprouver
        default: .inactive
        }
    }

    /// Inscrit ou retire l'app et rend l'état relu au système. À approuver, Réglages Système
    /// s'ouvrent sur la liste : sans cet accord, l'inscription ne fait rien.
    public static func regler(active: Bool) async throws -> Etat {
        let nouveau = try await Task.detached {
            let service = SMAppService.mainApp
            if active { try service.register() } else { try service.unregister() }
            return etat(service.status)
        }.value
        if nouveau == .aApprouver { ouvrirReglagesSysteme() }
        return nouveau
    }

    public static func ouvrirReglagesSysteme() { SMAppService.openSystemSettingsLoginItems() }
}

/// « Ouvrir avec la session », relu au système à chaque apparition et au retour dans l'app (il se
/// change aussi dans Réglages Système). L'échec d'un réglage : un signe d'avertissement, le détail
/// en infobulle.
private struct RangeeDOuverture: View {
    let libelles: Jetons.LibellesDesReglages
    let aide: String
    @State private var etat = OuvertureALaSession.Etat.inactive
    @State private var erreur: String?
    @Environment(\.couleursSynseria) private var c

    var body: some View {
        RangeeReglage(titre: libelles.ouverture, aide: aide) {
            HStack(spacing: Jetons.espace2) {
                if let erreur {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(c.avertissement.couleur).help(erreur)
                }
                if etat == .aApprouver {
                    Button(libelles.autoriser) { OuvertureALaSession.ouvrirReglagesSysteme() }
                        .help(libelles.autoriserAide)
                }
                Toggle(libelles.ouverture, isOn: Binding(get: { etat != .inactive }, set: regler))
                    .toggleStyle(.interrupteur)
            }
        }
        .task { etat = await OuvertureALaSession.lire() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task { etat = await OuvertureALaSession.lire() }
        }
    }

    private func regler(_ active: Bool) {
        Task {
            do {
                etat = try await OuvertureALaSession.regler(active: active)
                erreur = nil
            } catch {
                erreur = error.localizedDescription
                etat = await OuvertureALaSession.lire()
            }
        }
    }
}

/// Statistiques d'utilisation : partager ou non ; partagées, la date du dernier envoi (« Jamais » :
/// la valeur, pas un sous-texte) et ce qui part.
private struct SectionDesStatistiques: View {
    let statistiques: StatistiquesDesReglages
    let libelles: Jetons.LibellesDesReglages
    @State private var donnees = false
    @Environment(\.couleursSynseria) private var c

    var body: some View {
        SectionCompacte(titre: libelles.statistiques) {
            RangeeReglage(titre: libelles.partager, aide: statistiques.aide) {
                Toggle(libelles.partager, isOn: statistiques.partager).toggleStyle(.interrupteur)
            }
            if statistiques.partager.wrappedValue {
                RangeeReglage(titre: libelles.dernierEnvoi) {
                    HStack(spacing: Jetons.espace2) {
                        Text(statistiques.dernierEnvoi.map { $0.formatted(date: .abbreviated, time: .shortened) } ?? libelles.jamais)
                            .font(Jetons.typoMeta.font)
                            .monospacedDigit()
                            .foregroundStyle(c.encre2.couleur)
                        Button(libelles.voirLesDonnees) { donnees = true }
                            .buttonStyle(BoutonBorde())
                            .popover(isPresented: $donnees, arrowEdge: .bottom) {
                                DonneesEnvoyees(prochain: statistiques.prochainEnvoi(), dernier: statistiques.dernierRapport, libelles: libelles)
                            }
                    }
                }
            }
        }
    }
}

/// Le JSON d'un envoi, tel qu'il part : le prochain ou le dernier accepté ; « Copier » dit « Copié »
/// le temps de le voir.
public struct DonneesEnvoyees: View {
    public let prochain: String?
    public let dernier: String?
    public var libelles: Jetons.LibellesDesReglages
    @State private var voirLeDernier = false
    @State private var copie = false
    @Environment(\.couleursSynseria) private var c

    public init(prochain: String?, dernier: String?, libelles: Jetons.LibellesDesReglages) {
        self.prochain = prochain
        self.dernier = dernier
        self.libelles = libelles
    }

    /// Un rapport d'une journée tient en largeur sans revenir à la ligne.
    private static var taille: CGSize { CGSize(width: Jetons.largeurFeuille * 1.4, height: Jetons.largeurFeuille * 1.05) }

    public var body: some View {
        let texte = voirLeDernier ? dernier : prochain
        VStack(alignment: .leading, spacing: Jetons.espace3) {
            HStack {
                SegmenteTexte(titre: libelles.voirLesDonnees,
                              options: [(false, libelles.prochainEnvoi), (true, libelles.dernierEnvoi)], selection: $voirLeDernier)
                    .fixedSize()
                Spacer()
                Button(copie ? libelles.copie : libelles.copier) { copier(texte) }
                    .buttonStyle(BoutonBorde())
                    .disabled(texte == nil)
            }
            ScrollView {
                Text(texte ?? libelles.rienAEnvoyer)
                    .font(Jetons.typoCode.font)
                    .foregroundStyle((texte == nil ? c.encre2 : c.encre).couleur)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Jetons.espace3)
            }
            .background(c.fondTeinte.couleur, in: .rect(cornerRadius: Jetons.rayon2, style: .circular))
        }
        .padding(Jetons.espace4)
        .frame(width: Self.taille.width, height: Self.taille.height)
    }

    private func copier(_ texte: String?) {
        guard let texte else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(texte, forType: .string)
        copie = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            copie = false
        }
    }
}

/// Mise à jour : le canal (Bêta propose aussi les préversions), puis la ligne de la version.
private struct SectionDeMiseAJour: View {
    let miseAJour: MiseAJourDesReglages
    let libelles: Jetons.LibellesDesReglages

    var body: some View {
        SectionCompacte(titre: libelles.miseAJour) {
            RangeeReglage(titre: libelles.canal, aide: libelles.canalAide) {
                SegmenteTexte(titre: libelles.canal, options: [(false, libelles.stable), (true, libelles.beta)], selection: miseAJour.beta)
            }
            LigneDeMiseAJour(miseAJour: miseAJour, libelles: libelles)
        }
    }
}

/// La version, l'état de la mise à jour et le geste qu'il appelle : en rangée dans Général (la
/// version en libellé, l'état et le geste à droite), en colonne centrée dans À propos (la version
/// entière, sélectionnable, « Rechercher » dessous). Une version prête dit ce qu'elle apporte
/// (« Nouveautés ») avant qu'on l'installe.
public struct LigneDeMiseAJour: View {
    public enum Disposition: Sendable { case rangee, colonne }

    public let miseAJour: MiseAJourDesReglages
    public var libelles: Jetons.LibellesDesReglages
    public var disposition: Disposition
    @State private var notesOuvertes = false
    @Environment(\.couleursSynseria) private var c

    public init(miseAJour: MiseAJourDesReglages, libelles: Jetons.LibellesDesReglages, disposition: Disposition = .rangee) {
        self.miseAJour = miseAJour
        self.libelles = libelles
        self.disposition = disposition
    }

    private var version: String { libelles.version.replacingOccurrences(of: "%@", with: miseAJour.version) }

    public var body: some View {
        switch disposition {
        case .rangee:
            HStack(spacing: Jetons.espace2) {
                Text(version).font(Jetons.typoCorps.font).foregroundStyle(c.encre.couleur)
                Spacer(minLength: Jetons.espace3)
                etat.lineLimit(2)
                gestes
            }
        case .colonne:
            VStack(spacing: Jetons.espace2) {
                Text(version)
                    .font(Jetons.typoMeta.font)
                    .foregroundStyle(c.encre2.couleur)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
                etat.multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                // L'un sous l'autre : côte à côte, « Nouveautés » et « Installer… » débordaient la colonne.
                VStack(spacing: Jetons.espace2) { gestes }
            }
        }
    }

    /// La roue pendant une recherche ou un téléchargement, sinon ce qu'il y a à dire, en méta.
    @ViewBuilder private var etat: some View {
        if miseAJour.etat.occupee { RoueDActivite().accessibilityLabel(libelles.rechercher) }
        if let message { Text(message).font(Jetons.typoMeta.font).foregroundStyle(c.encre2.couleur) }
    }

    private var message: String? {
        switch miseAJour.etat {
        case .aJour: libelles.aJour
        case .telechargement(let version): libelles.telechargement.replacingOccurrences(of: "%@", with: version)
        case .echec(let texte): texte
        case .repos, .recherche, .prete: nil
        }
    }

    @ViewBuilder private var gestes: some View {
        if case .prete(let version, let notes) = miseAJour.etat {
            if !notes.isEmpty {
                Button(libelles.nouveautes) { notesOuvertes = true }
                    .buttonStyle(BoutonBorde())
                    .popover(isPresented: $notesOuvertes, arrowEdge: .bottom) { NotesDeVersion(notes: notes) }
            }
            Button(libelles.installer.replacingOccurrences(of: "%@", with: version), action: miseAJour.installer)
                .buttonStyle(BoutonPrincipal())
        } else {
            Button(libelles.rechercher, action: miseAJour.rechercher)
                .buttonStyle(BoutonBorde())
                .disabled(miseAJour.etat.occupee)
        }
    }
}

/// Les notes d'une version prête, en lecture seule : le Markdown en ligne (gras, liens, code), les
/// lignes gardées.
private struct NotesDeVersion: View {
    let notes: String
    @Environment(\.couleursSynseria) private var c

    var body: some View {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ScrollView {
            Text((try? AttributedString(markdown: notes, options: options)) ?? AttributedString(notes))
                .font(Jetons.typoCorps.font)
                .foregroundStyle(c.encre.couleur)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Jetons.espace4)
        }
        .frame(width: Jetons.largeurFeuille * 1.05, height: Jetons.largeurNav * 1.6)
    }
}
#endif
