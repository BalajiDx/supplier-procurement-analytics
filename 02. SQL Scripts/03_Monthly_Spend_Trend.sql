-- 03_Monthly_Spend_Trend.sql
-- Question : What is the monthly spend trend, with a 3-month moving average?
-- Note     : Window frame ROWS BETWEEN 2 PRECEDING AND CURRENT ROW.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH m AS (
    SELECT strftime('%Y-%m', OrderDate) AS month, SUM(QtyReceived * UnitCost) AS spend
    FROM PurchaseOrders WHERE IsOpen = 0
    GROUP BY month
)
SELECT month,
       ROUND(spend / 100000.0, 2) AS spend_lakh,
       ROUND(AVG(spend) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) / 100000.0, 2) AS moving_avg_3m_lakh
FROM m ORDER BY month;
