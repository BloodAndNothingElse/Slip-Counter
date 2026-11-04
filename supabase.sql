-- BANE game signups. Run this once in Supabase: SQL Editor > New query > paste > Run.

create table if not exists public.game_signups (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  email       text    not null check (length(email) <= 254 and email ~* '^[^@\s]+@[^@\s]+\.[^@\s]{2,}$'),
  score       integer not null default 0 check (score between 0 and 10000000),
  round       integer not null default 1 check (round between 1 and 1000),
  best_combo  integer not null default 0 check (best_combo between 0 and 100000),
  source      text    not null default 'bane-game' check (length(source) <= 40)
);

-- One row per email address, ignoring upper/lower case. The game treats a repeat as "already on the list".
create unique index if not exists game_signups_email_key on public.game_signups (lower(email));

-- Row Level Security: the public key in the game can ADD a signup and do nothing else.
alter table public.game_signups enable row level security;

drop policy if exists "anyone can sign up" on public.game_signups;
create policy "anyone can sign up"
  on public.game_signups
  for insert
  to anon
  with check (true);

grant insert on public.game_signups to anon;

-- There is deliberately NO select, update or delete policy for anon.
-- Nobody can read the email list from a browser. You read it in the Supabase dashboard (Table Editor).


-- ============ PUBLIC LEADERBOARD (run this block too) ============
-- Names and scores only. No emails are stored here, so it is safe for the public key to READ this table.
create table if not exists public.game_scores (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  name        text    not null check (name ~ '^[A-Za-z0-9 _.\-]{2,14}$'),
  score       integer not null check (score between 1 and 2000000),
  round       integer not null default 1 check (round between 1 and 1000),
  best_combo  integer not null default 0 check (best_combo between 0 and 100000)
);
create index if not exists game_scores_score_idx on public.game_scores (score desc);

alter table public.game_scores enable row level security;

drop policy if exists "anyone can read scores" on public.game_scores;
create policy "anyone can read scores" on public.game_scores for select to anon using (true);

drop policy if exists "anyone can post a score" on public.game_scores;
create policy "anyone can post a score" on public.game_scores for insert to anon with check (true);

grant select, insert on public.game_scores to anon;
-- No update or delete for anon. To remove a cheater or a bad name: Table Editor > game_scores > delete the row.
