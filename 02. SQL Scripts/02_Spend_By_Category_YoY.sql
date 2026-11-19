-- 02_Spend_By_Category_YoY.sql
-- Question : How did spend change by category from 2023 to 2024?
-- Note     : Conditional aggregation to pivot the years.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT s.Category,
       ROUND(SUM(CASE WHEN strftime('%Y', o.OrderDate) = '2023' THEN o.QtyReceived * UnitCost END) / 100000.0, 2) AS spend_2023_lakh,
       ROUND(SUM(CASE WHEN strftime('%Y', o.OrderDate) = '2024' THEN o.QtyReceived * UnitCost END) / 100000.0, 2) AS spend_2024_lakh,
       ROUND(100.0 * (SUM(CASE WHEN strftime('%Y', o.OrderDate) = '2024' THEN o.QtyReceived * UnitCost END)
                    / SUM(CASE WHEN strftime('%Y', o.OrderDate) = '2023' THEN o.QtyReceived * UnitCost END) - 1), 1) AS yoy_pct
FROM PurchaseOrders o
JOIN Suppliers s ON s.SupplierID = o.SupplierID
WHERE o.IsOpen = 0
GROUP BY s.Category
ORDER BY spend_2024_lakh DESC;
