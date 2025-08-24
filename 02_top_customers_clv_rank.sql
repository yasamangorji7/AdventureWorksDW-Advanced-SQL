/* Top customers by lifetime value (CLV) + rank & cumulative share */
WITH clv AS (
  SELECT
      c.CustomerKey,
      ISNULL(c.FirstName,'') + ' ' + ISNULL(c.LastName,'') AS CustomerName,
      SUM(f.SalesAmount) AS TotalSales
  FROM FactInternetSales f
  JOIN DimCustomer c ON c.CustomerKey = f.CustomerKey
  GROUP BY c.CustomerKey, c.FirstName, c.LastName
),
r AS (
  SELECT
      *,
      RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank,
      SUM(TotalSales) OVER () AS AllSales,
      SUM(TotalSales) OVER (ORDER BY TotalSales DESC
                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumSales
  FROM clv
)
SELECT
    CustomerKey, CustomerName, TotalSales,
    SalesRank,
    CumSales,
    CASE WHEN AllSales=0 THEN NULL ELSE CumSales * 1.0 / AllSales END AS CumShare
FROM r
ORDER BY SalesRank
OFFSET 0 ROWS FETCH NEXT 50 ROWS ONLY; -- Top 50
