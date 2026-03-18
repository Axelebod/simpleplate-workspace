#!/bin/bash
# Hunter Automation Script
# Runs every 2 hours

LOG_FILE="/root/.openclaw/workspace/logs/hunter-auto.log"
DASHBOARD_DIR="/root/.openclaw/workspace/dashboard"
CONFIG_FILE="/root/.openclaw/workspace/agent-config.json"

echo "[$(date)] Hunter automation started" >> $LOG_FILE

# Check if auto mode is enabled
if ! grep -q '"hunter".*"enabled": true' $CONFIG_FILE; then
    echo "[$(date)] Auto mode disabled, exiting" >> $LOG_FILE
    exit 0
fi

# Get leads without messages
node -e "
    const fs = require('fs');
    const leads = JSON.parse(fs.readFileSync('$DASHBOARD_DIR/data/scrapy/leads.json')).recentLeads;
    const messages = JSON.parse(fs.readFileSync('$DASHBOARD_DIR/data/hunter/messages.json'));
    
    const leadsNeedingMessages = leads.filter(l => 
        l.qualite_lead === 'high' && 
        !messages.messages.some(m => m.leadId === l.id)
    ).slice(0, 5); // Max 5 per run
    
    console.log(JSON.stringify(leadsNeedingMessages));
" > /tmp/leads_to_message.json 2>> $LOG_FILE

# Generate messages for each lead
cat /tmp/leads_to_message.json | node -e "
    const fs = require('fs');
    const leads = JSON.parse(fs.readFileSync(0, 'utf8'));
    const messages = JSON.parse(fs.readFileSync('$DASHBOARD_DIR/data/hunter/messages.json'));
    
    const templates = {
        restaurant: (name, ville) => \`Bonjour \${name} ! 🍽️\\n\\nJe suis tombé sur votre restaurant à \${ville} et je me suis rendu compte que vous n'aviez pas encore de site web.\\n\\nJe crée des sites simples et modernes pour les restaurants, avec prise de RDV et affichage de la carte.\\n\\nÇa peut vraiment aider à attirer plus de clients qui cherchent où manger dans le coin.\\n\\nSi ça vous intéresse, je peux vous montrer un exemple adapté à votre restaurant 👍\\n\\nAxel - SimplePlate\`,
        coiffeur: (name, ville) => \`Bonjour \${name} ! 💇\\n\\nJ'ai repéré votre salon à \${ville} et je me dis : avec tout ce que vous faites sur le terrain, les clients qui vous cherchent en ligne devraient vous trouver facilement.\\n\\nJe crée des sites vitrines clés-en-main pour les coiffeurs : simples, modernes, sans contrat d'abonnement.\\n\\nIntéressé pour qu'on en parle ?\\n\\nAxel - SimplePlate\`,
        artisan: (name, ville) => \`Bonjour \${name} ! 🔧\\n\\nJ'ai repéré votre entreprise à \${ville}. Aujourd'hui, quand vos futurs clients cherchent un artisan sur Google, vous n'apparaissez pas.\\n\\nJe propose des sites web vitrines clés-en-main pour les artisans du Var : simples, efficaces, sans frais mensuels cachés.\\n\\nÇa vous tente qu'on jette un œil à ce que ça pourrait donner ?\\n\\nAxel - SimplePlate\`
    };
    
    leads.forEach(lead => {
        const type = lead.type?.toLowerCase().includes('restaurant') ? 'restaurant' :
                     lead.type?.toLowerCase().includes('coiffeur') ? 'coiffeur' : 'artisan';
        
        const message = {
            id: 'msg-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9),
            leadId: lead.id,
            leadNom: lead.nom,
            type: lead.type,
            ville: lead.ville,
            email: lead.email,
            telephone: lead.contact,
            priorite: lead.qualite_lead,
            canal: lead.email ? 'email' : lead.facebook ? 'facebook' : 'telephone',
            status: 'draft',
            dateCreation: new Date().toISOString(),
            message: templates[type](lead.nom, lead.ville)
        };
        
        messages.messages.push(message);
        messages.totalMessages = messages.messages.length;
    });
    
    messages.lastUpdated = new Date().toISOString();
    fs.writeFileSync('$DASHBOARD_DIR/data/hunter/messages.json', JSON.stringify(messages, null, 2));
    console.log('Generated', leads.length, 'new messages');
" >> $LOG_FILE 2>&1

echo "[$(date)] Hunter automation complete" >> $LOG_FILE
