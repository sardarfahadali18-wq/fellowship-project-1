# Supabase Backend Configuration

- **Project URL:** `https://kxrpltrstwyhfqgtbywh.supabase.co`
- **Anon/Public Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4cnBsdHJzdHd5aGZxZ3RieXdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU1MTEyMzYsImV4cCI6MjEwMTA4NzIzNn0.rHA6fmnyHYo-IOtq9yV-PoRJEAZ0TF5Gpn0dyXxOcAE
`
- **Sync RPC Function:** `process_sync_events`
- **Expected Payload Format:**
```json
{
  "events_json": [
    {
      "event_uuid": "UUID",
      "student_id": "UUID",
      "event_type": "quiz_submitted | lesson_completed",
      "payload": {},
      "timestamp": "ISO8601"
    }
  ]
}