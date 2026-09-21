# PolyMap — Technology Stack Analysis

> Updated: 2026-09-21
> Context: Deep research on technologies, problems, solutions, case studies for ESP Dakar

---

## Current Stack (Working)

| Layer | Technology | Version | Status |
|-------|-----------|---------|--------|
| **Framework** | Flutter | ≥ 3.35 | ✅ Active |
| **Language** | Dart | ≥ 3.5 | ✅ Active |
| **State Management** | Provider | ^6.1.2 | ✅ Active |
| **Map** | flutter_map (OpenStreetMap) | ^7.0.2 | ✅ Active |
| **Coordinates** | latlong2 | ^0.9.1 | ✅ Active |
| **QR Scanner** | mobile_scanner | ^5.2.3 | ✅ Active |
| **Sensors** | sensors_plus | ^7.1.0 | ✅ Active |
| **Persistence** | shared_preferences | ^2.3.3 | ✅ Active |
| **Camera** | camera | ^0.11.0 | ✅ Active |
| **Web** | web | ^1.1.1 | ✅ Active |
| **Navigation** | Custom (PmNav) | — | ✅ Active |
| **Theme** | Custom (PmColors, PmTheme) | — | ✅ Active |
| **Layout** | Custom (PmLayout, PmBreakpoint) | — | ✅ Active |
| **AR Engine** | Custom Dart (ArScene, ArPoseController) | — | ⚠️ Partial |
| **Node Graph** | Custom (NodeGraph) | — | ⚠️ Partial |
| **CI/CD** | GitHub Actions | — | ✅ Basic |

---

## Target Stack (Planned)

### Map & Routing

| Component | Current | Target | Rationale |
|-----------|---------|--------|-----------|
| **Map Tiles** | Online OSM raster | PMTiles (bundled campus) | Offline-first, region-limited |
| **Map Renderer** | flutter_map | flutter_map + MapLibre GL option | Vector tiles, better offline |
| **Tile Caching** | None | flutter_map_tile_caching | Offline region download |
| **Indoor Floors** | Hand-built node graph | OSM Simple Indoor Tagging + node graph | Community-editable standard |
| **Routing** | None (static routes) | Valhalla (offline) | A* on node graph, offline-capable |
| **Map Region** | Full world OSM | Campus extract only | Free, private, fast |

### AR & Positioning

| Component | Current | Target | Rationale |
|-----------|---------|--------|-----------|
| **Positioning** | Simulated (Pavillon C) | QR + ARCore VIO dead reckoning | Student-zero budget, proven pattern |
| **AR SDK** | Custom Dart engine | Custom Dart + ARCore Geospatial API (v2) | Free tier, 1000 sessions/min |
| **WebAR Fallback** | None | MindAR.js (PWA) | Zero certification, all devices |
| **ARCore Check** | None | `checkVpsAvailabilityAsync()` | Device compatibility for Africa |
| **QR Anchoring** | Planned | QR codes per door/building | One-time setup, no recurring cost |
| **Positioning Accuracy** | N/A | 0.5-2m (QR) + drift (VIO) | Matches CEU Wayguide benchmarks |

### Authentication & Backend

| Component | Current | Target | Rationale |
|-----------|---------|--------|-----------|
| **Auth** | Simulated (guest/email) | Supabase Auth | Student/visitor modes, free tier |
| **Database** | Static Dart | Supabase PostgreSQL | Real-time, RLS, free tier |
| **Storage** | None | Supabase Storage | AR packs, campus maps |
| **Real-time** | None | Supabase Realtime | Timetable updates, room availability |
| **Offline Sync** | SharedPreferences | SQLite + sync | Offline-first, background sync |

### Testing & Quality

| Component | Current | Target | Rationale |
|-----------|---------|--------|-----------|
| **Unit Tests** | Minimal | ≥ 60% coverage | Code quality, regression prevention |
| **Widget Tests** | None | All screens tested | UI regression |
| **Integration Tests** | None | Critical paths | End-to-end flows |
| **Linting** | Basic | Strict analysis_options | Code quality |
| **Formatting** | Manual | `dart format` pre-commit | Consistency |
| **CI/CD** | APK + Web only | Full pipeline (test → build → deploy) | Quality gate |

---

## Problem-Solution Matrix

| Problem | Current Impact | Solution | Evidence |
|---------|---------------|----------|----------|
| **No indoor positioning** | AR shows arrows but doesn't know where phone is | QR + ARCore VIO dead reckoning | CEU Wayguide: 90% accuracy, 0.3s latency |
| **Online-only map** | Fails on campus network | PMTiles bundled in app | Protomaps, offline-capable |
| **No routing engine** | Static routes only | Valhalla offline routing | Self-hostable, free, mobile-optimized |
| **Simulated auth** | No real user management | Supabase Auth | Free tier, RLS, student/visitor |
| **Device fragmentation** | ARCore not available on all phones | WebAR fallback (MindAR) | All phones with WebGL |
| **Low-end devices** | AR drops on sub-$200 phones | ARCore diagnostic + degraded mode | Transsion 47% African market |
| **No offline data** | Campus data hardcoded in Dart | Supabase + local SQLite sync | Offline-first pattern |
| **No timetable integration** | EDT not available in app | Supabase real-time EDT | PolyPortal ecosystem integration |

---

## Case Study Benchmarks

| Source | Accuracy | Latency | Cost | Key Insight |
|--------|----------|---------|------|-------------|
| **CEU Wayguide (2026)** | 90% | 0.3s | $0 infra | QR + ARCore + 2D map, offline = valid pattern |
| **AAU Navigation (2026)** | N/A | N/A | $0 | Student team, zero budget, QR + A* shipped |
| **RUDN (2026)** | N/A | N/A | $80k-200k | 1000 QR codes, proves scale but not budget |
| **SLAM baseline (2025)** | 1.2m | N/A | $15k+ | Pure-SLAM comparison bar |
| **IJIRT (2025)** | 95% | N/A | Free web | Web-only, needs internet (opposite constraint) |

---

## Cost Analysis (2026)

| Approach | Year 1 | Year 2+ | Verdict |
|----------|--------|---------|---------|
| **QR codes (PolyMap)** | $50/building laminate | $0 | ✅ Selected |
| **BLE beacons** | $80k-200k | $20k-50k/yr | ❌ Too expensive |
| **Wi-Fi fingerprinting** | $4.4k-11k | Similar | ❌ iOS API restricted |
| **UWB** | $15k-40k | Enterprise | ❌ Overkill |

**Conclusion**: QR is the only viable option for a student project with zero budget. It's 2-3 orders of magnitude cheaper than alternatives.

---

## Device Reality (Senegal/Africa 2026)

| Factor | Data | Implication |
|--------|------|-------------|
| **Average selling price** | $202 | Low-end devices dominate |
| **Sub-$200 devices** | 75% of shipments | Most ESP students |
| **Sub-$100 shrinking** | -34% in 2026 | Memory inflation crisis |
| **Transsion market share** | 47% (Tecno/Infinix/itel) | ARCore certified ✅ |
| **Xiaomi/HyperOS issue** | "Certified but unreliable" | Redmi cluster problematic |
| **MediaTek** | Mixed support | Need diagnostic per device |

---

## Free/Open Source Stack (2026-verified)

| Component | Free Solution | License | Notes |
|-----------|--------------|---------|-------|
| **Map tiles** | Protomaps PMTiles / OpenFreeMap | ODbL / BSD-3 | Region extract, bundle in app |
| **Map rendering** | flutter_map / MapLibre GL | BSD-3 | Both free |
| **Offline tiles** | flutter_map_tile_caching | MIT | FMTC library |
| **Routing** | Valhalla / OSRM / GraphHopper | BSD-3 | Self-hostable, offline |
| **AR (native)** | ARCore Geospatial API | Free tier | 1000 sessions/min |
| **AR (web)** | MindAR / AR.js | MIT | No certification needed |
| **Authentication** | Supabase Auth | Free tier | 50k MAU free |
| **Database** | Supabase PostgreSQL | Free tier | 500MB, 2GB file storage |
| **Storage** | Supabase Storage | Free tier | 1GB |
| **CDN** | GitHub Pages | Free | Web deployment |
| **CI/CD** | GitHub Actions | Free | 2000 min/month |
| **Code analysis** | flutter analyze | Free | Built-in |

---

## Architecture Decision Records (ADRs)

### ADR-001: QR + VIO over Continuous Positioning
**Date**: 2026-09-21
**Status**: Accepted
**Context**: AAU Navigation's supervisor recommended scoping out continuous positioning. QR anchoring is the standard low-budget substitute.
**Decision**: Use QR codes as position anchors + ARCore VIO for dead reckoning between QR scans.
**Consequences**: No continuous blue-dot; one-shot recalibration at each QR scan.

### ADR-002: Offline-First Map
**Date**: 2026-09-21
**Status**: Accepted
**Context**: Konnectel campus network is unreliable. ISOC proves offline is a design requirement.
**Decision**: Bundle campus PMTiles in app. No network dependency for map rendering.
**Consequences**: App bundle grows by few MBs; zero network dependency for core features.

### ADR-003: Custom AR Engine over Plugin
**Date**: 2026-09-21
**Status**: Accepted
**Context**: `ar_flutter_plugin_2` is archived/thin ice. `ar_flutter_plugin` is dead since 2022.
**Decision**: Maintain bespoke Dart AR engine (ArScene, ArPoseController).
**Consequences**: More control, no dependency on unmaintained plugins, but more code to maintain.

### ADR-004: Supabase Backend over Custom Server
**Date**: 2026-09-21
**Status**: Accepted
**Context**: Need auth + data + real-time for campus services. Zero budget for infrastructure.
**Decision**: Supabase as backend (Auth, PostgreSQL, Storage, Realtime).
**Consequences**: Vendor lock-in to Supabase, but free tier covers all needs and RLS matches multi-tenant architecture.

---

## Sources

1. CEU Wayguide (IJSATE 2026): https://ijsate.com/wp-content/uploads/2026/04/V3I4P48_IJSATE0426023.pdf
2. AAU Navigation: https://ollioddi.dev/projects/aau-navigation
3. RUDN / Indoors Navigation: https://indoorsnavi.pro/en/seamless-navigation-on-campus-rudn/
4. OpenFreeMap: https://openfreemap.org
5. Protomaps/PMTiles: https://protomaps.com
6. flutter_map_tile_caching: https://github.com/JaffaKetchup/flutter_map_tile_caching
7. ARCore Geospatial API: https://developers.google.com/ar/develop/geospatial
8. MindAR: https://github.com/hiukim/mind-ar-js
9. Supabase: https://supabase.com
10. Omdia Africa smartphone data: https://omdia.tech.informa.com
