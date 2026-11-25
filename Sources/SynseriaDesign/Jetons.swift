// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
import SwiftUI

/// Les valeurs de design Synseria communes aux apps : toute couleur, taille ou durée
/// d'une vue vient d'ici, jamais d'un chiffre écrit dans la vue. Couleurs : `Nuancier.couleurs(thème, systemeSombre:)`.
public enum Jetons {
    public struct RVB: Sendable, Hashable {
        public let hex: UInt32
        public let opacite: Double
        public init(_ hex: UInt32, opacite: Double = 1) {
            self.hex = hex
            self.opacite = opacite
        }
        public func voile(_ opacite: Double) -> RVB { RVB(hex, opacite: opacite) }
        public var couleur: Color {
            Color(.sRGB, red: Double(hex >> 16 & 0xff) / 255, green: Double(hex >> 8 & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255, opacity: opacite)
        }
    }
    public enum Police: Sendable, Hashable { case ui, code }
    public struct Typo: Sendable, Hashable {
        public let graisse: Int
        public let taille: CGFloat
        public let interligne: CGFloat
        public let police: Police
        public var font: Font {
            let poids: Font.Weight = switch graisse {
            case 700: .bold
            case 600: .semibold
            case 500: .medium
            default: .regular
            }
            return .system(size: taille, weight: poids, design: police == .code ? .monospaced : .rounded)
        }
    }
    public struct Courbe: Sendable, Hashable {
        public let x1, y1, x2, y2: Double
        public func animation(_ duree: Double) -> Animation { .timingCurve(x1, y1, x2, y2, duration: duree) }
    }
    // MARK: Espacements
    /// écart entre une icône et son libellé, entre deux touches
    public static let espace1: CGFloat = 4
    /// marge d'une plaque dans la fenêtre, padding d'une rangée dans une carte
    public static let espace2: CGFloat = 8
    /// padding horizontal d'une rangée, écart entre éléments d'une ligne
    public static let espace3: CGFloat = 12
    /// gouttière de page, sous l'en-tête d'une page
    public static let espace4: CGFloat = 16
    /// entre deux blocs d'une page, padding d'une plaque
    public static let espace5: CGFloat = 24
    /// entre deux groupes d'une planche
    public static let espace6: CGFloat = 32
    /// entre deux sections, haut d'un flottant sous son ancre
    public static let espace7: CGFloat = 48

    // MARK: Typographie
    /// interface et titres (Rounded)
    public static let policeUi = Police.ui
    /// commandes, code, touches
    public static let policeCode = Police.code
    /// titre de page (« Lundi 16 novembre »)
    public static let typoTitrePage = Typo(graisse: 700, taille: 28, interligne: 32, police: .ui)
    /// titre de carte ou de section
    public static let typoSection = Typo(graisse: 600, taille: 17, interligne: 22, police: .ui)
    /// titre d'une fiche, d'un élément nommé
    public static let typoTitreCarte = Typo(graisse: 600, taille: 14, interligne: 20, police: .ui)
    /// texte courant, rangées, boutons
    public static let typoCorps = Typo(graisse: 400, taille: 14, interligne: 20, police: .ui)
    /// lecture longue (docs, overlay)
    public static let typoLecture = Typo(graisse: 400, taille: 15, interligne: 24, police: .ui)
    /// ligne secondaire sous un titre, compteurs
    public static let typoMeta = Typo(graisse: 400, taille: 12, interligne: 16, police: .ui)
    /// commande, bloc de code
    public static let typoCode = Typo(graisse: 400, taille: 13, interligne: 20, police: .code)
    /// touches, étiquettes, axes de graphique
    public static let typoMicro = Typo(graisse: 500, taille: 11, interligne: 16, police: .ui)

    // MARK: Rayons et filets
    /// touche, trou d'une commande, piste
    public static let rayon0: CGFloat = 4
    /// rangée compacte, menu, fond creux
    public static let rayon1: CGFloat = 8
    /// rangée, champ, fenêtre
    public static let rayon2: CGFloat = 12
    /// plaque, carte, flottant ; rayon intérieur = extérieur − padding
    public static let rayon3: CGFloat = 16
    /// bouton, sous-onglet, interrupteur
    public static let rayonPilule: CGFloat = 999
    /// bordure d'une plaque ou d'une carte, filet entre rangées
    public static let epaisseurFilet: CGFloat = 1
    /// anneau de focus au clavier
    public static let epaisseurFocus: CGFloat = 2
    /// écart de l'anneau de focus
    public static let decalageFocus: CGFloat = 2

    // MARK: Tailles
    /// rangée de liste, champ
    public static let hauteurRangee: CGFloat = 36
    /// bouton, onglet rond, sous-onglet
    public static let hauteurControle: CGFloat = 28
    /// interrupteur, badge, segment
    public static let hauteurCase: CGFloat = 24
    /// piste d'un curseur
    public static let hauteurPiste: CGFloat = 4
    /// case ronde d'une tâche, pouce d'interrupteur
    public static let diametreRond: CGFloat = 20
    /// feux de fenêtre, coche, punaise
    public static let diametreMini: CGFloat = 12
    /// pouce d'un curseur
    public static let diametrePouce: CGFloat = 16
    /// icône d'interface
    public static let tailleIcone: CGFloat = 16
    /// interrupteur
    public static let largeurInterrupteur: CGFloat = 48
    /// barre latérale ; base des petites largeurs (menus, listes)
    public static let largeurNav: CGFloat = 200
    /// feuille de confirmation ; borne de la liste d'un champ à suggestions
    public static let largeurFeuille: CGFloat = 400
    /// fenêtre À propos
    public static let largeurApropos: CGFloat = 340
    /// fenêtre des réglages
    public static let largeurReglages: CGFloat = 1120
    /// fenêtre des réglages : la même pour tous les onglets, Réglages ▸ Thème y tient sans défiler, en-tête compris
    public static let hauteurReglages: CGFloat = 710

    // MARK: Mouvement
    /// survol, pression
    public static let dureeRapide: Double = 0.12
    /// bascule, apparition
    public static let dureeNormale: Double = 0.2
    /// progression, changement de page
    public static let dureeLente: Double = 0.32
    /// caret, progression indéterminée (TimelineView dans l'app)
    public static let dureeBoucle: Double = 1.4
    /// un tour de l'indicateur d'activité
    public static let dureeTour: Double = 0.8
    /// par défaut
    public static let courbeStandard = Courbe(x1: 0.4, y1: 0, x2: 0.2, y2: 1)
    /// ce qui arrive (décélère)
    public static let courbeSortie = Courbe(x1: 0.2, y1: 0.8, x2: 0.2, y2: 1)
    /// ce qui s'en va (accélère)
    public static let courbeEntree = Courbe(x1: 0.4, y1: 0, x2: 1, y2: 1)

    // MARK: Verre et états
    /// part du fond de fenêtre dans le verre de ce qui prend le clavier (fenêtre, palette, overlay, panneau, bloc-notes), focus ou pas : le bureau flouté se voit presque en clair — valeur d'essai fixée à .05 d'après les essais de l'utilisateur (dans l'app, aucun texte ne se pose sur le verre)
    public static let verreOpaciteFocus: Double = 0.05
    /// verre de ce qui ne prend jamais le clavier (carte de réunion) — valeur d'essai fixée à .05 d'après les essais de l'utilisateur
    public static let verreOpaciteFlottant: Double = 0.05
    /// part du fond de fenêtre dans la barre d'une fenêtre (feux, onglets, recherche) : elle porte du texte, plus couvrante que le menu latéral — valeur d'essai
    public static let verreOpaciteBarre: Double = 0.4
    /// part du fond de fenêtre dans l'en-tête des réglages (onglets), d'un bord à l'autre : le verre y reste, plus couvrant que la barre ; plein seulement si le Mac refuse le verre
    public static let verreOpaciteEntete: Double = 0.72
    /// part du fond de fenêtre derrière la plaque, à droite du menu latéral (qui reste à verre-opacite-focus) — valeur d'essai
    public static let verreOpacitePage: Double = 0.2
    /// flou derrière le verre
    public static let verreFlou: CGFloat = 28
    /// contrôle désactivé
    public static let opaciteDesactive: Double = 0.4
    /// contrôle pressé : il rétrécit
    public static let echellePressee: Double = 0.97
    /// survol d'un contrôle neutre (bouton-icône, onglet rond) : l'encre en voile
    public static let voileSurvol: Double = 0.08
    /// pression d'un contrôle neutre : l'encre en voile
    public static let voilePression: Double = 0.14
    /// touche posée sur un plein : un voile de son texte
    public static let voileTouche: Double = 0.18
    /// piste d'un interrupteur éteint : l'encre mêlée à la plaque
    public static let pisteRepos: Double = 0.22
    /// piste d'un interrupteur éteint survolé
    public static let pisteSurvol: Double = 0.32
    /// opacité des plaques, cartes et blocs pleins posés sur le verre (1 = plein) — valeur choisie par l'utilisateur après essais
    public static let opacitePlaque: Double = 0.9
    /// opacité de tous les filets et bordures (fenêtres, overlay, palette, panneau), pilotée par cette seule variable globale ; purement esthétique : aucun texte n'est jamais posé sur une bordure
    public static let opaciteFilet: Double = 0.1
    /// filet d'un champ survolé : l'encre mêlée au filet
    public static let filetSurvol: Double = 0.35
}

extension Jetons {
    /// Les crans nommés du curseur de clarté.
    public enum CranDeClarte: String, CaseIterable, Sendable, Identifiable {
        case jour, crepuscule, penombre, nuit
        public var id: String { rawValue }
        public var nom: String {
            switch self {
            case .jour: "Jour"
            case .crepuscule: "Crépuscule"
            case .penombre: "Pénombre"
            case .nuit: "Nuit"
            }
        }
        public var position: Int {
            switch self {
            case .jour: 200
            case .crepuscule: 400
            case .penombre: 600
            case .nuit: 800
            }
        }
        /// La clarté par défaut en clair, et en sombre : celles que retient « Suivre le système ».
        public static let clair = CranDeClarte.jour
        public static let sombre = CranDeClarte.nuit
    }

    /// Les fonds nommés : les crans du curseur de fond, et les fonds accordés.
    public enum CranDeFond: String, CaseIterable, Sendable, Identifiable {
        case sable, ardoise
        public var id: String { rawValue }
        public var nom: String {
            switch self {
            case .sable: "Sable"
            case .ardoise: "Ardoise"
            }
        }
        public var teinte: Int {
            switch self {
            case .sable: 75
            case .ardoise: 255
            }
        }
    }

    /// La teinte de la marque, le cran nommé du curseur de couleur et la teinte par défaut.
    public enum Marque {
        public static let nom = "Synseria"
        public static let teinte = 260
    }

    /// Le thème de la marque, la clarté suivant le système : celui d'une racine qui n'a pas posé le sien.
    public static let themeDeLaMarque = Theme(teinte: 260, suivreLeSysteme: true)

    /// Les réglages du calcul des couleurs (`couleur.calcul` de jetons.json).
    public enum Parametres {
        public static let encreMarque = Octets(0x141A2B)
        public enum FondAccorde {
            public static let froid: [Double] = [130, 320]
            public static let sousUnFroid = CranDeFond.sable
            public static let sousUnChaud = CranDeFond.ardoise
        }
        public enum Migration {
            public static let themes: [String: Int] = ["cerise": 17, "terracotta": 36, "abricot": 50, "ambre": 75, "miel": 97, "sauge": 154, "lagon": 185, "bleuet": 254, "lilas": 296, "prune": 351, "graphite": 256]
            public static let fonds: [String: Int] = ["ardoise": 255, "lagune": 204, "sable": 75, "brique": 34, "graphite": 260]
            public static let nuances: [String: CranDeClarte] = ["jour": .jour, "crepuscule": .crepuscule, "penombre": .penombre, "nuit": .nuit]
            public static let chromaMin: Double = 0.02
        }
        /// Les curseurs de Réglages ▸ Thème.
        public enum Curseurs {
            public static let aimant: Double = 0.025
            public static let fond: [Double] = [0.85, 0.04]
            public static let pas: Double = 20
        }
        /// L'aperçu de Réglages ▸ Thème : le bureau derrière la fenêtre, le verre [clair, sombre].
        public enum Apercu {
            public static let degrade: [RVB] = [RVB(0x283A6B), RVB(0x7A4A8C), RVB(0xD9875B)]
            public static let taches: [(couleur: RVB, centre: [Double], rayon: [Double])] = [
                (RVB(0xFF8A5C), [0.18, 0.22], [0.14, 0.34]),
                (RVB(0x5AD1C6), [0.78, 0.3], [0.12, 0.32]),
                (RVB(0x8F7CFF), [0.52, 0.88], [0.16, 0.38]),
            ]
            public static let feux: [RVB] = [RVB(0xFF5F57), RVB(0xFEBC2E), RVB(0x28C840)]
            public static let page: [Double] = [0.65, 0.75]
            public static let barre: [Double] = [0.62, 0.7]
            public static let menu: [Double] = [0.42, 0.5]
            public static let overlay: Double = 0.8
            public static let canevas: [Double] = [560, 560]
            public static let zone: Double = 300
            public static let empilerSous: Double = 560
        }
        public enum Accent {
            public static let clarte: Double = 0.75
            public static let chroma: Double = 0.13
        }
        public enum Clarte {
            public static let ancres: [[Double]] = [[0, 1], [200, 0.965], [400, 0.875], [499, 0.86], [500, 0.34], [600, 0.31], [800, 0.22], [1000, 0]]
            public static let bascule: Double = 500
        }
        public enum Fond {
            public static let chroma: Double = 0.012
            public static let butee: Double = 0.002
            public static let etendueClair: Double = 0.14
            public static let etendueSombre: Double = 0.34
            public static let plancher: Double = 0.5
        }
        public enum Surfaces {
            public enum Clair {
                public static let plaque: [Double] = [0.035, 0.6]
                public static let fondTeinte: [Double] = [-0.035, 0.6]
                public static let filet: [Double] = [-0.12, 1]
            }
            public enum Sombre {
                public static let plaque: [Double] = [0.04, 0.8]
                public static let fondTeinte: [Double] = [0.08, 0.6]
                public static let filet: [Double] = [0.13, 1]
            }
        }
        public enum Encres {
            public enum Clair {
                public static let encre2: [Double] = [0.44, 0.015]
                public static let encre3: [Double] = [0.56, 0.015]
            }
            public enum Sombre {
                public static let encre: [Double] = [0.96, 0.006]
                public static let encre2: [Double] = [0.8, 0.015]
                public static let encre3: [Double] = [0.66, 0.015]
            }
        }
        public enum Semantiques {
            public static let chroma: Double = 0.16
            public static let clarte: [Double] = [0.55, 0.75]
            public static let danger: Double = 25
            public static let succes: Double = 150
            public static let avertissement: Double = 75
            public static let info: Double = 250
        }
        public static let pasClarte: Double = 0.01
        public enum Gamme {
            public static let tolerance: Double = 0.0001
            public static let reduction: Double = 0.9
            public static let essais: Double = 30
        }
        public static let tauxSelection: Double = 18
        public enum Choix {
            public static let depart: [Double] = [22, 26]
            public static let partSurvol: Double = 40
            public static let pas: Double = 2
            public static let max: Double = 40
            public static let contrasteChoixSurvol: Double = 1.1
            public static let contrasteSurvolFond: Double = 1.04
        }
        public static let creux: Double = 8
        public enum Seuils {
            public static let encre: Double = 7.3
            public static let encre2: Double = 4.8
            public static let encre3: Double = 3
            public static let filet: Double = 1.3
            public static let accentTexte: Double = 4.8
            public static let semantiques: Double = 4.8
            public static let texteSurAccent: Double = 4.6
            public static let texteSurAccentPlancher: Double = 4.5
            public static let texteSurEtat: Double = 4.5
            public static let texteSurVerre: Double = 3
        }
        public static let pasRenfort: Double = 0.05
        public static let pasTexteSurAccent: Double = 0.06
        public static let iterationsMax: Double = 80
        public static let texteFonce = Octets(0x0B0B0B)
        public static let pouceInterrupteur = Octets(0xFFFFFF)
        public enum Graphiques {
            public static let seuil: Double = 3
            public static let decalages: [[Double]] = [[0, 180, 60, 240, 120, 300], [0, 200, 100, 300, 50, 250], [0, 120, 240, 60, 180, 300], [0, 160, 320, 80, 240, 40]]
            public enum Clair {
                public static let saturation: Double = 64
                public static let clartes: [Double] = [0, 38, 52, 36, 50, 40]
            }
            public enum Sombre {
                public static let saturation: Double = 62
                public static let clartes: [Double] = [0, 76, 62, 78, 64, 74]
            }
            public static let sequentielle: [Double] = [0.16, 0.36, 0.56, 0.78, 1]
            public static let neutreDivergente: Double = 0.25
        }
        public enum Melanges {
            public static let accentSurvol: Double = 14
            public static let accentPresse: Double = 28
            public static let dangerSurvol: Double = 14
            public static let dangerPresse: Double = 28
        }
    }

    /// Les mots de Réglages ▸ Thème et de son aperçu, en français : ceux de la page de référence.
    public enum LibellesParDefaut {
        public static let systeme = "Système"
        public static let clarte = "Clarté"
        public static let couleur = "Couleur"
        public static let accorde = "Accordé"
        public static let fond = "Fond"
        public static let clair = "Clair"
        public static let sombre = "Sombre"
        public static let apercu = "Aperçu"
        public static let rechercher = "Rechercher"
        public static let accueil = "Accueil"
        public static let recents = "Récents"
        public static let collections = "Collections"
        public static let travail = "Travail"
        public static let projets = "Projets"
        public static let archives = "Archives"
        public static let personnel = "Personnel"
        public static let creer = "Créer"
        public static let progression = "Progression"
        public static let mesure = "64 %"
        public static let succes = "Succès"
        public static let alerte = "Alerte"
        public static let erreur = "Erreur"
        public static let vignette = "Titre de vignette"
        public static let sousTitre = "Sous-titre"
        public static let elementChoisi = "Élément sélectionné"
        public static let aujourdhui = "Aujourd’hui"
        public static let element = "Élément"
        public static let etiquette = "Étiquette"
        public static let elementFini = "Élément terminé"
        public static let hier = "Hier"
        public static let lien = "Lien d’accent"
        public static let actionChercher = "Rechercher une action"
        public static let actionChoisie = "Action sélectionnée"
        public static let actionAutre = "Autre action"
        public static let remplacer = "Remplacer"
        public static let copier = "Copier"
        public static let annuler = "Annuler"
    }

    /// Les mots de la fenêtre de réglages commune ; `%@` : le nom de l'app ou un numéro de version.
    public struct LibellesDesReglages: Sendable, Hashable {
        public var reglages: String
        public var aPropos: String
        public var general: String
        public var theme: String
        public var ouverture: String
        public var ouvertureAide: String
        public var autoriser: String
        public var autoriserAide: String
        public var maLangue: String
        public var langueDuSysteme: String
        public var rechercherUneLangue: String
        public var statistiques: String
        public var partager: String
        public var dernierEnvoi: String
        public var jamais: String
        public var voirLesDonnees: String
        public var prochainEnvoi: String
        public var rienAEnvoyer: String
        public var copier: String
        public var copie: String
        public var miseAJour: String
        public var canal: String
        public var canalAide: String
        public var stable: String
        public var beta: String
        public var version: String
        public var rechercher: String
        public var aJour: String
        public var telechargement: String
        public var nouveautes: String
        public var installer: String

        public init(reglages: String, aPropos: String, general: String, theme: String, ouverture: String, ouvertureAide: String, autoriser: String, autoriserAide: String, maLangue: String, langueDuSysteme: String, rechercherUneLangue: String, statistiques: String, partager: String, dernierEnvoi: String, jamais: String, voirLesDonnees: String, prochainEnvoi: String, rienAEnvoyer: String, copier: String, copie: String, miseAJour: String, canal: String, canalAide: String, stable: String, beta: String, version: String, rechercher: String, aJour: String, telechargement: String, nouveautes: String, installer: String) {
            self.reglages = reglages
            self.aPropos = aPropos
            self.general = general
            self.theme = theme
            self.ouverture = ouverture
            self.ouvertureAide = ouvertureAide
            self.autoriser = autoriser
            self.autoriserAide = autoriserAide
            self.maLangue = maLangue
            self.langueDuSysteme = langueDuSysteme
            self.rechercherUneLangue = rechercherUneLangue
            self.statistiques = statistiques
            self.partager = partager
            self.dernierEnvoi = dernierEnvoi
            self.jamais = jamais
            self.voirLesDonnees = voirLesDonnees
            self.prochainEnvoi = prochainEnvoi
            self.rienAEnvoyer = rienAEnvoyer
            self.copier = copier
            self.copie = copie
            self.miseAJour = miseAJour
            self.canal = canal
            self.canalAide = canalAide
            self.stable = stable
            self.beta = beta
            self.version = version
            self.rechercher = rechercher
            self.aJour = aJour
            self.telechargement = telechargement
            self.nouveautes = nouveautes
            self.installer = installer
        }

        public static let fr = LibellesDesReglages(reglages: "Réglages", aPropos: "À propos de %@", general: "Général", theme: "Thème", ouverture: "Ouvrir avec la session", ouvertureAide: "%@ s’ouvre avec ta session. Se règle aussi dans Réglages Système ▸ Général ▸ Ouverture.", autoriser: "Autoriser", autoriserAide: "macOS attend ton accord dans Réglages Système ▸ Général ▸ Ouverture.", maLangue: "Ma langue", langueDuSysteme: "Langue du système", rechercherUneLangue: "Rechercher", statistiques: "Statistiques d’utilisation", partager: "Partager les statistiques d’utilisation", dernierEnvoi: "Dernier envoi", jamais: "Jamais", voirLesDonnees: "Voir les données", prochainEnvoi: "Prochain envoi", rienAEnvoyer: "Rien à envoyer", copier: "Copier", copie: "Copié", miseAJour: "Mise à jour", canal: "Canal", canalAide: "Bêta propose aussi les versions préliminaires.", stable: "Stable", beta: "Bêta", version: "Version %@", rechercher: "Rechercher", aJour: "À jour", telechargement: "Téléchargement de la version %@…", nouveautes: "Nouveautés", installer: "Installer %@ et relancer")
        public static let en = LibellesDesReglages(reglages: "Settings", aPropos: "About %@", general: "General", theme: "Theme", ouverture: "Open at login", ouvertureAide: "%@ opens when you log in. Also set in System Settings ▸ General ▸ Login Items.", autoriser: "Allow", autoriserAide: "macOS is waiting for your approval in System Settings ▸ General ▸ Login Items.", maLangue: "My language", langueDuSysteme: "System language", rechercherUneLangue: "Search", statistiques: "Usage statistics", partager: "Share usage statistics", dernierEnvoi: "Last sent", jamais: "Never", voirLesDonnees: "View data", prochainEnvoi: "Next report", rienAEnvoyer: "Nothing to send", copier: "Copy", copie: "Copied", miseAJour: "Updates", canal: "Channel", canalAide: "Beta also offers pre-release versions.", stable: "Stable", beta: "Beta", version: "Version %@", rechercher: "Check", aJour: "Up to date", telechargement: "Downloading version %@…", nouveautes: "What’s New", installer: "Install %@ and relaunch")

        /// Ceux d'une langue (« en », « en-GB », « fr »…) ; le français pour une langue qu'ils n'ont pas.
        public static func langue(_ code: String) -> LibellesDesReglages {
            switch code.prefix(2) {
            case "en": .en
            default: .fr
            }
        }
    }
}

// Le calcul des couleurs de modele/couleur.js, porté pas à pas : chaque mélange revient à l'octet
// comme dans la page, sinon un seuil bascule d'un cran. Aucun réglage ici : tous viennent de
// `Parametres` (jetons.json). outils/test_swift.py compare ce calcul à la page, rôle par rôle.

extension Jetons {
    /// Le thème enregistré : la teinte de l'accent, le fond (accordé ou d'une teinte libre) et la
    /// clarté, une seule ou, pour suivre le système, une claire et une sombre retenues.
    public struct Theme: Hashable, Sendable, Codable {
        /// En degrés, 0…359.
        public var teinte: Int
        public var fond: Fond
        public var suivreLeSysteme: Bool
        /// Position du curseur de clarté, 0…1000 ; dès `Parametres.Clarte.bascule`, l'apparence est sombre.
        public var clarte: Int
        public var clarteClaire: Int
        public var clarteSombre: Int

        public init(teinte: Int = Marque.teinte, fond: Fond = .accorde, suivreLeSysteme: Bool = true,
             clarte: Int = CranDeClarte.clair.position,
             clarteClaire: Int = CranDeClarte.clair.position, clarteSombre: Int = CranDeClarte.sombre.position) {
            (self.teinte, self.fond, self.suivreLeSysteme) = (teinte, fond, suivreLeSysteme)
            (self.clarte, self.clarteClaire, self.clarteSombre) = (clarte, clarteClaire, clarteSombre)
        }

        /// La teinte du fond appliqué : l'accordée à la teinte, sinon la choisie.
        public var teinteDuFond: Int {
            if case .teinte(let t) = fond { t } else { Nuancier.fondAccorde(teinte) }
        }

        /// La clarté dessinée : avec le système, celle de son apparence.
        public func clarte(systemeSombre: Bool) -> Int {
            suivreLeSysteme ? (systemeSombre ? clarteSombre : clarteClaire) : clarte
        }

        /// L'apparence que l'app impose à ses fenêtres (`NSAppearance`) : nil quand elle suit le système.
        public var sombreImpose: Bool? { suivreLeSysteme ? nil : Nuancier.estSombre(clarte) }

        /// Ce que règle le curseur de clarté : avec le système, la moitié de son apparence seulement.
        public func bornes(systemeSombre: Bool) -> ClosedRange<Int> {
            let b = Int(Parametres.Clarte.bascule), fin = Nuancier.finDeLaClarte
            return !suivreLeSysteme ? 0...fin : systemeSombre ? b...fin : 0...(b - 1)
        }

        /// Pose la clarté réglée au curseur, bornée, là où elle se retient.
        public mutating func poserClarte(_ position: Int, systemeSombre: Bool) {
            let b = bornes(systemeSombre: systemeSombre), p = min(b.upperBound, max(b.lowerBound, position))
            if !suivreLeSysteme { clarte = p } else if systemeSombre { clarteSombre = p } else { clarteClaire = p }
        }
    }

    /// Le fond : accordé à la teinte de l'accent (de température opposée), ou d'une teinte libre.
    public enum Fond: Hashable, Sendable, Codable {
        case accorde
        case teinte(Int)
    }

    /// Les couleurs d'un point du continu, nommées par leur rôle (`couleur.roles` de jetons.json).
    public struct Couleurs: Hashable, Sendable {
        public let fondFenetre, plaque, filet, encre, encre2, encre3: RVB
        public let accent, texteSurAccent, accentTexte, fondTeinte: RVB
        public let danger, texteSurDanger, succes, avertissement, info, creux: RVB
        /// Survol et pression d'un plein : mêlés de l'encre ou du fond, celui qui s'écarte de son texte.
        public let accentSurvol, accentPresse, dangerSurvol, dangerPresse: RVB
        /// Le choix : sa teinte, sa part et celle du survol (en %).
        public let teinteChoix: RVB
        public let partChoix, partSurvol: Double
        /// Encres claires sur fond sombre : les contrôles du système se dessinent sombres.
        public let sombre: Bool

        public init(fondFenetre: RVB, plaque: RVB, filet: RVB, encre: RVB, encre2: RVB, encre3: RVB, accent: RVB, texteSurAccent: RVB, accentTexte: RVB, fondTeinte: RVB, danger: RVB, texteSurDanger: RVB, succes: RVB, avertissement: RVB, info: RVB, creux: RVB, accentSurvol: RVB, accentPresse: RVB, dangerSurvol: RVB, dangerPresse: RVB, teinteChoix: RVB, partChoix: Double, partSurvol: Double, sombre: Bool) {
            self.fondFenetre = fondFenetre
            self.plaque = plaque
            self.filet = filet
            self.encre = encre
            self.encre2 = encre2
            self.encre3 = encre3
            self.accent = accent
            self.texteSurAccent = texteSurAccent
            self.accentTexte = accentTexte
            self.fondTeinte = fondTeinte
            self.danger = danger
            self.texteSurDanger = texteSurDanger
            self.succes = succes
            self.avertissement = avertissement
            self.info = info
            self.creux = creux
            self.accentSurvol = accentSurvol
            self.accentPresse = accentPresse
            self.dangerSurvol = dangerSurvol
            self.dangerPresse = dangerPresse
            self.teinteChoix = teinteChoix
            self.partChoix = partChoix
            self.partSurvol = partSurvol
            self.sombre = sombre
        }

        /// Une carte a le fond de la plaque : elle s'en distingue par son filet.
        public var carte: RVB { plaque }
        public var selection: RVB { teinteChoix.voile(partChoix / 100) }
        public var survol: RVB { teinteChoix.voile(partSurvol / 100) }
    }

    /// Les palettes de données d'un point : catégorielle (distincte en protanopie et deutéranopie),
    /// séquentielle (plaque → première catégorie), divergente (danger → succès).
    public struct Graphiques: Hashable, Sendable {
        public let categorielle, sequentielle, divergente: [RVB]
        /// Le pire contraste d'une catégorie sur la plaque, et l'écart (ΔE OKLab × 100) entre voisines.
        public let contraste, ecartNormal, ecartDaltonien: Double

        public init(categorielle: [RVB], sequentielle: [RVB], divergente: [RVB], contraste: Double, ecartNormal: Double, ecartDaltonien: Double) {
            self.categorielle = categorielle
            self.sequentielle = sequentielle
            self.divergente = divergente
            self.contraste = contraste
            self.ecartNormal = ecartNormal
            self.ecartDaltonien = ecartDaltonien
        }
    }

    public enum Nuancier {
        public static func couleurs(_ theme: Theme, systemeSombre: Bool) -> Couleurs {
            couleurs(teinte: theme.teinte, fond: theme.teinteDuFond, clarte: theme.clarte(systemeSombre: systemeSombre))
        }

        public static func graphiques(_ theme: Theme, systemeSombre: Bool) -> Graphiques {
            graphiques(teinte: theme.teinte, fond: theme.teinteDuFond, clarte: theme.clarte(systemeSombre: systemeSombre))
        }

        /// Un point du continu : la teinte de l'accent et celle du fond (degrés), la clarté (0…1000).
        public static func couleurs(teinte: Int, fond: Int, clarte: Int) -> Couleurs {
            let v = valeurs(teinte: teinte, fond: fond, clarte: clarte)
            return Couleurs(
                fondFenetre: v.fondFenetre.rvb, plaque: v.plaque.rvb, filet: v.filet.rvb, encre: v.encre.rvb,
                encre2: v.encre2.rvb, encre3: v.encre3.rvb, accent: v.accent.rvb, texteSurAccent: v.texteSurAccent.rvb,
                accentTexte: v.accentTexte.rvb, fondTeinte: v.fondTeinte.rvb, danger: v.danger.rvb,
                texteSurDanger: v.texteSurDanger.rvb, succes: v.succes.rvb, avertissement: v.avertissement.rvb, info: v.info.rvb,
                creux: v.creux.rvb, accentSurvol: v.accentSurvol.rvb, accentPresse: v.accentPresse.rvb,
                dangerSurvol: v.dangerSurvol.rvb, dangerPresse: v.dangerPresse.rvb, teinteChoix: v.teinteChoix.rvb,
                partChoix: v.partChoix, partSurvol: v.partSurvol, sombre: estSombre(clarte))
        }

        public static func graphiques(teinte: Int, fond: Int, clarte: Int) -> Graphiques {
            graphiques(valeurs(teinte: teinte, fond: fond, clarte: clarte), clair: !estSombre(clarte))
        }

        // MARK: - La clarté et le fond

        public static func estSombre(_ clarte: Int) -> Bool { Double(clarte) >= Parametres.Clarte.bascule }

        /// La dernière position du curseur, celle de la dernière ancre.
        public static var finDeLaClarte: Int { Int(Parametres.Clarte.ancres[Parametres.Clarte.ancres.count - 1][0]) }

        /// Position du curseur → clarté OKLCH du fond, par ancres.
        public static func clarteDuFond(_ clarte: Int) -> Double {
            let A = Parametres.Clarte.ancres, c = Double(clarte)
            for i in 1..<A.count where c <= A[i][0] {
                let (a, b) = (A[i - 1], A[i])
                return a[1] + (b[1] - a[1]) * ((c - a[0]) / (b[0] - a[0]))
            }
            return A[A.count - 1][1]
        }

        /// La chroma du fond : nulle aux butées blanche et noire, au plancher près d'elles, pleine au-delà.
        public static func chromaDuFond(_ lb: Double, sombre: Bool) -> Double {
            typealias F = Parametres.Fond
            if sombre { return lb < F.butee ? 0 : F.chroma * (F.plancher + (1 - F.plancher) * lb / F.etendueSombre) }
            return lb > 1 - F.butee ? 0 : F.chroma * (F.plancher + (1 - F.plancher) * min(1, (1 - lb) / F.etendueClair))
        }

        /// Le fond de fenêtre seul : le dégradé du curseur de clarté.
        public static func fondDeFenetre(fond: Int, clarte: Int) -> Octets {
            let lb = clarteDuFond(clarte)
            return Oklch.couleur(lb, chromaDuFond(lb, sombre: estSombre(clarte)), Double(fond))
        }

        /// L'accent d'une teinte, avant les seuils : le dégradé du curseur de couleur.
        public static func accent(_ teinte: Int) -> Octets {
            Oklch.couleur(Parametres.Accent.clarte, Parametres.Accent.chroma, Double(teinte))
        }

        /// Le fond de température opposée à l'accent.
        public static func fondAccorde(_ teinte: Int) -> Int {
            typealias F = Parametres.FondAccorde
            let t = Double(teinte)
            return (t >= F.froid[0] && t < F.froid[1] ? F.sousUnFroid : F.sousUnChaud).teinte
        }

        /// Le cran le plus proche à moins de l'aimant (le premier à égalité), sinon la position elle-même.
        public static func aimanter(_ position: Int, _ crans: [Int], aimant: Int) -> Int {
            var pres: Int?
            for c in crans where abs(c - position) < aimant && (pres.map { abs(c - position) < abs($0 - position) } ?? true) {
                pres = c
            }
            return pres ?? position
        }

        // MARK: - L'ancien réglage

        /// L'ancien réglage (onze coloris ou Personnalisé, quatre nuances, fonds nommés ou libres) → le
        /// thème. `coloris` : le nom écrit d'un coloris (« abricot »), nil pour Personnalisé à
        /// `personnalise` ; `nuance` : « penombre », nil pour suivre le système ; `fond` : un fond nommé
        /// (« ardoise ») ou « #RRGGBB », nil pour celui du thème. Ce qui ne se lit pas garde le défaut.
        public static func migrer(coloris: String?, personnalise: UInt32?, nuance: String?, fond: String?) -> Theme {
            typealias M = Parametres.Migration
            var theme = Theme()
            if let coloris {
                if let t = M.themes[coloris] { theme.teinte = t }
            } else if let personnalise, let t = teinteDe(Octets(personnalise)) {
                theme.teinte = t
            }
            if let fond {
                let t = fond.hasPrefix("#") ? UInt32(fond.dropFirst(), radix: 16).flatMap { teinteDe(Octets($0)) } : M.fonds[fond]
                if let t { theme.fond = .teinte(t) }
            }
            if let nuance, let cran = M.nuances[nuance] {
                (theme.suivreLeSysteme, theme.clarte) = (false, cran.position)
            }
            return theme
        }

        /// La teinte OKLCH d'une couleur en degrés entiers ; nil sans chroma (un gris n'en a pas).
        public static func teinteDe(_ o: Octets) -> Int? {
            let (_, c, h) = Oklch.depuis(o)
            return c < Parametres.Migration.chromaMin ? nil : Int((h + 0.5).rounded(.down)) % 360
        }

        // MARK: - Les formules de la page

        /// Les rôles en cours de calcul.
        public struct Valeurs {
            public var fondFenetre, plaque, filet, fondTeinte: Octets
            public var encre = Octets.noir, encre2 = Octets.noir, encre3 = Octets.noir
            public var accent = Octets.noir, texteSurAccent = Octets.noir, accentTexte = Octets.noir
            public var danger = Octets.noir, succes = Octets.noir, avertissement = Octets.noir, info = Octets.noir
            public var texteSurDanger = Octets.noir, creux = Octets.noir, teinteChoix = Octets.noir
            public var accentSurvol = Octets.noir, accentPresse = Octets.noir, dangerSurvol = Octets.noir, dangerPresse = Octets.noir
            public var partChoix = 0.0, partSurvol = 0.0

            public init(fondFenetre: Octets, plaque: Octets, filet: Octets, fondTeinte: Octets) {
                (self.fondFenetre, self.plaque, self.filet, self.fondTeinte) = (fondFenetre, plaque, filet, fondTeinte)
            }

            public var surfaces: [Octets] { [fondFenetre, plaque, fondTeinte] }
            public var selections: [Octets] {
                [plaque, fondTeinte, fondFenetre].map { Octets.melange($0, accent, Parametres.tauxSelection / 100) }
            }
            /// Le fond d'une rangée choisie, sur la fenêtre et sur la plaque.
            public var choisis: [Octets] { [fondFenetre, plaque].map { Octets.melange($0, teinteChoix, partChoix / 100) } }
        }

        /// Surfaces et encres en OKLCH à la teinte du fond et à la clarté ; l'accent à sa teinte ; puis
        /// `finir` tient les seuils.
        public static func valeurs(teinte: Int, fond: Int, clarte: Int) -> Valeurs {
            let sombre = estSombre(clarte), lb = clarteDuFond(clarte), cf = chromaDuFond(lb, sombre: sombre)
            let h = Double(fond), i = sombre ? 1 : 0
            typealias A = Parametres.Accent
            typealias M = Parametres.Semantiques
            typealias S = Parametres.Seuils
            func surface(_ k: [Double]) -> Octets { Oklch.couleur(lb + k[0], cf * k[1], h) }
            let (plaque, fondTeinte, filet) = sombre
                ? (Parametres.Surfaces.Sombre.plaque, Parametres.Surfaces.Sombre.fondTeinte, Parametres.Surfaces.Sombre.filet)
                : (Parametres.Surfaces.Clair.plaque, Parametres.Surfaces.Clair.fondTeinte, Parametres.Surfaces.Clair.filet)
            var v = Valeurs(fondFenetre: fondDeFenetre(fond: fond, clarte: clarte), plaque: surface(plaque), filet: surface(filet), fondTeinte: surface(fondTeinte))
            let fonds = v.surfaces
            let (encre2, encre3) = sombre
                ? (Parametres.Encres.Sombre.encre2, Parametres.Encres.Sombre.encre3)
                : (Parametres.Encres.Clair.encre2, Parametres.Encres.Clair.encre3)
            v.encre = sombre ? Oklch.couleur(Parametres.Encres.Sombre.encre[0], Parametres.Encres.Sombre.encre[1], h) : Parametres.encreMarque
            v.encre2 = atteindre(encre2[0], encre2[1], h, fonds, S.encre2, sombre: sombre)
            v.encre3 = atteindre(encre3[0], encre3[1], h, fonds, S.encre3, sombre: sombre)
            v.accent = accent(teinte)
            v.texteSurAccent = Octets.contraste(Parametres.encreMarque, v.accent) >= Octets.contraste(.blanc, v.accent)
                ? Parametres.encreMarque : .blanc
            v.accentTexte = atteindre(A.clarte, A.chroma, Double(teinte), fonds, S.accentTexte, sombre: sombre)
            func semantique(_ t: Double) -> Octets { atteindre(M.clarte[i], M.chroma, t, fonds, S.semantiques, sombre: sombre) }
            (v.danger, v.succes, v.avertissement, v.info) = (semantique(M.danger), semantique(M.succes), semantique(M.avertissement), semantique(M.info))
            return finir(v, clair: !sombre)
        }

        /// La clarté OKLCH monte (sombre) ou descend (clair) jusqu'au seuil sur tous les fonds : la teinte
        /// et la chroma restent, là où `renforcer` les délaverait.
        public static func atteindre(_ l: Double, _ c: Double, _ h: Double, _ fonds: [Octets], _ seuil: Double, sombre: Bool) -> Octets {
            var l = l, couleur = Oklch.couleur(l, c, h), n = 0.0
            while Octets.pire(couleur, fonds) < seuil, n < Parametres.iterationsMax {
                l += sombre ? Parametres.pasClarte : -Parametres.pasClarte
                couleur = Oklch.couleur(l, c, h)
                n += 1
            }
            return couleur
        }

        /// Le choix : en clair l'accent écrit (l'accent, clair, teint sans assombrir : près du
        /// Crépuscule, choix et survol se confondraient), en sombre l'accent ; sa part monte par pas
        /// jusqu'à ce que choix et survol se distinguent, et le survol du fond.
        public static func doserChoix(_ v: inout Valeurs, clair: Bool, depart: Double) {
            typealias X = Parametres.Choix
            let t = clair ? v.accentTexte : v.accent
            func distincts(_ p: Double) -> Bool {
                [v.fondFenetre, v.plaque].allSatisfy { f in
                    let choix = Octets.melange(f, t, p / 100), survol = Octets.melange(f, t, p / 100 * (X.partSurvol / 100))
                    return Octets.contraste(choix, survol) >= X.contrasteChoixSurvol && Octets.contraste(survol, f) >= X.contrasteSurvolFond
                }
            }
            var p = depart
            while !distincts(p), p < X.max { p += X.pas }
            (v.teinteChoix, v.partChoix, v.partSurvol) = (t, p, p * X.partSurvol / 100)
        }

        /// `finir` : chaque encre va vers le noir (clair) ou le blanc (sombre) jusqu'à son seuil.
        public static func finir(_ depart: Valeurs, clair: Bool) -> Valeurs {
            typealias S = Parametres.Seuils
            var v = depart
            doserChoix(&v, clair: clair, depart: Parametres.Choix.depart[clair ? 0 : 1])
            let vers = clair ? Octets.noir : Octets.blanc
            let fonds = v.surfaces, tous = fonds + v.selections
            v.encre = Octets.renforcer(v.encre, fonds, S.encre, vers: vers)
            // Le filet se voit encore sur la fenêtre et la plaque, jusqu'au noir et au blanc.
            v.filet = Octets.renforcer(v.filet, [v.fondFenetre, v.plaque], S.filet, vers: vers)
            v.encre2 = Octets.renforcer(v.encre2, tous, S.encre2, vers: vers)
            v.encre3 = Octets.renforcer(v.encre3, fonds, S.encre3, vers: vers)
            v.accentTexte = Octets.renforcer(Octets.renforcer(v.accentTexte, tous, S.accentTexte, vers: vers), v.choisis, S.accentTexte, vers: vers)
            v.danger = Octets.renforcer(v.danger, fonds, S.semantiques, vers: vers)
            v.succes = Octets.renforcer(v.succes, fonds, S.semantiques, vers: vers)
            v.avertissement = Octets.renforcer(v.avertissement, fonds, S.semantiques, vers: vers)
            v.info = Octets.renforcer(v.info, fonds, S.semantiques, vers: vers)
            let texte = Octets.contraste(.noir, v.accent) > Octets.contraste(.blanc, v.accent) ? Octets.noir : Octets.blanc
            var n = 0.0
            while Octets.contraste(v.texteSurAccent, v.accent) < S.texteSurAccent, n < Parametres.iterationsMax {
                v.texteSurAccent = Octets.melange(v.texteSurAccent, texte, Parametres.pasTexteSurAccent)
                n += 1
            }
            // Un accent qui plafonne avec le noir comme avec le blanc s'écarte lui-même du texte.
            n = 0
            while Octets.contraste(v.texteSurAccent, v.accent) < S.texteSurAccentPlancher, n < Parametres.iterationsMax {
                v.accent = Octets.melange(v.accent, texte == .noir ? .blanc : .noir, Parametres.pasRenfort)
                n += 1
            }
            v.texteSurDanger = Octets.texteSur(v.danger)
            etats(&v)
            v.creux = Octets.melange(v.fondTeinte, v.encre, Parametres.creux / 100)
            return v
        }

        /// Survol et pression d'un plein (accent, danger) : il se mêle de l'encre ou du fond, celui qui
        /// s'écarte le plus de son texte. Vers l'encre seule, un accent clair au texte foncé
        /// s'assombrirait vers son propre texte, sous 4,5:1.
        public static func etats(_ v: inout Valeurs) {
            typealias M = Parametres.Melanges
            func pole(_ texte: Octets) -> Octets {
                Octets.contraste(v.encre, texte) >= Octets.contraste(v.fondFenetre, texte) ? v.encre : v.fondFenetre
            }
            let (a, d) = (pole(v.texteSurAccent), pole(v.texteSurDanger))
            v.accentSurvol = Octets.melange(v.accent, a, M.accentSurvol / 100)
            v.accentPresse = Octets.melange(v.accent, a, M.accentPresse / 100)
            v.dangerSurvol = Octets.melange(v.danger, d, M.dangerSurvol / 100)
            v.dangerPresse = Octets.melange(v.danger, d, M.dangerPresse / 100)
        }

        // MARK: - Graphiques

        public static func graphiques(_ v: Valeurs, clair: Bool) -> Graphiques {
            typealias G = Parametres.Graphiques
            let (saturation, clartes) = clair ? (G.Clair.saturation, G.Clair.clartes) : (G.Sombre.saturation, G.Sombre.clartes)
            let fonds = [v.plaque], vers = clair ? Octets.noir : Octets.blanc, h = v.accent.tsl.0
            var meilleur: (cat: [Octets], daltonien: Double, normal: Double)?
            for o in G.decalages {
                var c = [Octets.renforcer(v.accent, fonds, G.seuil, vers: vers)]
                for i in 1..<6 {
                    let teinte = (h + o[i]).truncatingRemainder(dividingBy: 360)
                    c.append(Octets.renforcer(Octets.tsl(teinte, saturation, clartes[i]), fonds, G.seuil, vers: vers))
                }
                var daltonien = 99.0, normal = 99.0
                for i in 0..<5 {
                    daltonien = min(daltonien, Oklab.ecart(c[i], c[i + 1], .deuteranopie), Oklab.ecart(c[i], c[i + 1], .protanopie))
                    normal = min(normal, Oklab.ecart(c[i], c[i + 1], nil))
                }
                if meilleur == nil || daltonien > meilleur!.daltonien { meilleur = (c, daltonien, normal) }
            }
            let m = meilleur!
            let neutre = Octets.melange(v.plaque, v.encre2, G.neutreDivergente)
            return Graphiques(
                categorielle: m.cat.map(\.rvb),
                sequentielle: G.sequentielle.map { Octets.melange(v.plaque, m.cat[0], $0).rvb },
                divergente: [v.danger, Octets.melange(v.danger, neutre, 0.5), neutre, Octets.melange(v.succes, neutre, 0.5), v.succes].map(\.rvb),
                contraste: m.cat.map { Octets.contraste($0, v.plaque) }.min() ?? 0,
                ecartNormal: m.normal, ecartDaltonien: m.daltonien)
        }
    }

    /// OKLab, et la simulation des daltonismes (Machado 2009, sévérité 1), pour l'écart des catégories.
    public enum Oklab {
        public enum Vision { case deuteranopie, protanopie }

        public static func ecart(_ a: Octets, _ b: Octets, _ vision: Vision?) -> Double {
            let x = lab(a, vision), y = lab(b, vision)
            return 100 * ((x[0] - y[0]) * (x[0] - y[0]) + (x[1] - y[1]) * (x[1] - y[1]) + (x[2] - y[2]) * (x[2] - y[2])).squareRoot()
        }

        public static func lab(_ o: Octets, _ vision: Vision?) -> [Double] {
            func lineaire(_ x: Int) -> Double {
                let v = Double(x) / 255
                return v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
            }
            var c = [lineaire(o.r), lineaire(o.v), lineaire(o.b)]
            if let vision {
                let m = vision == .deuteranopie
                    ? [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.01182, 0.04294, 0.968881]]
                    : [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]]
                c = m.map { $0[0] * c[0] + $0[1] * c[1] + $0[2] * c[2] }
            }
            c = c.map { max(0, min(1, $0)) }
            let l = cbrt(0.4122214708 * c[0] + 0.5363325363 * c[1] + 0.0514459929 * c[2])
            let m = cbrt(0.2119034982 * c[0] + 0.6806995451 * c[1] + 0.1073969566 * c[2])
            let s = cbrt(0.0883024619 * c[0] + 0.2817188376 * c[1] + 0.6299787005 * c[2])
            return [0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s,
                    1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s,
                    0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s]
        }
    }

    /// OKLCH ↔ sRVB comme la page : les cubes en produits, la chroma qui recule hors de la gamme et
    /// s'annule au blanc et au noir.
    public enum Oklch {
        public static func couleur(_ l: Double, _ c: Double, _ h: Double) -> Octets {
            typealias G = Parametres.Gamme
            let l = max(0, min(1, l))
            var c = l <= 0 || l >= 1 ? 0 : c
            for _ in 0..<Int(G.essais) {
                let x = brut(l, c, h)
                if x.allSatisfy({ $0 >= -G.tolerance && $0 <= 1 + G.tolerance }) { return octets(x) }
                c *= G.reduction
            }
            return octets(brut(l, 0, h))
        }

        /// sRVB linéaire, hors gamme compris.
        public static func brut(_ clarte: Double, _ c: Double, _ h: Double) -> [Double] {
            let a = c * cos(h * Double.pi / 180), b = c * sin(h * Double.pi / 180)
            var l = clarte + 0.3963377774 * a + 0.2158037573 * b
            var m = clarte - 0.1055613458 * a - 0.0638541728 * b
            var s = clarte - 0.0894841775 * a - 1.291485548 * b
            (l, m, s) = (l * l * l, m * m * m, s * s * s)
            return [4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
                    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
                    -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s]
        }

        public static func octets(_ x: [Double]) -> Octets {
            func gamma(_ v: Double) -> Double { 255 * (v <= 0.0031308 ? 12.92 * v : 1.055 * pow(v, 1 / 2.4) - 0.055) }
            return Octets(gamma(x[0]), gamma(x[1]), gamma(x[2]))
        }

        /// Clarté, chroma et teinte (degrés) d'une couleur.
        public static func depuis(_ o: Octets) -> (Double, Double, Double) {
            let lab = Oklab.lab(o, nil)
            return (lab[0], (lab[1] * lab[1] + lab[2] * lab[2]).squareRoot(),
                    (atan2(lab[2], lab[1]) * 180 / Double.pi + 360).truncatingRemainder(dividingBy: 360))
        }
    }

    /// Une couleur à l'octet, comme les `#RRGGBB` de la page : chaque opération y revient.
    public struct Octets: Hashable, Sendable {
        public let r, v, b: Int

        public static let noir = Octets(0x000000)
        public static let blanc = Octets(0xFFFFFF)

        public init(_ hex: UInt32) {
            (r, v, b) = (Int(hex >> 16 & 0xFF), Int(hex >> 8 & 0xFF), Int(hex & 0xFF))
        }

        /// Borné puis arrondi comme `Math.round`.
        public init(_ r: Double, _ v: Double, _ b: Double) {
            func octet(_ x: Double) -> Int { Int((max(0, min(255, x)) + 0.5).rounded(.down)) }
            (self.r, self.v, self.b) = (octet(r), octet(v), octet(b))
        }

        public var hex: UInt32 { UInt32(r) << 16 | UInt32(v) << 8 | UInt32(b) }
        public var rvb: RVB { RVB(hex) }

        public static func melange(_ a: Octets, _ b: Octets, _ t: Double) -> Octets {
            func m(_ x: Int, _ y: Int) -> Double { Double(x) + Double(y - x) * t }
            return Octets(m(a.r, b.r), m(a.v, b.v), m(a.b, b.b))
        }

        /// La luminance relative de WCAG, au seuil de la page (0,03928).
        public var luminance: Double {
            func lineaire(_ c: Int) -> Double {
                let x = Double(c) / 255
                return x <= 0.03928 ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * lineaire(r) + 0.7152 * lineaire(v) + 0.0722 * lineaire(b)
        }

        public static func contraste(_ a: Octets, _ b: Octets) -> Double {
            let (x, y) = (a.luminance, b.luminance)
            return (max(x, y) + 0.05) / (min(x, y) + 0.05)
        }

        public static func pire(_ c: Octets, _ fonds: [Octets]) -> Double { fonds.map { contraste(c, $0) }.min() ?? .infinity }

        /// Pousse `c` vers `vers` par pas jusqu'au seuil sur le pire des fonds.
        public static func renforcer(_ c: Octets, _ fonds: [Octets], _ seuil: Double, vers: Octets) -> Octets {
            var c = c, n = 0.0
            while pire(c, fonds) < seuil, n < Parametres.iterationsMax {
                c = melange(c, vers, Parametres.pasRenfort)
                n += 1
            }
            return c
        }

        /// Noir (le texte foncé de la page) ou blanc, celui qui se lit le mieux sur `c`.
        public static func texteSur(_ c: Octets) -> Octets { contraste(noir, c) > contraste(blanc, c) ? Parametres.texteFonce : blanc }

        /// Teinte (degrés), saturation et clarté (en %).
        public var tsl: (Double, Double, Double) {
            let c = [Double(r) / 255, Double(v) / 255, Double(b) / 255]
            let haut = c.max() ?? 0, bas = c.min() ?? 0, d = haut - bas, l = (haut + bas) / 2
            let s = d == 0 ? 0 : d / (1 - abs(2 * l - 1))
            var t = 0.0
            if d != 0 {
                if haut == c[0] {
                    t = ((c[1] - c[2]) / d).truncatingRemainder(dividingBy: 6)
                } else if haut == c[1] {
                    t = (c[2] - c[0]) / d + 2
                } else {
                    t = (c[0] - c[1]) / d + 4
                }
            }
            return ((t * 60 + 360).truncatingRemainder(dividingBy: 360), s * 100, l * 100)
        }

        public static func tsl(_ t: Double, _ s: Double, _ l: Double) -> Octets {
            let s = max(0, min(100, s)) / 100, l = l / 100
            let a = s * min(l, 1 - l)
            func f(_ n: Double) -> Double {
                let k = (n + t / 30).truncatingRemainder(dividingBy: 12)
                return l - a * max(-1, min(k - 3, 9 - k, 1))
            }
            return Octets(f(0) * 255, f(8) * 255, f(4) * 255)
        }

    }
}
