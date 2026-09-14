# Yazi — Change Request Batch (Sept 2026)

Paste this whole file into Claude Code at the root of the Yazi project and say:
*"Work through this list one item at a time. Show me the diff for each item before moving to the next."*

Items 1–9 are changes. Items 10–11 are bugs — diagnose before fixing.

**Stack reminder:** Flutter/Dart app, Node/Express backend with SQLite, web admin panel.
Backend lives at `/root/yazi/backend` on the droplet (164.92.167.224), port 8787, admin at `/admin`.
Add columns via migrations — do not rewrite the schema.

---

## 1. Remove "Website" from Schools and Nurseries

- Hide the website field/button on the **detail screen** for listings in the Schools and Nurseries categories only. Other categories (stores, clinics, activities) keep it.
- Also remove the Website input from the **admin panel form** for these two categories.
- **Do not drop the column from the database.** Just stop displaying and editing it — that way nothing is lost if it needs to come back.

**Done when:** opening any school or nursery shows no website row; opening a store still does.

---

## 2. Social links → logos only

Replace the text labels "Facebook", "WhatsApp", "Instagram" with their icons.

- Use the icon approach already in the project — check `pubspec.yaml` for `font_awesome_flutter` or bundled brand PNGs under `assets/` before adding any new package.
- Lay them out in a horizontal row, brand colours, tap target at least 44×44 px.
- **Only render an icon if that link actually exists** on the listing — no dead/greyed icons.
- Add `accessibilityLabel="Facebook"` etc. so screen readers still work.

---

## 3. Photos for all listings

This is the biggest item — split it in two:

**Source:** interim cover images come from each business's **Facebook or Instagram profile picture** (usually their logo), to be replaced with partner-supplied photos later. Profile pictures only — do not pull anything from the feeds of nurseries or schools, since those posts contain photos of children.

**3a. Make the pipeline work (do this first)**
- Confirm the admin panel photo upload saves correctly and the app displays it. Photo upload per listing was already built in Phase 1 — verify it works before building anything new.
- Make sure listings with no photo show a **category-specific placeholder** (school building, nursery, shop) rather than a broken image or grey box.
- Add bulk photo upload to the admin panel: select a listing, drop 1–5 images, first one becomes the cover.

**3b. Fill in the photos**
- Produce a list of every listing currently missing a photo, grouped by category, exported as CSV — so I can work through it.
- Add a `photo_source` field per listing (`social` / `partner` / `placeholder`) so the interim images are easy to find and swap out later.

---

## 4. Remove "Admission" from Nurseries

Admission is schools-only. Hide the Admission section/tab/button when the listing's category is Nursery. Make this driven by category, not a hardcoded list of listing IDs.

---

## 5. "Agy" → "Year" in Schools

The schools listing shows an age label that should read **Year** instead.

- Find the label string (search for `Agy`, `Age`, `age_range` in the schools components) and change the display text to "Year".
- Example: `FS1 – Grade 12` stays as is; but anywhere it says "Agy 4–18" it should read "Year 4–18".
- Nurseries keep "Age" — this change is schools-only.

---

## 6. Fixed header on the Home screen

The top block of Home (logo + tagline + search) should stay pinned while the list below scrolls.

- If Home uses `ScrollView`/`FlatList`, move the header **out** of it and place it above as a sibling, instead of using `ListHeaderComponent`.
- Keep it inside `SafeAreaView` so it doesn't sit under the notch.
- Check it doesn't get covered by the keyboard when the search field is focused.

---

## 7. Remove "Offers" and "Open Now" from Schools

- Remove both filter chips from the Schools category screen only.
- Leave them working for all other categories.
- Make sure no stale `offers=true` / `open_now=true` value stays in the filter state when switching into Schools from another category (this is a common bug — clear school-irrelevant filters on category change).

---

## 8. Admin: put a category "on hold"

**Partly built already — check before building.** The admin Categories list already has a **STATUS** column showing `ACTIVE` on all nine categories, so the database field exists. But the **Edit categorie** panel has no status field (only ID, Emoji, Name EN, Name AR, Color, Background wash, Sort order), so it can be seen but not changed.

Work needed:

1. **Find the existing column** in the categories table and confirm its name and allowed values before adding anything. Do not create a second status field alongside it.
2. **Add the control to the Edit form** — a toggle or dropdown: Active / On hold. Put it next to Sort order.
3. **Make the list row clickable** so status can be flipped without opening the editor, and style on-hold rows differently (greyed, amber badge) so they stand out.
4. **Check the API actually filters on it.** Very likely it returns all categories regardless of status — in which case setting one to on-hold would change nothing in the app. The public categories endpoint must exclude non-active ones; add `?include_hidden=true` for the admin panel.
5. **App side:** on-hold categories disappear from the home grid and from search. If a deep link points to a listing inside an on-hold category, show "temporarily unavailable" rather than crashing.

**Test it end to end:** set First Days to on hold, pull-to-refresh the app, confirm the tile is gone, set it back to active, confirm it returns.

---

## 9. Schools filters: Curriculum + Teaching Language (combinable)

**Scope: the filter area of the Schools category only.** Do not restyle the result cards, the bottom navigation, or anything else from the mockup — only the filter row and the rows directly under it.

### What exists now

Deutsch / English / Français already exist on the Schools screen, but as **subcategory tiles** (big square tiles with flag icons). Tiles are pick-one and cannot combine with anything.

**Convert these tiles into a filter chip.** Reuse the language data already sitting behind them — do not create a second parallel language field. Delete the tiles once the chip works.

Curriculum/System does not exist at all and must be built.

### Target layout (top to bottom)

**Row 1 — filter chips, horizontally scrollable:**

| Chip | Values | Behaviour |
|---|---|---|
| Area | existing areas | single select |
| Curriculum | IB, IG, American, National | multi-select |
| Teaching Language | English, French, Deutsch | multi-select |
| More Filters | Verified, Near me, Year | opens a sheet |

- When a chip has a value, it shows the label small on top and the **selected value underneath with an ×** to clear it — e.g. "Curriculum / IB ×" — and the chip turns its accent colour (Curriculum = light blue, Teaching Language = pink), exactly as in the mockup.
- Move **Verified** and **Near me** into "More Filters" rather than deleting them.
- The mockup shows a **Fees** chip. There is no fees data in the database, so **skip it for now** — don't add a chip that filters nothing.

**Row 2 — hint banner (optional, dismissible):** "French language and IB curriculum can be combined." Show it only until the user dismisses it once; store the dismissal locally.

**Row 3 — active filters:** `Active filters:` followed by removable pills ("Curriculum: IB ×") and a **Clear all** link on the right.

**Row 4 — result count and sort:** "3 schools found" on the left, "Sort by: Relevance" on the right.

### Filter logic

- The two filters **combine with AND**: Curriculum=IB **and** Language=French returns only schools that are both.
- Within one filter, multiple values combine with **OR**: IB or American returns either.
- A school teaching in more than one language ("French / English") must match **both** a French filter and an English filter. So store languages as a **multi-value field**, not one string.
- Same for curriculum — a school can be both IB and American.
- Empty result: show a message naming which filter to loosen, not a blank screen.

### Data work needed first

- Add `curriculum` (multi-value) to school records, plus an admin panel input for it.
- Confirm the existing language values are multi-value, not single strings. If single, migrate them.
- Export a CSV of schools missing curriculum values so I can fill them in.
- **Nothing to show until this data exists** — build the admin inputs and let me populate a few schools before wiring the app filters, otherwise the chips will look broken.

---

## 10. BUG — Nursery age filter returns wrong results

I've already entered age ranges on several nurseries and the filter doesn't match them.

**Diagnose before changing anything.** Likely causes, check in this order:

1. **Age stored as text, compared as number.** If `age_range` is a string like `"1-4"` or `"1 – 4 years"`, any numeric comparison silently fails. Check the actual column type and a few real values in the database.
2. **Range logic is wrong.** Filtering "age 3" should return every nursery whose range *contains* 3, i.e. `min_age <= 3 AND max_age >= 3`. A common mistake is `min_age = 3`, which only matches nurseries starting exactly at 3.
3. **Units mismatch.** Some nurseries may be entered in months (6–48) and others in years (0.5–4).
4. **Null handling.** Nurseries with no age set — decide whether they're included or excluded, and be consistent.

**Fix:** split into proper numeric `min_age_months` and `max_age_months` columns, migrate the existing text values, and use overlap logic. Show me the migration before running it.

---

## 11. BUG — Arrival duration missing on some nurseries

The travel-time estimate shows on some listings but not others.

Check in this order:

1. **Missing coordinates.** Most likely: those nurseries have no `latitude`/`longitude`, so distance can't be computed. Run a query for nurseries with null or zero coordinates — that list will probably match the broken ones exactly.
2. **Location permission** not granted, or the user's location is null — should show a neutral "enable location for travel time" message rather than nothing.
3. **Geocoding/API failure** silently swallowed by a try/catch with no fallback.

**Fix:** backfill missing coordinates (I can supply addresses), and make the component show an explicit fallback state instead of rendering nothing.

---

## Order I'd suggest

1. Quick wins: 1, 2, 4, 5, 6, 7 — all small, all low risk.
2. Bugs: 10, 11 — these affect people using the app right now.
3. Data/schema: 9, then 8.
4. Ongoing: 3.

Commit each item separately with a clear message so anything can be rolled back on its own.
