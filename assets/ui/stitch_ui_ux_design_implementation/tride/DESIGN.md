---
name: Tride
colors:
  surface: '#faf8ff'
  surface-dim: '#d9d9e5'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3fe'
  surface-container: '#ededf9'
  surface-container-high: '#e7e7f3'
  surface-container-highest: '#e1e2ed'
  on-surface: '#191b23'
  on-surface-variant: '#434655'
  inverse-surface: '#2e3039'
  inverse-on-surface: '#f0f0fb'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#00668a'
  on-secondary: '#ffffff'
  secondary-container: '#40c2fd'
  on-secondary-container: '#004d6a'
  tertiary: '#943700'
  on-tertiary: '#ffffff'
  tertiary-container: '#bc4800'
  on-tertiary-container: '#ffede6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#c4e7ff'
  secondary-fixed-dim: '#7bd0ff'
  on-secondary-fixed: '#001e2c'
  on-secondary-fixed-variant: '#004c69'
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb596'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#7d2d00'
  background: '#faf8ff'
  on-background: '#191b23'
  surface-variant: '#e1e2ed'
  background-cloud: '#F8FAFC'
  text-navy: '#0F172A'
  text-slate: '#64748B'
  sunset-orange: '#FB7A3C'
  warm-yellow: '#FDB813'
  natural-green: '#3E9C5D'
  sand-beige: '#EDE0CB'
typography:
  display-hero:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '600'
    lineHeight: '1.3'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  data-tabular:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '500'
    lineHeight: '1.4'
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  edge-margin-mobile: 20px
  edge-margin-desktop: 48px
  gutter: 16px
  section-gap: 40px
---

# Tride — Product & UI/UX Design Specification

*Version 2.0 — rebuilt from zero. Prepared as a design brief for Google Stitch AI.*

---

## 1. Product Vision

**Name:** Tride
**Tagline:** Travel Better, Together.
**Category:** Travel Planning & Travel Discovery App

**Core idea:** Tride helps people find where to go, get inspired, plan a trip, build an itinerary, and stay in control of their travel budget — all inside one experience that feels like a travel app, not a productivity tool that happens to be about travel.

**Tride is not:**
- An admin dashboard
- A CRUD database app
- A finance app
- A generic AI chatbot
- A template productivity app

**Tride is:**
- A travel companion
- A travel discovery platform
- A trip planning app
- A personal travel assistant

**The three-second test:** The moment someone opens Tride, before they read a single line of copy, the screen should say: *"This is an app for going places."* If a screen could be mistaken for a banking app, a task manager, or an admin panel with the labels swapped, it has failed this test — no matter how well it functions.

---

## 2. Design Philosophy

Tride is designed **editorial and immersive**, not modular and administrative. The previous version read as a dashboard because it defaulted to the safest, most generic pattern available: white card, icon, label, repeat. This version rejects that default on purpose.

**Working principles:**
- **Photography leads, UI supports.** Destination imagery is not decoration inside a card — it *is* the layout. Large images, full-bleed sections, and content sitting on top of photos (not next to them in a box) come first.
- **No repeating white-card grid.** Not every piece of information needs the same container. Vary size, shape, and treatment by what the content actually is: a hero moment, a scroll of choices, a timeline, a number.
- **Composition over containment.** Overlap elements, let images bleed to the edge, break the grid where it earns its keep. Whitespace is used deliberately, not as a leftover.
- **Every screen is a moment in a trip, not a step in a form.** Even a planning flow should feel like flipping through a travel journal, not filling out an intake form.

**Inspiration (mood only, not to be copied):** Airbnb's destination storytelling and photography scale, and Google Travel's easy, well-organized utility. Neither should be visually replicated — they're reference points for *confidence with imagery* and *clarity without clutter*, not templates to trace.

**The signature — Boarding Pass Trip Card:**
Tride needs one element that is unmistakably its own — something no dashboard app would ever have. That element is the **Trip Card**, shaped like a boarding pass: a main body (destination photo + trip name) joined to a smaller stub (dates, day count, status) by a dashed perforation line, with a small semi-circular notch cut into the top and bottom edge at the seam — exactly like a real ticket. This shape is reserved *only* for Trip Cards. It appears on Home (Upcoming Trip), on the Trips list, and at the top of Trip Detail — consistently, so it reads as a recognizable piece of the Tride identity rather than a one-off decoration.

This ties back to Tride's actual mark: a bold ribboned "T" wrapped in a thin orbit ring, with a small plane and swoosh cutting past it, and — inside the body of the letterform itself — a miniature scene of a winding road leading to a location pin. Two pieces of that mark carry forward as recurring UI motifs rather than staying locked inside the logo: the **orbit ring** becomes the frame for small circular badges (used for achievements and completed trips, see §16), and the **winding road + pin** becomes the visual language for routes — on itinerary maps and anywhere a path between stops should read as a journey, not a straight line. Between the boarding-pass Trip Card, the ring badge, and the road-and-pin route style, Tride ends up with one coherent visual family instead of a logo that sits on the splash screen and never appears again.

---

## 3. Visual Identity

**Personality:** Modern · Adventurous · Friendly · Premium · Fresh · Explorative · Relaxed

**Visual mood, in words:**
- "Weekend getaway"
- "Discover something new"
- "Let's go somewhere"
- "Plan your next adventure"

**Avoid entirely:** corporate, banking, admin, enterprise dashboard, generic SaaS. If a screen would look at home in an accounting tool with the icons swapped, it's wrong.

**Logo continuity:** The existing Tride mark is a bold ribboned letter "T," wrapped in a thin orbit ring, with a small plane and swoosh trail beside it and a miniature road-to-pin scene inside the letterform. None of this is repeated as a UI pattern everywhere — two pieces carry forward sparingly: the orbit ring as the shape for small achievement badges (see Profile, §16), and the road-and-pin scene as the visual cue for routes and journeys, so the connection feels earned rather than decorative.

---

## 4. Color Direction

Color is a supporting player. Destination photography is the primary source of color on most screens — the palette exists to frame it, not compete with it.

| Role | Color | Hex | Use for |
|---|---|---|---|
| Primary | Ocean Blue | `#2563EB` | Primary buttons, active nav state, links, key icons |
| Accent | Sky Blue | `#38BDF8` | Secondary highlights, progress fills, selected states |
| Background | Cloud White | `#F8FAFC` | App background |
| Surface | White | `#FFFFFF` | Elevated cards, sheets, modals |
| Text Primary | Deep Navy | `#0F172A` | Headlines, body text |
| Text Secondary | Slate | `#64748B` | Captions, metadata, timestamps |
| Sunset Orange | — | `#FB7A3C` | Beach/sunset content, warm CTAs, highlights |
| Warm Yellow | — | `#FDB813` | Ratings, sunlit accents, badges |
| Natural Green | — | `#3E9C5D` | Nature/eco experiences, success states |
| Sand Beige | — | `#EDE0CB` | Stay/budget category, warm neutral backgrounds |

**Rules:**
- The app should never read as "all blue." Blue carries structure and action; the travel accents carry *context* — orange for a beach destination, green for a nature trip, beige behind a "Stay" budget category.
- Use one accent at a time per screen or section. Don't rainbow a single card.
- Accents sit behind or beside photography — never instead of it.

---

## 5. Typography

Typography needs to carry as much personality as the imagery — it should never default to looking like dashboard labels.

| Role | Typeface | Weight | Size |
|---|---|---|---|
| Display (hero, greeting, section titles) | Poppins | SemiBold / Bold | 28–36px |
| Card & screen titles | Poppins | SemiBold | 18–20px |
| Body (descriptions, itinerary text) | Inter | Regular / Medium | 14–16px |
| Data (budget figures, dates, times) | Inter, tabular figures | Medium | 14–16px |
| Caption / label / eyebrow | Inter | Medium, uppercase, tracked | 11–12px |

**Why this pairing:** Poppins is geometric and friendly — it gives headlines their "adventurous" personality. Inter stays quiet and legible at small sizes, so long itinerary text and budget figures stay easy to scan instead of competing with the display type. Tabular figures keep columns of prices and times aligned without needing a separate monospace face.

**Example headline voice** (tone reference, not literal final copy):
- "Where will you go next?"
- "Your next adventure starts here."
- "Escape to paradise."
- "Ready for your next adventure?"

**Rule:** if a heading could be mistaken for a form field label ("Destination Name," "Trip Status"), rewrite it. Headlines should sound like something a travel editor wrote, not a database schema.

---

## 6. Navigation

**Bottom navigation (5 items):** Home · Explore · Trips · Budget · Profile

**AI Planner is deliberately not a tab.** Giving it a permanent slot in the bottom nav would make Tride read as an AI tool with travel features bolted on. Instead:
- On **Home**, it's offered as a clear, prominent entry point (e.g. a floating call-to-action or a dedicated card) — present, but not the first thing the eye hits.
- On **Trips**, starting a new trip offers "Plan with AI" as one path alongside manual planning.

This keeps the app-first identity: Tride is a travel app that happens to have a smart assistant inside it, not the reverse.

---

## 7. User Journey

**Discover → Get Inspired → Explore Destination → Plan Trip → Generate Itinerary → Save Trip → Travel → Track Budget → Complete Trip**

| Stage | What the design must do |
|---|---|
| Discover / Get Inspired | Home leads with imagery and ideas, not an empty search bar |
| Explore Destination | Detail pages read like a travel guide, not a spec sheet |
| Plan Trip | Feels conversational and light, one question at a time |
| Generate Itinerary | AI output looks hand-curated, not machine-dumped |
| Save Trip | The trip becomes a tangible object — a boarding pass, not a row |
| Travel / Track Budget | Budget stays framed as "this trip," never as personal finance |
| Complete Trip | Closing a trip feels like a small accomplishment, not an archive action |

At no point should the user feel like they're filling out a database record. They should feel like they're preparing for a trip.
