#!/bin/bash
# Wilson Automation Script
# Triggered by webhook when lead responds

LOG_FILE="/root/.openclaw/workspace/logs/wilson-auto.log"
DASHBOARD_DIR="/root/.openclaw/workspace/dashboard"
CONFIG_FILE="/root/.openclaw/workspace/agent-config.json"
SITE_DIR="/root/.openclaw/workspace/sites"

echo "[$(date)] Wilson automation started" >> $LOG_FILE

# Check if auto mode is enabled
if ! grep -q '"wilson".*"enabled": true' $CONFIG_FILE; then
    echo "[$(date)] Auto mode disabled, exiting" >> $LOG_FILE
    exit 0
fi

# Read webhook payload
PAYLOAD=$1
if [ -z "$PAYLOAD" ]; then
    echo "[$(date)] No payload received" >> $LOG_FILE
    exit 1
fi

LEAD_ID=$(echo $PAYLOAD | grep -o '"lead_id":"[^"]*"' | cut -d'"' -f4)

echo "[$(date)] Building site for lead: $LEAD_ID" >> $LOG_FILE

# Get lead info and build site
node -e "
    const fs = require('fs');
    const leads = JSON.parse(fs.readFileSync('$DASHBOARD_DIR/data/scrapy/leads.json')).recentLeads;
    const lead = leads.find(l => l.id === '$LEAD_ID');
    
    if (!lead) {
        console.log('Lead not found');
        process.exit(1);
    }
    
    // Select template
    const template = lead.type?.toLowerCase().includes('restaurant') ? 'restaurant' :
                     lead.type?.toLowerCase().includes('coiffeur') ? 'coiffeur' : 'artisan';
    
    // Create site directory
    const sitePath = '$SITE_DIR/' + lead.nom.toLowerCase().replace(/\s+/g, '-');
    fs.mkdirSync(sitePath, { recursive: true });
    
    // Copy template
    const templatePath = '$DASHBOARD_DIR/../templates/' + template;
    fs.cpSync(templatePath, sitePath, { recursive: true });
    
    // Customize index.html
    let html = fs.readFileSync(sitePath + '/index.html', 'utf8');
    html = html.replace(/{{NOM}}/g, lead.nom);
    html = html.replace(/{{VILLE}}/g, lead.ville);
    html = html.replace(/{{TYPE}}/g, lead.type);
    html = html.replace(/{{ADRESSE}}/g, lead.adresse || '');
    html = html.replace(/{{TELEPHONE}}/g, lead.contact || '');
    html = html.replace(/{{EMAIL}}/g, lead.email || '');
    
    fs.writeFileSync(sitePath + '/index.html', html);
    
    // Update dashboard
    const sites = JSON.parse(fs.readFileSync('$DASHBOARD_DIR/data/builder/sites.json'));
    sites.sites.push({
        id: 'site-' + Date.now(),
        leadId: lead.id,
        nom: lead.nom,
        type: lead.type,
        ville: lead.ville,
        template: template,
        path: sitePath,
        status: 'ready',
        createdAt: new Date().toISOString()
    });
    sites.totalSites = sites.sites.length;
    fs.writeFileSync('$DASHBOARD_DIR/data/builder/sites.json', JSON.stringify(sites, null, 2));
    
    console.log('Site built:', sitePath);
" >> $LOG_FILE 2>&1

echo "[$(date)] Site build complete for $LEAD_ID" >> $LOG_FILE
