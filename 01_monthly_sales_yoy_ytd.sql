/* Monthly Sales with YoY and YTD for Internet channel */
WITH s AS (
  SELECT
      d.CalendarYear,
      d.MonthNumberOfYear AS MonthNo,
      DATEFROMPARTS(d.CalendarYear, d.MonthNumberOfYear, 1) AS MonthStart,
      SUM(f.SalesAmount) AS Sales
  FROM FactInternetSales f
  JOIN DimDate d ON d.DateKey = f.OrderDateKey
  GROUP BY d.CalendarYear, d.MonthNumberOfYear
),
enh AS (
  SELECT
      CalendarYear,
      MonthNo,
      MonthStart,
      Sales,
      LAG(Sales, 12) OVER (ORDER BY MonthStart) AS Sales_PrevYear,
      SUM(Sales) OVER (PARTITION BY CalendarYear ORDER BY MonthStart
                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS YTD
  FROM s
)
SELECT
    CalendarYear,
    MonthNo,
    MonthStart,
    Sales,
    Sales_PrevYear,
    CASE WHEN Sales_PrevYear IS NULL OR Sales_PrevYear=0 THEN NULL
         ELSE (Sales - Sales_PrevYear) * 1.0 / Sales_PrevYear END AS YoY_GrowthPct,
    YTD
FROM enh
ORDER BY MonthStart;

