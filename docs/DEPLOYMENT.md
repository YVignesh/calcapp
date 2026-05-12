# Calc Studio Deployment Guide

The app is live at `https://calcstudioapp.com`, hosted on **Cloudflare Workers static assets** (the domain is managed in Cloudflare; the app is a static Flutter web build).

## Hosting — Cloudflare Workers static assets

The repo is configured for a Workers static-assets deploy via **`wrangler.jsonc`**:

```jsonc
{
  "name": "calcapp",
  "assets": {
    "directory": "./build/web",
    "not_found_handling": "single-page-application"  // deep links (/loan, /units/length, …) serve index.html
  },
  "observability": { "enabled": true }
}
```

So you must run `flutter build web --release` first, then deploy `build/web`:

```bash
flutter build web --release
npx wrangler deploy
```

For a Git-connected (auto-deploy) pipeline, the Cloudflare build must produce `build/web` before `wrangler deploy` runs — if the Cloudflare build image doesn't ship Flutter, build with GitHub Actions (or locally) and let the deploy step only run `wrangler deploy`. Do **not** point the deploy at the raw `web/` directory — that's only Flutter's source web shell; the real site is generated into `build/web`.

### Routing — do NOT add a `web/_redirects` file

`not_found_handling: "single-page-application"` already serves `index.html` with **HTTP 200** for any path that isn't a real asset (so `/loan`, `/units/length`, `/category/finance`, … all boot the SPA at that route). That's all the SPA fallback you need.

A `web/_redirects` file used to exist with explicit `/<route> /index.html 200` lines — **it was removed because it broke deep links**: Workers Assets does *not* honor `200`-rewrites in `_redirects`, so each listed route became a `307` redirect that Cloudflare normalized to `/` (every deep link bounced to the homepage — fatal for direct links and SEO, since every sitemap URL redirected). Paths *without* a `_redirects` rule were fine, which is the tell. **If deep links ever 307 to `/` again, check for a stray `_redirects` file (or a dashboard Redirect Rule) first.** Sanity check after any deploy: `curl -I https://calcstudioapp.com/loan` → must be `200`, not `307`.

### Headers — `web/_headers` *is* honored

Workers static assets reads `web/_headers` (this is verified: `main.dart.js` carries `Cache-Control: public, max-age=31536000, immutable`, `flutter_service_worker.js` is `no-cache`, `robots.txt`/`sitemap.xml` are `max-age=3600` — exactly the rules in the file). It currently sets `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`, `X-Frame-Options`, and the cache rules above. Worth adding: `Strict-Transport-Security` (HSTS) and optionally a `Content-Security-Policy`. Verify with `curl -I https://calcstudioapp.com/` and `curl -I https://calcstudioapp.com/main.dart.js`.

(If you ever migrate to Cloudflare **Pages** instead: use a Pages project with build command `flutter build web --release`, output directory `build/web`, no custom deploy command. On Pages, `_headers` works the same way and `_redirects` *does* support `/* /index.html 200` — but on the current Workers setup, leave `_redirects` out.)

## Domain setup

Add both hostnames in Cloudflare and pick one canonical:

- Canonical: `https://calcstudioapp.com`
- Redirect: `https://www.calcstudioapp.com/*` → `https://calcstudioapp.com/$1`

After deployment, verify:

- `https://calcstudioapp.com/`
- `https://calcstudioapp.com/loan`
- `https://calcstudioapp.com/compound-interest`
- `https://calcstudioapp.com/sitemap.xml`
- `https://calcstudioapp.com/robots.txt`

## Feedback

Enable **Cloudflare Email Routing**: `feedback@calcstudioapp.com` → your inbox. The app's Settings screen lets users copy this address. Suggested prompt:

> Tell us the calculator name, expected result, actual result, device, browser, and what felt confusing.

## Search Console (so the site shows up in Google)

1. Open Google Search Console → **Add property → Domain** → `calcstudioapp.com`.
2. Verify with the **DNS TXT record** in Cloudflare DNS (Cloudflare DNS → add `TXT` `@` = `google-site-verification=…`; leave it in place permanently). DNS verification covers `www`/non-`www` and every subdomain and needs no code change. (Alternative: the URL-prefix property + the `google-site-verification` meta-tag placeholder already in `web/index.html` — but that needs a rebuild + redeploy.)
3. Submit the sitemap: enter `sitemap.xml` under **Sitemaps**. (`robots.txt` already points to `https://calcstudioapp.com/sitemap.xml`.)
4. Use **URL Inspection → Request indexing** on `/` and a few high-value routes (`/loan`, `/mortgage`, `/bmi`, …); the sitemap covers the rest over days/weeks.
5. **Flutter-web caveat:** the app renders via CanvasKit/JS, which crawlers mostly can't read — the SEO surface is the static `<main class="seo-content">` block + JSON-LD in `web/index.html`, whose per-route title/description/content is swapped in client-side from `window.location.pathname`. Use **URL Inspection → Test live URL → View crawled page** on `/loan` etc. to confirm Googlebot actually got the per-route content; if it didn't, that's the thing to fix. (Optionally do the same in Bing Webmaster Tools — it can import the property from Search Console.)

## Analytics

Cloudflare's dashboard gives **infrastructure** analytics (traffic, cache, errors, geography). For **product** analytics (which calculator gets used, drop-off) you need **Cloudflare Web Analytics** — a small JS beacon; there's a commented-out placeholder for its token in `web/index.html`. (SPA route changes don't hit the server, so request analytics can't see them.)

Recommended custom events for a later app-analytics pass: tool opened · calculation completed · result copied · feedback email copied · validation error shown.

## Launch / re-deploy checklist

- [ ] `flutter analyze` passes (0 issues)
- [ ] `flutter test` passes
- [ ] `flutter build web --release` passes
- [ ] `npx wrangler deploy` (or the CI equivalent) succeeds
- [ ] apex + `www` redirect policy works
- [ ] `robots.txt` and `sitemap.xml` reachable on the live domain
- [ ] hashed assets serve a long `immutable` cache header (`curl -I .../main.dart.js`)
- [ ] Search Console verified + sitemap submitted; URL Inspection shows real per-route content
- [ ] Cloudflare Web Analytics enabled
- [ ] feedback email route works
- [ ] Lighthouse mobile scores checked
- [ ] smoke-test top calculator routes on desktop, tablet, and mobile
