# Alex Rubinsteyn’s website

Published at <https://iskandr.github.io/> from the `master` branch of this
repository. The site consists of static HTML, CSS, images, and downloads. The
`.nojekyll` file disables Jekyll processing; GitHub Pages serves the files directly.

Edit files here and push to `master` to publish updates. No build dependencies are
required. To preview locally:

```sh
python3 -m http.server 8000 --bind 127.0.0.1
```

Open <http://localhost:8000/>. The [full archive](https://iskandr.github.io/archive.html)
links to the original writing, presentations, teaching materials, and downloads.
Static directory indexes preserve the old Apache browsing URLs, including
`/files/`, `/images/`, `/text/`, and the computational photography results folders.

Dedicated redirect pages preserve the historical PHP, top-level article, and
`/writing/` URLs. PHP-style paths are static directories: the server adds a
trailing slash, then the HTML page redirects to the current destination.
JavaScript preserves query strings and fragments; a meta refresh and a link also
work without JavaScript. `404.html` retains a fallback for these known old URLs.
The legacy PDF URLs `/writing/RR_deriv.pdf` and `/hps/RR_deriv.pdf` serve the PDF
bytes directly. Historical CSS and sea-cow image paths are restored from Git.

Run the preservation audit after changes:

```sh
python3 scripts/check_archive.py
```

`migration-manifest.json` records 206 preserved asset hashes (197 matching the old
live server and 9 restored assets or PDF aliases), 24 original content pages,
13 legacy redirects, and 8 directory listings. The audit also checks internal
links, fragments, and sitemap targets. If intentionally replacing a download,
update its recorded hash alongside that change. External blogs stay on their
original hosts; their links are retained.

The previous Jekyll starter site remains in this repository’s Git history.

## Connect rubinsteyn.com

DNS for the domain is currently hosted by Linode (Akamai Cloud Manager).

1. In [account Pages settings](https://github.com/settings/pages), add
   `rubinsteyn.com` as a verified domain. Add GitHub’s provided TXT value under
   `_github-pages-challenge-iskandr` in Linode, then verify it on GitHub. Keep the
   TXT record after verification.
2. In [repository Pages settings](https://github.com/iskandr/iskandr.github.io/settings/pages),
   set the custom domain to `rubinsteyn.com` before changing the web DNS records.
   This creates a `CNAME` file in `master`; pull that commit before editing locally.
3. In [Linode Cloud Manager](https://cloud.linode.com/domains), open the
   `rubinsteyn.com` zone. Replace the apex web records and the `www` web records
   with the values below. Use a blank hostname for the apex in Linode’s UI.

| Hostname | Type | Target |
| --- | --- | --- |
| (blank) | A | `185.199.108.153` |
| (blank) | A | `185.199.109.153` |
| (blank) | A | `185.199.110.153` |
| (blank) | A | `185.199.111.153` |
| (blank) | AAAA | `2606:50c0:8000::153` |
| (blank) | AAAA | `2606:50c0:8001::153` |
| (blank) | AAAA | `2606:50c0:8002::153` |
| (blank) | AAAA | `2606:50c0:8003::153` |
| `www` | CNAME | `iskandr.github.io` |

Remove the old apex A/AAAA targets, plus the old `www` A/AAAA records, rather than
leaving them alongside these. Preserve mail, TXT verification, and unrelated
service records. Keep the existing Linode nameservers.

4. Wait for DNS propagation and GitHub’s certificate, then enable **Enforce HTTPS**
   in repository Pages settings. The old records had a 24-hour TTL, so some
   visitors may continue reaching the old host for up to a day. Keep that host
   available during the change.
5. Update `sitemap.txt` to use `https://rubinsteyn.com` in place of
   `https://iskandr.github.io` and push that change.

Once configured, `iskandr.github.io` and `www.rubinsteyn.com` redirect to
`rubinsteyn.com`. GitHub project sites without their own custom domains inherit
the user-site domain (for example, `rubinsteyn.com/weave/`). Check those project
links after switching.

References: [GitHub custom domain setup](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site),
[domain verification](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/verifying-your-custom-domain-for-github-pages),
[Linode DNS management](https://techdocs.akamai.com/cloud-computing/docs/manage-dns-records).
