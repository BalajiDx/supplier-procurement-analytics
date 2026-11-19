-- 08_Cost_Change_Bands.sql
-- Question : How big are the requested cost changes, and does the size affect approval and speed?
-- Note     : CASE bands on ChangePct (cost and equipment price requests only).
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH b AS (
    SELECT *, CASE WHEN ChangePct < 0 THEN '1. Decrease'
                   WHEN ChangePct < 3 THEN '2. 0-3%'
                   WHEN ChangePct < 6 THEN '3. 3-6%'
                   WHEN ChangePct < 10 THEN '4. 6-10%'
                   ELSE '5. 10%+' END AS band
    FROM ChangeRequests WHERE ChangePct IS NOT NULL
)
SELECT band, COUNT(*) AS requests,
       ROUND(100.0 * AVG(Decision = 'Rejected'), 1) AS rejected_pct,
       ROUND(100.0 * AVG(DecidedWithin24h), 1) AS within_24h_pct,
       ROUND(AVG(HoursToDecision), 1) AS avg_hours
FROM b GROUP BY band ORDER BY band;
