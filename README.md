# FieldTrack — Field Employee App

FieldTrack is a Flutter mobile application for field employees. It handles user
authentication, management of geofenced site locations, a local notification when
the device enters a saved site, and — the core of the assignment — a resilient
**offline-first todo synchronization** engine.

The UI is built from the provided Figma design and supports light/dark modes.

> **Note on scope:** No map UI is implemented (not required by the task). Focus was
> placed on correctness and stability of the offline sync flow.

---

## Architecture Overview

The project follows **Clean Architecture** with a strict separation into
`presentation → domain → data` layers per feature, and **BLoC** for state
management.

- **presentation** — Widgets, BLoCs, events and states.
- **domain** — Entities, repository contracts (abstract), and use cases. Pure Dart,
  no framework dependencies.
- **data** — Models (JSON/DB mapping), remote/local data sources, and repository
  implementations that return `Either<Failure, T>` (via `dartz`).

Dependencies flow inward: presentation and data depend on domain; domain depends on
nothing. Wiring is done through a `get_it` service locator (`lib/app/di`).

### Directory Structure

```
lib/
├── app/                          # App-level config
│   ├── di/                       # get_it dependency injection container
│   ├── routes/                   # go_router navigation
│   └── theme/                    # color system & typography
├── core/                         # Shared, cross-feature code
│   ├── constants/                # API endpoints & app constants
│   ├── error/                    # Failure / Exception types & mapping
│   ├── network/                  # Dio client + refresh interceptor, connectivity
│   ├── storage/                  # secure token storage, SQLite database
│   ├── usecases/                 # base UseCase contract
│   └── widgets/                  # shared buttons, fields, badges
├── features/
│   ├── auth/                     # register, login, refresh, logout, profile
│   ├── geofence/                 # geofence monitoring & notification services
│   ├── locations/                # CRUD for geofence sites
│   ├── profile/                  # user profile & account info
│   ├── sync/                     # offline pending-queue panel
│   └── todos/                    # daily checklist + offline-first logic
├── main_shell.dart               # bottom-navigation frame
└── main.dart                     # app entry point / bootstrap
```

### Key Packages & Why

| Concern | Package | Reason |
|---|---|---|
| State management | `flutter_bloc` | Required by task; predictable, testable event→state flow |
| Dependency injection | `get_it` | Lightweight service locator, decouples layers |
| Routing | `go_router` | Declarative routing with a shell route for bottom nav |
| HTTP | `dio` | Interceptors for auth headers + automatic token refresh |
| Secure storage | `flutter_secure_storage` | Encrypted storage for access/refresh tokens |
| Local DB | `sqflite` | Relational store for cached todos + pending-change queue |
| Connectivity | `connectivity_plus` | Stream of online/offline transitions to trigger sync |
| Location | `geolocator` | Position stream + distance calculation for geofencing |
| Notifications | `flutter_local_notifications` | Local notification on geofence entry |
| Functional errors | `dartz` | `Either<Failure, T>` for explicit, exhaustive error handling |

---

## Offline Sync Approach (core requirement)

The goal: todo checkboxes must be toggleable offline, update the UI instantly, and
sync automatically once connectivity returns — without data loss or duplicate writes.

**Flow:**

1. **Optimistic UI** — Toggling a checkbox immediately emits an updated `TodoLoaded`
   state (checkbox + progress update), marking the item `isPendingSync`. The user
   never waits on the network.
2. **Local queue** — The change is written to an SQLite `pending_changes` table and
   the cached `todos` row is updated, so the state survives an app restart.
3. **Deduplication** — The queue is **upserted per `todo_id`**: repeatedly toggling
   the same item collapses into a single pending row holding the latest value. This
   keeps the sync payload minimal and makes repeated updates safe (idempotent).
4. **Connectivity detection** — `ConnectivityService` exposes a broadcast stream.
   `TodoBloc` listens; on transition to `online` it dispatches `TodosSyncRequested`.
   A manual "Sync now" button on the Sync screen does the same.
5. **Batch sync** — Pending changes are sent together via `POST /api/v1/todos/sync`.
   On success the queue is cleared and todos are re-fetched, so nothing stays
   `pending`.

**Failure handling:** If a toggle's underlying write fails entirely, the BLoC
reloads from the local cache to restore a consistent state. If a sync fails, pending
items remain queued and are retried on the next connectivity event.

---

## Geofence & Notification Approach

- **Permission** — On startup the geofence service checks/requests location
  permission via `geolocator`. Location + notification permissions are declared in
  the Android manifest and iOS `Info.plist` (see below).
- **Monitoring** — `Geolocator.getPositionStream` (accuracy `high`, `distanceFilter:
  30 m`) drives evaluation. For each position, the device coordinates are compared
  against every **active** saved location using `Geolocator.distanceBetween`
  (great-circle distance).
- **Entry detection** — When distance ≤ the location's `radius_m` and the device was
  not previously inside, a notification `"You entered <location_name>"` fires.
- **Deduplication / anti-flicker** — An in-memory `_currentlyInside` set ensures
  exactly one notification per entry. Exit is only registered once the device passes
  **1.2× the radius**, preventing repeated notifications when hovering on the
  boundary.
- **Stable notification IDs** — Each geofence uses a stable id derived from its name,
  so entering multiple sites shows separate notifications instead of overwriting.

### Platform configuration
- **Android** (`android/app/src/main/AndroidManifest.xml`): `INTERNET`,
  `ACCESS_FINE/COARSE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `POST_NOTIFICATIONS`
  (requested at runtime for Android 13+), and foreground-service permissions.
- **iOS** (`ios/Runner/Info.plist`): `NSLocationWhenInUse…`,
  `NSLocationAlways…` usage strings and `UIBackgroundModes` (`location`, `fetch`).

---

## Setup & Running

### Prerequisites
- Flutter SDK `3.11.5` or newer (Dart `^3.11.5`)
- Android emulator / iOS simulator or a physical device

### Steps

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Backend / configuration**
   - The app is preconfigured to the hosted backend in
     `lib/core/constants/api_constants.dart`:
     ```dart
     static const String baseUrl = 'https://todo.progressivebyte.com';
     ```
   - To point at a different server, change `ApiConstants.baseUrl`. If you run the
     backend locally, use `http://10.0.2.2:<port>` on the Android emulator or your
     machine's LAN IP on a physical device (plain `localhost` refers to the device
     itself).

3. **Run**
   ```bash
   flutter run
   ```

4. **Tests** (if present)
   ```bash
   flutter test
   ```

### Release builds
```bash
flutter build apk --release      # Android APK
flutter build ipa --release      # iOS
```

> No code generation step is required — the project does not use `build_runner`.

---

## Assumptions & Known Limitations

- **Closed-app / killed-state geofencing is not implemented.** Monitoring runs from
  a `Geolocator` position stream started at app launch, so entry detection works
  while the app is in the foreground or backgrounded, but **not after the OS kills
  the process**. Delivering reliable killed-state detection would require registering
  OS-level region monitoring (iOS `CLLocationManager` regions) and a periodic
  background worker (`workmanager`) plus "Always" background-location permission —
  deliberately deferred per the task's guidance to document platform limitations
  rather than ship an unreliable background path. The manifest/plist are already
  provisioned (background location + background modes) to make this a clean next step.
- **Foreground permission only at runtime.** The geofence service currently requests
  "when in use" location. Background ("Always") permission is declared but not
  actively requested; add a staged request before enabling background monitoring.
- **Locations fetched per position update.** `getLocations()` is called on each 30 m
  movement. This is fine for the demo scale; a production build should cache the
  active-location list in memory and refresh on change.
- **Backend availability.** Geofence and network flows assume the hosted backend at
  `todo.progressivebyte.com` is reachable; when offline, location/auth calls return a
  `NetworkFailure` while the offline todo queue continues to work locally.
