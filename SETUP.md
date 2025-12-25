# Livesport Claude - Setup Guide

## Požadavky

- **macOS:** 13.0 (Ventura) nebo novější
- **Xcode:** 15.0 nebo novější
- **Anthropic API klíč:** Potřebujete platný API klíč od Anthropic

## Instalace

### 1. Konfigurace API klíče

Otevřete soubor a vložte váš Anthropic API klíč:

```swift
// LivesportClaude/LivesportClaude/App/AppConfiguration.swift
static let claudeAPIKey = "sk-ant-api03-..." // Váš API klíč
```

⚠️ **Důležité:** Nikdy necommitujte API klíč do gitu!

### 2. Otevření projektu v Xcode

Máte dvě možnosti:

#### Možnost A: Vytvoření projektu v Xcode (Doporučeno)

1. Otevřete Xcode
2. Vyberte **File > New > Project**
3. Zvolte **macOS > App**
4. Nastavte:
   - Product Name: `LivesportClaude`
   - Team: Váš team
   - Organization Identifier: `cz.livesport`
   - Bundle Identifier: `cz.livesport.LivesportClaude`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**
5. Uložte projekt do složky `LivesportClaude/`
6. **Smažte** automaticky vygenerované soubory (ContentView.swift, LivesportClaudeApp.swift)
7. **Přetáhněte** všechny složky z našeho projektu:
   - App/
   - Models/
   - Services/
   - Views/
   - Resources/
   - Info.plist

#### Možnost B: Ruční import souborů

1. Otevřete Xcode
2. Vyberte **File > New > Project**
3. Vytvořte základní Mac app
4. Přidejte všechny naše Swift soubory pomocí **File > Add Files to...**

### 3. Nastavení projektu

V Xcode project settings nastavte:

**General:**
- Minimum Deployments: macOS 13.0
- Bundle Identifier: `cz.livesport.LivesportClaude`

**Signing & Capabilities:**
- Nastavte váš development team

**Build Settings:**
- Swift Language Version: Swift 5

### 4. Build a spuštění

1. V Xcode stiskněte **⌘R** nebo klikněte na tlačítko Run
2. Aplikace by se měla zkompilovat a spustit
3. Měli byste vidět uvítací obrazovku

## První použití

1. **Vytvořit konverzaci:**
   - Klikněte na tlačítko **+** v levém panelu
   - Vyberte model (Sonnet 4.5 nebo Opus 4.5)

2. **Poslat zprávu:**
   - Napište text do dolního pole
   - Stiskněte Enter nebo klikněte na ↑
   - Odpověď od Claude se zobrazí streamovaně

3. **Přidat obrázek:**
   - Klikněte na ikonu 📎
   - Vyberte obrázek (PNG, JPEG, GIF, WebP)
   - Obrázek se přidá k vaší zprávě

4. **Nastavení:**
   - Klikněte na ikonu ⚙️ v toolbaru
   - Můžete změnit výchozí model a system prompt

## Struktura projektu

```
LivesportClaude/
├── LivesportClaude/
│   ├── App/
│   │   ├── LivesportClaudeApp.swift    # App entry point
│   │   └── AppConfiguration.swift       # Konfigurace (API klíč zde!)
│   ├── Models/
│   │   ├── ClaudeModel.swift           # Definice modelů
│   │   ├── Message.swift               # Message model
│   │   └── Conversation.swift          # Conversation model
│   ├── Services/
│   │   ├── ClaudeAPIClient.swift       # API komunikace
│   │   └── ConversationStorage.swift   # Lokální storage
│   ├── Views/
│   │   ├── ContentView.swift           # Hlavní view
│   │   ├── ChatView.swift              # Chat interface
│   │   ├── ConversationListView.swift  # Seznam konverzací
│   │   ├── MessageBubbleView.swift     # Message bubliny
│   │   └── SettingsView.swift          # Nastavení
│   └── Resources/
│       └── Assets.xcassets             # Assets (ikony, barvy)
└── README.md
```

## Řešení problémů

### Build chyby

**Chyba:** "No such module 'SwiftUI'"
- **Řešení:** Zkontrolujte že máte nastavený správný deployment target (macOS 13.0+)

**Chyba:** "Cannot find 'Message' in scope"
- **Řešení:** Ujistěte se, že všechny soubory jsou přidány do target membership

### Runtime problémy

**Aplikace crashuje při startu**
- Zkontrolujte že Info.plist je správně nakonfigurovaný
- Ověřte že všechny Views jsou správně importované

**API vrací chyby**
- Zkontrolujte že API klíč je správně nastavený v AppConfiguration.swift
- Ověřte že máte aktivní internetové připojení
- Zkontrolujte API limit na vašem Anthropic účtu

**Konverzace se neukládají**
- Aplikace ukládá data do `~/Library/Application Support/LivesportClaude/`
- Zkontrolujte oprávnění pro tuto složku

## Vývoj

### Přidání nových funkcí

Projekt je strukturovaný do logických částí:
- **Models**: Datové struktury
- **Services**: Business logika a API calls
- **Views**: UI komponenty

### Code style

- Používejte Swift naming conventions
- Komentujte složitý kód
- Udržujte views malé a znovupoužitelné

## Pokročilé funkce

### Export konverzací
1. Otevřete konverzaci
2. Klikněte na ikonu exportu (↑) v záhlaví
3. Vyberte formát (PDF nebo Markdown)
4. Uložte soubor

### Vyhledávání
1. Klikněte na ikonu lupy (🔍) v toolbaru
2. Zadejte hledaný text
3. Výsledky se zobrazí v reálném čase
4. Klikněte na výsledek pro přechod na konverzaci

### System Prompts
1. Otevřete Settings (⚙️)
2. Přejděte na tab "System Prompts"
3. Vyberte přednastavený prompt nebo vytvořte vlastní
4. Vybraný prompt se použije pro všechny nové konverzace

Dostupné presety:
- **Default Assistant** - Obecný asistent
- **Code Expert** - Pro programování a vývoj
- **Data Analyst** - Pro analýzu dat a statistiky
- **Product Manager** - Pro produktový management
- **Technical Writer** - Pro psaní dokumentace
- **DevOps Engineer** - Pro infrastrukturu a deployment

### Code Highlighting
- Automaticky detekuje code bloky v odpovědích
- Podporuje Swift, Python, JavaScript, TypeScript, SQL, JSON
- Copy tlačítko pro rychlé kopírování kódu

## Další kroky (budoucnost)

- [ ] Individuální API klíče pro zaměstnance
- [ ] Sdílení konverzací mezi zaměstnanci

## Podpora

Pro problémy a dotazy kontaktujte IT tým Livesport.

## License

Internal use only - Livesport s.r.o.
