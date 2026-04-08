/******************************************************************
 * RTO PULSE 2026: GENERATIVE AI ENRICHMENT
 * Goal: Use LLMs to generate qualitative sentiment analysis
 ******************************************************************/

-- Generating the AI Executive Summaries using Llama 3
CREATE OR REPLACE TABLE SEATTLE_HOUSING.GOLD.AI_MARKET_INSIGHTS AS
SELECT 
    CITY,
    RTO_STATUS,
    AVG_PPSF,
    TOTAL_SALES,
    -- Snowflake Cortex LLM Inference
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3-70b',
        CONCAT('You are a 2026 Real Estate Analyst. In ', CITY, 
               ' during the ', RTO_STATUS, ' phase, the avg price per sqft is $', 
               AVG_PPSF, '. Explain the impact of RTO mandates in 40 words.')
    ) AS AI_EXECUTIVE_SUMMARY
FROM SEATTLE_HOUSING.GOLD.FINAL_DASHBOARD_DATA;