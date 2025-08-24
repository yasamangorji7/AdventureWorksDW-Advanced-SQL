/* Cohort: first purchase month vs active months after */
WITH FirstOrder AS (
  SELECT
      c.CustomerKey,
      MIN(DATEFROMPARTS(d.CalendarYear, d.MonthNumberOfYear, 1)) AS CohortMonth
  FROM FactInternetSales f
  JOIN DimCustomer c ON c.CustomerKey = f.CustomerKey
  JOIN DimDate d ON d.DateKey = f.OrderDateKey
  GROUP BY c.CustomerKey
),
Activity AS (
  SELECT
      c.CustomerKey,
      DATEFROMPARTS(d.CalendarYear, d.MonthNumberOfYear, 1) AS ActivityMonth
  FROM FactInternetSales f
  JOIN DimCustomer c ON c.CustomerKey = f.CustomerKey
  JOIN DimDate d ON d.DateKey = f.OrderDateKey
  GROUP BY c.CustomerKey, d.CalendarYear, d.MonthNumberOfYear
),
Joined AS (
  SELECT
      o.CohortMonth,
      a.ActivityMonth,
      DATEDIFF(MONTH, o.CohortMonth, a.ActivityMonth) AS MonthIndex
  FROM FirstOrder o
  JOIN Activity a ON a.CustomerKey = o.CustomerKey
)
SELECT
    CohortMonth,
    MonthIndex,
    COUNT(DISTINCT CASE WHEN MonthIndex = 0 THEN a.ActivityMonth END) AS Dummy -- placeholder
FROM Joined j
LEFT JOIN Activity a ON a.ActivityMonth = j.ActivityMonth
GROUP BY CohortMonth, MonthIndex
ORDER BY CohortMonth, MonthIndex;

/* ساده‌تر: نرخ ریتنشن ماهانه تا ۱۲ ماه */
WITH cohort_size AS (
  SELECT CohortMonth, COUNT(*) AS CohortCustomers
  FROM (
    SELECT DISTINCT c.CustomerKey,
           MIN(DATEFROMPARTS(d.CalendarYear, d.MonthNumberOfYear, 1)) OVER (PARTITION BY c.CustomerKey) AS CohortMonth
    FROM FactInternetSales f
    JOIN DimCustomer c ON c.CustomerKey = f.CustomerKey
    JOIN DimDate d ON d.DateKey = f.OrderDateKey
  ) t
  GROUP BY CohortMonth
),
active AS (
  SELECT
      MIN(DATEFROMPARTS(d.CalendarYear, d.MonthNumberOfYear, 1)) OVER (PARTITION BY c.CustomerKey) AS CohortMonth,
      DATEFROMPARTS(d.CalendarYear, d.MonthNumberOfYear, 1) AS ActivityMonth,
      c.CustomerKey
  FROM FactInternetSales f
  JOIN DimCustomer c ON c.CustomerKey = f.CustomerKey
  JOIN DimDate d ON d.DateKey = f.OrderDateKey
  GROUP BY c.CustomerKey, d.CalendarYear, d.MonthNumberOfYear
),
final AS (
  SELECT
      CohortMonth,
      DATEDIFF(MONTH, CohortMonth, ActivityMonth) AS MonthIndex,
      COUNT(DISTINCT CustomerKey) AS ActiveCustomers
  FROM active
  GROUP BY CohortMonth, ActivityMonth
)
SELECT
    f.CohortMonth,
    f.MonthIndex,
    CAST(f.ActiveCustomers * 1.0 / NULLIF(cs.CohortCustomers,0) AS DECIMAL(10,4)) AS RetentionRate
FROM final f
JOIN cohort_size cs ON cs.CohortMonth = f.CohortMonth
WHERE f.MonthIndex BETWEEN 0 AND 12
ORDER BY CohortMonth, MonthIndex;
