-- ============================================================
-- GOOD SCHEMA — University Course Registration System
-- Walk through each decision and explain WHY.
-- ============================================================

-- ── Departments ──────────────────────────────────────────────
CREATE TABLE departments (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,  -- "Computer Science", "Mathematics"
    code        CHAR(4)      NOT NULL UNIQUE   -- "DCIT", "MATH"
);

-- ── Lecturers ─────────────────────────────────────────────────
CREATE TABLE lecturers (
    id          SERIAL PRIMARY KEY,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(200) NOT NULL UNIQUE,
    department_id INT NOT NULL REFERENCES departments(id)
);

-- ── Courses ───────────────────────────────────────────────────
CREATE TABLE courses (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(10)  NOT NULL UNIQUE,  -- "DCIT 301"
    title       VARCHAR(200) NOT NULL,
    credits     SMALLINT     NOT NULL CHECK (credits BETWEEN 1 AND 6),
    department_id INT NOT NULL REFERENCES departments(id),
    lecturer_id   INT         REFERENCES lecturers(id)
);

-- ── Students ──────────────────────────────────────────────────
CREATE TABLE students (
    id            SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL UNIQUE,   -- "10987654"
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(200) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,           -- bcrypt/Argon2 hash, never plaintext
    gpa           NUMERIC(3,2) CHECK (gpa BETWEEN 0.00 AND 4.00),
    enrolled_at   DATE         NOT NULL DEFAULT CURRENT_DATE,
    department_id INT          NOT NULL REFERENCES departments(id)
);

-- ── Enrollments (many-to-many: students ↔ courses) ───────────
-- This is the junction / bridge table that replaces the comma-separated string.
CREATE TABLE enrollments (
    id          SERIAL PRIMARY KEY,
    student_id  INT  NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    course_id   INT  NOT NULL REFERENCES courses(id)  ON DELETE RESTRICT,
    semester    VARCHAR(20) NOT NULL,                  -- "2024/2025-SEM1"
    enrolled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    grade       CHAR(2) CHECK (grade IN ('A','B+','B','C+','C','D','F','I')),

    UNIQUE (student_id, course_id, semester)           -- no duplicate enrollments
);

-- ── Fees ──────────────────────────────────────────────────────
CREATE TABLE fee_payments (
    id          SERIAL PRIMARY KEY,
    student_id  INT          NOT NULL REFERENCES students(id),
    amount_ghs  NUMERIC(10,2) NOT NULL CHECK (amount_ghs > 0),
    paid_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    reference   VARCHAR(100) NOT NULL UNIQUE,          -- MoMo or bank transaction ID
    semester    VARCHAR(20)  NOT NULL
);

-- ── Useful indexes ────────────────────────────────────────────
-- (covered in detail in demos/02-indexing)
CREATE INDEX idx_enrollments_student   ON enrollments(student_id);
CREATE INDEX idx_enrollments_course    ON enrollments(course_id);
CREATE INDEX idx_students_department   ON students(department_id);
CREATE INDEX idx_fee_payments_student  ON fee_payments(student_id);

-- ── Sample queries that are now clean and fast ────────────────

-- All courses a student is taking this semester:
-- SELECT c.code, c.title, l.last_name AS lecturer
-- FROM enrollments e
-- JOIN courses  c ON c.id = e.course_id
-- JOIN lecturers l ON l.id = c.lecturer_id
-- WHERE e.student_id = 42 AND e.semester = '2024/2025-SEM1';

-- Count students per department:
-- SELECT d.name, COUNT(s.id) AS student_count
-- FROM departments d
-- LEFT JOIN students s ON s.department_id = d.id
-- GROUP BY d.name
-- ORDER BY student_count DESC;

-- Students who haven't paid fees this semester:
-- SELECT s.student_number, s.first_name, s.last_name
-- FROM students s
-- WHERE NOT EXISTS (
--     SELECT 1 FROM fee_payments fp
--     WHERE fp.student_id = s.id AND fp.semester = '2024/2025-SEM1'
-- );
