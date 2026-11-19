-- 13_Open_POs_At_Cutoff.sql
-- Question : Which purchase orders were still not received at 31 Dec 2024, and how overdue are they?
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT s.SupplierName, COUNT(*) AS open_pos,
       SUM(o.PromisedDate < '2024-12-31') AS past_promised_date,
       ROUND(SUM(o.QtyOrdered * o.UnitCost) / 100000.0, 2) AS open_value_lakh,
       MIN(o.PromisedDate) AS oldest_promised_date
FROM PurchaseOrders o
JOIN Suppliers s ON s.SupplierID = o.SupplierID
WHERE o.IsOpen = 1
GROUP BY s.SupplierID
ORDER BY past_promised_date DESC, open_value_lakh DESC;
