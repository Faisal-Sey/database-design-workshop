-- ============================================================
-- NORMALIZATION WALKTHROUGH — 1NF → 2NF → 3NF
-- Context: GH university course catalogue (messy spreadsheet import)
-- ============================================================

-- ── UNNORMALIZED (0NF) ────────────────────────────────────────
-- This is what a real spreadsheet export looks like.
-- One row per student per semester, repeated data everywhere.

CREATE TABLE raw_import (
    student_name    TEXT,
    student_email   TEXT,
    courses_taken   TEXT,   -- "DCIT301, DCIT305, MATH201" — multiple values
    lecturer_names  TEXT,   -- "Dr. Asante, Prof. Otu, Dr. Mensah"
    dept_name       TEXT,
    dept_head       TEXT,   -- same head repeated for every student in the dept
    semester        TEXT
);

-- Problems:
--   - Multiple values in one cell (violates atomicity)
--   - No primary key
--   - Every column is text — no type safety

-- ─────────────────────────────────────────────────────────────
-- STEP 1: First Normal Form (1NF)
-- Rule: Every column must hold ONE atomic value. Each row unique.
-- ─────────────────────────────────────────────────────────────

CREATE TABLE student_courses_1nf (
    student_name    VARCHAR(200) NOT NULL,
    student_email   VARCHAR(200) NOT NULL,
    course_code     VARCHAR(20)  NOT NULL,   -- one course per row now
    course_title    VARCHAR(200) NOT NULL,
    lecturer_name   VARCHAR(200) NOT NULL,
    dept_name       VARCHAR(100) NOT NULL,
    dept_head       VARCHAR(200) NOT NULL,
    semester        VARCHAR(20)  NOT NULL,

    PRIMARY KEY (student_email, course_code, semester)  -- composite PK
);

-- Better — but we still have redundancy:
--   - student_name repeated for every course they take
--   - dept_head repeated for every student in the dept

-- ─────────────────────────────────────────────────────────────
-- STEP 2: Second Normal Form (2NF)
-- Rule: Remove partial dependencies — every non-key column must
--       depend on the WHOLE primary key, not just part of it.
-- ─────────────────────────────────────────────────────────────

-- course_title depends only on course_code, not on student_email.
-- Split it out.

CREATE TABLE courses_2nf (
    course_code   VARCHAR(20)  PRIMARY KEY,
    course_title  VARCHAR(200) NOT NULL,
    lecturer_name VARCHAR(200) NOT NULL,
    dept_name     VARCHAR(100) NOT NULL
);

CREATE TABLE enrollments_2nf (
    student_email VARCHAR(200) NOT NULL,
    student_name  VARCHAR(200) NOT NULL,
    course_code   VARCHAR(20)  NOT NULL REFERENCES courses_2nf(course_code),
    semester      VARCHAR(20)  NOT NULL,
    dept_name     VARCHAR(100) NOT NULL,  -- still repeated here — fix in 3NF
    dept_head     VARCHAR(200) NOT NULL,  -- transitively dependent on dept_name
    PRIMARY KEY (student_email, course_code, semester)
);

-- Better — but dept_head depends on dept_name, not on the student.
-- That's a transitive dependency.

-- ─────────────────────────────────────────────────────────────
-- STEP 3: Third Normal Form (3NF)
-- Rule: Remove transitive dependencies — non-key columns must
--       depend DIRECTLY on the primary key, nothing else.
-- ─────────────────────────────────────────────────────────────

CREATE TABLE departments_3nf (
    dept_name VARCHAR(100) PRIMARY KEY,
    dept_head VARCHAR(200) NOT NULL
);

CREATE TABLE courses_3nf (
    course_code VARCHAR(20)  PRIMARY KEY,
    course_title VARCHAR(200) NOT NULL,
    lecturer_name VARCHAR(200) NOT NULL,
    dept_name    VARCHAR(100) NOT NULL REFERENCES departments_3nf(dept_name)
);

CREATE TABLE students_3nf (
    email     VARCHAR(200) PRIMARY KEY,
    full_name VARCHAR(200) NOT NULL,
    dept_name VARCHAR(100) NOT NULL REFERENCES departments_3nf(dept_name)
);

CREATE TABLE enrollments_3nf (
    student_email VARCHAR(200) NOT NULL REFERENCES students_3nf(email),
    course_code   VARCHAR(20)  NOT NULL REFERENCES courses_3nf(course_code),
    semester      VARCHAR(20)  NOT NULL,
    grade         CHAR(2),
    PRIMARY KEY (student_email, course_code, semester)
);

-- ── Summary ───────────────────────────────────────────────────
-- 0NF: giant messy spreadsheet
-- 1NF: one value per cell, add a PK
-- 2NF: move columns that don't need the full PK to their own table
-- 3NF: move columns that depend on OTHER non-key columns out too

-- Result: 4 clean tables. Update Dr. Mensah's name once in
-- lecturers — it reflects everywhere. No stale data.

-- Real world note: most production schemas stop at 3NF.
-- BCNF / 4NF / 5NF exist but are rarely needed outside academia.
