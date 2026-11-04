# BANE: Slip & Counter

A one-file mobile game. No build step. Hosted on Vercel, emails stored in Supabase.

Files:
- `index.html`: the whole game
- `supabase.sql`: the signups table (run once in Supabase)
- `vercel.json`: basic security headers

## 1. Supabase (new project)

1. supabase.com > New project. Name it `bane-game`, pick a region near your players, save the database password somewhere safe.
2. SQL Editor > New query > paste `supabase.sql` > Run.
3. Project Settings > API. Copy the **Project URL** and the **publishable key** (older projects call it the `anon` key).
4. Open `index.html`, find the `CONFIG` block at the top of the script, and paste them in:
   ```
   SUPABASE_URL:'https://YOURPROJECT.supabase.co',
   SUPABASE_KEY:'sb_publishable_...',
   ```
5. Never paste the `service_role` or `secret` key into `index.html`. That key can read and delete everything.

## 2. GitHub

1. New repository, for example `bane-game`.
2. Upload `index.html`, `vercel.json`, `supabase.sql` and this README to the main branch.

## 3. Vercel

1. vercel.com > Add New > Project > import the `bane-game` repo.
2. Framework Preset: **Other**. Leave Build Command and Output Directory empty. Deploy.
3. Every push to `main` now redeploys the game.

## 4. Subdomain (Squarespace DNS)

1. Vercel project > Settings > Domains > add `play.bloodandnothingelse.com` (or any subdomain you like).
2. Vercel shows the DNS record to create. It is normally a CNAME pointing to `cname.vercel-dns.com`. Use exactly the value Vercel shows.
3. Squarespace > Settings > Domains > `bloodandnothingelse.com` > DNS Settings > Add Record:
   - Type: CNAME
   - Host: `play`
   - Data: the value from Vercel
4. Wait for Vercel to show the domain as valid. HTTPS is automatic.
5. Squarespace > Pages > add a **Link** to `https://play.bloodandnothingelse.com` in your menu.

## 5. Reading your signups

Supabase > Table Editor > `game_signups`. Use the export button for a CSV.

## Notes

- The publishable key is meant to be public. The table's Row Level Security lets it add rows only. It cannot read the list.
- Anyone can still submit fake emails to a public form. If that happens, add Cloudflare Turnstile or a Supabase Edge Function with rate limiting.
- You are collecting personal data. Add a privacy policy link to your site and honor unsubscribe requests in whatever tool you email from.


## Public leaderboard
Run the second block of `supabase.sql` ("PUBLIC LEADERBOARD") in the SQL Editor. It creates `game_scores`, which holds names and scores only, so the public key may read it. Emails stay in `game_signups`, which the public key cannot read. To remove a bad name or a fake score, open Table Editor > `game_scores` and delete the row.
