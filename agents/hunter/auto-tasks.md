# Tâches Automatiques - Hunter 🎯

## Génération Quotidienne (10h)

### Process
1. Lire les leads HIGH de Scrapy
2. Générer un message personnalisé par lead
3. Sauvegarder dans `dashboard/data/hunter/messages.json`
4. Marquer comme "draft"

### Template par défaut
```
Bonjour,

Je suis tombé sur [entreprise] à [ville]...

[Message personnalisé selon le secteur]

Axel - SimplePlate
```

## Validation Humaine
Les messages restent en "draft" jusqu'à validation par Axou.
