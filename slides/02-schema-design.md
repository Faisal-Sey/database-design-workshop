# Slide 2 — Schema Design

**Slide title:** Designing a Schema That Won't Haunt You

---

## Key message
A good schema makes impossible states impossible. The database enforces correctness, not just the app code.

## Demo sequence (30 min)

1. Open `demos/01-schema-design/bad-schema.sql`
   - Read it aloud. Ask: *"What problems do you see?"*
   - Wait. Let the audience answer first.

2. Open `demos/01-schema-design/good-schema.sql`
   - Walk through each table in order: departments → lecturers → courses → students → enrollments → fee_payments
   - Highlight: referential integrity, NOT NULL, CHECK constraints, junction table

3. Quick pivot to `demos/03-normalization/normalization-steps.sql`
   - Show 0NF → 1NF → 2NF → 3NF in sequence (5–7 min)
   - Key line: "3NF is good enough for production. You don't need 4NF."

## Design heuristics to repeat throughout

- "If you're storing a comma-separated list in a column, you need another table."
- "If changing one piece of data requires updating multiple rows, you have a normalization problem."
- "Constraints in the DB outlast constraints in the app. Apps get rewritten. Schemas don't."

---

**Demo:** `demos/01-schema-design/`, `demos/03-normalization/`
**Next:** Exercise 1 (`exercises/02-design-a-schema.md`), then `03-optimization.md`
