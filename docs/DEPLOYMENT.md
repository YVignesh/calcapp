# Calc Studio Deployment Guide

This guide is for launching the public beta at `https://calcstudioapp.com`.

## Recommended Host

Use **Cloudflare Pages**. The domain is already managed in Cloudflare, the app is a static Flutter web build, and the repo includes Cloudflare Pages files:

- `web/_redirects` for direct route fallback to the Flutter app.
- `web/_headers` for security and cache headers.
- `web/robots.txt`
- `web/sitemap.xml`

## Cloudflare Pages Settings

Connect the GitHub repository in **Cloudflare Dashboard > Workers & Pages > Create application > Pages > Connect to Git**.

Important: use a **Pages** project, not a Workers deploy command. If the log says `Executing user deploy command: npx wrangler deploy`, Cloudflare is deploying the raw `web/` folder instead of the Flutter release build. That is wrong for this app.

Use these build settings:

| Setting | Value |
| --- | --- |
| Framework preset | None |
| Build command | `flutter build web --release` |
| Build output directory | `build/web` |
| Root directory | `/` |

Do **not** set:

| Setting | Wrong value |
| --- | --- |
| Deploy command | `npx wrangler deploy` |
| Output directory | `web` |

The `web/` directory is only Flutter's source web shell. The deployable site is generated into `build/web` after `flutter build web --release`.

If the Cloudflare build image does not include Flutter, use one of these options:

1. Build with GitHub Actions and deploy `build/web` to Cloudflare Pages.
2. Use Cloudflare Pages Direct Upload after running `flutter build web --release` locally.
3. Configure the Pages build to install Flutter before the build command.

For a quick manual deploy from your machine:

```bash
flutter build web --release
npx wrangler pages deploy build/web --project-name calc-studio
```

For Git-connected deploys, the preferred project settings are still:

```text
Build command: flutter build web --release
Build output directory: build/web
```

## Domain Setup

In Cloudflare Pages, add:

- `calcstudioapp.com`
- `www.calcstudioapp.com`

Choose one canonical host. Recommended:

- Canonical: `https://calcstudioapp.com`
- Redirect: `https://www.calcstudioapp.com/*` -> `https://calcstudioapp.com/$1`

After deployment, verify:

- `https://calcstudioapp.com/`
- `https://calcstudioapp.com/loan`
- `https://calcstudioapp.com/compound-interest`
- `https://calcstudioapp.com/sitemap.xml`
- `https://calcstudioapp.com/robots.txt`

## Feedback Setup

Enable **Cloudflare Email Routing**:

- Address: `feedback@calcstudioapp.com`
- Destination: your personal inbox

The app Settings screen copies this feedback email for users.

Suggested feedback prompt:

> Tell us the calculator name, expected result, actual result, device, browser, and what felt confusing.

## Search Console

1. Open Google Search Console.
2. Add a Domain property for `calcstudioapp.com`.
3. Verify using the DNS TXT record in Cloudflare DNS.
4. Submit `https://calcstudioapp.com/sitemap.xml`.
5. Use URL Inspection on:
   - `/`
   - `/compound-interest`
   - `/loan`
   - `/mortgage`
   - `/bmi`
   - `/bmr`
   - `/percentage`

## Analytics

Enable **Cloudflare Web Analytics** for privacy-friendly traffic data.

Recommended events to add in a later app analytics pass:

- Tool opened
- Calculation completed
- Result copied
- Feedback email copied
- Validation error shown

## V1 Launch Checklist

- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] `flutter build web --release` passes
- [ ] Cloudflare Pages deploy succeeds
- [ ] Apex and `www` redirect policy works
- [ ] `robots.txt` reachable
- [ ] `sitemap.xml` reachable
- [ ] Search Console verified
- [ ] Sitemap submitted
- [ ] Cloudflare Web Analytics enabled
- [ ] Feedback email route works
- [ ] Lighthouse mobile scores checked
- [ ] Smoke test top calculator routes on desktop and mobile
