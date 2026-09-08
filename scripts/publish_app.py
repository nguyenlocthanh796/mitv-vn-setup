#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
publish_app.py - Tu dong upload APK len GitHub Releases va cap nhat apps.json
"""

import os
import sys
import json
import argparse
import subprocess
import urllib.request
import urllib.parse
import urllib.error

REPO_OWNER = "nguyenlocthanh796"
REPO_NAME = "mitv-vn-setup"

def get_git_token():
    env_token = os.environ.get("GITHUB_TOKEN")
    if env_token:
        return env_token.strip()
    try:
        proc = subprocess.Popen(
            ["git", "credential", "fill"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        out, _ = proc.communicate("protocol=https\nhost=github.com\n")
        for line in out.splitlines():
            if line.startswith("password="):
                return line.split("password=", 1)[1].strip()
    except Exception as e:
        print(f"[!] Khong lay duoc token tu git credential: {e}")
    return None

def github_api_request(url, method="GET", data=None, headers=None):
    req = urllib.request.Request(url, data=data, method=method)
    if headers:
        for k, v in headers.items():
            req.add_header(k, v)
    return urllib.request.urlopen(req)

def get_release_by_tag(token, tag="v1.0.0"):
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/releases/tags/{tag}"
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "mitv-publish-tool"
    }
    try:
        with github_api_request(url, headers=headers) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        print(f"[!] Loi lay thong tin release {tag}: {e.code} {e.reason}")
        return None

def delete_asset(token, asset_id):
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/releases/assets/{asset_id}"
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "mitv-publish-tool"
    }
    try:
        with github_api_request(url, method="DELETE", headers=headers):
            return True
    except Exception as e:
        print(f"[!] Khong xoa duoc asset cu {asset_id}: {e}")
        return False

def upload_asset(token, upload_url_template, filepath):
    filename = os.path.basename(filepath)
    clean_upload_url = upload_url_template.split("{")[0]
    target_url = f"{clean_upload_url}?name={urllib.parse.quote(filename)}"
    content_type = "application/vnd.android.package-archive" if filename.endswith(".apk") else "application/octet-stream"
    headers = {
        "Authorization": f"token {token}",
        "Content-Type": content_type,
        "User-Agent": "mitv-publish-tool"
    }
    file_size = os.path.getsize(filepath)
    print(f"[*] Dang upload {filename} ({file_size / (1024*1024):.2f} MB)...")
    with open(filepath, "rb") as f:
        file_data = f.read()
    
    req = urllib.request.Request(target_url, data=file_data, method="POST")
    for k, v in headers.items():
        req.add_header(k, v)
    with urllib.request.urlopen(req) as resp:
        res = json.loads(resp.read().decode("utf-8"))
        return res.get("browser_download_url")

def update_apps_json(apps_json_path, app_id, download_url, version=None, version_code=None):
    if not os.path.exists(apps_json_path):
        return
    with open(apps_json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    updated = False
    for app in data.get("apps", []):
        if app.get("id") == app_id:
            app["download_url"] = download_url
            if version:
                app["version"] = version
            if version_code is not None:
                app["versionCode"] = int(version_code)
            updated = True
            break
            
    if updated:
        with open(apps_json_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"[+] Da cap nhat apps.json cho app '{app_id}'.")

def main():
    parser = argparse.ArgumentParser(description="Upload APK/XAPK len GitHub Releases va cap nhat apps.json")
    parser.add_argument("--file", help="Duong dan den file APK/XAPK")
    parser.add_argument("--dir", help="Duong dan den thu muc chua cac APK/XAPK can upload hang loat")
    parser.add_argument("--app", help="ID cua app trong apps.json (vd: tv360, vtvgo)")
    parser.add_argument("--version", help="Phien ban ung dung (vd: 6.3)")
    parser.add_argument("--code", type=int, help="VersionCode (vd: 632)")
    parser.add_argument("--tag", default="v1.0.0", help="Tag release tren GitHub (mac dinh: v1.0.0)")
    parser.add_argument("--token", help="GitHub Personal Access Token")
    args = parser.parse_args()

    token = args.token or get_git_token()
    if not token:
        print("[!] Khong tim thay GitHub token. Vui long truyen qua --token hoac bien moi truong GITHUB_TOKEN.")
        sys.exit(1)

    release = get_release_by_tag(token, args.tag)
    if not release:
        print(f"[!] Khong tim thay release voi tag '{args.tag}'.")
        sys.exit(1)

    upload_url = release.get("upload_url")
    existing_assets = {a["name"]: a["id"] for a in release.get("assets", [])}

    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    apps_json_path = os.path.join(repo_root, "apps.json")

    files_to_upload = []
    if args.file:
        if not os.path.isfile(args.file):
            print(f"[!] File khong ton tai: {args.file}")
            sys.exit(1)
        files_to_upload.append(args.file)
    elif args.dir:
        if not os.path.isdir(args.dir):
            print(f"[!] Thu muc khong ton tai: {args.dir}")
            sys.exit(1)
        for f in os.listdir(args.dir):
            if f.endswith(".apk") or f.endswith(".xapk"):
                files_to_upload.append(os.path.join(args.dir, f))

    if not files_to_upload:
        print("[!] Vui long truyen --file hoac --dir.")
        sys.exit(1)

    for filepath in files_to_upload:
        filename = os.path.basename(filepath)
        if filename in existing_assets:
            print(f"[*] Xoa asset cu '{filename}' (ID: {existing_assets[filename]})...")
            delete_asset(token, existing_assets[filename])
        
        url = upload_asset(token, upload_url, filepath)
        print(f"[OK] Da upload: {filename} -> {url}")
        
        if args.app and len(files_to_upload) == 1:
            update_apps_json(apps_json_path, args.app, url, args.version, args.code)

if __name__ == "__main__":
    main()
