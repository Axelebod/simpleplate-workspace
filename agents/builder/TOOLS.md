# TOOLS.md - Builder

## Génération de code

### Templates de base
- `skills/templates/restaurant.html` — Template restaurant
- `skills/templates/artisan.html` — Template artisan
- `skills/templates/commerce.html` — Template commerce
- `skills/templates/coiffeur.html` — Template coiffeur

### Personnalisation
- Couleurs: Modifier variables CSS
- Textes: Remplacer contenu Lorem ipsum
- Images: Optimiser et compresser
- Logo: Intégrer si fourni

## Optimisation

### Images
- Format: WebP si possible, sinon JPEG/PNG optimisés
- Taille: Max 1920px de large
- Compression: TinyPNG ou équivalent

### Performance
- Minifier CSS/JS si possible
- Lazy loading des images
- Preload des polices

## Déploiement

### Options
1. **GitHub Pages** — Gratuit, simple
2. **Netlify** — Gratuit, drag & drop
3. **Vercel** — Gratuit, rapide
4. **Serveur client** — FTP/SFTP

### Process
1. Créer repo GitHub (si GitHub Pages)
2. Pousser les fichiers
3. Activer GitHub Pages
4. Récupérer l'URL
5. Transmettre au client

## Stockage

Les sites générés sont stockés dans :
- `sites/[entreprise]/` — Fichiers du site
- `sites/[entreprise].zip` — Archive pour livraison
