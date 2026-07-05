# ShiftBoard

A real-time daily task and communication board built for Supported Living staff — built to solve a problem I deal with directly as a Supported Living Supervisor: getting the day's tasks, menu, and announcements in front of staff simply and reliably, without relying on group texts or paper notes.

## What it does

- **Today's board**: staff open the app and immediately see today's menu, announcements, and task checklist — no navigation required.
- **Weekly menu planning**: admins set lunch and dinner for the whole week once; staff only ever see today's slice.
- **Task accountability**: tasks show who completed them, and only that person (or an admin) can uncheck it.
- **Announcement acknowledgment**: an "I saw this" button tracks who has actually seen important updates, visible to admins only.
- **Reusable task library**: admins build a list of common tasks once, either adding them ad hoc to a specific day or marking them "Daily" so they auto-populate every morning.
- **Role-based access**: a lightweight PIN system separates staff view (view + check off tasks) from admin view (full editing), with identity remembered per-device after the first login.
- **Live sync**: changes made by an admin appear on every device in real time, no manual refresh — powered by Firestore's real-time listeners.
- **Cross-platform**: native Android app, plus a web version for platforms without a published build (e.g., iOS via "Add to Home Screen").
- **Dark mode**: follows the device's system setting automatically.

## Architecture

- **Flutter + Dart**, single codebase targeting Android, iOS, and Web
- **Firebase Firestore** as the backend — one `daily_posts` document per day (keyed by date), one `week_menu` document, one `task_templates` collection
- **Firebase Authentication (Anonymous)** — every device signs in anonymously so Firestore security rules can require `request.auth != null`, closing the database off from public access, while staff/admin distinction is enforced at the application layer via PIN
- **`shared_preferences`** for per-device identity, so returning users skip the login screen
- **`StreamBuilder` + Firestore snapshots** for the live board — no polling, no push notification infrastructure needed
- **Firebase Hosting** for the web build, and **Firebase App Distribution** for shipping Android builds directly to testers without a Play Store listing

## Key design decisions and tradeoffs

- **Anonymous auth instead of full user accounts.** A small internal team with a shared PIN is a reasonable trust model; anonymous auth was the minimum needed to close Firestore off from the open internet without over-engineering the auth layer.
- **Live listeners over push notifications.** True push notifications require Cloud Functions and a paid Firebase plan. For a team that opens the app at shift start, real-time listeners deliver the same practical outcome for zero cost and no backend infrastructure.
- **Date-keyed documents.** Using the date as the Firestore document ID keeps "get today's board" a single predictable lookup rather than a query.
- **Task ownership enforcement.** Only the person who completed a task (or an admin) can uncheck it — a rule added directly from real usage feedback.
- **Web fallback for iOS.** Rather than paying for an Apple Developer account and setting up cloud Mac builds for a single iOS user, the same Flutter codebase runs as a web app, installable via Safari's "Add to Home Screen."

## Tech stack

Flutter, Dart, Firebase (Firestore, Authentication, Hosting, App Distribution), `shared_preferences`

## Status

In active daily use with a Supported Living team.