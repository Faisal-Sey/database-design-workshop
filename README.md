# Database Design for Software Engineers
### A Student Webinar by AmaliTech Coding Clubs

> **Audience:** Ghana university students (100–400 level)
> **Duration:** 2.5 – 3 hours (including hands-on exercises)
> **Format:** Live demo + Q&A + group exercises

---

## What You Will Learn

By the end of this session you will be able to:

- Choose the right database for a given problem (SQL vs NoSQL vs NewSQL)
- Design a clean schema from a real-world spec
- Apply indexing and query optimization techniques
- Spot and fix the five most common database mistakes in student projects

---

## Repo Structure

```
db-design-webinar/
├── slides/                 # Facilitator slide notes (markdown)
│   ├── 00-intro.md
│   ├── 01-db-selection.md
│   ├── 02-schema-design.md
│   ├── 03-optimization.md
│   ├── 04-common-mistakes.md
│   └── 05-wrap-up.md
├── demos/                  # Live-coding examples
│   ├── 01-schema-design/   # Good vs bad schema
│   ├── 02-indexing/        # Query performance before/after index
│   ├── 03-normalization/   # 1NF → 3NF walkthrough
│   └── 04-sql-vs-nosql/    # Same problem in Postgres & MongoDB
├── exercises/              # Student hands-on tasks
│   ├── 01-pick-your-db.md
│   ├── 02-design-a-schema.md
│   └── 03-optimize-this-query.md
└── resources/
    └── further-reading.md
```

---

## Prerequisites for Students

| Tool | Purpose | Free? |
|------|---------|-------|
| [DB Fiddle](https://www.db-fiddle.com/) | Run SQL in the browser | Yes |
| [MongoDB Atlas](https://www.mongodb.com/atlas) | Free cloud MongoDB | Yes |
| [draw.io](https://app.diagrams.net/) | ER diagram tool | Yes |

No local installation required — everything runs in the browser.

---

## Session Outline

| # | Topic | Time |
|---|-------|------|
| 0 | Intro & ice-breaker | 10 min |
| 1 | DB Selection framework | 25 min |
| 2 | Schema design live demo | 30 min |
| **—** | **Exercise 1 (schema)** | **15 min** |
| 3 | Indexing & optimization | 25 min |
| **—** | **Exercise 2 (optimize)** | **15 min** |
| 4 | Common mistakes + fixes | 20 min |
| 5 | Open Q&A + wrap-up | 15 min |

---

## How to Use This Repo

**Facilitators** — start with [`FACILITATOR_GUIDE.md`](FACILITATOR_GUIDE.md). It has talking points, timing cues, and answers to likely questions.

**Students** — follow along in `demos/` during the live session, then attempt `exercises/` independently. Answers are not included so your solutions are original.

---

## Contributing

Found a bug or want to add a demo? Open a PR. Keep examples Ghana-relevant where possible — local context makes concepts stick.
