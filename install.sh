#!/usr/bin/env sh

# https://stackoverflow.com/a/16844327/11391913
readonly RCol='\e[0m'        # Text Reset
readonly BRed='\e[1;31m';    # Bold & Red
readonly Bold='\e[1m';       # Bold
readonly Underline='\e[4m';  # Underline

if [ "$(id -u)" -eq 0 ]; then
    printf "Please run as ${BRed}user${RCol} not as root.\n" >&2;
    exit 1;
fi

printf \
"${Bold}Bing wallpaper changer installer${RCol}:

1. ${BRed}systemd${RCol} (recomended):
   ${Underline}No python module dependancy needed${RCol}. Install script is
   going to install systemd service and timer to ${HOME}/.config/systemd/user/
   bing-wallpaper-changer.py will be started by
   ${HOME}/.config/systemd/user/bing-wallpaper-changer.timer.

2. ${BRed}standalone${RCol}:
   ${Underline}schedule python module needed${RCol}. You need to install
   schedule module manually to your system before choose this option.
   bing-wallpaper-changer.py will be started by
   ${HOME}/.config/autostart/bing-wallpaper-changer.desktop.

3. ${BRed}uninstall${RCol}:
   Stops timer, service, daemon and then uninstall downloaded files except wallpapers.
   Downloaded wallpapers are not going to erase. You can find them in
   ${HOME}/.local/share/backgrounds/Bing Wallpapers/ directory.

Please select an option: [1/2/3] " >&2;

read -r option
#printf '%s\n' "$option"

case "$option" in
    1)
        printf "${BRed}systemd${RCol} install selected: \n"
        printf "Creating ${HOME}/.local/bin, ${HOME}/.config/systemd/user and\n"
        printf "${HOME}/.local/share/backgrounds/Bing Wallpapers/ directories.\n"
        mkdir -p "${HOME}"/.local/bin \
                 "${HOME}"/.config/systemd/user \
                 "${HOME}/.local/share/backgrounds/Bing Wallpapers/"

        printf "Downloading files...\n"
        if [ -f "$(command -v curl)" ]; then
            curl -sSL https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.py \
                --output "${HOME}"/.local/bin/bing-wallpaper-changer.py
            curl -sSL https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.service \
                --output "${HOME}"/.config/systemd/user/bing-wallpaper-changer.service
            curl -sSL https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.timer \
                --output "${HOME}"/.config/systemd/user/bing-wallpaper-changer.timer
        else
            wget --quiet --output-document="${HOME}"/.local/bin/bing-wallpaper-changer.py \
                https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.py
            wget --quiet --output-document="${HOME}"/.config/systemd/user/bing-wallpaper-changer.service \
                https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.service
            wget --quiet --output-document="${HOME}"/.config/systemd/user/bing-wallpaper-changer.timer \
                https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.timer
        fi

        printf "Starting bing-wallpaper-changer service...\n"
        chmod +x "${HOME}"/.local/bin/bing-wallpaper-changer.py
        systemctl --user daemon-reload
        systemctl --quiet --user enable --now bing-wallpaper-changer.timer
        printf "Done.\n"
        ;;
    2)
        # https://unix.stackexchange.com/a/80632
        if ! python3 -c 'import schedule' >/dev/null 2>&1; then
            printf "\n${BRed}schedule${RCol} %s\n%s\n%s\n" \
            "python module is not found in your system." \
            "Please install manually to your system and then" \
            "retry this install script.";
            exit 1;
        fi

        printf "${BRed}standalone${RCol} install selected:\n"
        printf "Creating ${HOME}/.local/bin, ${HOME}/.config/autostart and\n"
        printf "${HOME}/.local/share/backgrounds/Bing Wallpapers/ directories.\n"
        mkdir -p "${HOME}"/.local/bin \
                 "${HOME}"/.config/autostart \
                 "${HOME}/.local/share/backgrounds/Bing Wallpapers/"

        printf "Downloading files...\n"
        if [ -f "$(command -v curl)" ]; then
            curl -sSL https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.py \
                --output "${HOME}"/.local/bin/bing-wallpaper-changer.py
            curl -sSL https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.desktop \
                --output "${HOME}"/.config/autostart/bing-wallpaper-changer.desktop
        else
            wget --quiet --output-document="${HOME}"/.local/bin/bing-wallpaper-changer.py \
                https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.py
            wget --quiet --output-document="${HOME}"/.config/autostart/bing-wallpaper-changer.desktop \
                https://github.com/queeup/bing-wallpaper-changer/raw/main/bing-wallpaper-changer.desktop
        fi

        printf "Starting bing-wallpaper-changer...\n"
        chmod +x "${HOME}"/.local/bin/bing-wallpaper-changer.py
        "${HOME}"/.local/bin/bing-wallpaper-changer.py --daemon --quiet &

        printf "Done.\n"
        ;;
    3)
        printf "${BRed}uninstall${RCol} selected:\n"
        printf "Stoping daemon & service...\n"
        kill -TERM $(pgrep -f '^python.*bing-wallpaper-changer.py') >/dev/null 2>&1
        systemctl --quiet --user disable --now bing-wallpaper-changer.timer >/dev/null 2>&1
        printf "Uninstalling bing-wallpaper-changer...\n"
        rm "${HOME}"/.local/bin/bing-wallpaper-changer.py \
           "${HOME}"/.config/autostart/bing-wallpaper-changer.* \
           "${HOME}"/.config/systemd/user/bing-wallpaper-changer.* >/dev/null 2>&1
        systemctl --user daemon-reload
        printf "Done.\n"
        ;;
    *)
        printf "Wrong option selected. Please try again.\n"
esac
