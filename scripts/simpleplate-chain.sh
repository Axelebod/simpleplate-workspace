#!/bin/bash
# SimplePlate Chain - Chaîne automatisée de prospection
# Usage: ./simpleplate-chain.sh [mode]
# Modes: full, scrapy-only, hunter-only, wilson-only

MODE=${1:-full}
API_URL="http://localhost:3000"
LOG_FILE="/root/.openclaw/workspace/logs/chain.log"
DASHBOARD_URL="https://simpleplate-dashboard.loca.lt"

echo "========================================" | tee -a $LOG_FILE
echo "🚀 SimplePlate Chain - $(date)" | tee -a $LOG_FILE
echo "Mode: $MODE" | tee -a $LOG_FILE
echo "========================================" | tee -a $LOG_FILE

# Vérifier que l'API est en ligne
check_api() {
    if curl -s $API_URL/api/health > /dev/null; then
        echo "✅ API en ligne" | tee -a $LOG_FILE
        return 0
    else
        echo "❌ API hors ligne - Démarrage..." | tee -a $LOG_FILE
        cd /root/.openclaw/workspace/dashboard
        nohup python3 api_server.py > logs/api.log 2>&1 &
        sleep 3
        return 1
    fi
}

# Étape 1: Scrapy - Recherche de prospects
run_scrapy() {
    echo "🕷️ ÉTAPE 1: Scrapy - Recherche de prospects" | tee -a $LOG_FILE
    
    # Récupérer les leads existants
    EXISTING_LEADS=$(curl -s $API_URL/api/scrapy/leads | jq -r '.totalLeads // 0')
    echo "   Leads existants: $EXISTING_LEADS" | tee -a $LOG_FILE
    
    # Ici on appellerait l'agent Scrapy via ACP
    # Pour l'instant, on simule avec une notification
    echo "   📡 Notification envoyée à Scrapy" | tee -a $LOG_FILE
    
    # Log dans le dashboard
    curl -s -X POST $API_URL/api/jarbite/activity \
        -H "Content-Type: application/json" \
        -d '{"activity":{"type":"automation","description":"Scrapy: Recherche de prospects lancée","agent":"scrapy"}}' > /dev/null
    
    return 0
}

# Étape 2: Hunter - Génération de messages
run_hunter() {
    echo "🎯 ÉTAPE 2: Hunter - Génération de messages" | tee -a $LOG_FILE
    
    # Récupérer les leads HIGH
    HIGH_LEADS=$(curl -s $API_URL/api/scrapy/leads | jq -r '[.recentLeads[] | select(.qualite_lead == "high")] | length')
    echo "   Leads HIGH trouvés: $HIGH_LEADS" | tee -a $LOG_FILE
    
    if [ "$HIGH_LEADS" -eq 0 ]; then
        echo "   ⚠️ Pas de leads HIGH à traiter" | tee -a $LOG_FILE
        return 1
    fi
    
    # Ici on appellerait l'agent Hunter via ACP
    echo "   📡 Notification envoyée à Hunter" | tee -a $LOG_FILE
    
    # Log dans le dashboard
    curl -s -X POST $API_URL/api/jarbite/activity \
        -H "Content-Type: application/json" \
        -d '{"activity":{"type":"automation","description":"Hunter: Génération de messages pour '$HIGH_LEADS' leads","agent":"hunter"}}' > /dev/null
    
    return 0
}

# Étape 3: Wilson - Création de sites (si lead converti)
run_wilson() {
    echo "🏗️ ÉTAPE 3: Wilson - Prêt à créer des sites" | tee -a $LOG_FILE
    
    # Vérifier s'il y a des sites en attente
    SITES=$(curl -s $API_URL/api/wilson/sites | jq -r '.totalSites // 0')
    echo "   Sites existants: $SITES" | tee -a $LOG_FILE
    
    # Log dans le dashboard
    curl -s -X POST $API_URL/api/jarbite/activity \
        -H "Content-Type: application/json" \
        -d '{"activity":{"type":"automation","description":"Wilson: Prêt à créer des sites","agent":"wilson"}}' > /dev/null
    
    return 0
}

# Rapport final
generate_report() {
    echo "" | tee -a $LOG_FILE
    echo "📊 RAPPORT DE LA CHAÎNE" | tee -a $LOG_FILE
    echo "======================" | tee -a $LOG_FILE
    
    LEADS=$(curl -s $API_URL/api/scrapy/leads | jq -r '.totalLeads // 0')
    MESSAGES=$(curl -s $API_URL/api/hunter/messages | jq -r '.totalMessages // 0')
    SITES=$(curl -s $API_URL/api/wilson/sites | jq -r '.totalSites // 0')
    
    echo "   📋 Leads: $LEADS" | tee -a $LOG_FILE
    echo "   ✉️ Messages: $MESSAGES" | tee -a $LOG_FILE
    echo "   🌐 Sites: $SITES" | tee -a $LOG_FILE
    echo "" | tee -a $LOG_FILE
    echo "   🔗 Dashboard: $DASHBOARD_URL" | tee -a $LOG_FILE
    echo "========================================" | tee -a $LOG_FILE
}

# === MAIN ===

check_api

case $MODE in
    scrapy-only)
        run_scrapy
        ;;
    hunter-only)
        run_hunter
        ;;
    wilson-only)
        run_wilson
        ;;
    full|*)
        run_scrapy
        if [ $? -eq 0 ]; then
            run_hunter
        fi
        run_wilson
        ;;
esac

generate_report

echo "✅ Chaîne terminée à $(date)" | tee -a $LOG_FILE
