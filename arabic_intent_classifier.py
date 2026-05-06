
# -----------------------------------------------------------------------------------------
# مشروع: نموذج تصنيف النوايا (Intent Classifier) للتحكم في عربية ذكية بالأوامر الصوتية
# يدعم اللغتين: العربية والإنجليزية
# الملفات المطلوبة: dataset.csv في نفس المجلد
# -----------------------------------------------------------------------------------------

import sys
import os
import tempfile
import time
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import joblib
import re
import speech_recognition as sr

# استيراد مكتبات الصوت البديلة (Fallback)
try:
    import sounddevice as sd
    import scipy.io.wavfile as wav
    SOUNDDEVICE_AVAILABLE = True
except ImportError:
    SOUNDDEVICE_AVAILABLE = False
    print("Warning: sounddevice/scipy not found. Voice fallback disabled.")

from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
from sklearn.metrics import classification_report, confusion_matrix

sns.set(style="whitegrid")

# -----------------------------------------------------------------------------------------
# 1. تحميل وتجهيز البيانات (Data Loading & Preprocessing)
# -----------------------------------------------------------------------------------------
dataset_path = 'dataset.csv'
if not os.path.exists(dataset_path):
    print(f"❌ Error: '{dataset_path}' not found. Please place it next to the script.")
    sys.exit(1)

print(f"Loading dataset from {dataset_path}...")
df = pd.read_csv(dataset_path)

# التأكد من صحة الأعمدة
if 'text' not in df.columns or 'intent' not in df.columns:
    print("❌ Error: Dataset must contain 'text' and 'intent' columns.")
    sys.exit(1)

def clean_text(text):
    text = str(text).lower()
    text = re.sub(r'\s+', ' ', text).strip()
    # تجريد بسيط للهمزات لتفادي الاختلافات الإملائية في العربية
    text = re.sub(r"[أإآ]", "ا", text)
    text = re.sub(r"ة", "ه", text)
    text = re.sub(r"ى", "ي", text)
    
    # Normalization for strict commands (تطبيع الكلمات لتناسب الداتا الصارمة)
    text = re.sub(r"(وقف|اوقف|توقف|ستوب)", "اقف", text)
    text = re.sub(r"قدامي", "قدام", text)
    text = re.sub(r"ورى", "ورا", text)
    
    return text

df['text_clean'] = df['text'].apply(clean_text)

print(f"Loaded {len(df)} examples.")
print("Sample Data:")
print(df.sample(5))

# -----------------------------------------------------------------------------------------
# 2. تدريب النموذج (Training Pipeline)
# -----------------------------------------------------------------------------------------
X_train, X_test, y_train, y_test = train_test_split(
    df['text_clean'], 
    df['intent'], 
    test_size=0.15, 
    random_state=42, 
    stratify=df['intent']
)

pipeline = Pipeline([
    # Ngram (1,3) لالتقاط "خش يمين" و "turn right"
    ('tfidf', TfidfVectorizer(ngram_range=(1, 3))),
    ('clf', LogisticRegression(max_iter=2000, C=10, solver='lbfgs', random_state=42))
])

print(f"\nTraining on {len(X_train)} examples...")
pipeline.fit(X_train, y_train)

# -----------------------------------------------------------------------------------------
# 3. التقييم (Evaluation)
# -----------------------------------------------------------------------------------------
y_pred = pipeline.predict(X_test)
print("\n--- Classification Report ---")
print(classification_report(y_test, y_pred))

# حفظ النموذج
models_dir = 'models'
if not os.path.exists(models_dir): os.makedirs(models_dir)
model_path = os.path.join(models_dir, 'nlp_intent_model.joblib')
joblib.dump(pipeline, model_path)
print(f"Model saved to {model_path}")

# -----------------------------------------------------------------------------------------
# 4. التعرف على الصوت (Voice Recognition - Optimized Fallback)
# -----------------------------------------------------------------------------------------
def record_audio_fallback(duration=4, fs=16000): # Reduced duration & optimal sample rate for speech
    """تسجيل صوت باستخدام SoundDevice في حالة عدم وجود PyAudio"""
    if not SOUNDDEVICE_AVAILABLE:
        print("❌ Error: Both PyAudio and SoundDevice are missing!")
        return None
        
    print(f"🎤 Listening via SoundDevice (Fallback)... Speak for {duration}s")
    # تسجيل مونو (channels=1) وتردد 16000 (الأفضل تمييز الكلام)
    try:
        myrecording = sd.rec(int(duration * fs), samplerate=fs, channels=1, dtype='int16')
        print(f"   (Recording {duration}s... Speak louder!)")
        sd.wait()
        
        # Check volume level (Diagnosis)
        max_vol = np.max(np.abs(myrecording))
        print(f"   [Audio Max Level: {max_vol}] ", end='')
        
        if max_vol < 2000:
            print("⚠️ Too quiet! Auto-boosting volume...")
            if max_vol > 10: # Avoid boosting pure silence/noise
                # Amplify to target peak of ~10000 (about 30% of max capacity)
                boost_factor = 10000 / max_vol
                # Cap factor to prevent exploding distinct noise
                boost_factor = min(boost_factor, 20.0)
                myrecording = (myrecording * boost_factor).astype(np.int16)
                print(f"   [Boosted to: {np.max(np.abs(myrecording))}]")
        else:
            print("✅ Volume Good.")

        print("✅ Recording complete. Processing...")
        
        temp_wav = tempfile.mktemp(suffix=".wav")
        wav.write(temp_wav, fs, myrecording)
        return temp_wav
    except Exception as e:
        print(f"Recording Error: {e}")
        return None

def get_voice_command():
    recognizer = sr.Recognizer()
    
    # محاولة التسجيل
    try:
        with sr.Microphone() as source:
            print("\n🎤 Listening via Microphone (PyAudio)...")
            recognizer.adjust_for_ambient_noise(source, duration=0.5)
            try:
                audio_data = recognizer.listen(source, timeout=5, phrase_time_limit=5)
                # نحاول التعرف على العربية (مصر) والإنجليزية (أمريكا)
                # جرب العربية أولاً لأنها غالبة، أو ممكن نطلب اللغة من المستخدم
                # هنا سنستخدم 'ar-EG' لأنه يدعم الكلمات الإنجليزي الشائعة غالباً
                return recognize_audio_data(recognizer, audio_data)
            except sr.WaitTimeoutError:
                print("⏳ Timeout.")
                return None
    except (OSError, AttributeError):
        print("\n⚠️  PyAudio issue. Switching to SoundDevice fallback...")
        wav_path = record_audio_fallback()
        if wav_path:
            with sr.AudioFile(wav_path) as source:
                audio_data = recognizer.record(source)
                result = recognize_audio_data(recognizer, audio_data)
                try: os.remove(wav_path)
                except: pass
                return result
        else:
            return None 

def recognize_audio_data(recognizer, audio):
    # محاولة العربية أولاً (اللهجة المصرية)
    try:
        text = recognizer.recognize_google(audio, language="ar-EG")
        return text
    except sr.UnknownValueError:
        # الفشل في العربية -> محاولة الإنجليزية
        try:
            print("   (Trying English...)")
            text = recognizer.recognize_google(audio, language="en-US")
            return text
        except sr.UnknownValueError:
            print("❌ Could not understand audio (in Arabic or English).")
            return None
    except sr.RequestError:
        print("❌ Connection error.")
        return None
    except Exception as e:
        print(f"❌ Network/Service Error: {e}")
        return None

# -----------------------------------------------------------------------------------------
# 5. الحلقة التفاعلية (Interactive Loop)
# -----------------------------------------------------------------------------------------
print("\n" + "="*60)
print("     SMART CAR VOICE CONTROL - ARABIC/ENGLISH")
print("     نظام التحكم العربي/الإنجليزي للسيارة الذكية")
print("="*60)
print("Instructions:")
print("- Type command (e.g., 'forward', 'اطلع قدام', 'right').")
print("- Type 'v' for VOICE command.")
print("- Type 'q' to Quit.")

if not SOUNDDEVICE_AVAILABLE:
    print("\nNote: 'sounddevice' library missing. Voice fallback limits apply.")

while True:
    user_input = input("\n📝 Enter command (or 'v'): ").strip()
    
    if user_input.lower() == 'q':
        break
    
    if not user_input:
        continue

    final_command = None

    if user_input.lower() in ['v', 'voice', 'صوت', '2']:
        final_command = get_voice_command()
        if final_command is None: continue 
    else:
        final_command = user_input

    if final_command:
        clean_cmd = clean_text(final_command)
        if not clean_cmd: continue
            
        intent = pipeline.predict([clean_cmd])[0]
        probs = pipeline.predict_proba([clean_cmd])[0]
        confidence = np.max(probs)
        
        print("-" * 40)
        print(f"🗣️  Input:  '{final_command}'")
        print(f"🤖 Action: [{intent.upper()}]")
        print(f"📊 Confid: {confidence*100:.1f}%")
        print("-" * 40)

print("Goodbye!")
