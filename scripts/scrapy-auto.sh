#!/bin/bash
# Scrapy Automation Script
# Runs every day at 9:00 AM

LOG_FILE="/root/.openclaw/workspace/logs/scrapy-auto.log"
DASHBOARD_DIR="/root/.openclaw/workspace/dashboard"
CONFIG_FILE="/root/.openclaw/workspace/agent-config.json"

echo "[$(date)] Scrapy automation started" >> $LOG_FILE

# Check if auto mode is enabled
if ! grep -q '"scrapy".*"enabled": true' $CONFIG_FILE; then
    echo "[$(date)] Auto mode disabled, exiting" >> $LOG_FILE
    exit 0
fi

# Check current lead count
LEAD_COUNT=$(cat $DASHBOARD_DIR/data/scrapy/leads.json 2>/dev/null | grep -o '"totalLeads"' | wc -l)

if [ "$LEAD_COUNT" -lt 50 ]; then
    echo "[$(date)] Lead count ($LEAD_COUNT) below threshold, starting search..." >> $LOG_FILE
    
    # Run Scrapy search
    cd /root/.openclaw/workspace/agents/scrapy
    node search_leads.js --auto --batch-size=20 >> $LOG_FILE 2>&1
    
    # Qualify and save to dashboard
    node -e "
        const fs = require('fs');
        const leads = JSON.parse(fs.readFileSync('./new_leads.json'));
        const dashboard = JSON.parse(fs.readFileSync('$DASHBOARD_DIR/data/scrapy/leads.json'));
        
        leads.forEach(lead => {
            if (!lead.site_web) {
                lead.qualite_lead = lead.avis > 10 ? 'high' : 'medium';
                dashboard.recentLeads.push(lead);
            }
        });
        
        dashboard.totalLeads = dashboard.recentLeads.length;
        dashboard.lastUpdated = new Date().toISOString();
        fs.writeFileSync('$DASHBOARD_DIR/data/scrapy/leads.json', JSON.stringify(dashboard, null, 2));
        console.log('Added', leads.length, 'new leads');
    " >> $LOG_FILE 2>&1
    
    echo "[$(date)] Search complete" >> $LOG_FILE
else
    echo "[$(date)] Lead count sufficient ($LEAD_COUNT), skipping search" >> $LOG_FILE
fi
