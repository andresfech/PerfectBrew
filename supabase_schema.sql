-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create recipes table
create table public.recipes (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  method text not null,
  version int default 1,
  json_data jsonb not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security (RLS)
alter table public.recipes enable row level security;

-- Create policy to allow read access for everyone (public)
create policy "Allow public read access"
  on public.recipes
  for select
  using (true);

-- Create policy to allow write access for service role (used by migration scripts)
-- Note: In Supabase, the 'service_role' key bypasses RLS, but it's good practice to have explicit policies if using authenticated users.
create policy "Allow all access for authenticated users"
  on public.recipes
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- Create grinders table
create table public.grinders (
  id uuid primary key default uuid_generate_v4(),
  name text not null, -- e.g. "Timemore Chestnut C2s"
  method text not null, -- e.g. "AeroPress"
  settings_json jsonb not null, -- Stores the key-value mapping of "Recipe Name" -> "Clicks"
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for grinders
alter table public.grinders enable row level security;

-- Public read access for grinders
create policy "Allow public read access grinders"
  on public.grinders
  for select
  using (true);

-- Authenticated write access for grinders
create policy "Allow all access for authenticated users grinders"
  on public.grinders
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');
