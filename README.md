# SynseriaKit

Le design system Synseria et les utilitaires communs à ses apps : jetons, composants SwiftUI,
variables CSS, calcul des couleurs, télémétrie, mises à jour.

**Engendré par le SDS (Synseria-Design), jamais édité à la main.** Une correction se fait dans le SDS,
qui publie une nouvelle version ici.

## Installation

**Swift** (macOS 26) :

```swift
.package(url: "https://github.com/Synseria/SynseriaKit", exact: "2.2.1")
```

Produits : `SynseriaDesign` (`Jetons`, la trousse SwiftUI), `Telemetrie`, `MiseAJour`. Ce qui est propre
à une app (son gabarit, son thème par défaut, ses couleurs) reste dans l'app, en `extension Jetons`.

**Web** :

```sh
npm install github:Synseria/SynseriaKit#v2.2.1
```

ou par jsDelivr : `https://cdn.jsdelivr.net/gh/Synseria/SynseriaKit@v2.2.1/web/synseria.css` et
`…/web/couleur.js` (global `Couleur`, ou `require("@synseria/kit")`).

Les composants (`web/composants.js`, par `<script>` ou `import "@synseria/kit/composants.js"`) : `syn-bouton`,
`syn-interrupteur`, `syn-selecteur`, `syn-champ`, `syn-carte`, `syn-etat-vide`, `syn-formulaire`,
`syn-section`, `syn-rangee` — des éléments natifs, sur les variables de `synseria.css`, dans Angular,
React ou une page simple. La police de repli : `web/nunito.css` (Nunito, Google Fonts).

**Android** : ressources `android/` (`jetons.xml`, clair et nuit), préparées pour JitPack ; pas
encore construites.

## Versions

Chaque version suit un tag du SDS (`vX.Y.Z`, ou `vX.Y.Z-rc.N` pour une pré-version) et porte le même tag
ici. Une version publiée ne change jamais : une app s'y épingle par `exact:`.

## Licence

Propriétaire : voir `LICENSE`.
