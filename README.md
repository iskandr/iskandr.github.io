# Alex Rubinsteyn’s website

Published at <https://iskandr.github.io/> from the `master` branch of this
repository. The site consists of static HTML, CSS, images, and downloads. The
`.nojekyll` file disables Jekyll processing; GitHub Pages serves the files directly.

Edit files here and push to `master` to publish updates. No build dependencies are
required. To preview locally:

```sh
python3 -m http.server 8000 --bind 127.0.0.1
```

Open <http://localhost:8000/>. GitHub Pages serves `404.html` for missing routes;
Python’s simple server does not. The custom error page sends known old PHP URLs
to the corresponding static pages with JavaScript, preserving query strings and
fragments. These redirects initially receive HTTP 404 rather than a server-side
301. Navigation links remain available without JavaScript.

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
