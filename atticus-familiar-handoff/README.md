# Atticus „Familiar“ – Design-Handoff für Codex

Redesign des Ask-Overlays unseres Atticus-Forks (Basis: https://github.com/SaarthurR/atticus-mac).
Gewählte Richtung: **Familiar**, ein Volt-gelber Glibber-Blob mit **einem Auge**, das immer anschaut, was gerade zählt.
Das Panel ist seine Sprechblase, kein Käfig.

## Was in diesem Paket liegt

| Pfad | Inhalt |
|---|---|
| `SPEC.md` | **Die verbindliche Spezifikation.** Tokens, Auge, alle States, Hero-Sequenz mit Timeline, Fehler- und Abbruch-Szenarien, Freigabe-Sicherheit, A11y und Akzeptanzkriterien. |
| `tokens/tokens.css` · `tokens/tokens.json` | Farben, Typo, Radien und Motion als CSS-Variablen und JSON. |
| `designs/*.dc.html` | Die Mockups und Prototypen als Referenz (siehe unten). |
| `designs/canvas.json` | Index der Artboards. |

### Die Design-Dateien

Die `.dc.html` sind Design-Component-Dateien aus einem Design-Canvas.
**Sie laufen nicht eigenständig im Browser**, weil sie eine Template-Runtime brauchen (`{{hole}}`, `<sc-if>`, `<sc-for>`, `class Component extends DCLogic`).
Nutze sie als exakte Referenz für Markup, Inline-Styles, SVG-Filter und Animationslogik.

| Datei | Wofür |
|---|---|
| `FamiliarWow.dc.html` | **Haupt-Referenz.** Hero-Sequenz mit 7 Szenarien. Die gesamte Animationslogik steckt in `renderVals()`: Zeitleiste, Goo-Filter, Specular-Licht, Squash und Blick. |
| `FamiliarEye.dc.html` | Augen-System: Anatomie, Blickrichtungen, Ausdrücke, Größen, Motion-Tabelle. |
| `FamiliarStates.dc.html` | Weitere States: Denken, Tipp-Composer, „Welche?“-Auswahl, Fehler mit Retry, Thread mit „Gelernt“, Übergabe an einen Hintergrund-Agenten. |
| `FamiliarProto.dc.html` | Früher Prototyp (Panel-basiert). Nur noch für die Augen-Logik relevant. |
| `Familiar.dc.html` | Erstes Familiar-Mockup. Überholt durch die Dateien oben. |
| `Main.dc.html`, `Halo.dc.html` | Die zwei verworfenen Richtungen (Instrument, Halo). Nur Kontext. |

## Wo das im Atticus-Code landet

- `ui/ui.html`: das Overlay im WKWebView. `window.ui.*` ist die API, die Swift aufruft: `listen`, `status`, `ask` (Freigabe/Retry), `pick`, `stopped`, `agentStarted`, `dictated` und weitere. **Diese API bleibt stabil**, neu sind nur Darstellung und Choreografie.
- `ui/orbs.js`: der bisherige Orb (Canvas, Presets). Wird durch den Blob ersetzt. `setState(...)`-Aufrufe in `ui.html` auf die neuen Blob-States mappen (siehe SPEC §4).
- `Atticus.swift`:
  - `loadPage()` inlined `orbs.js` am Marker `/*ORBS*/`.
  - Das Overlay ist ein `NSPanel` mit `.nonactivatingPanel`.
  - Für die Reise der Figur zu anderen Fenstern braucht es ein zusätzliches, durchsichtiges Stage-Fenster (SPEC §9).

## Empfohlene Umsetzungs-Reihenfolge

1. **Tokens und Panel-Look.** Warmschwarzes Panel, Bricolage Grotesque + Geist, Radius 28. Noch keine neue Choreografie.
2. **Blob statt Orb.** Erst eine Web-Version als SVG mit Goo- und Jelly-Filter wie in `FamiliarWow.dc.html`, Auge mit Blick-Zielen, Blinzeln, Squash-Federn. Alle bestehenden Orb-States mappen.
3. **Neue Freigabe-Karte.** Papier-Karte, Blick-Sweep über die Risikofelder, Gate, Hold-to-confirm, „Nicht kaufen“ und Ablauf. Sicherheitsrelevant, deshalb vor allem Show-Effekt.
4. **Fehler- und Abbruch-States** aus SPEC §7.
5. **Geburt aus dem Menüleisten-Tropfen** und das Panel, das aus dem Blob wächst.
6. **Reise zum Arbeitsfenster** (Stage-Fenster, Fenster-Rects per AX oder CGWindowList).
7. **Produktion:** Metal-SDF-Shader statt SVG-Blur, drei Sounds, Haptik.

Schritte 1–4 sind reines Web (`ui.html`/`orbs.js`). Ab Schritt 5 braucht es Swift.
