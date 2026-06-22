# Exercise 3 — Optimize This Query

**Time:** 15 minutes (individual)
**Tools:** [DB Fiddle](https://www.db-fiddle.com/) (PostgreSQL 15)

---

## Setup

Paste this into DB Fiddle to create the tables and seed data:

```sql
CREATE TABLE students (
    id            SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL,
    first_name     VARCHAR(100) NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(200) NOT NULL,
    department     VARCHAR(100) NOT NULL,
    is_active      BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE courses (
    id    SERIAL PRIMARY KEY,
    code  VARCHAR(20) NOT NULL,
    title VARCHAR(200) NOT NULL
);

CREATE TABLE enrollments (
    id         SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id),
    course_id  INT NOT NULL REFERENCES courses(id),
    semester   VARCHAR(20) NOT NULL,
    grade      CHAR(2)
);

-- Seed 10,000 students
INSERT INTO students (student_number, first_name, last_name, email, department)
SELECT
    '10' || LPAD(gs::TEXT, 6, '0'),
    (ARRAY['Kofi','Ama','Kwame','Abena','Yaw','Akosua','Kojo','Adwoa'])[floor(random()*8+1)],
    (ARRAY['Mensah','Asante','Acheampong','Boateng','Owusu','Darko','Appiah'])[floor(random()*7+1)],
    'student' || gs || '@university.edu.gh',
    (ARRAY['Computer Science','Electrical Engineering','Business','Medicine','Law'])[floor(random()*5+1)]
FROM generate_series(1, 10000) gs;

-- Seed 50 courses
INSERT INTO courses (code, title)
SELECT 'DCIT' || (300 + gs), 'Course Number ' || gs
FROM generate_series(1, 50) gs;

-- Seed 80,000 enrollments
INSERT INTO enrollments (student_id, course_id, semester, grade)
SELECT
    floor(random()*10000+1)::INT,
    floor(random()*50+1)::INT,
    (ARRAY['2022/2023-SEM1','2022/2023-SEM2','2023/2024-SEM1','2023/2024-SEM2'])[floor(random()*4+1)],
    (ARRAY['A','B+','B','C+','C','D','F',NULL])[floor(random()*8+1)]
FROM generate_series(1, 80000);
```

---

## The Problem Query

A student portal runs this query every time a student logs in to show their transcript:

```sql
SELECT
    s.first_name || ' ' || s.last_name AS student_name,
    s.email,
    s.department,
    c.code,
    c.title,
    e.semester,
    e.grade
FROM enrollments e, students s, courses c
WHERE s.id = e.student_id
  AND c.id = e.course_id
  AND s.email = 'student42@university.edu.gh'
  AND s.is_active = TRUE
ORDER BY e.semester, c.code;
```

---

## Your Task

1. Run `EXPLAIN ANALYZE` on the query above. Note the total execution time.

2. Identify at least **two problems** with this query (hint: look at the query structure and the `EXPLAIN` output).

3. Fix the problems and run `EXPLAIN ANALYZE` again. How much faster is it?

4. Write your fixed query and list the changes you made.

---

## Things to Consider

- How is the `FROM` clause written? Is there a better way?
- What columns are being searched in `WHERE`?
- Are there any indexes on those columns? How would you add them?
- Is `SELECT *` ever used? (It isn't here — good. But what's equivalent to it in this query?)

---

## Bonus Challenge

The university IT team says the five most common queries against this database are:

1. Look up a student by email
2. Get all enrollments for a student in a given semester
3. Get all students in a given department
4. Get all students who got an 'F' grade this semester
5. Count enrollments per course (for class size monitoring)

Write the indexes you would create to support all five queries. For each index, explain in one sentence why you chose those columns.

---

## Facilitator Note

Expected fixes:
- Replace implicit join (`FROM a, b WHERE a.id = b.fk`) with explicit `JOIN ... ON`
- Add `CREATE INDEX idx_students_email ON students(email)`
- Add `CREATE INDEX idx_enrollments_student_semester ON enrollments(student_id, semester)`
- Note: `is_active` on its own is low-cardinality — a partial index works: `CREATE INDEX ON students(email) WHERE is_active = TRUE`
