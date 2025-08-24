/* ABC classification by revenue contribution */
WITH prod_rev AS (
  SELECT
      p.ProductKey,
      p.EnglishProductName AS ProductName,
      SUM(f.SalesAmount) AS Revenue
  FROM FactInternetSales f
  JOIN DimProduct p ON p.ProductKey = f.ProductKey
  GROUP BY p.ProductKey, p.EnglishProductName
),
ranked AS (
  SELECT
      *,
      SUM(Revenue) OVER () AS TotalRev,
      SUM(Revenue) OVER (ORDER BY Revenue DESC
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumRev
  FROM prod_rev
),
final AS (
  SELECT
      ProductKey, ProductName, Revenue,
      CAST(CumRev * 1.0 / NULLIF(TotalRev,0) AS DECIMAL(10,4)) AS CumShare
  FROM ranked
)
SELECT
    *,
    CASE
      WHEN CumShare <= 0.80 THEN 'A'
      WHEN CumShare <= 0.95 THEN 'B'
      ELSE 'C'
    END AS ABC_Class
FROM final
ORDER BY Revenue DESC;
