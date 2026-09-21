# PolyMap — Agile Scrum Framework

> Project: PolyMap — Navigation du campus ESP Dakar
> Methodology: Scrum (2-week sprints)
> Updated: 2026-09-21

---

## Team

| Role | Name | Responsibility |
|------|------|----------------|
| **Product Owner** | Pape B. Thiombane (Idle/Zelus) | Vision, backlog prioritization, ESP school requirements |
| **Scrum Master** | Pape B. Thiombane | Sprint facilitation, impediment removal |
| **Development Team** | OpenCode (AI agent) + Pape | Flutter/Dart implementation, testing, AR engine |

---

## Sprint Cycle

- **Sprint Duration**: 2 weeks
- **Sprint Planning**: Monday 09:00 GMT
- **Daily Standup**: 08:00 GMT (async via GitHub Issues)
- **Sprint Review**: Last Friday 17:00 GMT
- **Retrospective**: Last Friday 18:00 GMT

---

## Product Vision

**PolyMap** is the campus navigation app for the **École Supérieure Polytechnique de Dakar (ESP)**. It provides:

1. **Indoor + Outdoor navigation** using OpenStreetMap maps
2. **AR-guided wayfinding** with QR-anchored positioning
3. **Offline-first** operation for unreliable campus network
4. **Student-centric** design tailored to ESP Dakar campus realities

**Key metric**: Every student on campus can navigate to any room without asking for directions.

---

## Epic Backlog

### Epic 1: Foundation & Core Navigation (Sprint 1-2)
- [ ] Complete all 24 screen implementations
- [ ] Fix any broken navigation flows
- [ ] Add proper route animation transitions
- [ ] Ensure responsive layout across all breakpoints
- [ ] Unit tests for all screen widgets

### Epic 2: AR Positioning System (Sprint 3-4)
- [ ] Implement QR code anchor positioning system
- [ ] Build node-graph indoor navigation engine
- [ ] Integrate ARCore/ARKit positioning (QR + VIO)
- [ ] Add compass/boussole calibration UI
- [ ] WebAR fallback (MindAR/AR.js) for unsupported devices
- [ ] AR scene performance optimization

### Epic 3: Offline Map & Routing (Sprint 5-6)
- [ ] Bundle campus as PMTiles for offline rendering
- [ ] Integrate flutter_map_tile_caching
- [ ] Add Valhalla/OSRM offline routing
- [ ] Implement building floor plans (OSM Simple Indoor Tagging schema)
- [ ] Downloadable AR packs per building

### Epic 4: Authentication & User Management (Sprint 7-8)
- [ ] Supabase authentication integration (student/visitor modes)
- [ ] Student session management
- [ ] Profile management with ESP student ID
- [ ] Guest mode with limited features
- [ ] Favorites/preferences sync to Supabase

### Epic 5: Data & Backend Integration (Sprint 9-10)
- [ ] Supabase backend for campus data
- [ ] Real-time timetable (EDT) integration
- [ ] Room booking status
- [ ] Building hours and availability
- [ ] API for campus events

### Epic 6: Device Optimization & African Market (Sprint 11-12)
- [ ] Optimize for Transsion/Infinix/Tecno devices (47% African market)
- [ ] ARCore availability diagnostic
- [ ] WebAR degraded mode for unsupported devices
- [ ] Performance optimization for low-RAM devices (< 2GB)
- [ ] Offline-first data caching strategies
- [ ] FCFA pricing/localization

### Epic 7: Quality & Polish (Sprint 13-14)
- [ ] Comprehensive widget tests
- [ ] Integration tests for navigation flows
- [ ] Accessibility improvements (high contrast, voice guidance)
- [ ] French localization (default) + English option
- [ ] App icons and splash screen polish
- [ ] Performance profiling and optimization

### Epic 8: Deployment & CI/CD (Ongoing)
- [ ] GitHub Actions CI/CD pipeline
- [ ] Automated testing and deployment
- [ ] Android APK release pipeline
- [ ] iOS build pipeline
- [ ] GitHub Pages web deployment
- [ ] Fastlane for release management

---

## Sprint Planning Template

### Sprint Goal
[One-sentence goal for the sprint]

### Selected Stories
| # | Story | Points | Assignee | Status |
|---|-------|--------|----------|--------|
| 1 | [User story] | X | | To Do |
| 2 | [User story] | X | | To Do |

### Definition of Done
- [ ] Code committed with conventional commit message
- [ ] All tests passing
- [ ] Code analyzed (no warnings)
- [ ] PR reviewed and approved
- [ ] CI/CD pipeline green
- [ ] Documentation updated

---

## Sprint Retrospective Template

### What went well
- [ ]

### What could be improved
- [ ]

### Action items for next sprint
- [ ]

---

## Definition of Ready (DoR)

A story is ready for sprint planning when:
- [ ] Clear acceptance criteria defined
- [ ] UX mockup or reference exists
- [ ] Technical feasibility confirmed
- [ ] Dependencies identified
- [ ] Story estimated and prioritized

## Definition of Done (DoD)

A story is done when:
- [ ] All acceptance criteria met
- [ ] Tests written and passing (≥ 60% coverage)
- [ ] Code reviewed
- [ ] No critical bugs
- [ ] Documentation updated
- [ ] Deployed to develop branch
- [ ] CI/CD pipeline passing

---

## Tooling

| Tool | Purpose |
|------|---------|
| **GitHub Issues** | Backlog, sprint tracking |
| **GitHub Projects** | Kanban board (To Do / In Progress / Review / Done) |
| **GitHub Actions** | CI/CD pipeline |
| **OpenCode** | AI coding agent |
| **Flutter Test** | Unit & widget tests |
| **integration_test** | End-to-end tests |
| **codecov** | Test coverage reporting |
