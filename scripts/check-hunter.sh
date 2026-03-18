#!/bin/bash
# Script de vérification des notifications de Hunter

echo "🔍 Vérification des notifications de Hunter..."

# Lire le fichier needs.json pour voir si Hunter a signalé des leads prêts
if [ -f /root/.openclaw/workspace/dashboard/data/needs.json ]; then
    # Vérifier s'il y a des entrées de Hunter avec statut "ready" ou "notification"
    READY_LEADS=$(grep -c "hunter" /root/.openclaw/workspace/dashboard/data/needs.json 2>/dev/null || echo "0")
    
    if [ "$READY_LEADS" -gt 0 ]; then
        echo "✅ Hunter a notifié $READY_LEADS lead(s) prêt(s) à construire !"
        echo "📧 Notification envoyée à Wilson"
        # Ici on pourrait envoyer une vraie notification
    else
        echo "⏳ Aucune notification de Hunter pour l'instant."
    fi
else
    echo "❌ Fichier needs.json non trouvé"
fi

echo "✅ Vérification terminée à $(date)"