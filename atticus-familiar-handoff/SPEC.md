# Familiar – Spezifikation

## 1. Intent Brief

- **Nutzer:** Mac-Power-User und Entwickler, viele Anfragen am Tag.
- **Hauptaktion:** Shortcut halten, sprechen, kurz hinschauen, in Sekunden zurück an die Arbeit.
- **Nebenaktionen:** lange Aufgaben verfolgen, riskante Aktionen freigeben, Antwort kopieren oder neu fragen, diktieren.
- **Kontext:** schwebt über der aktiven App, periphere Aufmerksamkeit, **nimmt nie den Fokus**, liegt über hellen und dunklen Hintergründen.
- **Worst Case:** etwas Ungelesenes freigeben (Kauf, Senden, Löschen), oder ein Overlay, das Arbeit verdeckt oder langsam wirkt, sodass man es nicht mehr nutzt.
- **Leitsatz:** Die Figur lebt auf dem Bildschirm, das Panel ist ihre Sprechblase. WOW darf nie Tempo oder Sicherheit kosten und muss den 50. Aufruf am Tag überleben.

## 2. Tokens (siehe `tokens/`)

| Token | Wert | Verwendung |
|---|---|---|
| volt | `#D4FF3A` | Körper, Marke, Fortschritt |
| volt-light / volt-deep | `#EEFF9A` / `#9CBF14` | Radialverlauf des Körpers (Zentrum −30 %/−35 %) |
| rim | `#F7FFC8` | 1,5 px Randlicht unten, Deckkraft 0,7 |
| subsurface | `#F2FF9E` | inneres Leuchten, +6 px nach rechts unten, Blur 6–10, Deckkraft 0,55 |
| ink | `#0E0F0C` | Pupille, Text auf Volt und Papier |
| panel | `#15160F` bei 94–96 % | Overlay-Fläche, `backdrop-filter: blur(28px) saturate(1.4)` |
| paper / paper-ink | `#F3F0E6` / `#0E0F0C` | Freigabe-Karte |
| text / muted | `#F2F1EA` / `#8B8C80` (alt `#A9A797`) | Text auf dem Panel |
| amber | `#FFB020` | „Braucht dich“, Ungeduld vor Ablauf |
| alarm / alarm-on-paper | `#FF4D2E` / `#B3200A` | Risiko-Band, Text auf Papier |
| dull | `#B9C95A` | Fehler-Stimmung (matter Körper) |
| glow | `rgba(212,255,58,.16–.22)`, r 70 | Lichtspritzer auf der Fläche unter der Figur |
| highlight | `rgba(212,255,58,.35)` | Zeile, die das Auge gerade „liest“ |
| Agenten-Farben | `#7CF5FF`, `#FF9BE0`, `#B9A6FF` | Hintergrund-Agenten. Amber bleibt reserviert. |

**Typo:**

| Rolle | Schrift | Größen |
|---|---|---|
| Display | Bricolage Grotesque 650 (opsz) | Status 22/26, Lead 18/24, Betrag 32 |
| Body | Geist 400/500/600 | 15/24 Antwort, 13 Request, 12.5 Meta |
| Mono | Geist Mono | Zeiten, Countdown, Labels mit 0,06–0,08em Sperrung, uppercase |

**Radien:** Panel 28, Karte 20, Mini-Screen 14, Buttons pill (999), Chips 10, Hold-Button 14.

**Schatten:**

| Element | Schatten |
|---|---|
| Panel | `0 24px 60px rgba(0,0,0,.45), 0 0 0 1px rgba(212,255,58,.10)` |
| Kontaktschatten unter der Figur | Ellipse 40×8, Ink 35 %, Blur 3–4. Nur wenn sie sitzt. |

## 3. Die Figur

- **Körper:** Metaball, 56 px im Overlay (32 kompakt, 24 Diktat, 16 Menüleiste).
- **Pupille:** Ink, r 7–8 (bei 56 px), Bewegungsradius ±7.
- **Catchlight:** weiß, r 2,6, Versatz (2,8|−2,8) zur Pupille.
- **Unter 24 px:** kein Catchlight, dafür eine größere Pupille.
- **Squash:** volumenerhaltend, `sx = 1/sy`, Ankerpunkt unten.
  - Feder für die Landung: Steifigkeit 420, Dämpfung 24, Masse 1.
  - Landeimpuls: sy 0,82.
- **Blinzeln:** scaleY 1 → 0,1 → 1 in 120–140 ms, zufällig alle 3–6 s. Nie im „Fertig“-Squint.
- **Blick = Aufmerksamkeit.** Ziele sind echte Bildschirmpunkte, nicht feste Icons:

| State | Blickziel |
|---|---|
| Zuhören | Mauszeiger, wenn näher als 300 px, sonst leicht nach unten zu dir (0 | 1,5) |
| Denken / Schlucken | oben rechts (0 | −5), beim Hängen langsam driftend |
| Arbeiten | eigener Geister-Cursor in Chrome, Körper lehnt sich ≤ 4 px hin, Nicken (sy −0,06) bei jedem Klick |
| Freigabe | Sakkaden über Betrag → Karte → Fahrt → Hold-Button, je 220 ms (40 ms Sprung, Rest Verweilen) |
| Fehler | erst aufs Problem in Chrome, dann nach unten (0 | 4), dann zu dir |
| Fertig | Squint-Bogen statt Pupille (Pfad `M-8 2 Q0 -7 8 2`, Strich 3,8) |
| Mikro fehlt | Auge geschlossen (Pfad `M-8 -1 Q0 5 8 -1`) |

- **Ausdrücke:** Idle (Lid halb), Pleased (Squint + 4 px Hüpfer), Alert (amber, gestreckt, kleine Pupille, still), Sad (grau/matt, 10 % abgesackt), Shrug (seitliches Wackeln, 4 px, Abklingzeit 240 ms), Paused (hohler Körper), Safe-Mode-aus (dauerhaftes rotes Badge).

## 4. Mapping der bestehenden Orb-States

Ersetze `setState(...)` und die Presets in `orbs.js`:

| alt (orbs.js) | neu |
|---|---|
| breathing | Idle: atmet alle 4 s, Lid halb |
| listening | Zuhören: Körperradius ±4 % nach Mic-RMS (60 ms geglättet), Blick zur Maus |
| solving / searching | Denken: Kneten 2,4 s, Blick oben rechts; Suchen: Pupille scannt links ↔ rechts in 1,4 s |
| working | Arbeiten: Blick auf Mini-Screen oder Cursor, Satellit kreist einmal pro Schritt |
| connecting | Denken, ohne Satellit |
| Freigabe (`ui.ask`) | Alert: amber, Blick-Sweep (§6) |
| Fertig | Pleased → Check-Morph |
| Fehler (`workerFailed`, Retry-Karte) | Sad (§7) |

## 5. Hero-Sequenz (Referenz: `FamiliarWow.dc.html`, 1280×800)

Positionen gelten im 1280×800-Frame. HOME (1212|72), ICON (1132|12), PERCH auf Chrome (690|66), CARD (1190|118).

| t (ms) | Ereignis |
|---|---|
| 0 | Taste gedrückt. Menüleisten-Punkt skaliert 1 → 1,6. **Mikro ist sofort live**, unabhängig von der Animation. |
| 40–160 | Tropfen fällt am Goo-Faden vom ICON nach HOME (Bezier, Kontrollpunkt (1180|20)), r 6 → 26. |
| 160 | Landung: sy 0,82. |
| 180–400 | Das Panel wächst aus dem Blob nach links, Breite 56 → 360 (easeOutBack). Panel x = 1248 − Breite, y 36, Höhe 72. |
| 200–290 | Auge öffnet sich. |
| 220–2000 | Transkript streamt (x 908, 15/20, max. 262 px breit). Körper atmet mit der Stimme. |
| 2000 | Loslassen: „Schlucken“ (sy +0,08). Transkript auf 60 %. Blick nach oben. |
| 2400–2820 | Reise HOME → PERCH (Kontrollpunkt (960|−10)). Ab 140 px Abstand reißt der Goo-Faden. Ein Narben-Punkt (r 5, pulsierend) bleibt im Panel. |
| 2520–2760 | Panel wird Pille (Höhe 72 → 56): „Buche ICE 597 · Schritt n/4“, Volt-Fortschrittslinie, **Stopp-Button**. |
| 2820 | Landung auf der Chrome-Kante, 6 px Überlappung, Lichtspritzer auf der Tab-Leiste. |
| 2900–5200 | Geister-Cursor (18 px Ring, Volt 85 %) klickt Datum, Zug, Weiter. Das Auge folgt. |
| 5200–5440 | Pille morpht zur Papier-Karte: x 888, y 140, 360×330, Radius 20. |
| 5300–5700 | Hüpfer CARD auf die Kartenkante. |
| 5750 / 5970 / 6190 | Blick-Sweep über Betrag, Karte und Fahrt. Die Zeile leuchtet, das passende Chrome-Feld bekommt einen 2 px Volt-Rahmen mit Glow. |
| 6410 | Gate öffnet: Button von 0,4 auf volle Deckkraft, Label „Halten zum Bezahlen · 248,00 €“. |
| 6500–7300 | Halten, 800 ms: Ink füllt sich von links, Figur sy 1 → 0,8, Pupille 1 → 1,25. |
| 7300 | Bestätigt: Pop (sy 1,25), Stempel „Bezahlt ✓“ (−6°, Skalierung 1,3 → 1), Haptik, Sound. |
| 7500–7900 | Karte wird dunkle Pille (Höhe 116): „Gebucht“ mit [Öffnen] [Kopieren]. Figur hüpft heim, nimmt die Narbe per Goo auf, Squint. |
| D … D+500 | Abgang (D = 10900, oder 4 s ohne Hover): Panel zieht sich in den Blob (180 ms), Blob wird in die Menüleiste gesaugt (160 ms, ease-in), Icon pulsiert einmal. |

**Goo-Filter (Web-Version):**
```
feGaussianBlur stdDeviation=8 → feColorMatrix "1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 22 -10"
```
Der Filter liegt auf einer Gruppe aus Panel-Rechteck, Faden-Tropfen und Blob-Kreis. Die scharfe, beleuchtete Figur wird darüber gezeichnet.

**Jelly-Licht:**
```
SourceAlpha → blur 4 → feSpecularLighting(surfaceScale 6, specularConstant 1.1, specularExponent 28, fePointLight (-34,-70,110))
→ composite in SourceAlpha → arithmetic k2=1 k3=1 mit SourceGraphic
```

## 6. Freigabe: Sicherheitsregeln (nicht verhandelbar)

1. Das Gate öffnet erst nach dem Blick-Sweep über alle Risikofelder: mindestens 900 ms nach Erscheinen, plus 220 ms pro Feld.
2. **Hold-to-confirm** nur für Kauf, endgültiges Löschen und neue Empfänger. Sonst 600 ms Arming, dann normaler Klick.
   - Haltezeit 800 ms.
   - 1200 ms über 500 € oder bei Unumkehrbarem.
3. Früh loslassen bricht ab: die Füllung läuft in 200 ms zurück, die Figur federt zurück (Steifigkeit 260, Dämpfung 14).
4. Das Label nennt Verb und Ziel („Halten zum Bezahlen · 248,00 €“, „Senden an anna.berg@…“), nie nur „Erlauben“.
5. **„Nicht kaufen“ / Esc** ist immer sofort verfügbar. Esc ist ein nativer Hotkey, solange die Karte offen ist. Das Panel nimmt nie den Fokus.
6. **Ablauf heißt ablehnen.** Der Countdown steht auf der Karte („noch 0:58“).
7. Ändert sich der Inhalt der Karte, startet das Gate neu.
8. Strukturierte Felder (Betrag, Karte, Fahrt, Empfänger, Dateien) statt Kommandozeile. Das exakte Kommando steht hinter „Exaktes Kommando ▸“.
9. Reduce Motion und Calm Mode **verkürzen das Gate nie**.

## 7. Fehler- und Abbruch-States

Gemeinsame Regeln:
- Die Figur springt immer zuerst heim (280 ms, Goo-Merge mit der Narbe). Danach wird das Panel eine dunkle Pille mit Höhe 116: Titel 18 Display, Untertitel 13, zwei Buttons.
- In jedem Abbruch steht in Worten, dass nichts passiert ist.
- Keine roten Fehler-Kästen im Overlay. Die Stimmung trägt der Körper.

| Szenario | Auslöser | Figur | Panel (Titel · Text · Buttons, primär zuerst) |
|---|---|---|---|
| Langsam | 2 s ohne Antwort nach dem Loslassen | knetet weiter, Blick driftet oben | „Dauert länger als sonst …“ · „Claude antwortet langsam“ · [Abbrechen]. Danach geht es normal weiter. |
| Abgebrochen | Stopp in der Pille, Esc oder Hotkey | zuckt zusammen (sy +0,14), Blick zum Stopp, springt heim, wackelt | „Gestoppt“ · „Nichts gebucht. Chrome bleibt bei der Zugauswahl stehen.“ · [Weitermachen] [Schließen] |
| Kein Platz / Agent-Fehler | Agent meldet einen Fehler | sackt 10 % ab, Farbe → dull, Blick aufs Problem in Chrome, dann nach unten, dann heim | „Kein Platz im 09:04“ · „ICE 597 ist ausgebucht. Der 09:30 hat noch Plätze, 99,90 € pro Person.“ · [09:30 nehmen] [Andere zeigen]. Die Alternative leuchtet in Chrome. |
| Abgelehnt | „Nicht kaufen“ / Esc auf der Karte | Schulterzucken, Karte → Pille, heim | „Nicht gekauft“ · „Nichts bezahlt. Die Verbindung bleibt in Chrome offen.“ · **[Schließen]** [Doch kaufen]. „Doch kaufen“ ist bewusst nicht primär. |
| Abgelaufen | Countdown bei 0 | wird in den letzten 1,8 s amber, hüpft einmal auffordernd, sackt dann ab, Button „Abgelaufen“ | „Freigabe abgelaufen“ · „Nichts bezahlt. Sag „nochmal“, wenn du so weit bist.“ · [Nochmal fragen] [Schließen] |
| Mikro fehlt | Mikrofonzugriff verweigert | Auge bleibt zu, kein Atmen | „Ich kann dich nicht hören“ · „Mir fehlt der Zugriff aufs Mikrofon.“ · [Einstellungen öffnen] [Lieber tippen] |

Weitere States mit Mockup in `FamiliarStates.dc.html`: Denken mit Screen-Crop, Tipp-Composer (Modell-Chip, Zeigen, Mikro, ↑ holt die letzte Frage), „Welche?“-Auswahl (nummeriert, Freitext), KI nicht erreichbar mit [Nochmal] [Nicht jetzt] [Details kopieren], Thread mit gedimmter Vorfrage und „Gelernt“-Hinweis mit [Rückgängig], Übergabe an einen Hintergrund-Agenten mit Fertig-Toast.

## 8. Diktat

Volt-Pille, 36 px hoch, Ink-Balken als Welle, Blob 24 px.
- **Gesperrt:** schraffiertes „LOCKED“-Label, mit Text, nicht nur Farbe.
- **Fertig:** die Figur wird zum ✓.
- **Meldungen:** dunkle Pille mit Volt-Button [Kopieren].
- **Nie** Reise und nie Sound beim Diktat.

## 9. Produktion (macOS)

- **Rendering:**
  - Kein SVG-Blur in Produktion. Stattdessen Metal-SDF-Metaball mit Smooth-Min (SwiftUI `.layerEffect` oder `CAMetalLayer`), analytische Normalen für das Glanzlicht.
  - Budget: unter 2 ms GPU pro Frame. Render-Loop stoppt im Idle.
  - Verfehlt der erste Frame 180 ms, entfällt der Tropfen und das Panel erscheint direkt.
- **Stage-Fenster für die Reise:** ein durchsichtiges `NSPanel` pro Display:
  - Stil `[.borderless, .nonactivatingPanel]`, `level = .floating`, `ignoresMouseEvents = true`
  - `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]`
  - Fenster-Rects über AX (`kAXPosition`/`kAXSize`) oder `CGWindowListCopyWindowInfo`, mit 30 Hz, solange die Figur sitzt.
- **Regeln für die Reise:**
  - Nur bei Aufgaben über 3 s. Nie bei Antworten oder Diktat.
  - Sitzt nur auf der Titel- oder Tab-Leisten-Kante, nie über Inhalt.
  - Ist das Fenster verdeckt, sitzt sie auf dem Mini-Screen.
  - Die Reisedauer sinkt nach etwa 30 Nutzungen von 420 auf 280 ms.
- **Sound:** nur drei, auf −24 LUFS, folgen der System-Alert-Lautstärke. Kein Ton bei Rufen oder Zuhören.

| Sound | Beschreibung |
|---|---|
| fertig | „tick-pop“, 90 ms |
| Freigabe erscheint | „paper“, 160 ms |
| bestätigt | „stamp“, dazu `NSHapticFeedbackManager .levelChange` |

## 10. Reduce Motion und Calm Mode

- **Reduce Motion:**
  - Kein Tropfen, kein Goo, keine Reise, kein Squash.
  - Panel und Karte blenden in 120 ms über.
  - Blick-Sakkaden und Zeilen-Highlights **bleiben**, weil sie Information tragen. Hold mit 800 ms bleibt.
- **Calm Mode:** keine Sounds, kein Maus-Folgen, keine Reise. Material bleibt.
- **Gate-Zeiten** ändern sich in keinem Modus.

## 11. A11y

- Status: `role="status"`, `aria-live="polite"`. Angesagt werden nur Zustandswechsel, nicht jeder Timer-Tick.
- Freigabe: native `NSAccessibility`-Ansage mit hoher Priorität, zum Beispiel: „Freigabe nötig: 248 Euro an bahn.de. Escape lehnt ab.“
- Buttons mit Verb und Ziel als Label. Fokusring 2 px Volt mit 2 px Offset.
- Nie nur Farbe: Risiko, Gesperrt und Fehler stehen immer auch als Wort da.
- Kontrast: Panel mindestens 94 % deckend, damit Muted-Text auch über weißem Wallpaper ≥ 4,5:1 hat.

## 12. Akzeptanzkriterien

- [ ] Erster Transkript-Text ist spätestens 180 ms nach dem Tastendruck sichtbar. Das Mikro läuft ab dem Tastendruck.
- [ ] Freigabe lässt sich nicht vor Ende des Blick-Sweeps bestätigen. Früh loslassen bricht immer ab.
- [ ] Esc lehnt jede offene Freigabe ab, ohne dass das Overlay den Fokus nimmt.
- [ ] Jeder Abbruch- und Fehler-State nennt in Worten, dass nichts ausgeführt wurde.
- [ ] Alle bestehenden `window.ui.*`-Aufrufe funktionieren weiter. Die Tests in `tests/` bleiben grün oder werden bewusst angepasst.
- [ ] Reduce Motion: keine Bewegung außer Blick und Highlight, gleiche Gate-Zeiten.
- [ ] Idle: 0 % GPU, kein laufender Render-Loop.
- [ ] Panel-Kontrast über weißem und schwarzem Wallpaper geprüft.

## 13. Offene Entscheidungen (mit aktuellem Default)

- **Produktname und Wortmarke für den Fork:** noch offen, „Atticus“ ist Platzhalter.
- **Panel-Position:** oben rechts unter dem Menüleisten-Icon (Default, nötig für den Tropfen).
- **Narben-Punkt im Panel, während die Figur unterwegs ist:** behalten (Default).
- **Haltezeit:** nach Risiko gestaffelt, 800 ms Standard und 1200 ms über 500 € oder bei Unumkehrbarem (Default).
- **Bei Bildschirmfreigabe oder Meeting** (bestehende Meeting-Erkennung): Reise und Maus-Folgen aus (Default).
