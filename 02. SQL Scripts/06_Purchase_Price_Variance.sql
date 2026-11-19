-- 06_Purchase_Price_Variance.sql
-- Question : How far above the contract cost were POs priced, by category and year (purchase price variance)?
-- Note     : PPV = (PO unit cost - contract cost) x quantity received. Positive = paid more than contract.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT p.Category, strftime('%Y', o.OrderDate) AS year,
       ROUND(100.0 * (SUM(o.UnitCost * o.QtyReceived) / SUM(p.ContractCost * o.QtyReceived) - 1), 2) AS price_vs_contract_pct,
       ROUND(SUM((o.UnitCost - p.ContractCost) * o.QtyReceived) / 100000.0, 2) AS ppv_lakh
FROM PurchaseOrders o
JOIN Products p ON p.SKU = o.SKU
WHERE o.IsOpen = 0
GROUP BY p.Category, year
ORDER BY p.Category, year;
