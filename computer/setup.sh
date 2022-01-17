#!/bin/bash
cd

sudo apt update
sudo apt upgrade -y
sudo apt install -y vim git tmux curl xorg chromium python3-pip

pip3 install pynput gpiozero

git clone https://github.com/Amplus2/collatz-collection.git

sudo adduser --gecos '' kekw-admin

cat > .xinitrc <<EOF
#!/bin/sh

python3 /home/pi/collatz-collection/computer/keyboard_driver.py &

xrandr="$(xrandr | grep '*' | head -n 1 | awk '{ print $1 }')"

wid="$(echo "$xrandr" | cut -dx -f1)"
hei="$(echo "$xrandr" | cut -dx -f2)"

exec chromium https://amplus2.github.io/collatz-collection/ --kiosk \
    --start-fullscreen --fast --noerrdialogs --fast-start --disable-infobars \
    --disable-features=TranslateUI --disable-translate --window-size=$wid,$hei \
    --user-agent="Mozilla/5.0 (X11; Linux ARM) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36 SpielMalMathe"
EOF

cat > .profile <<EOF
#!/bin/sh
exec startx
EOF
