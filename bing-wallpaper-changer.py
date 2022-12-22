#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Bing Wallpaper Changer

It changes your gnome desktop wallpaper automatically from bing.com

author: queeup at zoho dot com
"""

import json
import os
import subprocess
import time
import logging
from argparse import ArgumentParser
from datetime import datetime
from base64 import b64decode
from urllib import parse
from urllib.error import HTTPError, URLError
from urllib.request import urlopen

URL = "aHR0cHM6Ly93d3cuYmluZy5jb20vSFBJbWFnZUFyY2hpdmUuYXNweD9mb3JtYXQ9anMmaWR4PTAmbj0x"


def get_parser():
    parser = ArgumentParser(
        prog="bing-wallpaper-changer.py",
        description="It changes your gnome desktop wallpaper automatically from bing.com",
    )
    parser.add_argument(
        "--daemon",
        "-d",
        action="store_true",
        default=False,
        help="Daemon with schedule python module",
    )
    parser.add_argument(
        "--once",
        "-1",
        action="store_true",
        default=False,
        help="Change wallpaper and exit.",
    )
    parser.add_argument(
        "--quiet",
        "-q",
        action="store_true",
        default=False,
        help="Don't print anything to console.",
    )
    return parser


def fetch_url(url):
    # if network is not ready (wakeup from suspend etc.), loop until connection to establish.
    while True:
        try:
            response = urlopen(url)
        except (URLError, HTTPError):
            time.sleep(1)
        else:
            # TODO: Find a elegant way to check VPN connection
            #       is up after wake from suspend and then execute
            time.sleep(2)  # wait for VPN connection after wake from suspend.
            return response


def get_data(url):
    json_data = json.load(fetch_url(url))["images"]
    return (
        f"https://www.bing.com{json_data[0]['url']}",
        # Retrieving parameters from a URL:
        # https://stackoverflow.com/a/41611063/11391913
        parse.parse_qs(parse.urlparse(json_data[0]["url"]).query)["id"][0],
    )


def get_wallpaper_data(url):
    wallpaper_url, wallpaper_file = get_data(url)
    wallpaper_folder = f"{os.environ['HOME']}/.local/share/backgrounds/Bing Wallpapers/"
    if not os.path.exists(wallpaper_folder):
        os.mkdir(wallpaper_folder)
    return wallpaper_folder + wallpaper_file, wallpaper_url


def download_wallpaper(wallpaper_url, wallpaper_file):
    with urlopen(wallpaper_url) as img_data:
        with open(wallpaper_file, "wb") as f:
            f.write(img_data.read())


def set_wallpaper(wallpaper_file):
    file = f"'file://{wallpaper_file}'"
    # Disable Black formatting:
    # https://stackoverflow.com/a/61579589/11391913
    # fmt: off
    subprocess.run(
        ["gsettings", "set", "org.gnome.desktop.background", "picture-options", "'zoom'",]
    )

    if subprocess.run(
        ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"],
        capture_output=True,
        text=True,
    ).stdout.strip("'\n") == "prefer-dark":
        subprocess.run(
            ["gsettings", "set", "org.gnome.desktop.background", "picture-uri-dark", file,]
        )
    else:
        # fmt: on
        subprocess.run(
            ["gsettings", "set", "org.gnome.desktop.background", "picture-uri", file]
        )


def changing_wallpaper(message):
    wallpaper_file, wallpaper_url = get_wallpaper_data(b64decode(URL).decode("utf-8"))
    if not os.path.isfile(wallpaper_file):
        if not get_parser().parse_args().quiet:
            logging.info(message)
        download_wallpaper(wallpaper_url, wallpaper_file)
        set_wallpaper(wallpaper_file)
    else:
        if not get_parser().parse_args().quiet:
            logging.info(
                "Bing Wallpaper Changer:\n"
                "Wallpaper already downloaded or not changed since last updated.\n"
                "Using downloaded wallpaper."
            )
        set_wallpaper(wallpaper_file)


def wallpaper_change_time():
    # Bing wallpapers are updated at 8AM UTC everyday. So calculate it for any timezone.
    time_difference = datetime.utcnow() - datetime.utcnow().replace(
        hour=8, minute=1, second=0, microsecond=0
    )
    return (datetime.now() - time_difference).strftime("%H:%M")


def main():
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    args = get_parser().parse_args()
    if args.once:
        changing_wallpaper("Bing Wallpaper Changer: Changing wallpaper.")
    elif args.daemon:
        try:
            import schedule
        except ModuleNotFoundError as e:
            logging.exception(e.msg)
            exit()

        # set wallpaper on first run
        changing_wallpaper("Bing Wallpaper Changer: Changing wallpaper.")
        schedule.every().day.at(wallpaper_change_time()).do(
            changing_wallpaper,
            "Bing Wallpaper Changer: Scheduled wallpaper change.",
        )

        while True:
            schedule.run_pending()
            time.sleep(1)
    else:
        get_parser().print_help()


if __name__ == "__main__":
    main()
