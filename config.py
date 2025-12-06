import os
from dotenv import load_dotenv

load_dotenv()  # از .env لود کن

# صرافی‌ها
BITUNIX_API_KEY = os.getenv('BITUNIX_API_KEY', '')  # اگر داری
BITUNIX_SECRET = os.getenv('BITUNIX_SECRET', '')
LBANK_API_KEY = os.getenv('LBANK_API_KEY', '')     # برای LBank
LBANK_SECRET = os.getenv('LBANK_SECRET', '')

# هوش مصنوعی (Groq — رایگان ثبت‌نام کن: groq.com)
GROQ_API_KEY = os.getenv('GROQ_API_KEY', '')

# تلگرام آلارم
TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN', '')  # از BotFather بگیر
TELEGRAM_CHAT_ID = os.getenv('TELEGRAM_CHAT_ID', '')  # آیدی چت خودت

# سمبل‌ها برای ترید (می‌تونی اضافه کنی)
SYMBOLS = ['BTC/USDT', 'ETH/USDT']

# تنظیمات عمومی
EXCHANGE = 'bitunix'  # یا 'lbank'
CHECK_INTERVAL = 60  # ثانیه (هر ۱ دقیقه چک کن)