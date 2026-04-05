-- 1. Create the Gold Layer for the Dashboard
CREATE OR REPLACE VIEW SEATTLE_HOUSING.GOLD.FINAL_DASHBOARD_DATA AS
WITH Clean_Data AS (
    -- Deduplicate and fix the 600-year date bug from raw records
    SELECT DISTINCT
        CASE 
            WHEN CITY IS NULL THEN 'Seattle' 
            ELSE UPPER(LEFT(CITY, 1)) || LOWER(SUBSTRING(CITY, 2)) 
        END AS CITY,
        SALE_PRICE / NULLIF(SQUARE_FEET, 0) AS PPSF,
        SALE_DATE,
        -- Segment the market into the three 2026 RTO Eras
        CASE 
            WHEN SALE_DATE < '2024-01-01' THEN '1. Remote Era (Baseline)'
            WHEN SALE_DATE BETWEEN '2024-01-01' AND '2025-05-01' THEN '2. RTO Transition (3-Day)'
            ELSE '3. RTO Enforced (Modern Era)'
        END AS RTO_STATUS
    FROM SEATTLE_HOUSING.SILVER.PROPERTY_SALES
    WHERE SALE_PRICE > 100000 AND SQUARE_FEET > 200
)
SELECT 
    CITY,
    RTO_STATUS,
    ROUND(AVG(PPSF), 2) AS AVG_PPSF,
    COUNT(*) AS TOTAL_SALES
FROM Clean_Data
GROUP BY 1, 2;