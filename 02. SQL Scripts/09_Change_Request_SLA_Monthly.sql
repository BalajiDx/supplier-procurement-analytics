-- 09_Change_Request_SLA_Monthly.sql
-- Question : How many change requests missed the 24-hour decision target each month?
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT strftime('%Y-%m', SubmittedAt) AS month,
       COUNT(*) AS requests,
       SUM(DecidedWithin24h = 0) AS missed_24h,
       ROUND(100.0 * AVG(DecidedWithin24h), 1) AS within_24h_pct
FROM ChangeRequests
GROUP BY month ORDER BY month;
