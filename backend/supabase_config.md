# Supabase Backend Configuration

- Project URL: set via the `SUPABASE_URL` environment variable
- Anon/Public Key: set via the `SUPABASE_ANON_KEY` environment variable
- Sync RPC Function: `process_sync_events`
- Expected Payload Format:
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