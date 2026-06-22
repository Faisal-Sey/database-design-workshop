# Slide 4 — Common Mistakes

**Slide title:** Five Mistakes That Will Hurt You in Production

---

## Key message
These are not hypothetical. They appear in production systems, in job interviews, and in post-mortems.

## The Five (rapid-fire, ~4 min each)

### 1. Plain-text passwords
> "A data breach exposes everything. Hash with bcrypt or Argon2. Never store the raw password — not even temporarily."

### 2. No indexes on foreign keys
> "Every JOIN on an un-indexed foreign key is a full table scan. Add the index when you create the FK."

```sql
-- If you write this:
ALTER TABLE enrollments ADD FOREIGN KEY (student_id) REFERENCES students(id);
-- Also write this:
CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);
```

### 3. Using the DB as a message queue
> "Polling a jobs table every second with SELECT ... WHERE status='pending' with 50 concurrent workers is a recipe for deadlocks and a fried DB. Use a real queue: Redis, RabbitMQ, or Celery."

### 4. Multi-step writes without transactions
> Show the MoMo example — money disappears if step 2 fails after step 1.

```sql
BEGIN;
  UPDATE wallets SET balance = balance - 50 WHERE user_id = 1;
  UPDATE wallets SET balance = balance + 50 WHERE user_id = 2;
COMMIT;
```

> "COMMIT means both happen. If anything fails, the whole thing rolls back. Use this for anything that must be atomic."

### 5. No migrations
> "Running ALTER TABLE directly on production with no migration file means you can never roll back, and the next developer can't reproduce your schema. Use Flyway, Liquibase, or your ORM's migration tool from day one — even on a small project."

---

**Demo:** no new demo file — these are all discussion points
**Next:** `05-wrap-up.md`
