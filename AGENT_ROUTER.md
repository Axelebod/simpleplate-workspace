# AGENT ROUTER - Groupe Telegram SimplePlate

## Groupe configuré
- **ID:** 5269482932
- **Nom:** SimplePlate (ou le nom que tu as donné)

## Mécanisme de routing

### Messages entrants du groupe
Tous les messages arrivent à Jarbite (agent principal).

### Détection des mentions
Jarbite scanne chaque message pour :
- `@scrapy` → Redirige vers agent Scrapy
- `@hunter` → Redirige vers agent Hunter
- `@jarbite` ou sans mention → Traité par Jarbite

### Commande de redirection
```javascript
// Quand @scrapy est détecté
sessions_spawn({
  agentId: "scrapy",
  task: message_content,
  mode: "session",
  thread: true
})

// Quand @hunter est détecté
sessions_spawn({
  agentId: "hunter", 
  task: message_content,
  mode: "session",
  thread: true
})
```

## Réponses
Les agents répondent dans leur propre session/thread.
Jarbite peut forward la réponse dans le groupe ou l'agent répond directement.

## Test
Pour tester, envoyer dans le groupe :
- `@scrapy Cherche des restaurants à Lyon`
- `@hunter Prépare un message pour Le Petit Bistrot, restaurant à Cogolin`
