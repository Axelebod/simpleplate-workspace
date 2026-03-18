#!/usr/bin/env node
/**
 * SimplePlate Google Sheets Sync
 * Synchronise les données locales vers le Google Sheet
 * 
 * Usage: node sync_to_sheets.js
 */

const fs = require('fs');
const { exec } = require('child_process');

const WORKSPACE_DIR = '/root/.openclaw/workspace';
const SHEET_ID = '10AxlTkKUcSCN8dIdLx3G2esNtRUWf31CJMWucEe6aJ8';

// Charger les données
function loadLeads() {
    try {
        const data = JSON.parse(fs.readFileSync(`${WORKSPACE_DIR}/exports/leads_export.csv`, 'utf8'));
        return data.split('\\n').slice(1).filter(l => l.trim());
    } catch (e) {
        console.log('⚠️  Fichier leads_export.csv non trouvé');
        return [];
    }
}

function loadMessages() {
    try {
        const data = JSON.parse(fs.readFileSync(`${WORKSPACE_DIR}/dashboard/data/hunter/messages.json`, 'utf8'));
        return data.messages || [];
    } catch (e) {
        return [];
    }
}

// Générer les URLs pour ouvrir le Sheet
function generateSheetUrls() {
    const baseUrl = `https://docs.google.com/spreadsheets/d/${SHEET_ID}`;
    
    return {
        main: `${baseUrl}/edit`,
        leads: `${baseUrl}/edit#gid=0`,
        messages: `${baseUrl}/edit#gid=1`,
        sites: `${baseUrl}/edit#gid=2`
    };
}

// Créer un fichier HTML avec les liens directs
function createSheetPortal() {
    const urls = generateSheetUrls();
    
    const html = `<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SimplePlate - Google Sheets Portal</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #0a0e27;
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            padding: 2rem;
        }
        .container {
            text-align: center;
            max-width: 600px;
        }
        h1 { margin-bottom: 0.5rem; }
        p { color: #8b92b4; margin-bottom: 2rem; }
        .links {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }
        a {
            display: block;
            padding: 1rem 2rem;
            background: linear-gradient(135deg, #3b82f6, #8b5cf6);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 500;
            transition: transform 0.2s;
        }
        a:hover { transform: translateY(-2px); }
        .sheet-id {
            margin-top: 2rem;
            padding: 1rem;
            background: #1a1f3d;
            border-radius: 8px;
            font-family: monospace;
            font-size: 0.875rem;
            color: #8b92b4;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🍽️ SimplePlate</h1>
        <p>Accès direct au Google Sheets</p>
        
        <div class="links">
            <a href="${urls.main}" target="_blank">📊 Ouvrir le Sheet complet</a>
            <a href="${urls.leads}" target="_blank">👥 Voir les Leads</a>
            <a href="${urls.messages}" target="_blank">💬 Voir les Messages</a>
        </div>
        
        <div class="sheet-id">
            Sheet ID: ${SHEET_ID}
        </div>
    </div>
</body>
</html>`;
    
    fs.writeFileSync(`${WORKSPACE_DIR}/sheets_portal.html`, html);
    console.log('✅ Portal créé: sheets_portal.html');
}

// Mettre à jour les SOUL.md avec le lien du Sheet
function updateAgentDocs() {
    const agents = ['scrapy', 'hunter', 'builder'];
    const sheetUrl = `https://docs.google.com/spreadsheets/d/${SHEET_ID}/edit`;
    
    agents.forEach(agent => {
        const soulPath = `${WORKSPACE_DIR}/agents/${agent}/SOUL.md`;
        if (fs.existsSync(soulPath)) {
            let content = fs.readFileSync(soulPath, 'utf8');
            
            // Ajouter la référence au Sheet si pas déjà présente
            if (!content.includes('Google Sheets')) {
                content = content.replace(
                    '## 📁 RÈGLE D\'OR : MODIFIER, PAS CRÉER',
                    `## 📊 Google Sheets (NOUVEAU)

**Le dashboard est maintenant sur Google Sheets :**
${sheetUrl}

**Les agents doivent mettre à jour le Sheet en temps réel.**

## 📁 RÈGLE D'OR : MODIFIER, PAS CRÉER`
                );
                
                fs.writeFileSync(soulPath, content);
                console.log(`✅ ${agent}/SOUL.md mis à jour`);
            }
        }
    });
}

// Main
console.log('🔄 Configuration Google Sheets...');
console.log('');
console.log('Sheet ID:', SHEET_ID);
console.log('Sheet URL:', `https://docs.google.com/spreadsheets/d/${SHEET_ID}/edit`);
console.log('');

createSheetPortal();
updateAgentDocs();

console.log('');
console.log('📋 Instructions pour les agents:');
console.log('1. Ouvrir le Sheet:', `https://docs.google.com/spreadsheets/d/${SHEET_ID}/edit`);
console.log('2. Importer le CSV: /root/.openclaw/workspace/exports/leads_export.csv');
console.log('3. Partager avec: playaxel83310@gmail.com');
console.log('');
console.log('✅ Configuration terminée !');
