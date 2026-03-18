#!/bin/bash
# Vérification automatique des leads prêts à construire

echo "🔍 Vérification des leads prêts à construire..."
echo "📅 $(date)"
echo ""

# Vérifier les leads avec statut "contacted-positive" ou "ready" ou "approved"
READY_COUNT=$(grep -c '"status": "contacted-positive"\|"status": "ready"\|"status": "approved"' /root/.openclaw/workspace/dashboard/data/scrapy/leads.json 2>/dev/null || echo "0")
TOTAL_LEADS=$(grep -c '"status":' /root/.openclaw/workspace/dashboard/data/scrapy/leads.json 2>/dev/null || echo "0")

echo "📊 Statistiques :"
echo "   • Total leads : $TOTAL_LEADS"
echo "   • Prêts à construire : $READY_COUNT"
echo ""

if [ "$READY_COUNT" -gt 0 ] 2>/dev/null; then
    echo "✅ $READY_COUNT lead(s) prêt(s) à construire !"
    echo "🚀 Wilson peut démarrer la construction"
    echo ""
    # Afficher les noms des leads prêts
    grep -B 5 '"status": "contacted-positive"\|"status": "ready"\|"status": "approved"' /root/.openclaw/workspace/dashboard/data/scrapy/leads.json | grep '"nom":' | head -5
else
    echo "⏳ Aucun lead prêt pour l'instant"
    echo "📋 Hunter doit encore contacter les prospects"
    echo ""
    echo "💡 Prochaine vérification dans 1 heure"
fi

echo ""
echo "✅ Vérification terminée"