#!/usr/bin/env python3
"""
download_fonts.py — Downloads required Google Fonts for Smart Car AI
Run once before building: python download_fonts.py
"""

import os
import urllib.request
import zipfile
import shutil

FONTS_DIR = os.path.join(os.path.dirname(__file__), "assets", "fonts")
os.makedirs(FONTS_DIR, exist_ok=True)

FONTS = {
    "Orbitron": {
        "url": "https://fonts.google.com/download?family=Orbitron",
        "files": {
            "Orbitron-Regular.ttf": "Orbitron/static/Orbitron-Regular.ttf",
            "Orbitron-Bold.ttf": "Orbitron/static/Orbitron-Bold.ttf",
            "Orbitron-ExtraBold.ttf": "Orbitron/static/Orbitron-ExtraBold.ttf",
        }
    },
    "Exo2": {
        "url": "https://fonts.google.com/download?family=Exo+2",
        "files": {
            "Exo2-Regular.ttf": "Exo_2/static/Exo2-Regular.ttf",
            "Exo2-Medium.ttf": "Exo_2/static/Exo2-Medium.ttf",
            "Exo2-SemiBold.ttf": "Exo_2/static/Exo2-SemiBold.ttf",
            "Exo2-Bold.ttf": "Exo_2/static/Exo2-Bold.ttf",
        }
    }
}

def download_font(name, info):
    zip_path = f"/tmp/{name}.zip"
    extract_path = f"/tmp/{name}_extracted"

    print(f"⬇  Downloading {name}...")
    try:
        urllib.request.urlretrieve(info["url"], zip_path)
    except Exception as e:
        print(f"   ✗ Download failed: {e}")
        print(f"   → Please manually download from: {info['url']}")
        return

    os.makedirs(extract_path, exist_ok=True)
    with zipfile.ZipFile(zip_path, "r") as z:
        z.extractall(extract_path)

    for dest_name, src_path in info["files"].items():
        src = os.path.join(extract_path, src_path)
        dst = os.path.join(FONTS_DIR, dest_name)
        if os.path.exists(src):
            shutil.copy(src, dst)
            print(f"   ✓ {dest_name}")
        else:
            print(f"   ✗ Not found: {src_path}")

    shutil.rmtree(extract_path, ignore_errors=True)
    os.remove(zip_path)

if __name__ == "__main__":
    print("\n🔠 Smart Car AI — Font Downloader\n")
    for name, info in FONTS.items():
        download_font(name, info)
    print(f"\n✅ Fonts saved to: {FONTS_DIR}\n")
    print("Now run: flutter pub get && flutter run\n")
