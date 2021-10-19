#!/usr/bin/env sh

mkdir -p ~/.local/bin ~/.config/autostart

echo "Install dependencies..."
pip install --quiet --user schedule

echo "Downloading files..."
curl -sSL https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.py --output ~/.local/bin/bing-wallpaper-changer.py
curl -sSL https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.desktop --output ~/.config/autostart/bing-wallpaper-changer.desktop

echo "Starting bing-wallpaper-changer..."
chmod +x ~/.local/bin/bing-wallpaper-changer.py
~/.local/bin/bing-wallpaper-changer.py &

echo "Done."
