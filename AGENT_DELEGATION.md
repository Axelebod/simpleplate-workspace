# AGENT DELEGATION - Système de délégation aux agents

## Principe
Quand un message arrive du groupe Telegram (5269482932) avec une mention :

### Détection
- Message commence par `@scrapy` → Délègue à agent Scrapy
- Message commence par `@hunter` → Délègue à agent Hunter
- Sans mention → Traité par Jarbite (main)

### Mécanisme de délégation

```javascript
// Détection @scrapy
if (message.startsWith("@scrapy")) {
  sessions_spawn({
    runtime: "acp",
    agentId: "scrapy",
    task: message.replace("@scrapy", "").trim(),
    mode: "session",
    thread: true,
    label: "scrapy-group-delegation"
  });
}

// Détection @hunter  
if (message.startsWith("@hunter")) {
  sessions_spawn({
    runtime: "acp",
    agentId: "hunter",
    task: message.replace("@hunter", "").trim(),
    mode: "session",
    thread: true,
    label: "hunter-group-delegation"
  });
}
```

### Réponse
L'agent répond dans sa propre session. Jarbite peut :
- Forward la réponse au groupe
- Ou laisser l'agent répondre directement (si binding configuré)

### Implémentation dans SOUL.md
Ajouter la règle :
"Quand je reçois un message du groupe Telegram (5269482932) commençant par @scrapy ou @hunter, je DOIS utiliser sessions_spawn pour déléguer à l'agent concerné. Je ne dois PAS simuler leur personnalité."
