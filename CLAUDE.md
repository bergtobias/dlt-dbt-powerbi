# CLAUDE.md — Data Pipeline Project

## Power BI PBIR — Lärdomar från felsökning

### 1. `pbi report set-background` är trasig — använd ALDRIG
Kommandot skriver fel JSON-format i `page.json` som gör att Desktop inte kan ladda rapporten.

**Fel format (vad pbi-cli skriver):**
```json
"color": { "solid": { "color": { "expr": { "Literal": { "Value": "'#F1F5F9'" } } } } }
"transparency": { "expr": { "Literal": { "Value": "0D" } } }
```
**Korrekt format:**
```json
"color": { "expr": { "Literal": { "Value": "'#F1F5F9'" } } }
"transparency": { "expr": { "Literal": { "Value": "0" } } }
```
Skriv `page.json` direkt med Write-verktyget istället.

---

### 2. `pbi report set-theme` skriver alltid fel sökväg
Kommandot registrerar temafilen med `"path": "BaseThemes/tema.json"` men filen hamnar i `RegisteredResources/tema.json`. Desktop hittar den inte och vägrar ladda rapporten.

**Fix efter varje `set-theme`:** Ändra `report.json` manuellt:
```json
"path": "tema.json"   // RÄTT — inte "BaseThemes/tema.json"
```

---

### 3. Tema-JSON: inga `{ "value": ... }` runt primitiver
Power BI theme-filer accepterar INTE `{ "value": 28 }` runt tal/boolean i `visualStyles`.

```json
// FEL
"fontSize": { "value": 28 }, "fontBold": { "value": true }

// RÄTT
"fontSize": 28, "fontBold": true
```
Undantag: `fontFamily` använder `[{ "value": "Segoe UI" }]` — det är korrekt.

---

### 4. Rundade hörn och bakgrundsfärg på visuella element — sätt i visual.json
Temat styr INTE container-egenskaper (färg, radius). Det måste sättas direkt i `visualContainerObjects` i varje `visual.json`:

```json
"visualContainerObjects": {
  "border": [{ "properties": {
    "show":   { "expr": { "Literal": { "Value": "true" } } },
    "color":  { "expr": { "Literal": { "Value": "'#C4B5FD'" } } },
    "radius": { "expr": { "Literal": { "Value": "16D" } } }
  }}],
  "background": [{ "properties": {
    "show":         { "expr": { "Literal": { "Value": "true" } } },
    "color":        { "expr": { "Literal": { "Value": "'#EDE9FE'" } } },
    "transparency": { "expr": { "Literal": { "Value": "0D" } } }
  }}]
}
```
Använd Python för att uppdatera flera visual.json-filer på en gång.

---

### 5. `version.json` — ändra inte värdet
pbi-cli skapar `version.json` med `"version": "2.0.0"`. Ändra INTE detta — Desktop läser inte rapporten om värdet är fel (t.ex. `"4.0"`).

---

### 6. UTF-8 BOM i tema-filer
Om en tema-JSON skapas i Windows (t.ex. VS Code) kan den ha UTF-8 BOM som pbi-cli inte accepterar. Strippa det innan användning:
```bash
sed '1s/^\xEF\xBB\xBF//' Tema.json > /tmp/Tema.json
pbi report set-theme --file /tmp/Tema.json
```

---

### 7. Stora tema-filer — använd Python för att modifiera
Bloom-temat är ~3MB med inbäddade bilder. Redigera det med Python, inte direkt i editorn:
```python
import json
with open("Tema.json", encoding="utf-8-sig") as f:
    theme = json.load(f)
# gör ändringar...
with open("Tema.json", "w", encoding="utf-8") as f:
    json.dump(theme, f, ensure_ascii=False, indent=2)
```

---

### 8. Validering — använd båda verktygen
```bash
# Strukturvalidering (filer, JSON, sidreferenser)
pbi report validate

# Schema-validering mot Microsofts officiella schema
check-jsonschema \
  --schemafile "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/report/3.3.0/schema.json" \
  report.json
```

---

### 9. BaseThemes-filen måste finnas i projektet
Desktop kräver att `CY26SU05.json` finns i `StaticResources/SharedResources/BaseThemes/`. Kopiera från Desktop-installationen:
```bash
cp "/mnt/c/Program Files/Microsoft Power BI Desktop/bin/WebView2Resources/minerva/sharedresources/BaseThemes/CY26SU05.json" \
   report/todo-report.Report/StaticResources/SharedResources/BaseThemes/
```
