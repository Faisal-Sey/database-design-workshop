# Slide 3 — Optimization

**Slide title:** Making Your Queries Fast

---

## Key message
Optimization is a trade-off. Every index you add speeds up reads and slows down writes. Know the trade-off before you add one.

## Demo sequence (25 min)

1. Open `demos/02-indexing/without-index.sql`
   - Run it. Show EXPLAIN ANALYZE output.
   - Point to "Seq Scan" — *"Postgres read every row."*

2. Open `demos/02-indexing/with-index.sql`
   - Add the index. Re-run the same query.
   - Compare cost. *"At 50M rows, this is the difference between seconds and milliseconds."*

3. Cover index rules quickly:
   - Index: WHERE, JOIN, ORDER BY columns
   - Don't index: low-cardinality columns (boolean, status with 2–3 values)
   - Composite index: column order matters
   - Covering index: include non-key columns to skip the heap fetch

## The N+1 Problem (5 min, no demo file needed)

Write pseudo-code on screen:
```
# Bad — N+1
for student in students:
    fetch(student.courses)

# Good — 2 queries
students = fetch_all_students()
courses  = fetch_courses_where_student_in(students.ids)
```

*"This is one of the most common interview questions at mid-level. Know it."*

## SELECT * note
Not a crime, but a habit that wastes bandwidth and blocks covering indexes.
Always name your columns in production code.

---

**Demo:** `demos/02-indexing/`
**Next:** Exercise 2 (`exercises/03-optimize-this-query.md`), then `04-common-mistakes.md`
