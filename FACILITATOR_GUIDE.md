# Facilitator Guide
## Database Design for Software Engineers — Student Webinar

---

## Before the Session

- [ ] Share the repo link with attendees 24 hours ahead
- [ ] Ask students to open [DB Fiddle](https://www.db-fiddle.com/) and confirm it loads
- [ ] Test your screen share at 1080p — SQL syntax must be readable at the back
- [ ] Print or pin the [session outline](README.md#session-outline) somewhere visible

**Recommended setup:** two browser windows side by side — DB Fiddle on the left, your slide notes on the right.

---

## Segment 0 — Intro & Ice-breaker (10 min)

**Goal:** warm up the room, surface what students already know.

**Talking points:**
- Introduce yourself in one sentence — keep it human, not a CV read-out.
- Ask the room: *"Raise your hand if you've built a project with a database."* Then: *"Keep it raised if the queries started slowing down after a few weeks."* — this usually gets a laugh and frames the whole session.
- Frame the problem: most CS courses teach you SQL syntax but not *why* you'd choose Postgres over MongoDB, or why your `SELECT *` is killing your app at 10,000 rows.

**Ice-breaker question (put in chat or say aloud):**
> *"Name one app Ghanaians use every day that you think has a really interesting database problem behind it."*

Expected answers: MTN MoMo, GhanaPostGPS, KNUST/UG student portals, Melcom/Jumia, Bolt. Briefly validate each — they are all correct.

---

## Segment 1 — DB Selection Framework (25 min)

**Key takeaway:** There is no universally "best" database. There is only the right fit for the access pattern.

### The Three Questions Framework

Before picking a DB, answer these three questions:

```
1. What is the shape of my data?
   → Highly relational (users, orders, payments) → SQL
   → Document-like, flexible schema (chat messages, configs) → NoSQL
   → Time-ordered events, metrics → Time-series DB

2. What does my app do most?
   → Heavy reads → optimize for reads (indexes, read replicas, caching)
   → Heavy writes → optimize for writes (partitioning, append-only logs)
   → Equal reads/writes → general-purpose relational DB is usually fine

3. What are my consistency requirements?
   → Money, inventory, grades → strong consistency → SQL (ACID)
   → Likes, view counts, analytics → eventual consistency is fine → NoSQL
```

### The Decision Matrix (draw this live)

| Scenario | Good fit |
|----------|---------|
| University student portal (grades, courses, fees) | PostgreSQL |
| Chat app (WhatsApp clone) | MongoDB or Cassandra |
| Real-time leaderboard (gaming) | Redis |
| Mobile money ledger (MoMo) | PostgreSQL with strict transactions |
| Product catalogue (e-commerce) | PostgreSQL or MongoDB |
| IoT sensor readings | TimescaleDB or InfluxDB |

**Common student mistake to flag here:** picking MongoDB because it's "modern" or "easier to start with" then trying to do complex joins later — painful. Conversely, using MySQL for a free-form configuration store where the schema changes every sprint.

### Talking Point: What runs Ghana's infrastructure?
- Ghana's banking systems (GCB, Ecobank) run on Oracle and DB2 — battle-tested relational.
- Fintech startups (Hubtel, Zeepay) use PostgreSQL + Redis.
- Modern SaaS companies hiring Ghanaian engineers (Flutterwave, Paystack) use PostgreSQL as the primary store, MongoDB for ancillary data.
- This is a signal: **relational is the safe default**. Learn it deeply before branching out.

---

## Segment 2 — Schema Design Live Demo (30 min)

**Live file:** `demos/01-schema-design/`

**Narrative:** A student group is building a university course registration system for their capstone project. Walk through the *bad* schema first, identify the problems, then reveal the good schema.

### Step 1 — Open `bad-schema.sql` and read it aloud

Ask the audience: *"What problems do you see?"*

Let them answer before you say anything. Students will usually spot:
- `courses` stored as a comma-separated string
- No foreign keys
- Storing full name instead of linking to a users table

Praise every answer, add ones they missed.

### Step 2 — Open `good-schema.sql` and walk through each design decision

Emphasise:
- **Referential integrity** — the DB enforces relationships, not just the app code
- **Normalization** prevents data getting out of sync
- **NOT NULL constraints** are your first line of defence

### Step 3 — Pivot to `demos/03-normalization/` for a quick 1NF → 3NF walkthrough

Keep this brisk (5–7 min). Most students have heard of normalization but never seen it applied step by step.

---

## Exercise 1 — Design a Schema (15 min)

See `exercises/02-design-a-schema.md`.

Ask students to work in pairs. While they work, circulate (or in virtual: ask 2–3 pairs to share their screen briefly).

**Watch for:** students jumping straight to code before thinking about entities and relationships. Encourage them to list entities first, then attributes, then relationships.

---

## Segment 3 — Indexing & Optimization (25 min)

**Live file:** `demos/02-indexing/`

**Key message:** An index is a trade-off — faster reads, slower writes, more disk. Know when to add one and when not to.

### Demo flow

1. Run `without-index.sql` — note the query plan (`EXPLAIN ANALYZE`) and execution time.
2. Add the index.
3. Run `with-index.sql` — compare.

**Talking points:**

- Index the columns you `WHERE`, `JOIN`, and `ORDER BY` on.
- Don't index low-cardinality columns (e.g., a boolean `is_active` on a table where 99% of rows are `true` — pointless).
- Composite indexes: column order matters. `(last_name, first_name)` helps `WHERE last_name = ?` but NOT `WHERE first_name = ?` alone.
- `SELECT *` is a code smell — always select only the columns you need.

### The N+1 Query Problem

```
# Bad — runs 1 + N queries
for student in students:
    fetch(student.courses)   # one DB hit per student

# Good — 2 queries total
fetch all students
fetch all courses WHERE student_id IN (...)
```

This is one of the most common performance bugs in student projects and junior developer code. Frame it as something interviewers ask about.

---

## Exercise 2 — Optimize This Query (15 min)

See `exercises/03-optimize-this-query.md`.

---

## Segment 4 — Common Mistakes (20 min)

**No new demo file needed** — use the mistakes as a rapid-fire discussion.

### The Five Mistakes

**1. Storing passwords in plain text**
> Still happens. Always hash (bcrypt, Argon2). Never store the raw password, not even temporarily.

**2. No indexes on foreign keys**
> Every `JOIN` on an un-indexed FK is a full table scan waiting to embarrass you in production.

**3. Using the database as a message queue**
> Polling a `jobs` table every second with `SELECT ... WHERE status = 'pending'` — this is how you get 100 connections all fighting over the same rows. Use a proper queue (Redis, RabbitMQ, Kafka) for async work.

**4. Not using transactions for multi-step writes**
> Mobile money example: debit sender, credit receiver. If step 2 fails after step 1 — money vanishes. Wrap both in a transaction.

```sql
BEGIN;
  UPDATE wallets SET balance = balance - 50 WHERE user_id = 1;
  UPDATE wallets SET balance = balance + 50 WHERE user_id = 2;
COMMIT;  -- both happen, or neither happens
```

**5. Ignoring database migrations**
> Running `ALTER TABLE` directly on a production DB with no migration file is how you break things and have no way to roll back. Use Flyway, Liquibase, or your ORM's migration tool from day one.

---

## Segment 5 — Q&A & Wrap-up (15 min)

**Prompt questions if the room is quiet:**
- *"What database does your current project use, and would you still pick the same one?"*
- *"Has anyone been bitten by a performance issue they didn't expect?"*
- *"What's one thing you'll change in your next project after today?"*

**Closing call-to-action:**
1. Star this repo and come back to the exercises.
2. Read the two links in `resources/further-reading.md` this week.
3. Share one thing you learned on Twitter/LinkedIn — tagging the coding club keeps the community growing.

---

## Timing Cheat Sheet

| Segment | Target end time (from start) |
|---------|------------------------------|
| Intro | 0:10 |
| DB Selection | 0:35 |
| Schema demo | 1:05 |
| Exercise 1 | 1:20 |
| Optimization | 1:45 |
| Exercise 2 | 2:00 |
| Mistakes | 2:20 |
| Q&A | 2:35 |

If you are running over: cut Exercise 2 short and move the optimization content into Q&A as a discussion rather than a live demo.

---

## Likely Questions & Answers

**Q: Should I learn MySQL or PostgreSQL?**
> PostgreSQL. It is feature-complete, free, and what most companies hiring in Africa use. MySQL is fine but Postgres has better support for JSON, full-text search, and advanced indexing.

**Q: Is Firebase a real database?**
> Firestore/Firebase Realtime Database are real databases — document stores backed by Google infrastructure. They're excellent for mobile apps and rapid prototyping. Just know they are not relational; complex queries are harder and you pay per read/write at scale.

**Q: What about SQLite?**
> SQLite is perfect for mobile apps (Android, iOS) and small desktop tools. It is the most deployed database in the world. Not suitable for multi-user web apps — no concurrent writes.

**Q: ORM vs raw SQL?**
> Use an ORM (SQLAlchemy, Prisma, Django ORM, Hibernate) for productivity on standard CRUD. Learn raw SQL anyway — ORMs generate bad queries sometimes and you need to spot it. At senior level, you need both.

**Q: How do big companies handle billions of rows?**
> Short answer: partitioning (splitting one giant table into smaller physical pieces), read replicas, caching layers (Redis), and eventually distributed databases (CockroachDB, Spanner). You don't need this until you have millions of users — premature optimization is real.
