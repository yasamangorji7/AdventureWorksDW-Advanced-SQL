/* Channel mix: Internet vs Reseller with GROUPING SETS */
WITH internet AS (
  SELECT d.CalendarYear AS Year, SUM(f.SalesAmount) AS Sales, 'Internet' AS Channel
  FROM FactInternetSales f
  JOIN DimDate d ON d.DateKey = f.OrderDateKey
  GROUP BY d.CalendarYear
),
reseller AS (
  SELECT d.CalendarYear AS Year, SUM(f.SalesAmount) AS Sales, 'Reseller' AS Channel
  FROM FactResellerSales f
  JOIN DimDate d ON d.DateKey = f.OrderDateKey
  GROUP BY d.CalendarYear
),
u AS (
  SELECT * FROM internet
  UNION ALL
  SELECT * FROM reseller
)
SELECT
   Year, Channel,
   SUM(Sales) AS Sales
FROM u
GROUP BY GROUPING SETS ((Year, Channel), (Year), ())
ORDER BY Year, Channel;
