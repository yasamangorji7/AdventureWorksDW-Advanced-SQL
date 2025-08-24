# AdventureWorksDW2022 – Advanced SQL Queries

این ریپو شامل مجموعه‌ای از کوئری‌های پیشرفته روی دیتابیس نمونه‌ی **AdventureWorksDW2022** (SQL Server) است: Window Functions، RFM، Basket Analysis، Cohort، ROLLUP/CUBE و GROUPING SETS.

## راه‌اندازی
1) دیتابیس را ریستور کنید (SSMS > Restore Database) یا از فایل `.bak` خودتان استفاده کنید.
2) هر فایل داخل پوشه `queries/` را در برابر دیتابیس اجرا کنید.

> نکته: جداول اصلی مورد استفاده: `FactInternetSales`, `FactResellerSales`, `DimDate`, `DimCustomer`, `DimProduct`, `DimSalesTerritory`.

## محتوا
- `01_monthly_sales_yoy_ytd.sql` – فروش ماهانه + YoY + YTD
- `02_top_customers_clv_rank.sql` – مشتریان برتر، رتبه و سهم تجمعی
- `03_rfm_scoring.sql` – امتیازدهی RFM با NTILE
- `04_market_basket_pairs.sql` – تحلیل هم‌خریدی و Confidence
- `05_cohort_retention.sql` – کوهورت ریتنشن تا ۱۲ ماه
- `06_product_abc_revenue.sql` – ABC مبتنی بر سهم درآمد
- `07_geo_rollup_grouping.sql` – ROLLUP/CUBE جغرافیا
- `08_channel_mix_grouping_sets.sql` – ترکیب کانال فروش

## لایسنس
MIT
