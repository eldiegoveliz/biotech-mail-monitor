#!/bin/bash

export GEMINI_API_KEY="TU_API_KEY_AQUI"
MY_EMAIL="tu-correo@ejemplo.com"
PROJECT_DIR="/ruta/a/tu/proyecto"
RAW_FILE="/tmp/biotech_raw_news.txt"

> "$RAW_FILE"

echo "Recopilando datos RSS..."

curl -s "https://www.fiercebiotech.com/rss/xml" | grep -iE '<title>|<description>' | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//' >> "$RAW_FILE"

curl -s "https://www.biospace.com/rss/news" | grep -iE '<title>|<description>' | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//' >> "$RAW_FILE"

curl -s "https://www.fda.gov/about-fda/contact-fda/stay-informed/rss-feeds/press-releases/rss.xml" | grep -iE '<title>|<description>' | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//' >> "$RAW_FILE"

curl -sL "https://www.statnews.com/feed/" | grep -iE '<title>|<description>' | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//' >> "$RAW_FILE"

curl -sL "https://endpoints.news/feed/" | grep -iE '<title>|<description>' | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//' >> "$RAW_FILE"

curl -sL "https://www.biopharmadive.com/feeds/news/" | grep -iE '<title>|<description>' | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//' >> "$RAW_FILE"

curl -sL "https://www.clinicaltrialsarena.com/feed/" | grep -iE '<title>|<description>' | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//' >> "$RAW_FILE"

curl -sL "https://www.fda.gov/about-fda/contact-fda/stay-informed/rss-feeds/advisory-committees/rss.xml" | grep -iE '<title>|<description>' | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//' >> "$RAW_FILE"

curl -sL "https://www.bioworld.com/rss" | grep -iE '<title>|<description>' | sed -e 's/<[^>]*>//g' | sed 's/^[ \t]*//' >> "$RAW_FILE"

cd "$PROJECT_DIR"
./venv/bin/python fda_calendar_scraper.py
cat scraped_catalysts.txt >> "$RAW_FILE"

echo "Datos recopilados. Analizando con Gemini..."

CURRENT_DATE=$(date +"%A, %B %d, %Y")

PROMPT="Act as a senior biotechnology analyst. 
CRITICAL DATE CONTEXT: Today's date is exactly ${CURRENT_DATE}. Any event occurring after this exact date is in the FUTURE. Any event occurring before this date is in the PAST. You must accurately determine if an event has already happened or is upcoming based on today's date. Do not mistakenly classify tomorrow or future dates as past events.

Below is a raw text dump of RSS news from FierceBiotech, BioSpace, and the FDA from the last few days.
Your job is to read this unstructured text, identify real biotechnology events, and filter out the 'noise' (executive appointments, marketing events, etc.).

OBJECTIVE:
Select and summarize ALL critical events found in the data, divided into two sections. DO NOT limit the output to a 'Top 10'. Extract as many relevant events as possible.
Pay SPECIAL ATTENTION to finding news about microcap and small-cap biotech companies. Do not just focus on large-cap pharma.

SECTION 1: PAST EVENTS (Events that have already occurred).
SECTION 2: UPCOMING CATALYSTS (Events scheduled for today and the next 14 days, including explicit mentions of 'planned FDA filings', 'planned Phase 2/3 trial initiations', and 'expected data readouts'). 

Strictly prioritize:
1. Clinical Trial Results (Phase 2 or 3. Phase 1 or 1/2 only if the treatment is highly notable).
2. Regulatory Decisions (FDA Approvals, CRLs, AdComs).
3. Upcoming PDUFA dates and scheduled FDA Advisory Committee meetings.

For every event, determine its timeline relative to today (${CURRENT_DATE}). Be extremely specific with the companies involved (provide the full company name and ticker symbol) and the exact name of the drug, treatment, or active compound.

REQUIRED FORMAT:
This output will be sent directly as a plain text email. 
DO NOT use Markdown tables. DO NOT use emojis or special Unicode characters.
Format the output as a clean, plain text list using standard ASCII characters. Use this exact layout:

==================================================
SECTION 1: PAST EVENTS (RECENT RESULTS & DECISIONS)
==================================================
* COMPANY (TICKER): [Full Company Name] ([TICKER])
  DRUG/THERAPY: [Exact Chemical/Brand Name of the Treatment]
  EVENT DATE: [Exact date] (PAST EVENT)
  EVENT TYPE: [Type of Event]
  IMPACT LEVEL: [High/Medium]
  SUMMARY: [1-2 concise, highly technical sentences]
--------------------------------------------------

==================================================
SECTION 2: UPCOMING CATALYSTS (NEXT 0-14 DAYS)
==================================================
* COMPANY (TICKER): [Full Company Name] ([TICKER])
  DRUG/THERAPY: [Exact Chemical/Brand Name of the Treatment]
  EXPECTED DATE: [Exact or estimated date] (UPCOMING EVENT)
  EVENT TYPE: [Type of Event, e.g., PDUFA, AdCom Meeting, Expected Phase 3 Data]
  IMPACT LEVEL: [High/Medium]
  SUMMARY: [1-2 concise, highly technical sentences]
--------------------------------------------------

Here is the raw data to analyze:
--- DATA START ---
$(cat "$RAW_FILE")
--- DATA END ---"

REPORT=$(gemini -m gemini-2.5-flash -p "$PROMPT")

if [ -z "$REPORT" ] || echo "$REPORT" | grep -q "Error when talking to Gemini API"; then
  echo "[$(date)] FALLO: La API de Gemini no devolvió resultados." >> "$PROJECT_DIR/pipeline.log"
else
  echo "$REPORT" | mail -s "Biotech Full Report - $(date +'%d/%m/%Y')" "$MY_EMAIL"

  echo "[$(date)] ejecutado y correo enviado a $MY_EMAIL" >> "$PROJECT_DIR/pipeline.log"
fi
