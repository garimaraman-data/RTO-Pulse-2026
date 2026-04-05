-- 2. Generate AI Market Summaries using Snowflake Cortex (Llama 3)
CREATE OR REPLACE TABLE SEATTLE_HOUSING.GOLD.MARKET_INSIGHTS AS
SELECT 
    CITY,
    RTO_STATUS,
    AVG_PPSF,
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3-70b',
        CONCAT('You are a real estate analyst in March 2026. Explain why the Price Per SqFt is $', 
               AVG_PPSF, ' in ', CITY, ' during the ', RTO_STATUS, 
               ' era. Keep it under 50 words.')
    ) AS AI_EXECUTIVE_SUMMARY
FROM SEATTLE_HOUSING.GOLD.FINAL_DASHBOARD_DATA;