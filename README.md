# 🚛 Logistic Transport

[![Flutter](https://img.shields.io/badge/Flutter-3.44.6+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.2+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-blue)]()



Flutter mobile app for owner-operators and small fleets: scan a Bill of Lading, pin every stop on Google Maps, track the load, log expenses, upload POD, and see real profit.

Built as a production-style product — role-aware UI, secure sessions, OCR, live maps, and reporting — not a tutorial clone.

---

## What I built

- End-to-end trucking workflow: auth → scan/create load → map stops → expenses → signed BOL / POD → reports
- Owner vs sub-driver roles (fleet admin hidden from child drivers)
- Google Maps location picker + multi-stop load map + live GPS
- Backend-aligned coordinates `[lng, lat]` with Places, Geocoding, and Directions
- Silent tab refresh so Home / Loads / Reports do not flicker after mutations

---

## Stack

Flutter · Dart · BLoC/Cubit · Dio · Secure Storage · Google Maps · Geolocator · Places / Geocoding / Directions APIs · Image Picker · Signature · WebView

---

## Features (product)

| Area | What it does |
|---|---|
| Auth | Login, register, OTP, forgot/reset password, encrypted tokens, splash token refresh |
| Home | Status counts, assigned loads (owners), scan/add shortcuts, subscription prompt |
| Loads | Filters, owner scopes (my loads / all drivers / per driver), search, pagination |
| OCR | Camera/gallery BOL scan → auto-fill load ID, company, rate, stops |
| Map | Pin picker, autocomplete, multi-stop markers, live “You” pin |
| Accounting | Fuel / toll / maintenance / other + receipts; profit = rate − expenses |
| Documents | Signature merge onto BOL; POD upload |
| Reports | Week / month / custom range, charts, send to accountant |
| Fleet | Manage sub-drivers, accountant, plans & WebView checkout |

---

## Map & polyline (technical highlight)

The map is used in **create load**, **OCR review**, and **load details** — not a standalone demo.

**Location picker**
- Center overlay pin (not a draggable marker) with a lift animation while panning
- Reverse geocode only after camera idle + 280ms debounce
- Nearby Search prefers a POI within ~55m (warehouse/shop), not Plus Codes
- Request IDs drop stale geocode responses when the user pans fast

**Stop fields**
- Type → Places Autocomplete (500ms debounce) → Place Details
- OCR text auto-resolves the first suggestion so coordinates exist without a tap
- Map confirm writes `[lng, lat]` and suppresses a second search loop

**Load map**
- Blue pickups, red deliveries, green live GPS
- Camera fits all stops (`LatLngBounds` + fallback zoom)
- GPS stream throttled to **20m** so the pin does not jitter when parked

**Road polyline**
- Directions API → encoded `overview_polyline` → custom decoder (Google algorithm, 1e5 precision) → `Polyline` that follows roads, not a straight line
- In-flight request IDs prevent an old route from overwriting a newer one
- Live layer updates the driver pin without spamming Directions on every GPS tick

---

## Hard problems I solved

1. **Stale async** — geocode, Places, and Directions all use version/request IDs so the last user action wins.
2. **Coordinate contract** — API is `[lng, lat]`; widgets are `LatLng(lat, lng)`. One conversion path; no ocean pins.
3. **OCR shape drift** — parser accepts singular or list addresses/coords from the backend.
4. **Role flicker** — `isParentDriver` persisted at login, restored on splash into `AuthSession`.
5. **Immersive UI vs notch** — sticky system UI zeroes padding; custom inset restores SafeArea.
6. **Tab state** — `IndexedStack` + `GlobalKey`s for silent refresh after create/upload.
7. **GPS noise / cost** — 20m filter, first-fix camera fit only, map still useful if permission is denied.

---

## Architecture

Feature-first (`auth`, `home`, `load`, `map`, `bill_of_loading`, `report`, `profile`). Cubits own API calls. Secrets stay in `.env` (`MAP_API_KEY`), injected into Android as `com.google.android.geo.API_KEY`.

---

## Demo path (2 minutes)

1. Login as owner → Home counts + assigned loads  
2. Scan BOL → fields fill → adjust a stop on the map  
3. Load Details → View Map → all stops + live pin  
4. Add fuel expense → Reports profit updates  
5. Upload POD → Missing POD drops  

---
## Image
<table>
  <tr>
    <td><img width="360" height="808" alt="image" src="https://github.com/user-attachments/assets/1f66d5fb-afc9-4b3e-af2c-95ada97ea43a" /></td>
    <td><img width="360" height="808" alt="image" src="https://github.com/user-attachments/assets/b551de87-2938-4ab5-9e6f-6f43ff071385" /></td>
    <td><img width="360" height="808" alt="image" src="https://github.com/user-attachments/assets/7391a2de-5797-4e1c-8e33-1ba221c30def" /></td>
    <td><img width="360" height="808" alt="image" src="https://github.com/user-attachments/assets/4b9f5a6a-acdd-484c-874a-72c65858efb0" /></td>
  </tr>
</table>

---
## Setup

```bash
flutter pub get
# add MAP_API_KEY to .env (Maps, Places, Geocoding, Directions)
flutter run
