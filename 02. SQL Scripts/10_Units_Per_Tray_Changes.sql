-- 10_Units_Per_Tray_Changes.sql
-- Question : Which approved units-per-tray updates change how many units a store receives per tray, and in which direction?
-- Note     : Only approved requests. A smaller tray means more trays to handle for the same units.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT p.Category,
       COUNT(*) AS approved_tray_updates,
       SUM(c.NewValue > c.OldValue) AS tray_size_up,
       SUM(c.NewValue < c.OldValue) AS tray_size_down,
       ROUND(AVG(c.NewValue - c.OldValue), 1) AS avg_units_change
FROM ChangeRequests c
JOIN Products p ON p.SKU = c.SKU
WHERE c.ChangeType = 'Units per Tray Update' AND c.Decision = 'Approved'
GROUP BY p.Category
ORDER BY approved_tray_updates DESC;
