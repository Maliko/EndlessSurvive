// Automatischer Spieltest fuer das Balancing.
// Aufruf: node tools/bot-playtest.js [Schritte] [URL]
// Achtung: ueberschreibt den aktuellen Spielstand.
const { chromium } = require('playwright');

(async () => {
  const steps = +process.argv[2] || 300;
  const url = process.argv[3] || 'http://localhost:5080';
  const browser = await chromium.launch();
  const p = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  const errors = [];
  p.on('pageerror', e => errors.push(e.message));

  // Charakter anlegen: alle freien Punkte der Reihe nach verteilen
  await p.goto(url + '/new');
  await p.waitForSelector('.create-card');
  await p.fill('.field input', 'Bot');
  for (let i = 0; i < 40; i++) {
    const clicked = await p.evaluate((i) => {
      const btns = [...document.querySelectorAll('.create-row .stepper button')].filter(b => b.textContent.trim() === '+' && !b.disabled);
      if (!btns.length) return false;
      btns[i % btns.length].click();
      return true;
    }, i);
    if (!clicked) break;
    await p.waitForTimeout(20);
  }
  await p.click('button:has-text("Kapsel oeffnen")');
  await p.waitForSelector('.notice');
  await p.keyboard.press('Enter');

  const hp = async () => p.evaluate(() => {
    const [a, m] = document.querySelector('.hud .bar-hp .bar-value').innerText.split('/').map(x => +x.trim());
    return a / m;
  });
  const has = sel => p.evaluate(s => !!document.querySelector(s), sel);

  let events = 0, combats = 0, trades = 0;
  for (let step = 0; step < steps; step++) {
    // offene Dialoge abarbeiten
    for (let guard = 0; guard < 60; guard++) {
      if (await has('.combat-dialog')) {
        if (await has('.combat-result')) { combats++; await p.keyboard.press('Enter'); }
        else {
          const h = await hp();
          const canHeal = await has('.combat-items button');
          const canShoot = await p.evaluate(() => { const b = document.querySelectorAll('.combat-actions button')[1]; return b && !b.disabled; });
          if (h < 0.35 && canHeal) await p.evaluate(() => document.querySelector('.combat-items button')?.click());
          else if (h < 0.2) await p.keyboard.press('3');
          else await p.keyboard.press(canShoot ? '2' : '1');
        }
      } else if (await has('.trade-dialog')) {
        trades++;
        await p.keyboard.press('Escape'); // Bot tauscht nicht, er beendet den Handel
      } else if (await has('.event-dialog')) {
        if (await has('.event-dialog .options')) {
          const k = await p.evaluate(() => {
            const i = [...document.querySelectorAll('.event-dialog .option')].findIndex(x => !x.disabled);
            return i < 0 ? 1 : i + 1;
          });
          await p.keyboard.press(String(k));
          events++;
        } else await p.keyboard.press('Enter');
      } else if (await has('.notice')) {
        await p.keyboard.press('Enter');
      } else break;
      await p.waitForTimeout(40);
    }

    // freie Punkte verteilen
    await p.evaluate(() => {
      for (let i = 0; i < 20; i++) {
        const b = [...document.querySelectorAll('.char-panel .plus')];
        if (!b.length) break;
        b[i % b.length].click();
      }
    });

    if (await hp() < 0.5) { await p.keyboard.press('r'); await p.waitForTimeout(40); continue; }
    // zufaellig laufen, mit leichtem Drang nach Suedosten (weg vom Bunker)
    const key = Math.random() < 0.4 ? 'dsaw'[Math.floor(Math.random() * 4)] : (Math.random() < 0.5 ? 'd' : 's');
    await p.keyboard.press(key);
    await p.waitForTimeout(40);
  }

  await p.screenshot({ path: 'bot-playtest.png' });
  console.log(`Kaempfe ${combats} | Ereignisse ${events} | Haendler ${trades} | Fehler ${JSON.stringify(errors)}`);
  console.log((await p.locator('.stats').innerText()).replace(/\n/g, ' | '));
  console.log((await p.locator('.hud').innerText()).replace(/\n/g, ' '));
  await browser.close();
})();
