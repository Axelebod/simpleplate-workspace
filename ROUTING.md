# ROUTING.md - Système de routage par mention

## Mécanisme

Jarbite (agent principal) intercepte tous les messages Telegram.

### Détection des mentions

Si le message commence par :
- `@scrapy ...` → transféré à l'agent Scrapy
- `@hunter ...` → transféré à l'agent Hunter
- Sans mention → traité par Jarbite

### Commande pour transférer

```bash
openclaw agent --agent hunter --message "CONTENU" --deliver --to telegram:ID
```

## Implémentation

Dans SOUL.md de Jarbite, ajouter la règle :
- Scanner le message entrant pour les patterns `@nom`
- Si détecté, exécuter la commande ci-dessus avec l'agent concerné

## Notes

- Les agents doivent être bindés à Telegram pour pouvoir répondre
- Alternative : Jarbite récupère la réponse et la forward manuellement
