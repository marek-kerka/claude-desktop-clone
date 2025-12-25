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
- [ ] **Všechny nové funkce mají unit testy**
- [ ] **Testy procházejí lokálně (`./run_tests.sh`)**
- [ ] **Code coverage je ≥70%**
- [ ] Dokumentace je aktualizovaná
- [ ] UI je responzivní a funguje v dark mode
- [ ] Žádné hardcoded API klíče nebo citlivé údaje
- [ ] Commit messages jsou jasné a popisné
- [ ] SwiftLint warnings jsou opravené

## Testing

### Unit Tests

Před commitem spusťte testy:

```bash
cd LivesportClaude
./run_tests.sh
```

**Požadavky:**
- ✅ Všechny testy musí projít
- ✅ Code coverage ≥70%
- ✅ Žádné compiler warnings

### Psaní testů

Pro nové funkce vytvořte unit testy:

```swift
func testNewFeature() {
    // Arrange - připravte test data
    let model = MyModel()

    // Act - zavolejte testovanou funkci
    let result = model.doSomething()

    // Assert - ověřte výsledek
    XCTAssertEqual(result, expectedValue)
}
```

### Manuální testování

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

### CI/CD Pipeline

GitHub Actions automaticky spustí:
- Unit testy
- Build verification
- SwiftLint
- Coverage check

Pull requesty musí projít všemi checks.

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
