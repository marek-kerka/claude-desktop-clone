# Quick Start - 5 minut k fungující aplikaci

## Rychlý setup (macOS)

### 1. Nastavte API klíč (1 minuta)

Otevřete v editoru:
```
LivesportClaude/LivesportClaude/App/AppConfiguration.swift
```

Nahraďte:
```swift
static let claudeAPIKey = "YOUR_ANTHROPIC_API_KEY_HERE"
```

Vaším API klíčem:
```swift
static let claudeAPIKey = "sk-ant-api03-xxxxx..."
```

### 2. Otevřete v Xcode (2 minuty)

**Varianta A - Vytvoření nového projektu:**

1. Otevřete Xcode
2. **File > New > Project**
3. Vyberte **macOS > App**
4. Nastavte:
   - Product Name: `LivesportClaude`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Bundle ID: `cz.livesport.LivesportClaude`
5. Uložte do složky tohoto repozitáře
6. **Přetáhněte** všechny složky z `LivesportClaude/LivesportClaude/` do Xcode project navigatoru

**Varianta B - Import Package.swift (jednodušší):**

1. V terminálu:
   ```bash
   cd LivesportClaude
   open Package.swift
   ```
2. Xcode se otevře automaticky
3. Počkejte na načtení package dependencies

### 3. Build & Run (2 minuty)

1. V Xcode stiskněte **⌘R**
2. Aplikace se zkompiluje a spustí
3. Klikněte na **+** pro novou konverzaci
4. Začněte chatovat!

## Hotovo! 🎉

Aplikace běží a jste připraveni používat Claude.

## Co dál?

- 📖 Přečtěte si [SETUP.md](SETUP.md) pro detailní dokumentaci
- 🔧 Otevřete Settings (⚙️) pro konfiguraci
- 💡 Vyzkoušejte přidat obrázek (📎 tlačítko)

## Problém?

Nejčastější problémy:

**Build chyba:**
- Zkontrolujte že máte Xcode 15+
- Deployment target musí být macOS 13.0+

**API chyba:**
- Ověřte API klíč v AppConfiguration.swift
- Zkontrolujte internetové připojení

Více v [SETUP.md](SETUP.md#řešení-problémů)
