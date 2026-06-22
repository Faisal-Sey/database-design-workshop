-- ============================================================
-- BAD SCHEMA — University Course Registration System
-- Show this first. Ask students: "What problems do you see?"
-- ============================================================

-- Everything crammed into one table.
-- A real student project submitted in a GH university capstone.
CREATE TABLE students (
    id          INT,
    fullname    VARCHAR(200),         -- first + last mixed together
    email       VARCHAR(200),
    password    VARCHAR(200),         -- plain text! never do this
    courses     TEXT,                 -- "CS101, CS201, MATH101" stored as a string
    lecturer    TEXT,                 -- "Dr. Mensah, Prof. Agyei" — same problem
    fees_paid   VARCHAR(10),          -- "yes" or "no" stored as a string
    gpa         TEXT,                 -- should be NUMERIC
    reg_date    VARCHAR(50)           -- "June 2024" — not a real date
);

-- Problems to surface with the audience:
--
-- 1. No primary key — duplicates are impossible to detect or remove.
--
-- 2. Comma-separated courses — you can NEVER query "all students in CS101"
--    without LIKE '%CS101%', which is slow, fragile, and breaks if course
--    codes contain commas.
--
-- 3. Passwords in plain text — a data breach exposes every account.
--
-- 4. fees_paid as "yes"/"no" string — should be a BOOLEAN.
--    What happens when someone types "Yes" or "YES"?
--
-- 5. gpa as TEXT — you cannot do AVG(gpa), ORDER BY gpa DESC, or
--    enforce that it stays between 0.0 and 4.0.
--
-- 6. reg_date as a human-readable string — you cannot sort by date,
--    calculate semesters, or do date arithmetic.
--
-- 7. No foreign keys — nothing enforces that a course actually exists.
--    Students can register for "MADE_UP_999" and the DB won't complain.
--
-- 8. No normalization — if Dr. Mensah changes his title, you update
--    every row that mentions him. Miss one → inconsistent data forever.
