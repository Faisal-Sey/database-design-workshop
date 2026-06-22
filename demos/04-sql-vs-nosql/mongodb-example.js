/**
 * SQL vs NoSQL — MongoDB approach for the same e-commerce catalogue.
 * Run in MongoDB Atlas free tier (M0 cluster) or mongosh.
 * Compare with postgres-example.sql to see the trade-offs.
 */

// ── Document shape ─────────────────────────────────────────────
// In MongoDB, each product is a self-contained document.
// No joins needed — related data is embedded.

const sampleProducts = [
  {
    sku: "ELEC-001",
    name: "Tecno Camon 20 Pro",
    description: "Latest Tecno flagship with 108MP camera",
    price_ghs: 1299.00,
    stock_qty: 45,
    category: "Electronics",          // denormalised — string, not a reference
    is_active: true,
    attributes: {                      // fully flexible, no schema needed
      brand: "Tecno",
      storage: "256GB",
      color: "Dark",
      screen: "6.67in",
      battery: "5000mAh",
      os: "Android 13"
    },
    tags: ["smartphone", "tecno", "4g"],
    created_at: new Date()
  },
  {
    sku: "FASH-001",
    name: "Kente Print Dress",
    price_ghs: 85.00,
    stock_qty: 30,
    category: "Fashion",
    is_active: true,
    attributes: {
      color: "multi",
      sizes_available: ["S", "M", "L", "XL"],  // arrays are native
      material: "cotton",
      region_of_origin: "Ashanti"
    },
    tags: ["kente", "traditional", "women"],
    created_at: new Date()
  }
];

// ── Insert ─────────────────────────────────────────────────────
db.products.insertMany(sampleProducts);

// ── Queries ────────────────────────────────────────────────────

// Find all electronics under GHS 1000
db.products.find(
  { category: "Electronics", price_ghs: { $lt: 1000 }, is_active: true },
  { sku: 1, name: 1, price_ghs: 1 }           // projection = SELECT columns
).sort({ price_ghs: 1 });

// Find products with storage 256GB
db.products.find({ "attributes.storage": "256GB" });

// Full-text search (requires a text index)
db.products.createIndex({ name: "text", description: "text" });
db.products.find({ $text: { $search: "smartphone" } });

// Inventory value per category (aggregation pipeline)
db.products.aggregate([
  { $match: { is_active: true } },
  { $group: {
      _id: "$category",
      inventory_value: { $sum: { $multiply: ["$price_ghs", "$stock_qty"] } }
  }},
  { $sort: { inventory_value: -1 } }
]);

// Update stock (atomic — safe for single document)
db.products.updateOne(
  { sku: "ELEC-001" },
  { $inc: { stock_qty: -1 } }                  // decrement by 1
);

// ── Index ──────────────────────────────────────────────────────
db.products.createIndex({ category: 1, price_ghs: 1 });
db.products.createIndex({ "attributes.storage": 1 });
db.products.createIndex({ is_active: 1 });

// ── When MongoDB wins here ─────────────────────────────────────
// ✓ attributes can change per product type — no ALTER TABLE needed
// ✓ Embedding arrays (sizes_available) is natural
// ✓ Horizontal scaling across servers is built-in
// ✓ Developer iteration speed: add new fields without migration
//
// ── Where PostgreSQL wins ─────────────────────────────────────
// ✗ "Total revenue across all orders for customer X" requires
//   the application to join across documents — expensive in app code
// ✗ No multi-document ACID transactions by default
//   (available since v4.0 but complex to use correctly)
// ✗ Aggregation pipeline syntax is verbose vs SQL for reporting
// ✗ Schema flexibility becomes a liability at scale —
//   you get inconsistent documents that break the app
//
// ── The honest take ───────────────────────────────────────────
// For a product catalogue alone: either works fine.
// For the WHOLE e-commerce system (orders, payments, users, inventory):
// PostgreSQL wins because consistency and joins matter everywhere.
// Use MongoDB when the document model is genuinely a better fit,
// not just because it feels faster to get started.
