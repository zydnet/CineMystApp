# Messages Feature - Data Flow Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         iOS App                                  │
│                                                                   │
│  ┌──────────────────┐         ┌──────────────────┐              │
│  │ Messages Tab     │────────▶│ Chat View        │              │
│  │ (List)           │         │ (Detail)         │              │
│  └────────┬─────────┘         └────────┬─────────┘              │
│           │                            │                         │
│           │ fetchConversations()       │ sendMessage()           │
│           │ loadConversations()        │ fetchMessages()         │
│           ▼                            ▼                         │
│  ┌────────────────────────────────────────────────┐             │
│  │         MessagesService (Singleton)            │             │
│  │  • fetchConversations()                        │             │
│  │  • fetchMessages()                             │             │
│  │  • sendMessage()                               │             │
│  │  • markMessagesAsRead()                        │             │
│  │  • searchUsers()                               │             │
│  │  • getOrCreateConversation()                   │             │
│  └────────────────┬───────────────────────────────┘             │
│                   │                                              │
│                   │ Uses global supabase client                 │
│                   ▼                                              │
│  ┌────────────────────────────────────────────────┐             │
│  │     Supabase Client (auth/Supabase.swift)     │             │
│  │  • Handles authentication                      │             │
│  │  • Makes database queries                      │             │
│  │  • Manages API requests                        │             │
│  └────────────────┬───────────────────────────────┘             │
└───────────────────┼───────────────────────────────────────────┘
                    │
                    │ HTTPS Requests
                    │
┌───────────────────▼───────────────────────────────────────────┐
│                   Supabase Backend                             │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                   PostgreSQL Database                    │  │
│  │                                                           │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │
│  │  │conversations │  │   messages   │  │user_profiles │  │  │
│  │  ├──────────────┤  ├──────────────┤  ├──────────────┤  │  │
│  │  │ id           │  │ id           │  │ id           │  │  │
│  │  │ participant1 │  │ conversation │  │ full_name    │  │  │
│  │  │ participant2 │  │ sender_id    │  │ username     │  │  │
│  │  │ last_message │  │ content      │  │ avatar_url   │  │  │
│  │  │ unread_count │  │ is_read      │  │ bio          │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │  │
│  │                                                           │  │
│  │  ┌───────────────────────────────────────────────────┐  │  │
│  │  │          Row Level Security (RLS)                 │  │  │
│  │  │  • Users see only their conversations             │  │  │
│  │  │  • Users read only their messages                 │  │  │
│  │  │  • Users send messages only in their convos       │  │  │
│  │  └───────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## User Flow: Viewing Messages

```
User opens Messages Tab
         │
         ▼
MessagesViewController.viewWillAppear()
         │
         ▼
loadConversations() called
         │
         ▼
Show loading indicator
         │
         ▼
Task { ... } - Async call
         │
         ▼
MessagesService.shared.fetchConversations()
         │
         ▼
Supabase query:
  SELECT * FROM conversations
  WHERE participant1_id = current_user
     OR participant2_id = current_user
  ORDER BY last_message_time DESC
         │
         ▼
For each conversation:
  Fetch other user's profile
         │
         ▼
Convert to ConversationViewModel
         │
         ▼
MainActor.run {
  Update UI
  Reload table
  Hide loading indicator
}
         │
         ▼
User sees conversation list
```

## User Flow: Sending a Message

```
User taps conversation
         │
         ▼
Open ChatViewController
         │
         ▼
Load messages from backend
         │
         ▼
User types message and taps "Send"
         │
         ▼
sendMessage() called
         │
         ▼
Task { ... } - Async call
         │
         ▼
MessagesService.shared.sendMessage(
  conversationId: id,
  content: "Hello!"
)
         │
         ▼
Supabase INSERT:
  INSERT INTO messages
  (conversation_id, sender_id, content)
  VALUES (...)
         │
         ▼
Database Trigger fires:
  UPDATE conversations
  SET last_message_content = "Hello!"
      last_message_time = NOW()
         │
         ▼
Message saved successfully
         │
         ▼
Clear input field
Reload messages
         │
         ▼
User sees new message in chat
```

## Data Transformation Flow

```
┌─────────────────────┐
│  Supabase Database  │
│                     │
│  ConversationModel  │  ← Raw database model
│  + UserProfile      │
└──────────┬──────────┘
           │
           │ Service Layer
           │
           ▼
┌─────────────────────┐
│  MessagesService    │
│                     │
│  Fetches & Combines │
│  Data               │
└──────────┬──────────┘
           │
           │ Mapping
           │
           ▼
┌─────────────────────┐
│ ConversationViewModel│ ← UI-friendly model
│                     │
│  • name: String     │
│  • preview: String  │
│  • timeText: String │
│  • avatar: UIImage? │
└──────────┬──────────┘
           │
           │ Display
           │
           ▼
┌─────────────────────┐
│  TableView Cell     │
│                     │
│  Shows to User      │
└─────────────────────┘
```

## Security Flow (RLS)

```
User Request
     │
     ▼
┌────────────────────┐
│ Supabase Client    │
│ auth.currentUser   │
└─────────┬──────────┘
          │
          │ Includes JWT token
          │
          ▼
┌─────────────────────────┐
│  Supabase Backend       │
│                         │
│  1. Verify JWT          │
│  2. Extract user_id     │
│  3. Apply RLS Policies  │
│                         │
│  Policy Example:        │
│  WHERE participant1 =   │
│        auth.uid()       │
│     OR participant2 =   │
│        auth.uid()       │
└─────────┬───────────────┘
          │
          │ Filtered Results
          │
          ▼
┌─────────────────────────┐
│  Return only data user  │
│  is authorized to see   │
└─────────────────────────┘
```

## Error Handling Flow

```
Backend Call
     │
     ├─────────────┐
     │             │
 Success       Failure
     │             │
     ▼             ▼
Return Data    Throw Error
     │             │
     │             ▼
     │        Catch Block
     │             │
     │             ├──────────────┐
     │             │              │
     │         Auth Error    Other Error
     │         (Code 401)         │
     │             │              │
     │             ▼              ▼
     │        Silent Fail    Show Alert
     │        (User not       to User
     │         logged in)         │
     │                            │
     ▼                            ▼
Update UI                   Log Error
                            Update UI
```

## Real-time Updates (Future Enhancement)

```
┌─────────────────────┐
│  User A sends       │
│  message            │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Supabase INSERT    │
└──────────┬──────────┘
           │
           ├──────────────────┐
           │                  │
           ▼                  ▼
┌─────────────────┐   ┌─────────────────┐
│  Realtime       │   │  Push           │
│  Subscription   │   │  Notification   │
└──────────┬──────┘   └──────────┬──────┘
           │                     │
           │                     │
           ▼                     ▼
┌─────────────────────────────────────┐
│  User B's App                       │
│  • Receives new message             │
│  • Updates UI automatically         │
│  • Shows notification (if closed)   │
└─────────────────────────────────────┘
```

## File Organization

```
CineMystApp/
├── Message/
│   ├── MessagesViewController.swift     # Main UI
│   │   ├── ConversationViewModel       # View model
│   │   ├── ConversationCell            # Table cell
│   │   ├── StoryCell                   # Stories
│   │   └── ChatViewController          # Chat detail
│   │
│   ├── models/
│   │   ├── Message.swift               # Message model
│   │   └── ConversationModel.swift     # Conversation model
│   │
│   ├── service/
│   │   └── MessagesService.swift       # Backend API
│   │
│   └── README.md                        # Documentation
│
├── auth/
│   ├── Supabase.swift                  # Global client
│   ├── SupabaseConfig.swift            # Config
│   └── AuthManager.swift               # Auth logic
│
└── database/
    └── messages_schema.sql             # DB setup
```

## Key Components Interaction

```
┌──────────────────────────────────────────────────────────┐
│                    MessagesViewController                 │
│  • Manages UI                                            │
│  • Shows conversations list                              │
│  • Handles user interactions                             │
└─────────────────┬────────────────────────────────────────┘
                  │
                  │ Calls
                  ▼
┌──────────────────────────────────────────────────────────┐
│                    MessagesService                        │
│  • Singleton instance                                    │
│  • Handles all backend operations                        │
│  • Transforms data for UI                                │
└─────────────────┬────────────────────────────────────────┘
                  │
                  │ Uses
                  ▼
┌──────────────────────────────────────────────────────────┐
│                    Supabase Client                        │
│  • Global instance (supabase)                            │
│  • Manages auth state                                    │
│  • Executes database queries                             │
│  • Handles network requests                              │
└─────────────────┬────────────────────────────────────────┘
                  │
                  │ Communicates with
                  ▼
┌──────────────────────────────────────────────────────────┐
│                    Supabase Backend                       │
│  • PostgreSQL database                                   │
│  • RESTful API                                           │
│  • Authentication                                        │
│  • Row Level Security                                    │
└──────────────────────────────────────────────────────────┘
```

---

These diagrams show the complete flow of data through the Messages feature, from the UI to the database and back. The architecture is clean, secure, and scalable!
