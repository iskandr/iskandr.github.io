#!/usr/bin/env python3
"""Check that migrated downloads, content pages, and legacy paths remain intact."""

from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urljoin, urlsplit
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
HOSTS = {'iskandr.github.io', 'rubinsteyn.com', 'www.rubinsteyn.com'}
PROJECT_PATHS = {'/weave', '/weave/'}


class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
        self.anchors = set()
        self.refresh = None

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if attrs.get('id'):
            self.anchors.add(attrs['id'])
        if tag == 'a' and attrs.get('name'):
            self.anchors.add(attrs['name'])
        for name in ('href', 'src'):
            if attrs.get(name):
                self.links.append(attrs[name])
        if tag == 'meta' and attrs.get('http-equiv', '').lower() == 'refresh':
            self.refresh = attrs.get('content', '').split('url=', 1)[-1].strip()


def main():
    manifest = json.loads((ROOT / 'migration-manifest.json').read_text())
    files = {
        source.relative_to(ROOT).as_posix(): source
        for source in ROOT.rglob('*')
        if source.is_file() and '.git' not in source.parts
    }
    errors = []

    def resolve(path):
        relative = unquote(path).lstrip('/')
        if relative in files:
            return relative
        index = relative.rstrip('/') + '/index.html' if relative else 'index.html'
        return index if index in files else None

    for name, record in manifest['assets'].items():
        if name not in files:
            errors.append(f'Missing preserved asset: {name}')
        elif hashlib.sha256(files[name].read_bytes()).hexdigest() != record['sha256']:
            errors.append(f'Preserved asset changed: {name}')
    for old, target in manifest['original_pages'].items():
        if not resolve(target):
            errors.append(f'Missing original page: {old} -> {target}')
    for directory in manifest['directory_listings']:
        if f'{directory}/index.html' not in files:
            errors.append(f'Missing directory listing: {directory}')

    pages = {}
    for name, source in files.items():
        if name.endswith('.html'):
            page = Page()
            page.feed(source.read_text(encoding='utf-8'))
            pages[name] = page
    for old, target in manifest['redirects'].items():
        name = resolve(old)
        if name not in pages or pages[name].refresh != target:
            errors.append(f'Missing or incorrect redirect: {old} -> {target}')
        if not resolve(target):
            errors.append(f'Missing redirect destination: {old} -> {target}')
    links = 0
    for name, page in pages.items():
        for value in page.links:
            url = urlsplit(urljoin('https://iskandr.github.io/' + name, value))
            if url.hostname not in HOSTS:
                continue
            if url.hostname == 'iskandr.github.io' and url.path in PROJECT_PATHS:
                continue
            target = resolve(url.path)
            if target is None:
                errors.append(f'{name}: missing local link: {value}')
            elif url.fragment and target in pages and unquote(url.fragment) not in pages[target].anchors:
                errors.append(f'{name}: missing fragment: {value}')
            links += 1
    for value in (ROOT / 'sitemap.txt').read_text().splitlines():
        if not resolve(urlsplit(value).path):
            errors.append(f'Missing sitemap target: {value}')
    if errors:
        raise SystemExit('\n'.join(errors))
    print(f"Verified {len(manifest['assets'])} preserved asset hashes, "
          f"{len(manifest['original_pages'])} original pages, "
          f"{len(manifest['redirects'])} legacy redirects, "
          f"{len(manifest['directory_listings'])} directory listings, and {links} local links.")


if __name__ == '__main__':
    main()
