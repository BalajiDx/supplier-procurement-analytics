-- 04_Supplier_OTIF_Scorecard.sql
-- Question : How does each supplier score on On-Time, In-Full (OTIF) and rejected quantity?
-- Note     : On time = received on or before the promised date. In full = received quantity >= ordered quantity.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT s.SupplierName,
       COUNT(*) AS delivered_pos,
       ROUND(100.0 * AVG(o.ReceivedDate <= o.PromisedDate), 1) AS on_time_pct,
       ROUND(100.0 * AVG(o.QtyReceived >= o.QtyOrdered), 1) AS in_full_pct,
       ROUND(100.0 * AVG(o.ReceivedDate <= o.PromisedDate AND o.QtyReceived >= o.QtyOrdered), 1) AS otif_pct,
       ROUND(100.0 * SUM(o.QtyRejected) / SUM(o.QtyReceived), 2) AS reject_pct
FROM PurchaseOrders o
JOIN Suppliers s ON s.SupplierID = o.SupplierID
WHERE o.IsOpen = 0
GROUP BY s.SupplierID
ORDER BY otif_pct ASC;
