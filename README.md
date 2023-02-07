# Bing Wallpaper Changer

It changes your wallpaper everyday at 8AM UTC ([or your local time](https://github.com/queeup/bing-wallpaper-changer/blob/main/bing-wallpaper-changer.py#L135)) with [Bing](https://www.bing.com) wallpaper.

Linux & Gnome (and derivatives) only at the moment.

## Dependencies

- Python 3
- [systemd](https://github.com/systemd/systemd) or [schedule](https://github.com/dbader/schedule)

## Install

*Use as a normal user.*

*This script creates directories, downloads necessary files from this github repo to your system (to your user folder) and then runs wallpaper changer script.*

### With curl

```bash
sh -c "$(curl -fsSL https://github.com/queeup/bing-wallpaper-changer/raw/main/install.sh)"
```

### With wget

```bash
sh -c "$(wget -nv https://github.com/queeup/bing-wallpaper-changer/raw/main/install.sh -O -)"
```

## Uninstall

Run [install](#install) script and then choose option **3**.
