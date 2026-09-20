CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  role TEXT CHECK (role IN ('parent', 'child')) NOT NULL,
  display_name TEXT NOT NULL,
  grade_level TEXT CHECK (grade_level IN ('Basic 1', 'Basic 3', 'JSS 1')),
  quest_coins INTEGER DEFAULT 0,
  avatar_data JSONB DEFAULT '{}'::jsonb
);

CREATE TABLE syllabus_nodes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  child_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  subject TEXT NOT NULL,
  topic_title TEXT NOT NULL,
  status TEXT CHECK (status IN ('locked', 'active', 'completed')) DEFAULT 'locked',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  node_id UUID REFERENCES syllabus_nodes(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  options JSONB NOT NULL,
  correct_index INTEGER NOT NULL
);

CREATE TABLE rewards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  child_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  coin_cost INTEGER NOT NULL,
  is_redeemed BOOLEAN DEFAULT FALSE,
  parent_approved BOOLEAN DEFAULT FALSE
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE syllabus_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;
