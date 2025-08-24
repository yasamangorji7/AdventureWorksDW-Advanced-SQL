/* Product pair co-occurrence within the same order; support & confidence */
WITH lines AS (
  SELECT SalesOrderNumber, ProductKey
  FROM FactInternetSales
  GROUP BY SalesOrderNumber, ProductKey
),
pairs AS (
  SELECT
      l1.ProductKey AS P1,
      l2.ProductKey AS P2,
      COUNT(*) AS PairCount
  FROM lines l1
  JOIN lines l2
    ON l1.SalesOrderNumber = l2.SalesOrderNumber
   AND l1.ProductKey < l2.ProductKey      -- جلوگیری از تکرار و خود-جفت
  GROUP BY l1.ProductKey, l2.ProductKey
),
base AS (
  SELECT ProductKey, COUNT(*) AS OrdersWithProduct
  FROM lines
  GROUP BY ProductKey
),
calc AS (
  SELECT
      p.P1, p.P2, p.PairCount,
      b1.OrdersWithProduct AS BaseP1,
      b2.OrdersWithProduct AS BaseP2
  FROM pairs p
  JOIN base b1 ON b1.ProductKey = p.P1
  JOIN base b2 ON b2.ProductKey = p.P2
)
SELECT
    p1.EnglishProductName AS ProductA,
    p2.EnglishProductName AS ProductB,
    PairCount,
    CAST(PairCount * 1.0 / NULLIF(BaseP1,0) AS DECIMAL(10,4)) AS Confidence_A_to_B,
    CAST(PairCount * 1.0 / NULLIF(BaseP2,0) AS DECIMAL(10,4)) AS Confidence_B_to_A
FROM calc c
JOIN DimProduct p1 ON p1.ProductKey = c.P1
JOIN DimProduct p2 ON p2.ProductKey = c.P2
WHERE PairCount >= 10       -- حداقل فراوانی برای معناداری
ORDER BY PairCount DESC, Confidence_A_to_B DESC
OFFSET 0 ROWS FETCH NEXT 50 ROWS ONLY;
