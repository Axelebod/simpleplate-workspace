---
name: team-communication
description: |
  Système de communication et notification entre agents SimplePlate. 
  Permet aux agents de s'envoyer des messages, notifier des événements, 
  et déclencher des actions chez d'autres agents.
triggers:
  - "notify agent"
  - "send message to"
  - "alert team"
  - "broadcast"
  - "agent notification"
---

# Team Communication Skill

Système de notification et communication entre les agents SimplePlate.

## Usage

### Notifier un agent spécifique

```javascript
// Notifier Hunter que des leads sont prêts
notifyAgent('hunter', {
  type: 'leads_ready',
  count: 10,
  message: '10 nouveaux leads HIGH prêts à être contactés'
});
```

### Broadcast à toute l'équipe

```javascript
// Informer tous les agents d'une vente
broadcast({
  type: 'sale_closed',
  client: 'Restaurant XYZ',
  revenue: 100,
  message: '🎉 Nouveau client signé ! Wilson doit créer le site.'
});
```

### Mettre à jour le statut d'un agent

```javascript
// Mettre à jour le statut dans l'Office
updateAgentStatus('scrapy', {
  status: 'working',
  currentTask: 'Recherche leads à Toulon',
  progress: 45
});
```

## Types de notifications

| Type | Description | Destinataire |
|------|-------------|--------------|
| `leads_ready` | Nouveaux leads trouvés | Hunter |
| `message_sent` | Message envoyé à un prospect | Jarbite |
| `lead_responded` | Prospect a répondu | Wilson + Jarbite |
| `site_ready` | Site créé et déployé | Hunter + Jarbite |
| `sale_closed` | Client signé | Tous |
| `error` | Erreur nécessite attention | Jarbite |
| `daily_report` | Rapport quotidien | Axou |

## Fichiers partagés

Les notifications sont stockées dans :
```
/dashboard/data/notifications.json
/dashboard/data/agent-status.json
```

## Exemples

### Scrapy → Hunter
```javascript
// Quand Scrapy trouve des leads
const notification = {
  from: 'scrapy',
  to: 'hunter',
  type: 'leads_ready',
  timestamp: new Date().toISOString(),
  data: {
    count: 12,
    ville: 'Toulon',
    quality: 'high'
  },
  message: '🐶 12 nouveaux leads à Toulon prêts pour toi !'
};

saveNotification(notification);
```

### Hunter → Jarbite
```javascript
// Quand Hunter envoie des messages
const notification = {
  from: 'hunter',
  to: 'jarbite',
  type: 'message_sent',
  timestamp: new Date().toISOString(),
  data: {
    count: 6,
    canal: 'email'
  },
  message: '🎯 6 messages envoyés par email ce matin'
};

saveNotification(notification);
```

### Wilson → Tous
```javascript
// Quand Wilson finit un site
const notification = {
  from: 'wilson',
  to: 'all',
  type: 'site_ready',
  timestamp: new Date().toISOString(),
  data: {
    client: 'Chez Nous',
    url: 'https://chez-nous.demo.com'
  },
  message: '🏗️ Site livré pour Chez Nous ! Prêt à présenter au client.'
};

broadcast(notification);
```

## Webhook interne

Pour déclencher une action chez un autre agent :

```bash
curl -X POST http://localhost:3000/api/internal/notify \
  -H "Content-Type: application/json" \
  -d '{
    "from": "hunter",
    "to": "wilson", 
    "type": "build_site",
    "lead_id": "cogolin-005",
    "priority": "high"
  }'
```

## Dashboard en temps réel

Le Office view se met à jour automatiquement quand :
- Un agent change de statut
- Une notification est envoyée
- Une tâche est complétée

Les agents peuvent voir en temps réel ce que les autres font.
