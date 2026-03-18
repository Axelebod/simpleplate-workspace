#!/usr/bin/env python3
"""
SimplePlate Google Sheets Sync
Synchronise les données entre le workspace et Google Sheets
"""

import json
import os
from datetime import datetime

# Configuration
SHEET_ID = "YOUR_SHEET_ID_HERE"  # À remplacer après création
WORKSPACE_DIR = "/root/.openclaw/workspace"

def load_json(filepath):
    """Charge un fichier JSON"""
    try:
        with open(filepath, 'r') as f:
            return json.load(f)
    except:
        return {}

def export_leads_to_csv():
    """Exporte les leads vers CSV pour import Google Sheets"""
    leads_data = load_json(f"{WORKSPACE_DIR}/dashboard/data/scrapy/leads.json")
    
    csv_lines = ["ID,Nom,Type,Ville,Téléphone,Email,Site Web,Qualité,Statut"]
    
    for lead in leads_data.get("recentLeads", []):
        csv_lines.append(
            f"{lead.get('id','')},{lead.get('nom','')},{lead.get('type','')},"
            f"{lead.get('ville','')},{lead.get('contact','')},{lead.get('email','')},"
            f"{'Oui' if lead.get('site_web') else 'Non'},{lead.get('qualite_lead','')},"
            f"{lead.get('status','nouveau')}"
        )
    
    output_file = f"{WORKSPACE_DIR}/exports/leads_export.csv"
    os.makedirs(f"{WORKSPACE_DIR}/exports", exist_ok=True)
    
    with open(output_file, 'w') as f:
        f.write('\n'.join(csv_lines))
    
    print(f"✅ Leads exportés: {output_file}")
    return output_file

def export_messages_to_csv():
    """Exporte les messages vers CSV"""
    messages_data = load_json(f"{WORKSPACE_DIR}/dashboard/data/hunter/messages.json")
    
    csv_lines = ["ID,Lead ID,Entreprise,Ville,Canal,Statut,Message"]
    
    for msg in messages_data.get("messages", []):
        # Tronquer le message pour CSV
        message = msg.get('message', '').replace('\n', ' ')[:100]
        csv_lines.append(
            f"{msg.get('id','')},{msg.get('leadId','')},{msg.get('leadNom','')},"
            f"{msg.get('ville','')},{msg.get('canal','')},{msg.get('status','')},"
            f"\"{message}\""
        )
    
    output_file = f"{WORKSPACE_DIR}/exports/messages_export.csv"
    
    with open(output_file, 'w') as f:
        f.write('\n'.join(csv_lines))
    
    print(f"✅ Messages exportés: {output_file}")
    return output_file

def generate_setup_script():
    """Génère un script pour configurer l'API Google Sheets"""
    script = '''#!/bin/bash
# Setup Google Sheets API

echo "=== Setup Google Sheets API pour SimplePlate ==="
echo ""
echo "1. Va sur https://console.cloud.google.com/"
echo "2. Crée un projet 'SimplePlate'"
echo "3. Active l'API Google Sheets"
echo "4. Crée des credentials (Service Account)"
echo "5. Télécharge le fichier JSON"
echo "6. Place-le ici: ~/.openclaw/workspace/google-credentials.json"
echo ""
echo "Puis exécute: pip3 install gspread oauth2client"
echo ""
'''
    
    with open(f"{WORKSPACE_DIR}/setup_google_sheets.sh", 'w') as f:
        f.write(script)
    os.chmod(f"{WORKSPACE_DIR}/setup_google_sheets.sh", 0o755)
    
    print(f"✅ Script de setup créé: {WORKSPACE_DIR}/setup_google_sheets.sh")

if __name__ == "__main__":
    print("🔄 Export des données pour Google Sheets...")
    print("")
    
    export_leads_to_csv()
    export_messages_to_csv()
    generate_setup_script()
    
    print("")
    print("📋 Prochaines étapes:")
    print("1. Installe les dépendances: pip3 install gspread oauth2client")
    print("2. Configure l'API Google Sheets (voir setup_google_sheets.sh)")
    print("3. Importe les CSV dans Google Sheets")
    print("4. Partage le Sheet avec: playaxel83310@gmail.com")
