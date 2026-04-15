# Biotech Monitor

A CLI automation tool designed to monitor the biotechnology sector, aggregate news, and track upcoming FDA catalysts using LLM analysis (Gemini in this case).

## What it does
This pipeline extracts raw data from multiple biotech RSS feeds and scrapes institutional FDA calendars. Instead of struggling with complex XML parsing or being blocked by anti-bot systems, it aggregates all raw text into a single file and passes it to the **Gemini API**.

Gemini acts as a senior financial analyst, filtering the noise (like marketing events or CEO changes) and outputting a highly structured plain-text report prioritizing:
1. **Past Events:** Recent Phase 2/3 clinical trial data and FDA decisions.
2. **Upcoming Catalysts:** PDUFA dates, AdCom meetings, and expected trial data within the next 0-14 days.

Special focus is given to uncovering catalysts in **Microcap and Small-cap** biotech companies that are often buried in the news.

## Features
* **ETL Architecture:** Separates data gathering (Bash + Python) from data analysis (LLM), preventing rate-limit issues (HTTP 429) common in agentic LLM loops.
* **Cloudflare Bypass:** Uses Python's `cloudscraper` to access institutional calendars (like Benzinga) that block standard bots.
* **Plain Text Emails:** Generates clean, ASCII-based emails that look perfect on any client, avoiding Markdown rendering issues.
* **Cron-Ready:** Designed to run autonomously on a Linux VPS.

## Prerequisites
* A Linux environment (VPS recommended).
* `bash`, `curl`, `grep`, `sed`, `mailx` (for sending emails).
* `python3` and `pip`.
* Gemini CLI installed (`npm install -g @google/gemini-cli`).
* A free Gemini API Key from [Google AI Studio](https://aistudio.google.com/app/apikey).

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/biotech-intelligence-pipeline.git
   cd biotech-intelligence-pipeline
   ```

2. **Set up the Python Virtual Environment:**
   ```bash
   python3 -m venv venv
   ./venv/bin/pip install cloudscraper beautifulsoup4
   ```

3. **Configure the Bash Script:**
   Open `biotech_newsletter_bot.sh` and edit the configuration section:
   ```bash
   export GEMINI_API_KEY="YOUR_API_KEY_HERE"
   MY_EMAIL="your-email@example.com"
   PROJECT_DIR="/path/to/this/directory"
   ```

4. **Make the script executable:**
   ```bash
   chmod +x biotech_newsletter_bot.sh
   ```

## Usage

Run the script manually to test:
```bash
./biotech_newsletter_bot.sh
```

### Automating with Cron
To receive the report automatically (e.g., every Monday, Wednesday, and Friday at 8:00 AM), add this to your crontab (`crontab -e`):

```cron
0 8 * * 1,3,5 /bin/bash /path/to/your/directory/biotech_newsletter_bot.sh >> /path/to/your/directory/pipeline.log 2>&1
```

## Disclaimer
This project is for informational purposes only and does not constitute financial advice. Biotech investments are highly volatile. This is just a personal project.
