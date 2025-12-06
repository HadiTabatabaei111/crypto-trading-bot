import ccxt
import pandas as pd
import requests
import time
from config import (EXCHANGE, BITUNIX_API_KEY, BITUNIX_SECRET, LBANK_API_KEY, LBANK_SECRET,
                    GROQ_API_KEY, TELEGRAM_TOKEN, TELEGRAM_CHAT_ID, SYMBOLS, CHECK_INTERVAL)
from dotenv import load_dotenv
load_dotenv()

def get_exchange():
    """اتصال به صرافی"""
    if EXCHANGE == 'bitunix':
        return ccxt.bitunix({
            'apiKey': BITUNIX_API_KEY,
            'secret': BITUNIX_SECRET,
            'enableRateLimit': True,
        })
    elif EXCHANGE == 'lbank':
        return ccxt.lbank({
            'apiKey': LBANK_API_KEY,
            'secret': LBANK_SECRET,
            'enableRateLimit': True,
        })
    else:
        raise ValueError("صرافی نامعتبر! bitunix یا lbank انتخاب کن.")

def fetch_data_grid(exchange, symbols):
    """گرفتن جدول داده‌ها"""
    tickers = exchange.fetch_tickers(symbols)
    data = []
    for symbol, ticker in tickers.items():
        data.append({
            'Symbol': symbol,
            'Last Price': ticker['last'],
            'Volume (24h)': ticker['quoteVolume'],
            'Change (24h)': f"{ticker['percentage']:.2f}%" if 'percentage' in ticker else 'N/A',
            'High (24h)': ticker['high'],
            'Low (24h)': ticker['low']
        })
    df = pd.DataFrame(data)
    return df

def send_telegram(msg):
    """ارسال آلارم به تلگرام"""
    if not TELEGRAM_TOKEN or not TELEGRAM_CHAT_ID:
        print(f"آلارم: {msg}")  # اگر تلگرام ست نکردی، اینجا پرینت می‌شه
        return
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    try:
        requests.post(url, data={'chat_id': TELEGRAM_CHAT_ID, 'text': msg})
    except Exception as e:
        print(f"خطا در تلگرام: {e}")

def analyze_with_ai(df_str):
    """تحلیل با هوش مصنوعی (Groq)"""
    if not GROQ_API_KEY:
        return "GROQ_API_KEY ست نشده! تحلیل دستی: قیمت‌ها رو چک کن."
    
    prompt = f"""
    تحلیل بازار کریپتو بر اساس این داده‌ها (تاریخ: {pd.Timestamp.now().strftime('%Y-%m-%d %H:%M')}):
    {df_str}
    
    برای هر سیمبل:
    - تصمیم: بخر / بفروش / نگه‌دار
    - قدرت سیگنال (۱-۱۰)
    - استاپ‌لاس و تارگت پیشنهادی (بر اساس قیمت فعلی)
    - دلیل کوتاه
    
    خروجی رو فارسی و مفید بنویس. فقط جدول یا لیست ساده.
    """
    
    try:
        response = requests.post(
            "https://api.groq.com/openai/v1/chat/completions",
            headers={"Authorization": f"Bearer {GROQ_API_KEY}", "Content-Type": "application/json"},
            json={
                "model": "llama3.1-70b-versatile",  # یا llama3-groq-70b-8192-tool-use
                "messages": [{"role": "user", "content": prompt}],
                "max_tokens": 300,
                "temperature": 0.7
            }
        )
        return response.json()['choices'][0]['message']['content']
    except Exception as e:
        return f"خطا در AI: {e}. از مدل دیگه استفاده کن."

def main():
    exchange = get_exchange()
    print(f"ربات شروع شد! صرافی: {EXCHANGE.upper()}")
    
    while True:
        try:
            df = fetch_data_grid(exchange, SYMBOLS)
            df_str = df.to_string(index=False)
            
            print("\n=== Data Grid ===")
            print(df_str)
            
            # تحلیل AI
            analysis = analyze_with_ai(df_str)
            print("\n=== تحلیل AI ===")
            print(analysis)
            
            # چک آلارم ساده (مثال: اگر BTC بالای 100k بره)
            btc_price = df[df['Symbol'] == 'BTC/USDT']['Last Price'].iloc[0] if 'BTC/USDT' in SYMBOLS else 0
            if btc_price > 100000:
                send_telegram(f"🚨 آلارم! BTC بالای ۱۰۰k: {btc_price} USDT")
            
            time.sleep(CHECK_INTERVAL)
        except Exception as e:
            print(f"خطا: {e}")
            time.sleep(30)

if __name__ == "__main__":
    main()