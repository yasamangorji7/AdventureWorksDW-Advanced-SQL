/* RFM scoring for Internet customers */
DECLARE @asof DATE = (SELECT MAX(FullDateAlternateKey) FROM DimDate);

WITH ords AS (
  SELECT
      c.CustomerKey,
      COUNT(DISTINCT f.SalesOrderNumber) AS Orders,
      SUM(f.SalesAmount) AS Revenue,
      MAX(d.FullDateAlternateKey) AS LastOrderDate
  FROM FactInternetSales f
  JOIN DimCustomer c ON c.CustomerKey = f.CustomerKey
  JOIN DimDate d ON d.DateKey = f.OrderDateKey
  GROUP BY c.CustomerKey
),
rfm AS (
  SELECT
      *,
      DATEDIFF(DAY, LastOrderDate, @asof) AS RecencyDays
  FROM ords
),
scored AS (
  SELECT
      CustomerKey,
      Orders,
      Revenue,
      RecencyDays,
      NTILE(5) OVER (ORDER BY RecencyDays ASC) AS R_Score,   -- کمتر بهتر
      NTILE(5) OVER (ORDER BY Orders DESC)      AS F_Score,
      NTILE(5) OVER (ORDER BY Revenue DESC)     AS M_Score
  FROM rfm
)
SELECT *,
       (R_Score + F_Score + M_Score) AS RFM_Total
FROM scored
ORDER BY RFM_Total DESC;
