# :mortar_board: Fellowship Projects: Zeppelin Labs Flutter Fellowship

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![Projects](https://img.shields.io/badge/Projects-4-success)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

Four production-style Flutter apps built during the **Zeppelin Labs Flutter Fellowship** by **Team M2**, led by **Sardar Fahad Ali**.

## :bookmark_tabs: Table of Contents

- [Projects Overview](#bar_chart-projects-overview)
- [Project 1: Medication & Habit Reminder](#pill-project-1--medication--habit-reminder-app)
- [Project 2: Offline-First Rural Education](#school-project-2--offline-first-rural-education-app)
- [Project 3: SafeWalk](#woman-project-3--safewalk)
- [Project 4: KhataBook Lite](#books-project-4--khatabook-lite)
- [Tech Stack](#hammer_and_wrench-tech-stack)
- [Getting Started](#rocket-getting-started)
- [Team](#busts_in_silhouette-team)

## :bar_chart: Projects Overview

| # | Project | Focus | Key Tech | Status |
|---|---------|-------|----------|--------|
| 1 | Medication & Habit Reminder | Health and caregiver monitoring | Firebase Auth, Firestore | :white_check_mark: Completed (85/100) |
| 2 | Offline-First Rural Education | Education in low connectivity areas | Isar, Markdown | :white_check_mark: Completed |
| 3 | SafeWalk | Women's safety companion | Firebase, FCM, Supabase | :white_check_mark: Completed |
| 4 | KhataBook Lite | Digital ledger for street vendors | Isar, Firestore, WorkManager | :white_check_mark: Completed |

---

## :pill: Project 1 | Medication & Habit Reminder App

A Flutter + Firebase app that helps users manage medication schedules and daily habits, with a real-time caregiver dashboard for monitoring adherence.

**Features**
- :lock: Firebase Authentication (sign up / login)
- :alarm_clock: Smart reminder scheduling service
- :family: Real-time caregiver dashboard powered by Firestore
- :chart_with_upwards_trend: Adherence tracking and history

---

## :school: Project 2 | Offline-First Rural Education App

A Flutter + Isar (local NoSQL DB) app that delivers lessons and quizzes to students in low or no connectivity rural areas, fully functional offline.

**Features**
- :no_mobile_phones: Offline-first architecture using **Isar**
- :books: Lesson pack parser (zip/manifest based content delivery)
- :book: Markdown-rendered lesson viewer
- :white_check_mark: Lesson completion tracking
- :pencil: Quiz engine integrated with lesson content
- :bust_in_silhouette: Student profile and progress tracking

**Run it standalone**
```bash
flutter pub get
flutter run -t lib/view_lessons.dart
```
Or launch Project 1 normally and tap the school icon after login to open Project 2.

---

## :woman: Project 3 | SafeWalk

A women's safety companion app that keeps trusted contacts in the loop during a walk and triggers instant alerts in an emergency.

**Features**
- :sos: SOS button with siren, flashlight, SMS fallback and FCM push alerts
- :walking_woman: "Walk With Me" live session sharing
- :telephone_receiver: Fake Call to safely exit uncomfortable situations
- :stopwatch: Check-in timer with route deviation detection
- :lock: Authentication and trusted contacts management

**Download:** [Release APK v1.0-safewalk](https://github.com/sardarfahadali18-wq/fellowship-project-1/releases/tag/v1.0-safewalk)

---

## :books: Project 4 | KhataBook Lite

An offline-first digital ledger (khata) app for street vendors and shopkeepers in Pakistan. Works without internet and syncs automatically when connectivity returns.

**Features**
- :iphone: Phone OTP signup with Pakistani number validation and persistent session
- :globe_with_meridians: Multi-language support (Urdu, English, Punjabi, Sindhi) with RTL layouts
- :memo: Core ledger loop: add customers, record transactions, live balance view
- :arrows_counterclockwise: Offline-first storage with sync queue, retry with exponential backoff and 15 minute background sync
- :cloud: Firestore backup and restore with owner-only security rules
- :bell: WhatsApp/SMS reminders and shareable ledger with overdue filtering
- :bar_chart: Home dashboard: Gave / Got / You will receive summary and recent activity

---

## :hammer_and_wrench: Tech Stack

| Layer | Technologies |
|-------|--------------|
| Framework | Flutter, Dart |
| Backend | Firebase Auth, Cloud Firestore, Cloud Functions, FCM, Supabase |
| Local Storage | Isar |
| Background Work | WorkManager |
| Content | Markdown rendering |
| Workflow | Git, GitHub PRs, branch per module |

## :rocket: Getting Started

```bash
git clone https://github.com/sardarfahadali18-wq/fellowship-project-1.git
cd fellowship-project-1
flutter pub get
flutter run
```

## :busts_in_silhouette: Team

| Role | Member | KhataBook Lite Module | SafeWalk Module |
|------|--------|-----------------------|-----------------|
| Team Lead | Sardar Fahad Ali | Home dashboard, PR review and final QA | Fake Call, PR coordination |
| Developer | Faizan | Auth and Onboarding | Auth and Trusted Contacts |
| Developer | Hamza | Offline Storage and Sync Engine | Walk With Me session |
| Developer | Hammas | Core Ledger Loop | SOS and Alerts |
| Developer | Adil | Reminders and Sharing | Check-in Timer and Route Deviation |

---

Built by **Team M2** at **Zeppelin Labs Flutter Fellowship**