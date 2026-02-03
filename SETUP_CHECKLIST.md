# ✅ Messages Backend Integration - Setup Checklist

Use this checklist to ensure everything is properly set up.

## 📋 Pre-Setup

- [ ] Supabase account is active
- [ ] Supabase project is created
- [ ] Supabase URL and Key are configured in app
- [ ] User authentication is working
- [ ] App builds without errors

## 🗄️ Database Setup

### Step 1: Create Tables
- [ ] Open Supabase dashboard
- [ ] Navigate to SQL Editor
- [ ] Open `database/messages_schema.sql`
- [ ] Copy entire file contents
- [ ] Paste and run in SQL Editor
- [ ] Verify "Success. No rows returned" message

### Step 2: Verify Tables
Run this query to check tables exist:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('conversations', 'messages', 'user_profiles');
```
- [ ] `conversations` table exists
- [ ] `messages` table exists
- [ ] `user_profiles` table exists

### Step 3: Check RLS
Run this query to verify RLS is enabled:
```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('conversations', 'messages', 'user_profiles');
```
- [ ] RLS enabled on `conversations`
- [ ] RLS enabled on `messages`
- [ ] RLS enabled on `user_profiles`

### Step 4: Check Policies
Run this query to verify policies exist:
```sql
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('conversations', 'messages', 'user_profiles');
```
- [ ] At least 3 policies on `conversations`
- [ ] At least 3 policies on `messages`
- [ ] At least 3 policies on `user_profiles`

## 📁 Code Files

### Verify Files Exist
- [ ] `Message/models/Message.swift`
- [ ] `Message/models/ConversationModel.swift`
- [ ] `Message/service/MessagesService.swift`
- [ ] `Message/MessagesViewController.swift` (updated)
- [ ] `Message/README.md`

### Verify Xcode Target
- [ ] Open Xcode
- [ ] Select `Message.swift` file
- [ ] Check File Inspector (right panel)
- [ ] Verify "Target Membership" includes your app target
- [ ] Repeat for all new files

## 🔨 Build & Compile

- [ ] Clean build folder (Cmd+Shift+K)
- [ ] Build project (Cmd+B)
- [ ] No errors shown
- [ ] No warnings about missing files
- [ ] App runs on simulator/device

## 👤 Test Data Setup

### Option A: Create Test User Profiles
Run in SQL Editor:
```sql
-- Get your current user ID
SELECT id, email FROM auth.users LIMIT 5;

-- Create profile for yourself (replace YOUR_USER_ID)
INSERT INTO user_profiles (id, full_name, username, avatar_url)
VALUES (
    'YOUR_USER_ID'::UUID,
    'Your Name',
    'your_username',
    'https://example.com/avatar.jpg'
);
```
- [ ] User profile created for test user 1
- [ ] User profile created for test user 2

### Option B: Create Test Conversation
Run in SQL Editor:
```sql
-- Create a test conversation (replace USER_IDs)
INSERT INTO conversations (participant1_id, participant2_id, last_message_content, last_message_time)
VALUES (
    'USER_1_ID'::UUID,
    'USER_2_ID'::UUID,
    'Hey, how are you?',
    NOW()
);

-- Get the conversation ID
SELECT id FROM conversations ORDER BY created_at DESC LIMIT 1;

-- Add test messages (replace CONVERSATION_ID and USER_IDs)
INSERT INTO messages (conversation_id, sender_id, content) VALUES
    ('CONVERSATION_ID'::UUID, 'USER_1_ID'::UUID, 'Hey, how are you?'),
    ('CONVERSATION_ID'::UUID, 'USER_2_ID'::UUID, 'I am good! Thanks for asking!'),
    ('CONVERSATION_ID'::UUID, 'USER_1_ID'::UUID, 'Great! Want to work on a project together?');
```
- [ ] Test conversation created
- [ ] Test messages added

## 🧪 Manual Testing

### Test 1: Load Messages Screen
- [ ] Open app
- [ ] Login as user
- [ ] Navigate to Messages tab
- [ ] Loading indicator appears briefly
- [ ] No crash occurs
- [ ] Either conversations appear OR empty state shows

### Test 2: View Empty State
If no conversations:
- [ ] Empty state label shows
- [ ] Text reads "No conversations yet"
- [ ] Can still navigate around app

### Test 3: View Conversations
If conversations exist:
- [ ] Conversations list displays
- [ ] User names show correctly
- [ ] Last message preview shows
- [ ] Timestamps show (Today, Yesterday, etc.)
- [ ] Avatar images load (or placeholder shows)

### Test 4: Open Chat
- [ ] Tap on a conversation
- [ ] Chat view opens
- [ ] Title shows other user's name
- [ ] Messages load and display
- [ ] Chronological order (oldest to newest)

### Test 5: Send Message
- [ ] Type message in input field
- [ ] Tap "Send" button
- [ ] Message clears from input
- [ ] Messages reload
- [ ] New message appears in chat
- [ ] Go back to Messages list
- [ ] Last message updated in conversation preview

### Test 6: Error Handling
Test not logged in:
- [ ] Logout of app
- [ ] Go to Messages tab
- [ ] No crash occurs
- [ ] Either shows empty state or error message

Test network error:
- [ ] Turn off WiFi/cellular
- [ ] Pull to refresh messages
- [ ] Error message shows
- [ ] No crash occurs

## 📊 Monitoring

### Check Logs
In Xcode console, look for:
- [ ] "🔍 Fetching conversations for user: [UUID]"
- [ ] "✅ Loaded X conversations"
- [ ] No "❌" error messages
- [ ] No authentication errors

### Check Supabase Dashboard
- [ ] Go to Supabase > Database > Tables
- [ ] Open `conversations` table
- [ ] Verify conversations exist
- [ ] Open `messages` table
- [ ] Verify messages exist
- [ ] Check timestamps are recent

## 🔍 Troubleshooting

If conversations don't load:
- [ ] Check Xcode console for errors
- [ ] Verify user is logged in
- [ ] Check database has data
- [ ] Verify RLS policies are correct
- [ ] Test SQL queries directly in Supabase

If can't send messages:
- [ ] Check network connection
- [ ] Verify conversation exists
- [ ] Check RLS policies allow INSERT
- [ ] Look for errors in console

If avatars don't load:
- [ ] Check avatar_url in database
- [ ] Verify URLs are valid and public
- [ ] Check network connection
- [ ] Try placeholder image

## 📚 Documentation Review

- [ ] Read `Message/README.md`
- [ ] Review `MESSAGES_SETUP.md`
- [ ] Check `MIGRATION_GUIDE.md`
- [ ] View `MESSAGES_DIAGRAMS.md`
- [ ] Understand `MESSAGES_INTEGRATION_COMPLETE.md`

## 🎯 Next Steps

After everything works:
- [ ] Add more test users
- [ ] Create real conversations
- [ ] Test with multiple devices
- [ ] Consider real-time updates
- [ ] Plan push notifications
- [ ] Design user search feature
- [ ] Add media message support

## ✨ Optional Enhancements

- [ ] Add pull-to-refresh gesture
- [ ] Implement search in conversations
- [ ] Add swipe actions (delete, archive)
- [ ] Show typing indicators
- [ ] Add read receipts
- [ ] Implement message reactions
- [ ] Add voice messages
- [ ] Support group chats
- [ ] Add message forwarding
- [ ] Implement message deletion

## 🎉 Completion

When all above items are checked:
- [ ] Take a screenshot of working app
- [ ] Document any custom changes
- [ ] Commit code to version control
- [ ] Tag release version
- [ ] Celebrate! 🎊

---

## 📞 Support Resources

If you encounter issues:

1. **Console Logs**: Check Xcode console for detailed errors
2. **Supabase Logs**: Check Supabase dashboard > Logs
3. **Documentation**: Review all .md files in project
4. **SQL Testing**: Test queries directly in Supabase SQL Editor
5. **RLS Policies**: Verify policies in Supabase > Authentication > Policies

## 🔗 Quick Links

- Supabase Dashboard: https://app.supabase.com
- Supabase Docs: https://supabase.com/docs
- Swift Async/Await: https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html
- iOS Documentation: https://developer.apple.com/documentation/

---

**Status**: ⬜ Not Started | 🔄 In Progress | ✅ Complete

Last Updated: $(date)
