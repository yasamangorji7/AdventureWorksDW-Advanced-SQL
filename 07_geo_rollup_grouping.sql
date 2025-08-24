/* Geography rollups using ROLLUP/CUBE */
SELECT
    GROUPING_ID(st.SalesTerritoryGroup, st.SalesTerritoryCountry, st.SalesTerritoryRegion) AS GID,
    st.SalesTerritoryGroup,
    st.SalesTerritoryCountry,
    st.SalesTerritoryRegion,
    SUM(f.SalesAmount) AS Sales
FROM FactInternetSales f
JOIN DimSalesTerritory st ON st.SalesTerritoryKey = f.SalesTerritoryKey
GROUP BY CUBE(st.SalesTerritoryGroup, st.SalesTerritoryCountry, st.SalesTerritoryRegion)
ORDER BY GID, st.SalesTerritoryGroup, st.SalesTerritoryCountry, st.SalesTerritoryRegion;
