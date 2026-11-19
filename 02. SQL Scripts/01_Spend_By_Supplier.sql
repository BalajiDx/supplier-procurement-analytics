-- 01_Spend_By_Supplier.sql
-- Question : Which suppliers take the most spend (received value, 2023-2024), and what share of total?
-- Note     : Window function for the share of total.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT s.SupplierName, s.Category,
       COUNT(*) AS po_count,
       ROUND(SUM(o.QtyReceived * UnitCost) / 100000.0, 2) AS spend_lakh,
       ROUND(100.0 * SUM(o.QtyReceived * UnitCost) / SUM(SUM(o.QtyReceived * UnitCost)) OVER (), 2) AS spend_share_pct
FROM PurchaseOrders o
JOIN Suppliers s ON s.SupplierID = o.SupplierID
WHERE o.IsOpen = 0
GROUP BY s.SupplierID
ORDER BY spend_lakh DESC;
