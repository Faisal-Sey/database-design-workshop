-- ============================================================
-- SQL vs NoSQL — Same Problem, Two Approaches
-- Problem: Store and query product catalogue for a Ghanaian
--          e-commerce site (think: local Jumia clone).
-- This file: PostgreSQL approach
-- ============================================================

-- ── Schema ────────────────────────────────────────────────────

CREATE TABLE categories (
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE  -- "Electronics", "Fashion", "Food"
);

CREATE TABLE products (
    id            SERIAL PRIMARY KEY,
    sku           VARCHAR(50)   NOT NULL UNIQUE,
    name          VARCHAR(300)  NOT NULL,
    description   TEXT,
    price_ghs     NUMERIC(10,2) NOT NULL CHECK (price_ghs >= 0),
    stock_qty     INT           NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    category_id   INT           NOT NULL REFERENCES categories(id),
    is_active     BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    -- PostgreSQL's JSONB column for flexible attributes
    -- e.g. {"color":"red","size":"XL"} for fashion
    --      {"brand":"Samsung","storage":"128GB"} for electronics
    attributes   JSONB
);

CREATE INDEX idx_products_category  ON products(category_id);
CREATE INDEX idx_products_active    ON products(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_products_attributes ON products USING GIN(attributes); -- JSON search

-- ── Sample data ───────────────────────────────────────────────

INSERT INTO categories (name) VALUES ('Electronics'), ('Fashion'), ('Food & Groceries');

INSERT INTO products (sku, name, price_ghs, stock_qty, category_id, attributes)
VALUES
    ('ELEC-001', 'Tecno Camon 20 Pro',    1299.00, 45, 1,
     '{"brand":"Tecno","storage":"256GB","color":"Dark","screen":"6.67in"}'),
    ('ELEC-002', 'Itel S23 Smartphone',    499.00, 120, 1,
     '{"brand":"Itel","storage":"64GB","color":"Black","screen":"6.6in"}'),
    ('FASH-001', 'Kente Print Dress',       85.00, 30, 2,
     '{"color":"multi","size":["S","M","L","XL"],"material":"cotton"}'),
    ('FOOD-001', 'Olam Vegetable Oil 5L',   62.50, 200, 3, NULL);

-- ── Queries ───────────────────────────────────────────────────

-- Find all electronics under GHS 1000
SELECT sku, name, price_ghs
FROM products
WHERE category_id = 1
  AND price_ghs < 1000
  AND is_active = TRUE
ORDER BY price_ghs ASC;

-- Find all products with storage >= 128GB (JSON query)
SELECT sku, name, price_ghs, attributes->>'storage' AS storage
FROM products
WHERE attributes->>'storage' IN ('128GB','256GB','512GB');

-- Full-text search on product name
SELECT sku, name, price_ghs
FROM products
WHERE to_tsvector('english', name) @@ plainto_tsquery('english', 'smartphone');

-- Inventory value by category
SELECT c.name AS category, SUM(p.price_ghs * p.stock_qty) AS inventory_value_ghs
FROM products p
JOIN categories c ON c.id = p.category_id
WHERE p.is_active = TRUE
GROUP BY c.name
ORDER BY inventory_value_ghs DESC;

-- ── When PostgreSQL wins here ─────────────────────────────────
-- ✓ Price range filters, aggregations, ORDER BY are fast and natural
-- ✓ JSONB gives you flexible attributes without a schema change
-- ✓ Transactions ensure stock_qty never goes negative under concurrent orders
-- ✓ Complex reporting queries are one SQL statement
