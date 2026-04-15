import cloudscraper
from bs4 import BeautifulSoup
import json
import sys
import os

def scrape_benzinga():
    scraper = cloudscraper.create_scraper(browser='chrome')
    try:
        response = scraper.get('https://www.benzinga.com/calendars/fda')
        soup = BeautifulSoup(response.text, 'html.parser')
        
        output = ["UPCOMING FDA CALENDAR FROM BENZINGA"]
        
        found_data = False
        tables = soup.find_all('table')
        if tables:
            found_data = True
            for table in tables:
                rows = table.find_all('tr')
                for row in rows:
                    cols = row.find_all(['th', 'td'])
                    cols = [ele.text.strip() for ele in cols]
                    if cols:
                        output.append(" | ".join(cols))
        
        if not found_data:
            body = soup.find('body')
            if body:
                text = body.get_text(separator='\n', strip=True)
                output.append(text)
                
        script_dir = os.path.dirname(os.path.abspath(__file__))
        output_path = os.path.join(script_dir, "scraped_catalysts.txt")
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write("\n".join(output))
        print("Scraping finished.")
            
    except Exception as e:
        print(f"Error scraping: {e}")

if __name__ == "__main__":
    scrape_benzinga()
