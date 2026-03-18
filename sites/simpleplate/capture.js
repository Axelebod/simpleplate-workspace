const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({
        headless: 'new',
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 900 });
    await page.goto('file:///root/.openclaw/workspace/sites/simpleplate/index.html', { waitUntil: 'networkidle0' });
    await page.screenshot({ path: '/root/.openclaw/workspace/sites/simpleplate/preview.png', fullPage: true });
    await browser.close();
    console.log('Screenshot saved!');
})();