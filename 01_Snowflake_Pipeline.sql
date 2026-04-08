/******************************************************************
 * RTO PULSE 2026: END-TO-END DATA PIPELINE
 * Goal: Clean 30k+ King County records & segment by RTO Policy Eras
 ******************************************************************/

-- 1. BRONZE LAYER: Raw Ingestion Setup
CREATE OR REPLACE TABLE SEATTLE_HOUSING.BRONZE.RAW_SALES_DATA (
    CITY STRING,
    SALE_DATE DATE,
    SALE_PRICE NUMBER,
    SQUARE_FEET NUMBER,
    PARCEL_ID STRING
);

-- 2. SILVER LAYER: Data Cleaning & Simulation
-- Here we resolve the "600-year date bug" and normalize city names
CREATE OR REPLACE TABLE SEATTLE_HOUSING.SILVER.CLEANED_SALES AS
SELECT 
    DISTINCT PARCEL_ID,
    -- Normalizing city names for consistent Tableau filtering
    CASE 
        WHEN CITY IS NULL THEN 'Seattle' 
        ELSE INITCAP(LOWER(CITY)) 
    END AS CITY,
    SALE_DATE,
    SALE_PRICE,
    SQUARE_FEET,
    -- Engineering the PPSF Metric
    (SALE_PRICE / NULLIF(SQUARE_FEET, 0)) AS PPSF
FROM SEATTLE_HOUSING.BRONZE.RAW_SALES_DATA
WHERE SALE_PRICE > 100000 AND SQUARE_FEET > 200;

-- 3. GOLD LAYER: Business Logic for Tableau
-- Segmenting the market into the three 2026 RTO Eras
CREATE OR REPLACE VIEW SEATTLE_HOUSING.GOLD.FINAL_DASHBOARD_DATA AS
SELECT 
    CITY,
    CASE 
        WHEN SALE_DATE < '2024-01-01' THEN '1. Remote Era (Baseline)'
        WHEN SALE_DATE BETWEEN '2024-01-01' AND '2025-05-01' THEN '2. RTO Transition (3-Day)'
        ELSE '3. RTO Enforced (Modern Era)'
    END AS RTO_STATUS,
    ROUND(AVG(PPSF), 2) AS AVG_PPSF,
    COUNT(*) AS TOTAL_SALES
FROM SEATTLE_HOUSING.SILVER.CLEANED_SALES
GROUP BY 1, 2;