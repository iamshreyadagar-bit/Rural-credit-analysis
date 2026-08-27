-- ============================================
-- SECTION 1: DATA VALIDATION
-- ==================================================
SELECT COUNT(*) AS TotalRows FROM CreditData;
SELECT COUNT(*) AS TotalRows FROM DepositsData;

SELECT TOP 10 * FROM CreditData;
SELECT TOP 10 * FROM DepositsData;

-- ---------------------------------------------------------------------------------------
-- SECTION 2: TOP/BOTTOM DISTRICTS BY UTILIZATION (2024)
-- ========================================================================================
-- Highest utilization: districts drawing near-full sanctioned credit

SELECT TOP 10 State, District, Credit_Utilization_Ratio
FROM CreditData
WHERE Year = '2024'
ORDER BY Credit_Utilization_Ratio DESC;

-- Lowest utilization: credit sanctioned but not drawn (accessibility gap candidates)
SELECT TOP 10 State, District, Credit_Utilization_Ratio, Credit_Limit_Cr
FROM CreditData
WHERE Year = '2024'
ORDER BY Credit_Utilization_Ratio ASC;

-- =================================================  -------------------------
-- SECTION 3: STATE-LEVEL AGGREGATION (GROUP BY)
-- =================================================  -------------------------
SELECT 
    State,
    AVG(Credit_Utilization_Ratio) AS Avg_Utilization,
    SUM(Credit_Limit_Cr) AS Total_Credit_Limit,
    SUM(Amount_Outstanding_Cr) AS Total_Outstanding,
    COUNT(*) AS Num_Districts
FROM CreditData
WHERE Year = '2024'
GROUP BY State
ORDER BY Avg_Utilization DESC;

-- ============================================ ------------------------------------
-- SECTION 4: YEAR-OVER-YEAR TREND PER DISTRICT
-- ============================================ ------------------------------------
SELECT State, District, Year, Credit_Utilization_Ratio
FROM CreditData
WHERE District = 'PUNE'   -- change to any district you want to inspect
ORDER BY Year;

-- ===================================================================
-- SECTION 5: GROWTH CALCULATION (2019 vs 2024) — SELF JOIN
-- ====================================================================
SELECT 
    c2024.State,
    c2024.District,
    c2019.Credit_Limit_Cr AS Limit_2019,
    c2024.Credit_Limit_Cr AS Limit_2024,
    ROUND(((c2024.Credit_Limit_Cr - c2019.Credit_Limit_Cr) / c2019.Credit_Limit_Cr) * 100, 2) AS Pct_Growth
FROM CreditData c2024
JOIN CreditData c2019 
    ON c2024.District = c2019.District AND c2024.State = c2019.State
WHERE c2024.Year = '2024' AND c2019.Year = '2019'
    AND c2019.Credit_Limit_Cr > 0
ORDER BY Pct_Growth DESC;

-- ============================================
-- SECTION 6: RANKING WITHIN EACH STATE (WINDOW FUNCTION)
-- ============================================
SELECT 
    State, District, Credit_Utilization_Ratio,
    RANK() OVER (PARTITION BY State ORDER BY Credit_Utilization_Ratio DESC) AS Rank_In_State
FROM CreditData
WHERE Year = '2024';

-- ============================================
-- SECTION 7: FLAGGING POLICY-RELEVANT DISTRICTS
-- ============================================
-- Districts with LOW utilization but HIGH sanctioned limits = untapped credit access gap
SELECT State, District, Credit_Limit_Cr, Credit_Utilization_Ratio
FROM CreditData
WHERE Year = '2024' 
    AND Credit_Utilization_Ratio < 0.6 
    AND Credit_Limit_Cr > (SELECT AVG(Credit_Limit_Cr) FROM CreditData WHERE Year = '2024')
ORDER BY Credit_Limit_Cr DESC;

-- ============================================
-- SECTION 8: DEPOSITS TABLE — HISTORICAL TREND (SEPARATE STORY)
-- ============================================
SELECT District, Year, Total_Deposits_Cr
FROM DepositsData
WHERE District = 'PUNE'
ORDER BY Year;

SELECT Year, SUM(Total_Deposits_Cr) AS AllIndia_Deposits
FROM DepositsData
GROUP BY Year
ORDER BY Year;

