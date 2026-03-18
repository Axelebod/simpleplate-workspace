# Agent Automation System

## Objectif
Les agents doivent fonctionner 24/7 sans intervention humaine.

## Architecture

### Scrapy (Recherche) 🐶
**Automations:**
- Cron: Recherche quotidienne à 9h00
- Trigger: Quand moins de 50 leads en stock
- Action: Cherche 20 nouveaux leads → Les ajoute au dashboard

**Décisions auto:**
- Qualifie HIGH si: avis + photos + pas de site
- Ignore si: site existant ou activité inactive

### Hunter (Messages) 🎯  
**Automations:**
- Cron: Vérifie nouveaux leads toutes les 2h
- Trigger: Lead HIGH sans message
- Action: Génère message personnalisé → Marque "ready_to_send"

**Décisions auto:**
- Choisit le canal (email vs Facebook) selon dispo
- Adapte le ton selon le métier
- Planifie l'envoi (pas tout d'un coup)

### Wilson (Sites) 🏗️
**Automations:**
- Webhook: Quand lead répond "intéressé"
- Trigger: Commande reçue
- Action: Crée site en 10 min → Déploie → Notifie

**Décisions auto:**
- Choix template selon métier
- Génération contenu auto
- Déploiement sans validation

### Jarbite (Coordination) 👑
**Automations:**
- Cron: Rapport quotidien à 18h00
- Trigger: Alertes des agents
- Action: Rééquilibre, corrige, optimise

**Décisions auto:**
- Si backlog messages > 10: Alert Hunter
- Si leads < 20: Alert Scrapy
- Si sites en attente > 3: Alert Wilson

## File d'attente (Queue)
Chaque agent a sa queue:
- `queue/scrapy/todo.json`
- `queue/hunter/todo.json`  
- `queue/wilson/todo.json`

Les agents consomment leur queue en autonomie.

## Webhooks internes
```
POST /internal/webhook
{
  "event": "lead.responded",
  "lead_id": "xxx",
  "response": "intéressé"
}
→ Déclenche Wilson
```

## Monitoring auto
- Heartbeat toutes les 5 min
- Alertes Slack/email si agent down
- Logs centralisés

## Sécurité
- Limite: max 50 messages/jour (anti-spam)
- Validation auto: pas de doublons
- Pause auto: si taux de réponse < 1%

## Premier déploiement
1. Activer cron Scrapy (9h quotidien)
2. Activer cron Hunter (toutes les 2h)
3. Activer webhook Wilson (on-demand)
4. Activer rapport Jarbite (18h quotidien)

---
*Système en mode autonome.*
