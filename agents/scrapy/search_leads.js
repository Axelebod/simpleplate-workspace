const { chromium } = require('playwright');

async function searchBusinesses() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();
  
  const leads = [];
  const cities = ['Toulon', 'Hyères', 'Fréjus', 'Draguignan', 'Saint-Tropez', 'Sainte-Maxime', 'Brignoles', 'Le Luc'];
  const types = ['restaurant', 'coiffeur', 'plombier', 'électricien', 'garage', 'menuisier'];
  
  for (const city of cities) {
    for (const type of types) {
      try {
        console.log(`Recherche: ${type} à ${city}`);
        
        // Aller sur Google Maps
        await page.goto(`https://www.google.com/maps/search/${type}+${city}+Var`, { timeout: 30000 });
        await page.waitForTimeout(5000);
        
        // Attendre que les résultats chargent
        await page.waitForSelector('[data-result-index]', { timeout: 10000 }).catch(() => {});
        
        // Extraire les entreprises
        const businesses = await page.evaluate(() => {
          const results = [];
          const items = document.querySelectorAll('[data-result-index]');
          
          items.forEach((item, index) => {
            if (index >= 3) return; // Limiter à 3 par recherche
            
            const nameEl = item.querySelector('h3, .fontHeadlineSmall');
            const name = nameEl ? nameEl.textContent.trim() : '';
            
            if (name) {
              results.push({
                nom: name,
                type: '',
                ville: '',
                adresse: '',
                contact: '',
                email: '',
                facebook: '',
                instagram: '',
                site_web: false,
                qualite_lead: 'high',
                source: 'Google Maps',
                date_recherche: new Date().toISOString().split('T')[0],
                status: 'nouveau'
              });
            }
          });
          
          return results;
        });
        
        leads.push(...businesses);
        console.log(`Trouvé ${businesses.length} entreprises`);
        
        await page.waitForTimeout(2000);
      } catch (error) {
        console.error(`Erreur pour ${type} à ${city}:`, error.message);
      }
    }
  }
  
  await browser.close();
  
  // Sauvegarder les résultats
  const fs = require('fs');
  fs.writeFileSync('/root/.openclaw/workspace/agents/scrapy/leads_var.json', JSON.stringify({
    lastUpdated: new Date().toISOString(),
    totalLeads: leads.length,
    leads: leads
  }, null, 2));
  
  console.log(`\n✅ Total: ${leads.length} leads trouvés`);
  console.log('Résultats sauvegardés dans leads_var.json');
}

searchBusinesses().catch(console.error);
