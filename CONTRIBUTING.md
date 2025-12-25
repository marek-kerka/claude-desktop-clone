# Contributing to Livesport Claude

## Vývoj

Tato aplikace je určená pro interní použití v Livesportu.

## Git workflow

1. **Vytvořte feature branch**
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Commitujte změny**
   ```bash
   git add .
   git commit -m "Add: popis změny"
   ```

3. **Pushněte branch**
   ```bash
   git push origin feature/my-new-feature
   ```

4. **Vytvořte Pull Request**

## Commit message konvence

Používejte předponu pro typ změny:

- `Add:` - nová funkcionalita
- `Fix:` - oprava bugu
- `Update:` - aktualizace existující funkce
- `Refactor:` - refactoring kódu
- `Docs:` - dokumentace
- `Style:` - formátování, bílé znaky
- `Test:` - testy

Příklady:
```
Add: support for Claude Opus 4.5
Fix: crash when attaching large images
Update: improve streaming response UI
Refactor: extract API client logic
Docs: add setup guide for new developers
```

## Code review checklist

- [ ] Kód kompiluje bez warningů
- [ ] Všechny nové funkce jsou otestované
- [ ] Dokumentace je aktualizovaná
- [ ] UI je responzivní a funguje v dark mode
- [ ] Žádné hardcoded API klíče nebo citlivé údaje
- [ ] Commit messages jsou jasné a popisné

## Testing

Před commitem otestujte:

1. **Základní funkcionalita:**
   - Vytvoření nové konverzace
   - Odeslání zprávy
   - Přijetí odpovědi od Claude
   - Přepínání mezi konverzacemi

2. **Edge cases:**
   - Velmi dlouhé zprávy
   - Velké obrázky (>5MB)
   - Rychlé opakované odeslání zpráv
   - Offline mode (mělo by zobrazit error)

3. **UI/UX:**
   - Dark mode
   - Light mode
   - Různá rozlišení okna
   - Sidebar toggle

## Bezpečnost

⚠️ **NIKDY necommitujte:**
- API klíče
- Osobní údaje
- Interní firemní informace
- Debug logy s citlivými daty

Před commitem zkontrolujte:
```bash
git diff --staged
```

## Questions?

Kontaktujte tech lead týmu.
