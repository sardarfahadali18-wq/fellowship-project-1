# SafeWalk — Auth & Trusted Contacts Module
**Module Owner:** Faizan  
**Project:** SafeWalk (Women's Safety Companion App) — Group M2 (Zeppelin Labs Flutter Fellowship)  
**Branch:** `feature/auth-trusted-contacts`

---

## 📌 Module Overview

Faizan's assigned module covers the end-to-end implementation of **User Authentication** and **Trusted Contacts Management**:
1. **Firebase Authentication**: Sign Up, Sign In, Forgot Password, User Profile & Safety Notes, Session Persistence, and Error Handling.
2. **Trusted Contacts Management**: Complete CRUD (Create, Read, Update, Delete) for trusted contacts, marking primary emergency contacts, search/filter, quick call/SMS triggers, and offline local cache fallback.
3. **Firestore Data Structures**: Structured Firestore models matching the team's data contract (`users/{uid}` and `users/{uid}/trusted_contacts/{contactId}`).
4. **Backend / MongoDB Atlas Integration**: Configurable credentials setup for Firebase and MongoDB Atlas Data API.

---

## 🗄️ Firestore Data Structure & Schema

### 1. User Profile (`users/{uid}`)
```json
{
  "uid": "FIREBASE_AUTH_UID",
  "email": "sarah@example.com",
  "displayName": "Sarah Khan",
  "phoneNumber": "+92 300 1234567",
  "emergencyNote": "Blood group O+, carries inhaler",
  "createdAt": "2026-08-26T10:00:00Z",
  "updatedAt": "2026-08-26T10:00:00Z"
}
```

### 2. Trusted Contacts Subcollection (`users/{uid}/trusted_contacts/{contactId}`)
*100% compatible with `WalkContact` and `TrustedContactReader` used across SafeWalk.*
```json
{
  "name": "Fatima (Mom)",
  "phoneNumber": "+92 300 9876543",
  "relationship": "Mother",
  "email": "fatima@example.com",
  "isEmergency": true,
  "priorityOrder": 0,
  "notes": "Available 24/7, lives 10 mins away",
  "createdAt": "2026-08-26T10:00:00Z",
  "updatedAt": "2026-08-26T10:00:00Z"
}
```

---

## 🔑 Where to Add Credentials

### A. Firebase Credentials
When ready, you can place your Firebase credentials in the following standard files:

1. **`lib/firebase_options.dart`** or **`lib/config/app_credentials.dart`**:
   - `apiKey`
   - `appId`
   - `projectId` (`fellowship-flutter-project-m2`)
   - `messagingSenderId`
2. **Android Google Services File**:
   - Save your `google-services.json` file inside `android/app/google-services.json`.

*(Note: The app is equipped with safe demo mode fallbacks so all UI and flows can be tested even before live Firebase keys are injected).*

---

### B. MongoDB Atlas Credentials
If syncing user profiles or contacts to MongoDB Atlas, add your credentials in **`lib/config/app_credentials.dart`**:

```dart
class AppCredentials {
  static const String mongoDbAppId = 'YOUR_MONGODB_APP_ID';
  static const String mongoDbApiKey = 'YOUR_MONGODB_API_KEY';
  static const String mongoDbClusterName = 'Cluster0';
  static const String mongoDbDatabase = 'safewalk_db';
}
```

---

## 🚀 How to Run and Test

### 1. Run the SafeWalk App:
```bash
flutter run -t lib/main_safewalk.dart
```

### 2. Run Automated Unit & Widget Tests:
```bash
flutter test test/user_profile_model_test.dart test/trusted_contact_model_test.dart test/contact_card_widget_test.dart
```

---

## 📱 Features Implemented

| Screen / Feature | Description | File |
| :--- | :--- | :--- |
| **Login Screen** | Email/Password login, input validation, error handling, password reveal toggle | `lib/screens/auth/login_screen.dart` |
| **Sign Up Screen** | Registration with Name, Email, Phone, Password, and Safety Guidelines agreement | `lib/screens/auth/signup_screen.dart` |
| **Forgot Password** | Password reset request with email verification | `lib/screens/auth/forgot_password_screen.dart` |
| **Profile Screen** | User info, emergency medical notes, edit modal, and sign out | `lib/screens/auth/profile_screen.dart` |
| **Trusted Contacts List** | Live real-time stream of contacts, search bar, emergency badges, quick call & SMS | `lib/screens/contacts/trusted_contacts_list_screen.dart` |
| **Add / Edit Contact** | Relationship choice chips, phone validator, emergency switch | `lib/screens/contacts/add_edit_contact_screen.dart` |
| **Contact Card Widget** | Material 3 card with initials avatar, status badge, action buttons | `lib/widgets/contact_card.dart` |
| **Auth Service** | Firebase Auth management + Firestore user profile sync | `lib/services/auth_service.dart` |
| **Contacts Service** | Firestore CRUD + SharedPreferences offline caching | `lib/services/trusted_contacts_service.dart` |
| **SafeWalk Main Shell** | Bottom Navigation connecting Dashboard, Contacts, and Profile | `lib/screens/safewalk_main_shell.dart` |
| **Firestore Security Rules** | Rules protecting `users/{userId}` and `trusted_contacts/{contactId}` | `firestore.rules` |

---

## 🤝 Team Integration Notes

- **Hamza (`Walk With Me`)**: `TrustedContactsService` writes directly to `users/{uid}/trusted_contacts` which `TrustedContactReader` reads. `TrustedContact.toWalkContact()` converts any contact into `WalkContact`.
- **Hammas (`SOS + Alerts`)**: Emergency contacts marked with `isEmergency: true` are prioritized for instant alert messaging.
- **Adil (`Check-In Timer`)**: Contacts can be retrieved via `getEmergencyContacts(uid)` for auto-alerting on missed check-ins.
- **Sardar (`Fake Call + Lead`)**: `SafeWalkMainShell` includes direct access to Fake Call alongside Contacts and Walk sessions.
