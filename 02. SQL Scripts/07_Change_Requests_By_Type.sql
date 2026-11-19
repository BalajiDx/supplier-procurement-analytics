-- 07_Change_Requests_By_Type.sql
-- Question : How many supplier change requests came in by type, and how fast were they decided?
-- Note     : The service target is a decision within 24 hours of submission.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT ChangeType,
       COUNT(*) AS requests,
       ROUND(100.0 * AVG(Decision = 'Approved'), 1) AS approved_pct,
       ROUND(100.0 * AVG(Decision = 'Rejected'), 1) AS rejected_pct,
       ROUND(100.0 * AVG(DecidedWithin24h), 1) AS within_24h_pct,
       ROUND(AVG(HoursToDecision), 1) AS avg_hours
FROM ChangeRequests
GROUP BY ChangeType
ORDER BY requests DESC;
