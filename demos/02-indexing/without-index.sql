-- ============================================================
-- INDEXING DEMO — Part 1: No Index
-- Paste into DB Fiddle (PostgreSQL 15) and run.
-- Show students the EXPLAIN ANALYZE output — look at "Seq Scan".
-- ============================================================

-- Seed a realistic-sized table of mobile money transactions
CREATE TABLE momo_transactions (
    id              SERIAL PRIMARY KEY,
    sender_phone    VARCHAR(15) NOT NULL,
    receiver_phone  VARCHAR(15) NOT NULL,
    amount_ghs      NUMERIC(10,2) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'completed',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert 50,000 rows to make the scan noticeable
INSERT INTO momo_transactions (sender_phone, receiver_phone, amount_ghs, status, created_at)
SELECT
    '02' || LPAD((random() * 99999999)::INT::TEXT, 8, '0'),
    '05' || LPAD((random() * 99999999)::INT::TEXT, 8, '0'),
    (random() * 999 + 1)::NUMERIC(10,2),
    (ARRAY['completed','pending','failed'])[floor(random()*3+1)],
    NOW() - (random() * INTERVAL '365 days')
FROM generate_series(1, 50000);

-- ── Query: find all transactions from a specific phone number ─
EXPLAIN ANALYZE
SELECT id, receiver_phone, amount_ghs, created_at
FROM momo_transactions
WHERE sender_phone = '0241234567';

-- What to point out in the output:
--   Seq Scan on momo_transactions  (cost=0.00..1234.56 ...)
--                ^^^^^^^^
--   PostgreSQL read EVERY row to find matches.
--   At 50k rows this is fast. At 50 million rows (MTN's actual volume)?
--   This query would take seconds. Users would see a spinner.
