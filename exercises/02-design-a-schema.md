# Exercise 2 — Design a Schema

**Time:** 15 minutes (pairs)
**Tools:** [DB Fiddle](https://www.db-fiddle.com/) (PostgreSQL 15) or paper

---

## Brief

A group of final-year students at KNUST are building **CampusRide** — a ride-sharing app for students on campus. They want students to be able to:

- Register as a **passenger** or **driver** (or both)
- Drivers register their vehicle (make, model, plate, number of seats)
- Passengers post a **ride request** with a pickup point, destination, and preferred time
- Drivers can **accept** a request
- After the ride, passengers leave a **rating** (1–5 stars) and optional comment for the driver

---

## Your Task

Design a PostgreSQL schema for CampusRide. Write the `CREATE TABLE` statements.

**Before you write any SQL:**

1. List all the **entities** you can identify (nouns from the brief above)
2. For each entity, list its **attributes**
3. Draw or write out the **relationships** between entities (one-to-many? many-to-many?)

Then translate to SQL.

---

## Requirements

Your schema must:

- [ ] Use appropriate data types (not everything is `TEXT`)
- [ ] Have primary keys on every table
- [ ] Use foreign keys to enforce relationships
- [ ] Include at least two `NOT NULL` constraints
- [ ] Include at least one `CHECK` constraint (hint: rating range)
- [ ] Handle the case where a user is both a passenger AND a driver

---

## Stretch Goals (if you finish early)

- Add a `ride_status` that tracks whether a ride is `open`, `accepted`, `in_progress`, or `completed`
- How would you store the GPS coordinates of pickup and drop-off points?
- What index would you add if the most common query is "find all open ride requests near a given location"?

---

## Facilitator Note

There is no single correct answer. Look for:
- Separate `users`, `vehicles`, `ride_requests`, `ride_acceptances`, `ratings` tables
- A `user_roles` or `driver_profiles` junction to handle dual roles
- `rating` as `SMALLINT CHECK (rating BETWEEN 1 AND 5)`, not `TEXT`
- Foreign key from `ride_acceptances.driver_id` → `users.id`
