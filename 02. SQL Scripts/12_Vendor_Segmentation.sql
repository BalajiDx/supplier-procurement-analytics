-- 12_Vendor_Segmentation.sql
-- Question : Which suppliers need attention when spend, delivery (OTIF) and requested cost increases are combined?
-- Note     : Review = OTIF below 75% or average requested increase above 6.5%. Strategic = top-10 spend and not Review.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH perf AS (
    SELECT SupplierID, SUM(QtyReceived * UnitCost) AS spend,
           100.0 * AVG(ReceivedDate <= PromisedDate AND QtyReceived >= QtyOrdered) AS otif
    FROM PurchaseOrders WHERE IsOpen = 0 GROUP BY SupplierID
), chg AS (
    SELECT SupplierID, AVG(ChangePct) AS avg_increase, COUNT(*) AS cost_requests
    FROM ChangeRequests WHERE ChangePct IS NOT NULL GROUP BY SupplierID
), j AS (
    SELECT p.*, c.avg_increase, c.cost_requests, RANK() OVER (ORDER BY p.spend DESC) AS spend_rank
    FROM perf p LEFT JOIN chg c ON c.SupplierID = p.SupplierID
)
SELECT s.SupplierName, j.spend_rank, ROUND(j.spend / 100000.0, 2) AS spend_lakh, ROUND(j.otif, 1) AS otif_pct,
       ROUND(j.avg_increase, 2) AS avg_requested_increase_pct, j.cost_requests,
       CASE WHEN j.otif < 75 OR j.avg_increase > 6.5 THEN 'Review'
            WHEN j.spend_rank <= 10 THEN 'Strategic' ELSE 'Maintain' END AS segment
FROM j JOIN Suppliers s ON s.SupplierID = j.SupplierID
ORDER BY CASE WHEN j.otif < 75 OR j.avg_increase > 6.5 THEN 0 ELSE 1 END, j.spend_rank;
