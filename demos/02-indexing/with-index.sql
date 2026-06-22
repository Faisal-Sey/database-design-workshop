-- ============================================================
-- INDEXING DEMO — Part 2: With Index
-- Run AFTER without-index.sql. Compare EXPLAIN ANALYZE output.
-- ============================================================

-- Add the index on the column we search by most
CREATE INDEX idx_momo_sender_phone ON momo_transactions(sender_phone);

-- Run the exact same query
EXPLAIN ANALYZE
SELECT id, receiver_phone, amount_ghs, created_at
FROM momo_transactions
WHERE sender_phone = '0241234567';

-- What to point out now:
--   Index Scan using idx_momo_sender_phone ...
--   ^^^^^^^^^^^
--   PostgreSQL jumped straight to matching rows — no full table scan.
--   Cost drops dramatically. At 50M rows the difference is seconds → milliseconds.

-- ── Composite index: when you filter by two columns ──────────
-- Common query: "show me all completed transactions from this number"
CREATE INDEX idx_momo_sender_status ON momo_transactions(sender_phone, status);

EXPLAIN ANALYZE
SELECT id, amount_ghs, created_at
FROM momo_transactions
WHERE sender_phone = '0241234567'
  AND status = 'completed';

-- ── Covering index: include extra columns to avoid a heap fetch ─
-- If you ALWAYS select (receiver_phone, amount_ghs) with this filter,
-- include them in the index so Postgres never has to touch the main table.
CREATE INDEX idx_momo_sender_covering
    ON momo_transactions(sender_phone)
    INCLUDE (receiver_phone, amount_ghs, created_at);

-- ── When NOT to add an index ──────────────────────────────────
-- The 'status' column alone has only 3 distinct values.
-- An index on a low-cardinality column is useless — Postgres will
-- ignore it and do a seq scan anyway.

-- BAD index (low cardinality):
-- CREATE INDEX idx_momo_status ON momo_transactions(status);

-- ── Index cost: check table size with and without ─────────────
SELECT
    pg_size_pretty(pg_total_relation_size('momo_transactions')) AS total_size,
    pg_size_pretty(pg_indexes_size('momo_transactions'))        AS index_size;

-- Every index you add:
--   ✓ speeds up SELECT / WHERE / JOIN on those columns
--   ✗ slows down INSERT / UPDATE / DELETE (index must be maintained)
--   ✗ uses disk space
-- Rule of thumb: index what you query, not everything.
