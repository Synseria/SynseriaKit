// Engendré par Synseria-Design — jamais édité à la main : https://github.com/Synseria/SynseriaKit
/* Les composants web du SDS : des éléments natifs (custom elements à shadow DOM) qui ne lisent que les
   variables de synseria.css (ou de Couleur.variables) : ils héritent du thème posé sur :root, sans
   framework — Angular, React ou une page simple. Une feuille partagée (adoptedStyleSheets) porte les
   règles de la trousse ; chaque attribut se relit quand il change (un framework les lie après coup).

   <syn-bouton variante="plein|secondaire|discret" icone="plus" libelle="…" desactive>
   <syn-interrupteur coche libelle="…" desactive>         change {checked}, propriété checked
   <syn-selecteur libelle="…" valeur="…"><option>…</option></syn-selecteur>   change {value}, propriété value ; une seule liste ouverte
   <syn-champ libelle="…" placeholder="…" valeur="…" icone="recherche" type="…" grand desactive>   input, change {value}
   <syn-carte titre="…"><… slot="geste"></…>contenu</syn-carte>
   <syn-etat-vide icone="…" titre="…"><syn-bouton>…</syn-bouton></syn-etat-vide>   jamais de phrase dessous
   <syn-formulaire> ▸ <syn-section titre="…"> ▸ <syn-rangee libelle="…" aide="…">contrôle</syn-rangee>   l'aide en infobulle */
(function(){
  if(typeof window==='undefined'||!window.customElements||window.customElements.get('syn-bouton'))return;
  var CSS=[
    ':host{font:var(--typo-corps);color:var(--encre)}',
    'svg.i{width:var(--taille-icone);height:var(--taille-icone);flex:none;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}',
    // boutons : plein (accent), secondaire (bordé), discret (texte d'accent)
    '.b{height:var(--hauteur-controle);padding:0 var(--espace-3);border-radius:var(--rayon-pilule);display:inline-flex;align-items:center;justify-content:center;gap:var(--espace-2);font:var(--typo-corps);border:var(--epaisseur-filet) solid transparent;background:none;color:var(--encre);cursor:pointer;white-space:nowrap;transition:background var(--duree-rapide) var(--courbe-standard),color var(--duree-rapide) var(--courbe-standard),transform var(--duree-rapide) var(--courbe-standard)}',
    '.b.pri{background:var(--accent);color:var(--texte-sur-accent)}.b.pri:hover{background:var(--accent-survol)}.b.pri:active{background:var(--accent-presse);transform:scale(var(--echelle-pressee))}',
    '.b.sec{background:var(--fond-fenetre);border-color:var(--filet)}.b.sec:hover{background:linear-gradient(var(--survol),var(--survol)),var(--fond-fenetre)}.b.sec:active{background:linear-gradient(var(--selection),var(--selection)),var(--fond-fenetre);transform:scale(var(--echelle-pressee))}',
    '.b.ter{color:var(--accent-texte);padding:0 var(--espace-2)}.b.ter:hover{background:var(--survol)}.b.ter:active{background:var(--selection);transform:scale(var(--echelle-pressee))}',
    '.b.ico{width:var(--hauteur-controle);padding:0}',
    '.b:focus-visible{outline:var(--anneau-focus);outline-offset:var(--decalage-focus)}.b:disabled{opacity:var(--opacite-desactive);pointer-events:none}',
    // interrupteur
    '.tg{width:var(--largeur-interrupteur);height:var(--hauteur-case);border-radius:var(--rayon-pilule);background:color-mix(in srgb,var(--encre) var(--piste-repos),var(--plaque));position:relative;border:0;padding:0;cursor:pointer;flex:none;display:block;transition:background var(--duree-normale) var(--courbe-standard)}',
    '.tg::after{content:"";position:absolute;top:2px;left:2px;width:var(--diametre-rond);height:var(--diametre-rond);border-radius:50%;background:var(--pouce-interrupteur);transition:transform var(--duree-normale) var(--courbe-sortie),width var(--duree-rapide) var(--courbe-standard)}',
    '.tg:hover{background:color-mix(in srgb,var(--encre) var(--piste-survol),var(--plaque))}.tg:active::after{width:calc(var(--diametre-rond) + var(--espace-1))}',
    '.tg.on{background:var(--accent)}.tg.on:hover{background:var(--accent-survol)}.tg.on::after{transform:translateX(var(--hauteur-case))}.tg.on:active::after{transform:translateX(calc(var(--hauteur-case) - var(--espace-1)))}',
    '.tg:focus-visible{outline:var(--anneau-focus);outline-offset:var(--decalage-focus)}.tg:disabled{opacity:var(--opacite-desactive);pointer-events:none}',
    // champ, et le sélecteur qui en a le dessin
    '.f{display:flex;align-items:center;gap:var(--espace-2);height:var(--hauteur-controle);padding:0 var(--espace-3);border-radius:var(--rayon-2);background:var(--fond-fenetre);border:var(--epaisseur-filet) solid var(--filet);color:var(--encre);min-width:0;box-sizing:border-box;transition:border-color var(--duree-rapide) var(--courbe-standard)}',
    '.f.grand{height:var(--hauteur-rangee)}',
    '.f:hover{border-color:color-mix(in srgb,var(--encre) var(--filet-survol),var(--filet))}.f:focus-within,.f.foc{border-color:var(--accent);outline:var(--anneau-focus);outline-offset:0}',
    '.f.dis{opacity:var(--opacite-desactive);pointer-events:none}',
    '.f input{all:unset;flex:1;min-width:0;font:var(--typo-corps);color:var(--encre)}.f input::placeholder{color:var(--encre-3)}.f svg.i{color:var(--encre-3)}',
    '.slc{font:var(--typo-corps);text-align:left;justify-content:space-between;width:100%;cursor:pointer;outline:none}',
    '.slc .lb{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.slc svg.i{width:var(--diametre-mini);height:var(--diametre-mini);color:var(--encre-2)}',
    '.mnu{position:absolute;top:calc(100% + var(--espace-1));left:0;z-index:20;box-sizing:border-box;min-width:100%;width:max-content;max-width:min(var(--largeur-feuille),calc(100vw - var(--espace-6)));max-height:calc(var(--hauteur-controle)*8 + var(--espace-1)*2);overflow-y:auto;padding:var(--espace-1);display:flex;flex-direction:column;background:var(--fond-fenetre);border:var(--epaisseur-filet) solid var(--filet);border-radius:var(--rayon-2)}',
    '.mnu.droite{left:auto;right:0}',
    '.mi{height:var(--hauteur-controle);flex:none;border-radius:var(--rayon-1);display:flex;align-items:center;gap:var(--espace-2);padding:0 var(--espace-2);color:var(--encre);white-space:nowrap;cursor:pointer}',
    '.mi .ck{width:var(--taille-icone);flex:none;display:grid}.mi.hov{background:var(--accent);color:var(--texte-sur-accent)}.mi.hov svg.i{color:inherit}',
    // carte, état vide, formulaire compact
    '.carte{background:var(--carte);border:var(--epaisseur-filet) solid var(--filet);border-radius:var(--rayon-3);padding:var(--espace-4);display:flex;flex-direction:column;gap:var(--espace-3);height:100%;box-sizing:border-box}',
    '.carte .h{display:flex;align-items:center;justify-content:space-between;gap:var(--espace-3);min-height:var(--hauteur-controle)}.carte h3{margin:0;font:var(--typo-section)}',
    '.vide{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:var(--espace-3);padding:var(--espace-5);min-height:calc(var(--hauteur-rangee)*4);text-align:center}',
    '.vide .ic{width:calc(var(--hauteur-rangee)*1.5);height:calc(var(--hauteur-rangee)*1.5);border-radius:50%;background:color-mix(in srgb,var(--accent) var(--taux-selection),transparent);color:var(--accent-texte);display:grid;place-items:center}',
    '.vide .ic svg.i{width:var(--espace-5);height:var(--espace-5)}.vide .tl{font:var(--typo-titre-carte)}',
    '.sc{display:flex;flex-direction:column;gap:var(--espace-3)}',
    '.sct{font:var(--typo-titre-carte);color:var(--encre-2);padding-left:var(--espace-1);margin-bottom:var(--espace-1)}',
    '.scc{background:var(--carte);border:var(--epaisseur-filet) solid var(--filet);border-radius:var(--rayon-2)}',
    '.rr{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:var(--espace-2) var(--espace-3);min-height:calc(var(--hauteur-rangee) - var(--espace-2));padding:var(--espace-1) var(--espace-3)}',
    ':host(syn-rangee:not(:first-of-type)) .rr{border-top:var(--epaisseur-filet) solid var(--filet)}',
    '.rr .lab{flex:1 1 8em;min-width:0}.rr .fin{display:flex;align-items:center;gap:var(--espace-2);margin-left:auto}'
  ].join('\n');
  var feuille=new CSSStyleSheet();feuille.replaceSync(CSS);

  // les icônes du SDS dont les composants ont besoin (trait, 24 × 24)
  var ICONES={plus:'M12 5v14M5 12h14',moins:'M5 12h14',recherche:'M10.5 4.5a6 6 0 1 0 0 12a6 6 0 1 0 0-12zM15 15l5 5',chevron:'M6 9l6 6 6-6',coche:'M5.5 12.5l4.2 4.2L18.5 7.8',
    ampoule:'M9 18h6M10 21h4M12 3a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2.1h5c0-.9.4-1.6 1-2.1A6 6 0 0 0 12 3z',
    thermometre:'M14 14.8V5a2 2 0 0 0-4 0v9.8a4 4 0 1 0 4 0zM12 9v7',eclair:'M13 3L5 13.5h6l-1 7.5 8-10.5h-6z',
    camera:'M4 8a2 2 0 0 1 2-2h2l1.5-2h5L16 6h2a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2zM12 9.5a3.5 3.5 0 1 0 0 7a3.5 3.5 0 1 0 0-7z',
    lune:'M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z',soleil:'M12 8a4 4 0 1 0 0 8a4 4 0 1 0 0-8zM12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5.3 5.3l1.4 1.4M17.3 17.3l1.4 1.4M18.7 5.3l-1.4 1.4M6.7 17.3l-1.4 1.4',
    porte:'M6 21V4.5A1.5 1.5 0 0 1 7.5 3h9A1.5 1.5 0 0 1 18 4.5V21M3.5 21h17M14.5 12.5v.5',canape:'M5 11V8a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v3M3 13a2 2 0 0 1 4 0v2h10v-2a2 2 0 0 1 4 0v5H3zM5 18v2M19 18v2'};
  function icone(n){return ICONES[n]?'<svg class="i" viewBox="0 0 24 24" aria-hidden="true"><path d="'+ICONES[n]+'"/></svg>':''}
  function esc(s){return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;')}
  function emettre(el,nom,detail){el.dispatchEvent(new CustomEvent(nom,{bubbles:true,composed:true,detail:detail}))}
  function racine(el,html){var r=el.shadowRoot||el.attachShadow({mode:'open'});r.adoptedStyleSheets=[feuille];r.innerHTML=html;return r}
  function afficher(el,genre){if(!el.style.display)el.style.display=genre}

  // un élément qui se redessine entier à chaque attribut observé : ce qu'il montre ne vit que dans ses attributs et ses slots
  function simple(attributs,genre,dessin){
    return class extends HTMLElement{
      static get observedAttributes(){return attributs}
      connectedCallback(){afficher(this,genre);racine(this,dessin(this))}
      attributeChangedCallback(){if(this.shadowRoot)racine(this,dessin(this))}
    }
  }
  var VARIANTES={plein:'pri',secondaire:'sec',discret:'ter'};
  var SynBouton=simple(['variante','icone','desactive','libelle'],'inline-flex',function(el){var ic=el.getAttribute('icone'),seul=ic&&!el.textContent.trim(),l=el.getAttribute('libelle');
    return '<button part="bouton" class="b '+(VARIANTES[el.getAttribute('variante')]||'sec')+(seul?' ico':'')+'"'+(el.hasAttribute('desactive')?' disabled':'')+
      (l?' aria-label="'+esc(l)+'" title="'+esc(l)+'"':'')+'>'+icone(ic)+'<slot></slot></button>'});
  var SynCarte=simple(['titre'],'block',function(el){var t=el.getAttribute('titre');
    return '<section class="carte">'+(t?'<div class="h"><h3>'+esc(t)+'</h3><slot name="geste"></slot></div>':'')+'<slot></slot></section>'});
  var SynEtatVide=simple(['icone','titre'],'block',function(el){
    return '<div class="vide"><span class="ic">'+icone(el.getAttribute('icone'))+'</span><b class="tl">'+esc(el.getAttribute('titre'))+'</b><slot></slot></div>'});
  var SynFormulaire=simple([],'block',function(){return '<div class="sc"><slot></slot></div>'});
  var SynSection=simple(['titre'],'block',function(el){var t=el.getAttribute('titre');
    return (t?'<div class="sct">'+esc(t)+'</div>':'')+'<div class="scc"><slot></slot></div>'});
  var SynRangee=simple(['libelle','aide'],'block',function(el){var a=el.getAttribute('aide');
    return '<div class="rr"'+(a?' title="'+esc(a)+'"':'')+'><span class="lab">'+esc(el.getAttribute('libelle'))+'</span><span class="fin"><slot></slot></span></div>'});

  class SynInterrupteur extends HTMLElement{
    static get observedAttributes(){return ['coche','desactive','libelle']}
    get checked(){return this.hasAttribute('coche')}
    set checked(v){this.toggleAttribute('coche',!!v)}
    connectedCallback(){if(this.shadowRoot)return;afficher(this,'inline-flex');racine(this,'<button class="tg" role="switch"></button>');
      this.shadowRoot.querySelector('button').addEventListener('click',()=>{this.checked=!this.checked;emettre(this,'change',{checked:this.checked})});this.peindre()}
    attributeChangedCallback(){this.peindre()}
    peindre(){var b=this.shadowRoot&&this.shadowRoot.querySelector('button');if(!b)return;
      b.classList.toggle('on',this.checked);b.setAttribute('aria-checked',this.checked);b.disabled=this.hasAttribute('desactive');b.setAttribute('aria-label',this.getAttribute('libelle')||'')}
  }

  // une seule liste ouverte dans la page ; clic, espace, ⏎ ou ↓ ouvrent ; ↑↓ ⏎ ⎋, la frappe saute à l'option
  var ouvert=null;
  document.addEventListener('mousedown',function(e){if(ouvert&&e.composedPath().indexOf(ouvert)<0)ouvert.fermer()});
  class SynSelecteur extends HTMLElement{
    static get observedAttributes(){return ['valeur','libelle','desactive']}
    get options(){return [].map.call(this.querySelectorAll('option'),function(o){return o.textContent.trim()})}
    get value(){return this.getAttribute('valeur')||this.options[0]||''}
    set value(v){this.setAttribute('valeur',v)}
    connectedCallback(){if(this.shadowRoot)return;afficher(this,'inline-block');this.style.position='relative';this.style.minWidth='0';
      var r=racine(this,'<button class="f slc" aria-haspopup="listbox"><span class="lb"></span>'+icone('chevron')+'</button>');
      this.bouton=r.querySelector('button');this.s=-1;
      this.bouton.addEventListener('mousedown',e=>{e.preventDefault();this.bouton.focus();this.menu?this.fermer():this.ouvrir(false)});
      this.bouton.addEventListener('keydown',e=>this.touche(e));
      this.bouton.addEventListener('blur',()=>this.fermer());
      // des options posées ou changées après coup (une boucle d'un framework) : le libellé suit
      new MutationObserver(()=>{this.peindre();if(this.menu)this.lignes()}).observe(this,{childList:true,subtree:true,characterData:true});
      this.peindre()}
    attributeChangedCallback(){this.peindre()}
    peindre(){if(!this.bouton)return;this.bouton.querySelector('.lb').textContent=this.value;this.bouton.title=this.value;
      this.bouton.disabled=this.hasAttribute('desactive');this.bouton.classList.toggle('dis',this.bouton.disabled);
      this.bouton.setAttribute('aria-label',(this.getAttribute('libelle')||'')+' : '+this.value)}
    ouvrir(clavier){if(ouvert&&ouvert!==this)ouvert.fermer();ouvert=this;var o=this.options;this.s=clavier?Math.max(0,o.indexOf(this.value)):-1;
      this.menu=document.createElement('div');this.menu.className='mnu';this.menu.setAttribute('role','listbox');
      this.menu.addEventListener('mousedown',e=>{e.preventDefault();var mi=e.target.closest('.mi');if(mi)this.choisir(+mi.dataset.i)});
      this.menu.addEventListener('mouseover',e=>{var mi=e.target.closest('.mi');if(mi){this.s=+mi.dataset.i;this.lignes()}});
      this.shadowRoot.appendChild(this.menu);this.bouton.classList.add('foc');this.lignes();
      var b=this.menu.getBoundingClientRect();if(b.right>innerWidth-8)this.menu.classList.add('droite')}
    lignes(){var v=this.value,s=this.s;this.menu.innerHTML=this.options.map(function(o,i){return '<div class="mi'+(i===s?' hov':'')+'" role="option" aria-selected="'+(o===v)+'" data-i="'+i+'"><span class="ck">'+(o===v?icone('coche'):'')+'</span>'+esc(o)+'</div>'}).join('');
      var h=this.menu.querySelector('.hov');if(h)h.scrollIntoView({block:'nearest'})}
    fermer(){if(this.menu){this.menu.remove();this.menu=null}if(this.bouton)this.bouton.classList.remove('foc');if(ouvert===this)ouvert=null}
    choisir(i){var o=this.options[i];this.fermer();if(o!=null&&o!==this.value){this.value=o;emettre(this,'change',{value:o})}}
    touche(e){var n=this.options.length,k=e.key;
      if(k==='ArrowDown'||k==='ArrowUp'){e.preventDefault();if(!this.menu)return this.ouvrir(true);this.s=Math.min(n-1,Math.max(0,this.s+(k==='ArrowDown'?1:-1)));this.lignes()}
      else if(k==='Enter'||k===' '){e.preventDefault();if(!this.menu)this.ouvrir(true);else if(this.s>=0)this.choisir(this.s);else this.fermer()}
      else if(k==='Escape'&&this.menu){e.preventDefault();this.fermer()}
      else if(k==='Tab')this.fermer();
      else if(k.length===1&&!e.metaKey&&!e.ctrlKey){if(!this.menu)this.ouvrir(true);var p=k.toLowerCase(),i=this.options.findIndex(function(o){return o.toLowerCase().indexOf(p)===0});if(i>=0){this.s=i;this.lignes()}}}
  }

  class SynChamp extends HTMLElement{
    static get observedAttributes(){return ['valeur','placeholder','libelle','icone','type','grand','desactive']}
    get value(){return this.input?this.input.value:(this.getAttribute('valeur')||'')}
    set value(v){if(this.input)this.input.value=v;else this.setAttribute('valeur',v)}
    connectedCallback(){if(this.shadowRoot)return;afficher(this,'block');this.style.minWidth='0';this.dessiner()}
    attributeChangedCallback(nom){if(!this.shadowRoot)return;if(nom==='icone'||nom==='grand')return this.dessiner();this.relire(nom==='valeur')}
    dessiner(){var garde=this.input?this.input.value:this.getAttribute('valeur')||'';
      var r=racine(this,'<label class="f">'+icone(this.getAttribute('icone'))+'<input></label>');
      this.input=r.querySelector('input');this.input.value=garde;
      this.input.addEventListener('input',e=>{e.stopPropagation();emettre(this,'input',{value:this.value})});
      this.input.addEventListener('change',()=>emettre(this,'change',{value:this.value}));this.relire(false)}
    relire(valeur){var i=this.input;if(valeur)i.value=this.getAttribute('valeur')||'';
      i.placeholder=this.getAttribute('placeholder')||'';i.type=this.getAttribute('type')||'text';i.disabled=this.hasAttribute('desactive');
      i.setAttribute('aria-label',this.getAttribute('libelle')||this.getAttribute('placeholder')||'');
      var f=this.shadowRoot.querySelector('.f');f.classList.toggle('grand',this.hasAttribute('grand'));f.classList.toggle('dis',i.disabled)}
  }

  [['syn-bouton',SynBouton],['syn-interrupteur',SynInterrupteur],['syn-selecteur',SynSelecteur],['syn-champ',SynChamp],['syn-carte',SynCarte],
   ['syn-etat-vide',SynEtatVide],['syn-formulaire',SynFormulaire],['syn-section',SynSection],['syn-rangee',SynRangee]].forEach(function(x){customElements.define(x[0],x[1])});
})();
