-- 1. Add parent_id column to profiles table
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE;

-- 2. Update the signup trigger to handle parent_id from metadata
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    role,
    display_name,
    grade_level,
    parent_id,
    quest_coins,
    avatar_data
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'role', 'parent'),
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'grade_level',
    (NEW.raw_user_meta_data->>'parent_id')::uuid,
    0,
    '{}'::jsonb
  );
  RETURN NEW;
END;
$$;

-- 3. Security Definer Helper Function (prevents infinite recursion in RLS)
CREATE OR REPLACE FUNCTION public.is_parent_of(_child_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = _child_id AND parent_id = auth.uid()
  );
$$;

--------------------------------------------------------------------------------
-- 4. PROFILES POLICIES
--------------------------------------------------------------------------------
-- Users can view their own profile OR profiles of children they manage
CREATE POLICY "View profiles" ON public.profiles
  FOR SELECT USING (
    id = auth.uid() OR public.is_parent_of(id)
  );

-- Parents can update their children's profiles or their own
CREATE POLICY "Update profiles" ON public.profiles
  FOR UPDATE USING (
    id = auth.uid() OR public.is_parent_of(id)
  );

--------------------------------------------------------------------------------
-- 5. SYLLABUS NODES POLICIES
--------------------------------------------------------------------------------
-- Kids can view their nodes; Parents can view their children's nodes
CREATE POLICY "Select syllabus nodes" ON public.syllabus_nodes
  FOR SELECT USING (
    child_id = auth.uid() OR public.is_parent_of(child_id)
  );

-- Only Parents can create, update, or delete syllabus nodes
CREATE POLICY "Parent manage syllabus nodes" ON public.syllabus_nodes
  FOR ALL USING (
    public.is_parent_of(child_id)
  );

--------------------------------------------------------------------------------
-- 6. QUESTIONS (BOSS BATTLES) POLICIES
--------------------------------------------------------------------------------
-- Kids and Parents can read questions linked to accessible nodes
CREATE POLICY "Select questions" ON public.questions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.syllabus_nodes sn
      WHERE sn.id = node_id
      AND (sn.child_id = auth.uid() OR public.is_parent_of(sn.child_id))
    )
  );

-- Only Parents can manage (create/edit) generated questions
CREATE POLICY "Parent manage questions" ON public.questions
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.syllabus_nodes sn
      WHERE sn.id = node_id AND public.is_parent_of(sn.child_id)
    )
  );

--------------------------------------------------------------------------------
-- 7. REWARDS POLICIES
--------------------------------------------------------------------------------
-- Kids and Parents can view rewards
CREATE POLICY "Select rewards" ON public.rewards
  FOR SELECT USING (
    child_id = auth.uid() OR public.is_parent_of(child_id)
  );

-- Only Parents can create or delete rewards
CREATE POLICY "Parent create/delete rewards" ON public.rewards
  FOR INSERT WITH CHECK (public.is_parent_of(child_id));

CREATE POLICY "Parent delete rewards" ON public.rewards
  FOR DELETE USING (public.is_parent_of(child_id));

-- Kids can update (claim/redeem); Parents can update (approve)
CREATE POLICY "Update rewards" ON public.rewards
  FOR UPDATE USING (
    child_id = auth.uid() OR public.is_parent_of(child_id)
  );
