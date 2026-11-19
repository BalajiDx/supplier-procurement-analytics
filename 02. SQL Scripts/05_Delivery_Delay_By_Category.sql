-- 05_Delivery_Delay_By_Category.sql
-- Question : Which categories deliver late most often, and by how many days?
-- Note     : julianday() for date differences.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT s.Category,
       COUNT(*) AS delivered_pos,
       ROUND(100.0 * AVG(o.ReceivedDate > o.PromisedDate), 1) AS late_pct,
       ROUND(AVG(CASE WHEN o.ReceivedDate > o.PromisedDate
                      THEN julianday(o.ReceivedDate) - julianday(o.PromisedDate) END), 1) AS avg_days_late_when_late,
       ROUND(AVG(julianday(o.ReceivedDate) - julianday(o.OrderDate)), 1) AS avg_actual_lead_days
FROM PurchaseOrders o
JOIN Suppliers s ON s.SupplierID = o.SupplierID
WHERE o.IsOpen = 0
GROUP BY s.Category
ORDER BY late_pct DESC;
