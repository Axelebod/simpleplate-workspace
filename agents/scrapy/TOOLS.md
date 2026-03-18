# TOOLS.md - Scrapy

## Sources de leads

### Google Maps
- Recherche par secteur + ville
- Extraction nom, adresse, téléphone, site

### Annuaires
- Pages Jaunes
- Yelp
- Societe.com

### Réseaux sociaux
- Facebook (présence mais pas de site)
- Instagram business

## Détection site web

### Signes "PAS de site"
- Pas de lien site sur Google Maps
- "Site web" vide ou N/A
- Seulement "Facebook" ou "Instagram"
- Lien cassé (404, domaine expiré)

### Signes "Site obsolète"
- Design des années 2000
- Dernière mise à jour > 2 ans
- HTTP non sécurisé (pas de HTTPS)
- Mobile non responsive

## Scoring

| Critère | Impact |
|---------|--------|
| Avis récents (+10 en 3 mois) | +HIGH |
| Photos à jour | +HIGH |
| Horaires renseignés | +MEDIUM |
| Téléphone visible | +MEDIUM |
| Seulement réseaux sociaux | vérifier qualité |

## Stockage

Fichier: `leads.json`
Format: Array d'objets avec scoring
