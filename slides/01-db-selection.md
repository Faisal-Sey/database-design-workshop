# Slide 1 — Database Selection

**Slide title:** Choosing the Right Database

---

## Key message
There is no universally "best" database. There is only the right fit for the access pattern.

## The Three Questions (write on the board / share screen)

```
1. What is the shape of my data?
2. What does my app do most — reads or writes?
3. How consistent does my data need to be?
```

## Decision matrix

Draw this live — don't just show a slide.

| Scenario | Good fit |
|----------|---------|
| Student portal | PostgreSQL |
| Chat app | MongoDB / Cassandra |
| Leaderboard | Redis |
| MoMo ledger | PostgreSQL (ACID) |
| IoT sensors | TimescaleDB |

## Talking point: what do Ghanaian companies actually use?
- Banks: Oracle / DB2
- Fintechs (Hubtel, Zeepay): PostgreSQL + Redis
- The lesson: **relational is the safe default.** Learn it deeply first.

## Common mistake to flag
Picking MongoDB because it's "easier to start" then struggling with joins 3 months later.
Opposite mistake: using MySQL for a config store that changes schema every sprint.

---

**Demo:** none — discussion only
**Next:** `02-schema-design.md`
