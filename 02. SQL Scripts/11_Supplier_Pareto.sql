-- 11_Supplier_Pareto.sql
-- Question : How many suppliers make up 80% of spend (Pareto / ABC)?
-- Note     : Running total with a window function, then ABC class.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH s AS (
    SELECT SupplierID, SUM(QtyReceived * UnitCost) AS spend FROM PurchaseOrders WHERE IsOpen = 0 GROUP BY SupplierID
), r AS (
    SELECT SupplierID, spend,
           100.0 * SUM(spend) OVER (ORDER BY spend DESC ROWS UNBOUNDED PRECEDING) / SUM(spend) OVER () AS cum_pct,
           ROW_NUMBER() OVER (ORDER BY spend DESC) AS rnk
    FROM s
)
SELECT rnk, sp.SupplierName, ROUND(spend / 100000.0, 2) AS spend_lakh, ROUND(cum_pct, 1) AS cumulative_pct,
       CASE WHEN cum_pct - 100.0 * spend / (SELECT SUM(spend) FROM s) < 80 THEN 'A'
            WHEN cum_pct - 100.0 * spend / (SELECT SUM(spend) FROM s) < 95 THEN 'B' ELSE 'C' END AS abc_class
FROM r JOIN Suppliers sp ON sp.SupplierID = r.SupplierID
ORDER BY rnk;
