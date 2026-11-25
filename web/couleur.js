// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
/*
  Calcul des couleurs — la seule source, porté pas à pas dans modele/Nuancier.swift. Pur : lit #jetons,
  ne touche pas au DOM. Un thème est un point du continu : la teinte de l'accent (degrés entiers), la
  teinte du fond (accordée, de température opposée, ou libre) et la clarté (position du curseur,
  0…1000). Surfaces et encres se tirent en OKLCH de la teinte du fond et de la clarté, puis `finir`
  tient les seuils de contraste en ce point, quel qu'il soit.
    Couleur.couleurs(teinte, fond, clarte) → {rôle: "#RRGGBB", part-choix, part-survol}
    Couleur.theme(reglage, systemeSombre) → idem, pour un réglage enregistré (voir `reglage`)
    Couleur.variables(v, graphes) → les variables CSS d'une portée de thème
*/
var Couleur = (function () {
  var JETONS = {"version":2,"gabarit":{"Espacements":{"espace-1":{"valeur":"4px","role":"écart entre une icône et son libellé, entre deux touches"},"espace-2":{"valeur":"8px","role":"marge d'une plaque dans la fenêtre, padding d'une rangée dans une carte"},"espace-3":{"valeur":"12px","role":"padding horizontal d'une rangée, écart entre éléments d'une ligne"},"espace-4":{"valeur":"16px","role":"gouttière de page, sous l'en-tête d'une page"},"espace-5":{"valeur":"24px","role":"entre deux blocs d'une page, padding d'une plaque"},"espace-6":{"valeur":"32px","role":"entre deux groupes d'une planche"},"espace-7":{"valeur":"48px","role":"entre deux sections, haut d'un flottant sous son ancre"}},"Typographie":{"police-ui":{"valeur":"ui-rounded,\"SF Pro Rounded\",\"Nunito\",system-ui,sans-serif","role":"interface et titres (Rounded)"},"police-code":{"valeur":"ui-monospace,\"SF Mono\",Menlo,monospace","role":"commandes, code, touches"},"typo-titre-page":{"valeur":"700 28px/32px var(--police-ui)","role":"titre de page (« Lundi 16 novembre »)"},"typo-section":{"valeur":"600 17px/22px var(--police-ui)","role":"titre de carte ou de section"},"typo-titre-carte":{"valeur":"600 14px/20px var(--police-ui)","role":"titre d'une fiche, d'un élément nommé"},"typo-corps":{"valeur":"400 14px/20px var(--police-ui)","role":"texte courant, rangées, boutons"},"typo-lecture":{"valeur":"400 15px/24px var(--police-ui)","role":"lecture longue (docs, overlay)"},"typo-meta":{"valeur":"400 12px/16px var(--police-ui)","role":"ligne secondaire sous un titre, compteurs"},"typo-code":{"valeur":"400 13px/20px var(--police-code)","role":"commande, bloc de code"},"typo-micro":{"valeur":"500 11px/16px var(--police-ui)","role":"touches, étiquettes, axes de graphique"}},"Rayons et filets":{"rayon-0":{"valeur":"4px","role":"touche, trou d'une commande, piste"},"rayon-1":{"valeur":"8px","role":"rangée compacte, menu, fond creux"},"rayon-2":{"valeur":"12px","role":"rangée, champ, fenêtre"},"rayon-3":{"valeur":"16px","role":"plaque, carte, flottant ; rayon intérieur = extérieur − padding"},"rayon-pilule":{"valeur":"999px","role":"bouton, sous-onglet, interrupteur"},"epaisseur-filet":{"valeur":"1px","role":"bordure d'une plaque ou d'une carte, filet entre rangées"},"epaisseur-focus":{"valeur":"2px","role":"anneau de focus au clavier"},"decalage-focus":{"valeur":"2px","role":"écart de l'anneau de focus"}},"Tailles":{"hauteur-rangee":{"valeur":"36px","role":"rangée de liste, champ"},"hauteur-controle":{"valeur":"28px","role":"bouton, onglet rond, sous-onglet"},"hauteur-case":{"valeur":"24px","role":"interrupteur, badge, segment"},"hauteur-piste":{"valeur":"4px","role":"piste d'un curseur"},"diametre-rond":{"valeur":"20px","role":"case ronde d'une tâche, pouce d'interrupteur"},"diametre-mini":{"valeur":"12px","role":"feux de fenêtre, coche, punaise"},"diametre-pouce":{"valeur":"16px","role":"pouce d'un curseur"},"taille-icone":{"valeur":"16px","role":"icône d'interface"},"largeur-interrupteur":{"valeur":"48px","role":"interrupteur"},"largeur-nav":{"valeur":"200px","role":"barre latérale ; base des petites largeurs (menus, listes)"},"largeur-feuille":{"valeur":"400px","role":"feuille de confirmation ; borne de la liste d'un champ à suggestions"},"largeur-apropos":{"valeur":"340px","role":"fenêtre À propos"},"largeur-reglages":{"valeur":"1120px","role":"fenêtre des réglages"},"hauteur-reglages":{"valeur":"710px","role":"fenêtre des réglages : la même pour tous les onglets, Réglages ▸ Thème y tient sans défiler, en-tête compris"}},"Mouvement":{"duree-rapide":{"valeur":"120ms","role":"survol, pression"},"duree-normale":{"valeur":"200ms","role":"bascule, apparition"},"duree-lente":{"valeur":"320ms","role":"progression, changement de page"},"duree-boucle":{"valeur":"1400ms","role":"caret, progression indéterminée (TimelineView dans l'app)"},"duree-tour":{"valeur":"800ms","role":"un tour de l'indicateur d'activité"},"courbe-standard":{"valeur":"cubic-bezier(.4,0,.2,1)","role":"par défaut"},"courbe-sortie":{"valeur":"cubic-bezier(.2,.8,.2,1)","role":"ce qui arrive (décélère)"},"courbe-entree":{"valeur":"cubic-bezier(.4,0,1,1)","role":"ce qui s'en va (accélère)"}},"Verre et états":{"verre-opacite-focus":{"valeur":".05","role":"part du fond de fenêtre dans le verre de ce qui prend le clavier (fenêtre, palette, overlay, panneau, bloc-notes), focus ou pas : le bureau flouté se voit presque en clair — valeur d'essai fixée à .05 d'après les essais de l'utilisateur (dans l'app, aucun texte ne se pose sur le verre)"},"verre-opacite-flottant":{"valeur":".05","role":"verre de ce qui ne prend jamais le clavier (carte de réunion) — valeur d'essai fixée à .05 d'après les essais de l'utilisateur"},"verre-opacite-barre":{"valeur":".4","role":"part du fond de fenêtre dans la barre d'une fenêtre (feux, onglets, recherche) : elle porte du texte, plus couvrante que le menu latéral — valeur d'essai"},"verre-opacite-entete":{"valeur":".72","role":"part du fond de fenêtre dans l'en-tête des réglages (onglets), d'un bord à l'autre : le verre y reste, plus couvrant que la barre ; plein seulement si le Mac refuse le verre"},"verre-opacite-page":{"valeur":".2","role":"part du fond de fenêtre derrière la plaque, à droite du menu latéral (qui reste à verre-opacite-focus) — valeur d'essai"},"verre-flou":{"valeur":"28px","role":"flou derrière le verre"},"opacite-desactive":{"valeur":".4","role":"contrôle désactivé"},"echelle-pressee":{"valeur":".97","role":"contrôle pressé : il rétrécit"},"voile-survol":{"valeur":"8%","role":"survol d'un contrôle neutre (bouton-icône, onglet rond) : l'encre en voile"},"voile-pression":{"valeur":"14%","role":"pression d'un contrôle neutre : l'encre en voile"},"voile-touche":{"valeur":"18%","role":"touche posée sur un plein : un voile de son texte"},"piste-repos":{"valeur":"22%","role":"piste d'un interrupteur éteint : l'encre mêlée à la plaque"},"piste-survol":{"valeur":"32%","role":"piste d'un interrupteur éteint survolé"},"opacite-plaque":{"valeur":".9","role":"opacité des plaques, cartes et blocs pleins posés sur le verre (1 = plein) — valeur choisie par l'utilisateur après essais"},"opacite-filet":{"valeur":".1","role":"opacité de tous les filets et bordures (fenêtres, overlay, palette, panneau), pilotée par cette seule variable globale ; purement esthétique : aucun texte n'est jamais posé sur une bordure"},"filet-survol":{"valeur":"35%","role":"filet d'un champ survolé : l'encre mêlée au filet"}}},"couleur":{"roles":{"fond-fenetre":"fond de la fenêtre et des flottants","plaque":"plaque de contenu posée dans la fenêtre","carte":"carte posée sur la plaque : même fond, se distingue par son filet","filet":"bordures et séparateurs","encre":"texte principal","encre-2":"texte secondaire","encre-3":"indication, icône discrète, texte de remplacement","accent":"remplissage d'accent (bouton principal, coche, onglet actif)","texte-sur-accent":"texte et icône posés sur l'accent","accent-texte":"accent écrit en texte (durée, lien, sous-onglet actif)","selection":"fond d'un élément choisi : teinte-choix à part-choix","survol":"fond d'un élément survolé : teinte-choix à part-survol","creux":"fond des boutons ronds, des pistes et du code en ligne : fond-teinte mêlé d'encre","danger":"destruction, erreur","texte-sur-danger":"texte posé sur le danger","succes":"réussite","avertissement":"attention","info":"information","fond-teinte":"surface teintée : champ, tuile, recherche","accent-survol":"accent survolé : accent mêlé de l'encre ou du fond, celui qui s'écarte de son texte","accent-presse":"accent pressé : accent mêlé de l'encre ou du fond, celui qui s'écarte de son texte","danger-survol":"danger survolé : danger mêlé de l'encre ou du fond, celui qui s'écarte de son texte","danger-presse":"danger pressé : danger mêlé de l'encre ou du fond, celui qui s'écarte de son texte"},"modele":"Un thème = une teinte d'accent, une clarté continue (curseur 0…1000) et un fond accordé (température opposée à l'accent) ou de teinte libre. Tout le reste se calcule (modele/couleur.js) ; les seuils de contraste sont tenus en chaque point.","marque":{"nom":"Synseria","teinte":260},"fonds":[{"nom":"Sable","teinte":75},{"nom":"Ardoise","teinte":255}],"fond-accorde":{"froid":[130,320],"sous-un-froid":"Sable","sous-un-chaud":"Ardoise"},"fond-accorde-role":"le fond par défaut, de température opposée à l'accent : une teinte d'accent dans [froid[ prend le fond « sous-un-froid », les autres « sous-un-chaud »","clarte":{"crans":[{"nom":"Jour","position":200},{"nom":"Crépuscule","position":400},{"nom":"Pénombre","position":600},{"nom":"Nuit","position":800}],"clair":"Jour","sombre":"Nuit"},"clarte-role":"les crans nommés du curseur de clarté ; « clair » et « sombre » : les clartés par défaut, et celles que retient « Suivre le système »","curseurs":{"aimant":0.025,"fond":[0.85,0.04],"pas":20},"curseurs-role":"les curseurs de Réglages ▸ Thème : l'aimant attire sur un cran (part de la course), le dégradé du fond [clarté, chroma OKLCH], le pas (degrés) des dégradés de teinte","apercu":{"bureau":{"degrade":["#283A6B","#7A4A8C","#D9875B"],"taches":[{"couleur":"#FF8A5C","centre":[0.18,0.22],"rayon":[0.14,0.34]},{"couleur":"#5AD1C6","centre":[0.78,0.3],"rayon":[0.12,0.32]},{"couleur":"#8F7CFF","centre":[0.52,0.88],"rayon":[0.16,0.38]}]},"bureau-role":"le bureau derrière l'aperçu : un dégradé à 135°, puis des taches rondes (centre en part du bureau, rayons en part de la distance au coin le plus loin : plein, puis fondu)","feux":["#FF5F57","#FEBC2E","#28C840"],"canevas":[560,560],"zone":300,"empiler-sous":560,"canevas-role":"l'aperçu tient sans défiler : chaque fenêtre est dessinée sur son canevas [largeur, hauteur] puis mise à l'échelle dans la zone (sa hauteur fixe) ; deux fenêtres s'empilent sous la largeur empiler-sous","verre":{"page":[0.65,0.75],"barre":[0.62,0.7],"menu":[0.42,0.5],"overlay":0.8},"verre-role":"part du fond de fenêtre dans le verre de l'aperçu [clair, sombre] ; l'overlay : la plaque","libelles":{"systeme":"Système","clarte":"Clarté","couleur":"Couleur","accorde":"Accordé","fond":"Fond","clair":"Clair","sombre":"Sombre","apercu":"Aperçu","rechercher":"Rechercher","accueil":"Accueil","recents":"Récents","collections":"Collections","travail":"Travail","projets":"Projets","archives":"Archives","personnel":"Personnel","creer":"Créer","progression":"Progression","mesure":"64 %","succes":"Succès","alerte":"Alerte","erreur":"Erreur","vignette":"Titre de vignette","sous-titre":"Sous-titre","element-choisi":"Élément sélectionné","aujourdhui":"Aujourd’hui","element":"Élément","etiquette":"Étiquette","element-fini":"Élément terminé","hier":"Hier","lien":"Lien d’accent","action-chercher":"Rechercher une action","action-choisie":"Action sélectionnée","action-autre":"Autre action","remplacer":"Remplacer","copier":"Copier","annuler":"Annuler"}},"migration":{"themes":{"cerise":17,"terracotta":36,"abricot":50,"ambre":75,"miel":97,"sauge":154,"lagon":185,"bleuet":254,"lilas":296,"prune":351,"graphite":256},"fonds":{"ardoise":255,"lagune":204,"sable":75,"brique":34,"graphite":260},"nuances":{"jour":"Jour","crepuscule":"Crépuscule","penombre":"Pénombre","nuit":"Nuit"},"chroma-min":0.02,"role":"l'ancien réglage (coloris, Personnalisé, nuance, fond nommé ou libre) vers le thème : la teinte OKLCH de l'accent Jour d'un coloris, d'un fond, d'une couleur libre ; une couleur sous chroma-min n'a pas de teinte : la marque pour l'accent, le fond accordé pour le fond ; une nuance, le cran de même nom ; « suivre le système », les clartés par défaut"},"calcul":{"accent":{"clarte":0.75,"chroma":0.13},"clarte":{"ancres":[[0,1],[200,0.965],[400,0.875],[499,0.86],[500,0.34],[600,0.31],[800,0.22],[1000,0]],"bascule":500},"clarte-role":"position du curseur (0…1000) → clarté OKLCH du fond, par ancres ; le milieu (0,34–0,86) est sauté : aucune encre n'y tient 7:1. Dès la bascule, l'apparence est sombre (encres claires).","fond":{"chroma":0.012,"butee":0.002,"etendue-clair":0.14,"etendue-sombre":0.34,"plancher":0.5},"fond-role":"chroma du fond : chroma × (plancher + (1 − plancher) × part), la part montant de la butée blanche (clair, sur etendue-clair) ou noire (sombre, sur etendue-sombre) ; nul à moins de butee du blanc ou du noir","surfaces":{"clair":{"plaque":[0.035,0.6],"fond-teinte":[-0.035,0.6],"filet":[-0.12,1]},"sombre":{"plaque":[0.04,0.8],"fond-teinte":[0.08,0.6],"filet":[0.13,1]}},"surfaces-role":"[écart de clarté OKLCH au fond, part de sa chroma] ; une surface qui touche le blanc ou le noir perd sa chroma","encres":{"clair":{"encre-2":[0.44,0.015],"encre-3":[0.56,0.015]},"sombre":{"encre":[0.96,0.006],"encre-2":[0.8,0.015],"encre-3":[0.66,0.015]}},"encres-role":"[clarté OKLCH, chroma] à la teinte du fond ; l'encre claire est celle de la marque","semantiques":{"chroma":0.16,"clarte":[0.55,0.75],"danger":25,"succes":150,"avertissement":75,"info":250},"semantiques-role":"teinte OKLCH de chaque couleur sémantique, à la chroma et la clarté de départ [clair, sombre]","pas-clarte":0.01,"gamme":{"tolerance":0.0001,"reduction":0.9,"essais":30},"taux-selection":18,"choix":{"depart":[22,26],"part-survol":40,"pas":2,"max":40,"contraste-choix-survol":1.1,"contraste-survol-fond":1.04},"creux":8,"seuils":{"encre":7.3,"encre-2":4.8,"encre-3":3,"filet":1.3,"accent-texte":4.8,"semantiques":4.8,"texte-sur-accent":4.6,"texte-sur-accent-plancher":4.5,"texte-sur-etat":4.5,"texte-sur-verre":3},"seuils-surfaces":"filet contre fond-fenetre et plaque ; encre, encre-3 et sémantiques contre fond-fenetre, plaque, fond-teinte ; encre-2 et accent-texte contre ces trois surfaces et leurs sélections, accent-texte aussi contre le choix ; texte-sur-accent contre l'accent (l'accent s'écarte sous le plancher) ; texte-sur-etat : le texte d'un plein contre son survol et sa pression","pas-renfort":0.05,"pas-texte-sur-accent":0.06,"iterations-max":80,"texte-fonce":"#0B0B0B","pouce-interrupteur":"#FFFFFF","pouce-interrupteur-role":"le pouce d'un interrupteur, allumé ou éteint, comme celui de macOS : seule la piste prend l'accent","graphiques":{"seuil":3,"decalages":[[0,180,60,240,120,300],[0,200,100,300,50,250],[0,120,240,60,180,300],[0,160,320,80,240,40]],"clair":{"saturation":64,"clartes":[0,38,52,36,50,40]},"sombre":{"saturation":62,"clartes":[0,76,62,78,64,74]},"sequentielle":[0.16,0.36,0.56,0.78,1],"neutre-divergente":0.25},"melanges":{"accent-survol":14,"accent-presse":28,"danger-survol":14,"danger-presse":28},"melanges-role":"part (%) de l'encre ou du fond dans un état survolé ou pressé d'un plein"}},"reglages":{"libelles":{"fr":{"reglages":"Réglages","a-propos":"À propos de %@","general":"Général","theme":"Thème","ouverture":"Ouvrir avec la session","ouverture-aide":"%@ s’ouvre avec ta session. Se règle aussi dans Réglages Système ▸ Général ▸ Ouverture.","autoriser":"Autoriser","autoriser-aide":"macOS attend ton accord dans Réglages Système ▸ Général ▸ Ouverture.","ma-langue":"Ma langue","langue-du-systeme":"Langue du système","rechercher-une-langue":"Rechercher","statistiques":"Statistiques d’utilisation","partager":"Partager les statistiques d’utilisation","dernier-envoi":"Dernier envoi","jamais":"Jamais","voir-les-donnees":"Voir les données","prochain-envoi":"Prochain envoi","rien-a-envoyer":"Rien à envoyer","copier":"Copier","copie":"Copié","mise-a-jour":"Mise à jour","canal":"Canal","canal-aide":"Bêta propose aussi les versions préliminaires.","stable":"Stable","beta":"Bêta","version":"Version %@","rechercher":"Rechercher","a-jour":"À jour","telechargement":"Téléchargement de la version %@…","nouveautes":"Nouveautés","installer":"Installer %@ et relancer"},"en":{"reglages":"Settings","a-propos":"About %@","general":"General","theme":"Theme","ouverture":"Open at login","ouverture-aide":"%@ opens when you log in. Also set in System Settings ▸ General ▸ Login Items.","autoriser":"Allow","autoriser-aide":"macOS is waiting for your approval in System Settings ▸ General ▸ Login Items.","ma-langue":"My language","langue-du-systeme":"System language","rechercher-une-langue":"Search","statistiques":"Usage statistics","partager":"Share usage statistics","dernier-envoi":"Last sent","jamais":"Never","voir-les-donnees":"View data","prochain-envoi":"Next report","rien-a-envoyer":"Nothing to send","copier":"Copy","copie":"Copied","mise-a-jour":"Updates","canal":"Channel","canal-aide":"Beta also offers pre-release versions.","stable":"Stable","beta":"Beta","version":"Version %@","rechercher":"Check","a-jour":"Up to date","telechargement":"Downloading version %@…","nouveautes":"What’s New","installer":"Install %@ and relaunch"}},"libelles-role":"les mots de la fenêtre de réglages commune (onglets communs, Général, À propos), en français et en anglais ; %@ : le nom de l’app ou un numéro de version. Les aides propres à une app (ce qu’elle partage, à quoi sert sa langue) restent à l’app"},"marque":{"nuit":"#16284F","planete":"#7CADFF","encre":{"clair":"#141A2B","sombre":"#FDFDFF"},"encre-2":{"clair":"#555E75","sombre":"#AFB8CC"}}};
  var T = JETONS.couleur, C = T.calcul;
  var NOIR = '#000000', BLANC = '#FFFFFF', ENCRE_MARQUE = JETONS.marque.encre.clair;

  // --- Outils : hex, mélange linéaire en sRVB, luminance et contraste WCAG, TSL
  function versRvb(h) { h = h.replace('#', ''); return [0, 2, 4].map(function (i) { return parseInt(h.substr(i, 2), 16); }); }
  function versHex(a) { return '#' + a.map(function (v) { return Math.round(Math.max(0, Math.min(255, v))).toString(16).padStart(2, '0'); }).join('').toUpperCase(); }
  function melange(a, b, t) { var x = versRvb(a), y = versRvb(b); return versHex(x.map(function (v, i) { return v + (y[i] - v) * t; })); }
  function luminance(h) { var c = versRvb(h).map(function (v) { v /= 255; return v <= .03928 ? v / 12.92 : Math.pow((v + .055) / 1.055, 2.4); }); return .2126 * c[0] + .7152 * c[1] + .0722 * c[2]; }
  function contraste(a, b) { var x = luminance(a), y = luminance(b); if (x < y) { var t = x; x = y; y = t; } return (x + .05) / (y + .05); }
  // le plus mauvais contraste d'une couleur sur une liste de fonds
  function pire(c, fonds) { return Math.min.apply(0, fonds.map(function (b) { return contraste(c, b); })); }
  // pousse c vers le noir (clair) ou le blanc (sombre) jusqu'au seuil sur tous les fonds
  function renforcer(c, fonds, seuil, vers) { var n = 0; while (pire(c, fonds) < seuil && n < C['iterations-max']) { c = melange(c, vers, C['pas-renfort']); n++; } return c; }
  function versTsl(h) {
    var c = versRvb(h).map(function (v) { return v / 255; }), mx = Math.max.apply(0, c), mn = Math.min.apply(0, c), d = mx - mn, l = (mx + mn) / 2, s = d ? d / (1 - Math.abs(2 * l - 1)) : 0, t = 0;
    if (d) { if (mx === c[0]) t = ((c[1] - c[2]) / d) % 6; else if (mx === c[1]) t = (c[2] - c[0]) / d + 2; else t = (c[0] - c[1]) / d + 4; }
    return [(t * 60 + 360) % 360, s * 100, l * 100];
  }
  function tsl(h, s, l) {
    s = Math.max(0, Math.min(100, s)) / 100; l /= 100; var a = s * Math.min(l, 1 - l);
    function f(n) { var k = (n + h / 30) % 12; return l - a * Math.max(-1, Math.min(k - 3, 9 - k, 1)); }
    return versHex([f(0) * 255, f(8) * 255, f(4) * 255]);
  }
  // noir ou blanc, celui qui se lit le mieux sur c
  function texteSur(c) { return contraste(NOIR, c) > contraste(BLANC, c) ? C['texte-fonce'] : BLANC; }

  // --- OKLCH ↔ sRVB. Les cubes s'écrivent en produits : identiques à l'octet en Swift.
  function lineaire(v) { v /= 255; return v <= .04045 ? v / 12.92 : Math.pow((v + .055) / 1.055, 2.4); }
  function gamma(v) { return 255 * (v <= .0031308 ? 12.92 * v : 1.055 * Math.pow(v, 1 / 2.4) - .055); }
  function versOklch(h) {
    var c = versRvb(h).map(lineaire);
    var l = Math.cbrt(.4122214708 * c[0] + .5363325363 * c[1] + .0514459929 * c[2]), m = Math.cbrt(.2119034982 * c[0] + .6806995451 * c[1] + .1073969566 * c[2]), s = Math.cbrt(.0883024619 * c[0] + .2817188376 * c[1] + .6299787005 * c[2]);
    var L = .2104542553 * l + .793617785 * m - .0040720468 * s, A = 1.9779984951 * l - 2.428592205 * m + .4505937099 * s, B = .0259040371 * l + .7827717662 * m - .808675766 * s;
    return [L, Math.sqrt(A * A + B * B), (Math.atan2(B, A) * 180 / Math.PI + 360) % 360];
  }
  function brut(L, ch, H) {
    var a = ch * Math.cos(H * Math.PI / 180), b = ch * Math.sin(H * Math.PI / 180);
    var l = L + .3963377774 * a + .2158037573 * b, m = L - .1055613458 * a - .0638541728 * b, s = L - .0894841775 * a - 1.291485548 * b;
    l = l * l * l; m = m * m * m; s = s * s * s;
    return [4.0767416621 * l - 3.3077115913 * m + .2309699292 * s, -1.2684380046 * l + 2.6097574011 * m - .3413193965 * s, -.0041960863 * l - .7034186147 * m + 1.707614701 * s];
  }
  // Hors de la gamme sRVB, la chroma recule jusqu'à y entrer ; au blanc et au noir, elle est nulle.
  function oklch(L, ch, H) {
    var G = C.gamme;
    L = Math.max(0, Math.min(1, L));
    if (L <= 0 || L >= 1) ch = 0;
    for (var i = 0; i < G.essais; i++) {
      var x = brut(L, ch, H);
      if (x.every(function (v) { return v >= -G.tolerance && v <= 1 + G.tolerance; })) return versHex(x.map(gamma));
      ch *= G.reduction;
    }
    return versHex(brut(L, 0, H).map(gamma));
  }
  // La clarté OKLCH monte (sombre) ou descend (clair) jusqu'au seuil sur tous les fonds : la teinte
  // et la chroma restent, là où `renforcer` les délaverait.
  function atteindre(L, ch, H, fonds, seuil, sombre) {
    var c = oklch(L, ch, H), n = 0;
    while (pire(c, fonds) < seuil && n < C['iterations-max']) { L += sombre ? C['pas-clarte'] : -C['pas-clarte']; c = oklch(L, ch, H); n++; }
    return c;
  }

  // --- La clarté : position du curseur (0…1000) → clarté OKLCH du fond, par ancres
  function estSombre(clarte) { return clarte >= C.clarte.bascule; }
  function clarteDuFond(clarte) {
    var A = C.clarte.ancres;
    for (var i = 1; i < A.length; i++) if (clarte <= A[i][0]) { var a = A[i - 1], b = A[i]; return a[1] + (b[1] - a[1]) * ((clarte - a[0]) / (b[0] - a[0])); }
    return A[A.length - 1][1];
  }
  // la chroma du fond : nulle aux butées blanche et noire, au plancher près d'elles, pleine au-delà
  function chromaDuFond(Lb, sombre) {
    var F = C.fond;
    if (sombre) return Lb < F.butee ? 0 : F.chroma * (F.plancher + (1 - F.plancher) * Lb / F['etendue-sombre']);
    return Lb > 1 - F.butee ? 0 : F.chroma * (F.plancher + (1 - F.plancher) * Math.min(1, (1 - Lb) / F['etendue-clair']));
  }

  // le fond de fenêtre seul, pour les dégradés d'un curseur
  function fondDeFenetre(fond, clarte) { var Lb = clarteDuFond(clarte); return oklch(Lb, chromaDuFond(Lb, estSombre(clarte)), fond); }
  // l'accent d'une teinte, avant les seuils : le dégradé du curseur de couleur
  function accent(teinte) { return oklch(C.accent.clarte, C.accent.chroma, teinte); }

  // --- Les seuils : encre ≥ 7,3, encre-3 ≥ 3 ; encre-2 et accent-texte ≥ 4,8 sur les surfaces et leurs
  //     sélections ; accent-texte aussi sur le choix ; sémantiques ≥ 4,8 ; texte-sur-accent ≥ 4,6
  function surfaces(v) { return [v['fond-fenetre'], v.plaque, v['fond-teinte']]; }
  function selections(v) { var p = C['taux-selection'] / 100; return [melange(v.plaque, v.accent, p), melange(v['fond-teinte'], v.accent, p), melange(v['fond-fenetre'], v.accent, p)]; }
  // le fond d'une rangée choisie, sur la fenêtre et sur la plaque
  function choisis(v) { var p = v['part-choix'] / 100; return [melange(v['fond-fenetre'], v['teinte-choix'], p), melange(v.plaque, v['teinte-choix'], p)]; }
  // Le choix : en clair l'accent écrit (l'accent, clair, teint sans assombrir : près du Crépuscule,
  // choix et survol se confondraient), en sombre l'accent ; sa part monte par pas jusqu'à ce que
  // choix et survol se distinguent, et le survol du fond.
  function doserChoix(v, clair, depart) {
    var X = C.choix, t = clair ? v['accent-texte'] : v.accent, p = depart;
    function distincts(p) { return [v['fond-fenetre'], v.plaque].every(function (f) {
      var choix = melange(f, t, p / 100), survol = melange(f, t, p / 100 * (X['part-survol'] / 100));
      return contraste(choix, survol) >= X['contraste-choix-survol'] && contraste(survol, f) >= X['contraste-survol-fond']; }); }
    while (!distincts(p) && p < X.max) p += X.pas;
    v['teinte-choix'] = t; v['part-choix'] = p; v['part-survol'] = p * X['part-survol'] / 100;
  }
  function finir(v, clair) {
    var S = C.seuils, vers = clair ? NOIR : BLANC, fonds = surfaces(v), tous = fonds.concat(selections(v));
    doserChoix(v, clair, C.choix.depart[clair ? 0 : 1]);
    v.encre = renforcer(v.encre, fonds, S.encre, vers);
    // le filet se voit encore sur la fenêtre et la plaque, jusqu'au noir et au blanc
    v.filet = renforcer(v.filet, [v['fond-fenetre'], v.plaque], S.filet, vers);
    v['encre-2'] = renforcer(v['encre-2'], tous, S['encre-2'], vers);
    v['encre-3'] = renforcer(v['encre-3'], fonds, S['encre-3'], vers);
    v['accent-texte'] = renforcer(renforcer(v['accent-texte'], tous, S['accent-texte'], vers), choisis(v), S['accent-texte'], vers);
    ['danger', 'succes', 'avertissement', 'info'].forEach(function (k) { v[k] = renforcer(v[k], fonds, S.semantiques, vers); });
    var ac = v.accent, n = 0, tx = contraste(NOIR, ac) > contraste(BLANC, ac) ? NOIR : BLANC;
    while (contraste(v['texte-sur-accent'], ac) < S['texte-sur-accent'] && n < C['iterations-max']) { v['texte-sur-accent'] = melange(v['texte-sur-accent'], tx, C['pas-texte-sur-accent']); n++; }
    // un accent qui plafonne avec le noir comme avec le blanc s'écarte lui-même du texte
    for (n = 0; contraste(v['texte-sur-accent'], v.accent) < S['texte-sur-accent-plancher'] && n < C['iterations-max']; n++) v.accent = melange(v.accent, tx === NOIR ? BLANC : NOIR, C['pas-renfort']);
    v['texte-sur-danger'] = texteSur(v.danger);
    etats(v);
    // le fond des boutons ronds, des pistes et du code en ligne : la surface teintée, mêlée d'encre
    v.creux = melange(v['fond-teinte'], v.encre, C.creux / 100);
    return v;
  }
  // Survol et pression d'un plein (accent, danger) : il se mêle de l'encre ou du fond, celui qui
  // s'écarte le plus de son texte. Vers l'encre seule, un accent clair au texte foncé s'assombrirait
  // vers son propre texte, sous 4,5:1.
  function etats(v) {
    ['accent', 'danger'].forEach(function (b) {
      var tx = v['texte-sur-' + b], pole = contraste(v.encre, tx) >= contraste(v['fond-fenetre'], tx) ? v.encre : v['fond-fenetre'];
      ['survol', 'presse'].forEach(function (e) { v[b + '-' + e] = melange(v[b], pole, C.melanges[b + '-' + e] / 100); });
    });
  }

  // --- Un point du continu : la teinte de l'accent, celle du fond (degrés entiers), la clarté (0…1000)
  function couleurs(teinte, fond, clarte) {
    var sombre = estSombre(clarte), Lb = clarteDuFond(clarte), cF = chromaDuFond(Lb, sombre), S = C.surfaces[sombre ? 'sombre' : 'clair'];
    var E = C.encres[sombre ? 'sombre' : 'clair'], A = C.accent, M = C.semantiques, I = sombre ? 1 : 0;
    function surface(k) { return oklch(Lb + S[k][0], cF * S[k][1], fond); }
    var v = { 'fond-fenetre': fondDeFenetre(fond, clarte), plaque: surface('plaque'), 'fond-teinte': surface('fond-teinte'), filet: surface('filet') };
    var fonds = surfaces(v);
    v.encre = sombre ? oklch(E.encre[0], E.encre[1], fond) : ENCRE_MARQUE;
    v['encre-2'] = atteindre(E['encre-2'][0], E['encre-2'][1], fond, fonds, C.seuils['encre-2'], sombre);
    v['encre-3'] = atteindre(E['encre-3'][0], E['encre-3'][1], fond, fonds, C.seuils['encre-3'], sombre);
    v.accent = accent(teinte);
    v['texte-sur-accent'] = contraste(ENCRE_MARQUE, v.accent) >= contraste(BLANC, v.accent) ? ENCRE_MARQUE : BLANC;
    v['accent-texte'] = atteindre(A.clarte, A.chroma, teinte, fonds, C.seuils['accent-texte'], sombre);
    ['danger', 'succes', 'avertissement', 'info'].forEach(function (k) { v[k] = atteindre(M.clarte[I], M.chroma, M[k], fonds, C.seuils.semantiques, sombre); });
    return finir(v, !sombre);
  }

  // --- Le réglage enregistré : {teinte, fond (null : accordé, sinon sa teinte), suivreLeSysteme,
  //     clarte (la seule, sans suivre), clarteClaire et clarteSombre (retenues pour suivre)}
  function cran(nom) { return T.clarte.crans.filter(function (c) { return c.nom === nom; })[0]; }
  function fondNomme(nom) { return T.fonds.filter(function (f) { return f.nom === nom; })[0]; }
  function fondAccorde(teinte) { var F = T['fond-accorde']; return fondNomme(teinte >= F.froid[0] && teinte < F.froid[1] ? F['sous-un-froid'] : F['sous-un-chaud']).teinte; }
  function reglage(o) {
    var clair = cran(T.clarte.clair).position, sombre = cran(T.clarte.sombre).position;
    var r = { teinte: T.marque.teinte, fond: null, suivreLeSysteme: true, clarte: clair, clarteClaire: clair, clarteSombre: sombre };
    Object.keys(o || {}).forEach(function (k) { r[k] = o[k]; });
    return r;
  }
  function teinteDuFond(r) { return r.fond === null ? fondAccorde(r.teinte) : r.fond; }
  function clarteDe(r, systemeSombre) { return r.suivreLeSysteme ? (systemeSombre ? r.clarteSombre : r.clarteClaire) : r.clarte; }
  // la moitié du curseur où se règle la clarté : avec le système, celle de son apparence
  function bornes(r, systemeSombre) { var b = C.clarte.bascule, fin = C.clarte.ancres[C.clarte.ancres.length - 1][0]; return !r.suivreLeSysteme ? [0, fin] : systemeSombre ? [b, fin] : [0, b - 1]; }
  // la clarté réglée au curseur, bornée, là où elle se retient → un nouveau réglage
  function poserClarte(r, position, systemeSombre) {
    var b = bornes(r, systemeSombre), p = Math.min(b[1], Math.max(b[0], position)), n = reglage(r);
    if (!r.suivreLeSysteme) n.clarte = p; else if (systemeSombre) n.clarteSombre = p; else n.clarteClaire = p;
    return n;
  }
  // le cran le plus proche à moins de l'aimant (le premier à égalité), sinon la position elle-même
  function aimanter(position, crans, aimant) {
    var pres = null;
    crans.forEach(function (c) { if (Math.abs(c - position) < aimant && (pres === null || Math.abs(c - position) < Math.abs(pres - position))) pres = c; });
    return pres === null ? position : pres;
  }
  function theme(r, systemeSombre) { return couleurs(r.teinte, teinteDuFond(r), clarteDe(r, systemeSombre)); }

  // --- L'ancien réglage (onze coloris ou Personnalisé, quatre nuances, fonds nommés ou libres) :
  //     {coloris: "abricot" | null, personnalise: "#RRGGBB" | null, nuance: "penombre" | null (suit le
  //     système), fond: "ardoise" | "#RRGGBB" | null (celui du thème)} → le réglage
  function teinteDe(hex) { var o = versOklch(hex); return o[1] < T.migration['chroma-min'] ? null : Math.round(o[2]) % 360; }
  function migrer(a) {
    var M = T.migration, r = reglage(), t = null, f = null;
    if (a.coloris && a.coloris in M.themes) t = M.themes[a.coloris];
    else if (!a.coloris && a.personnalise) t = teinteDe(a.personnalise);
    if (t !== null) r.teinte = t;
    if (a.fond) f = /^#/.test(a.fond) ? teinteDe(a.fond) : a.fond in M.fonds ? M.fonds[a.fond] : null;
    if (f !== null) r.fond = f;
    if (a.nuance && a.nuance in M.nuances) { r.suivreLeSysteme = false; r.clarte = cran(M.nuances[a.nuance]).position; }
    return r;
  }

  // --- Graphiques : catégorielle (6, choisie pour rester distincte en protanopie et deutéranopie),
  //     séquentielle (plaque → première catégorie), divergente (danger → neutre → succès)
  function oklabLineaire(c) {
    c = c.map(function (v) { return Math.max(0, Math.min(1, v)); });
    var l = Math.cbrt(.4122214708 * c[0] + .5363325363 * c[1] + .0514459929 * c[2]), m = Math.cbrt(.2119034982 * c[0] + .6806995451 * c[1] + .1073969566 * c[2]), s = Math.cbrt(.0883024619 * c[0] + .2817188376 * c[1] + .6299787005 * c[2]);
    return [.2104542553 * l + .793617785 * m - .0040720468 * s, 1.9779984951 * l - 2.428592205 * m + .4505937099 * s, .0259040371 * l + .7827717662 * m - .808675766 * s];
  }
  // matrices de simulation (Machado 2009, sévérité 1) : deutéranopie, protanopie
  var SIMULATION = { d: [[.367322, .860646, -.227968], [.280085, .672501, .047413], [-.01182, .04294, .968881]], p: [[.152286, 1.052583, -.204868], [.114503, .786281, .099216], [-.003882, -.048116, 1.051998]] };
  function oklab(h, vision) {
    var c = versRvb(h).map(lineaire);
    if (!vision) return oklabLineaire(c);
    return oklabLineaire(SIMULATION[vision].map(function (r) { return r[0] * c[0] + r[1] * c[1] + r[2] * c[2]; }));
  }
  function ecart(a, b, vision) { var x = oklab(a, vision), y = oklab(b, vision); return 100 * Math.hypot(x[0] - y[0], x[1] - y[1], x[2] - y[2]); }
  function graphiques(v, clair) {
    var G = C.graphiques, R = G[clair ? 'clair' : 'sombre'], fonds = [v.plaque], vers = clair ? NOIR : BLANC, h = versTsl(v.accent)[0], meilleur = null;
    G.decalages.forEach(function (o) {
      var c = [renforcer(v.accent, fonds, G.seuil, vers)];
      for (var i = 1; i < 6; i++) c.push(renforcer(tsl((h + o[i]) % 360, R.saturation, R.clartes[i]), fonds, G.seuil, vers));
      var cvd = 99, normale = 99;
      for (i = 0; i < 5; i++) { cvd = Math.min(cvd, ecart(c[i], c[i + 1], 'd'), ecart(c[i], c[i + 1], 'p')); normale = Math.min(normale, ecart(c[i], c[i + 1])); }
      if (!meilleur || cvd > meilleur.cvd) meilleur = { cat: c, cvd: cvd, normale: normale };
    });
    var neutre = melange(v.plaque, v['encre-2'], G['neutre-divergente']);
    meilleur.seq = G.sequentielle.map(function (t) { return melange(v.plaque, meilleur.cat[0], t); });
    meilleur.div = [v.danger, melange(v.danger, neutre, .5), neutre, melange(v.succes, neutre, .5), v.succes];
    meilleur.contraste = Math.min.apply(0, meilleur.cat.map(function (x) { return contraste(x, v.plaque); }));
    return meilleur;
  }

  // --- Les variables CSS d'une portée de thème : les rôles, la sélection et le survol, les palettes
  var EMIS = ['fond-fenetre', 'plaque', 'filet', 'encre', 'encre-2', 'encre-3', 'accent', 'texte-sur-accent', 'accent-texte', 'danger', 'texte-sur-danger',
    'succes', 'avertissement', 'info', 'creux', 'fond-teinte', 'accent-survol', 'accent-presse', 'danger-survol', 'danger-presse'];
  function variables(v, graphes) {
    var o = EMIS.map(function (k) { return '--' + k + ':' + v[k]; });
    o.push('--selection:color-mix(in srgb,' + v['teinte-choix'] + ' ' + v['part-choix'] + '%,transparent)', '--survol:color-mix(in srgb,' + v['teinte-choix'] + ' ' + v['part-survol'] + '%,transparent)');
    if (graphes) [['cat', graphes.cat], ['seq', graphes.seq], ['div', graphes.div]].forEach(function (g) { g[1].forEach(function (x, i) { o.push('--graphe-' + g[0] + '-' + (i + 1) + ':' + x); }); });
    return o.join(';');
  }

  return { JETONS: JETONS, couleurs: couleurs, theme: theme, reglage: reglage, migrer: migrer, teinteDuFond: teinteDuFond, fondAccorde: fondAccorde,
    clarteDe: clarteDe, bornes: bornes, poserClarte: poserClarte, fondDeFenetre: fondDeFenetre, accent: accent, aimanter: aimanter, estSombre: estSombre, graphiques: graphiques, variables: variables,
    oklch: oklch, contraste: contraste, pire: pire, surfaces: surfaces, selections: selections, choisis: choisis, texteSur: texteSur };
})();
if (typeof module !== 'undefined' && module.exports) module.exports = Couleur;
