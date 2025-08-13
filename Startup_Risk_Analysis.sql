SELECT *
FROM startup_risk;

#1. RISK SCORE SUMMARY STATS
SELECT 
    ROUND(MIN(Risk_Score),2) AS min_risk,
    ROUND(MAX(Risk_Score),2) AS max_risk,
    ROUND(AVG(Risk_Score),2) AS avg_risk,
    ROUND(STDDEV(Risk_Score),2) AS std_dev
FROM startup_risk;

#2. COUNT STARTUPS BY RISK CATEGORY
SELECT risk_category,
COUNT(*) AS total_startups
FROM startup_risk
GROUP BY risk_category
ORDER BY FIELD(risk_category, 
    'Very Low Risk', 'Low Risk', 'Medium Risk', 'High Risk', 'Very High Risk');
    
#3. TOP 10 RISKIEST STARTUPS
SELECT startup_name, 
industry, 
region, 
startup_age, 
Risk_Score AS risk_score, 
risk_category
FROM startup_risk
ORDER BY Risk_Score DESC
LIMIT 10;

#4. 5 INDUSTRIES WITH THE MOST RISK
SELECT industry,
ROUND(AVG(Risk_Score),2) AS avg_risk_score,
COUNT(*) AS startup_count
FROM startup_risk
GROUP BY industry
ORDER BY avg_risk_score DESC
LIMIT 5;

#5. 5 INDUSTRIES WITH THE LEAST RISK
SELECT industry,
ROUND(AVG(Risk_Score),2) AS avg_risk_score,
COUNT(*) AS startup_count
FROM startup_risk
GROUP BY industry
ORDER BY avg_risk_score ASC
LIMIT 5;

#6. REGIONS ORDERED BY RISK
SELECT region,
ROUND(AVG(Risk_Score),2) AS avg_risk_score,
COUNT(*) AS startup_count
FROM startup_risk
GROUP BY region
ORDER BY avg_risk_score DESC;

#7. PERCENTAGE OF STARTUPS IN EACH RISK CATEGORY PER REGION
SELECT region, 
risk_category,
COUNT(*) AS count_in_category,
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY region), 2) AS pct_in_category
FROM startup_risk
GROUP BY region, risk_category
ORDER BY region, risk_category;

#8. PERCENTAGE OF STARTUPS IN EACH REGION PER RISK CATEGORY
SELECT risk_category,
region,
COUNT(*) AS count_in_region,
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY risk_category), 2) AS pct_of_risk_category
FROM startup_risk
GROUP BY risk_category, region
ORDER BY risk_category, pct_of_risk_category DESC;

#9. COUNT AND PERCENTAGE OF HIGH-RISK STARTUPS
SELECT risk_category,
COUNT(*) AS count,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM startup_risk), 2) AS percentage
FROM startup_risk
WHERE risk_category IN ('High Risk', 'Very High Risk')
GROUP BY risk_category;

#10. COUNT OF STARTUPS PER RISK CATEGORY IN EACH INDUSTRY
SELECT industry
risk_category,
COUNT(*) AS count_per_category
FROM startup_risk
GROUP BY industry, risk_category
ORDER BY industry, risk_category;

#11. AVERAGE RISK SCORE BY STARTUP AGE GROUPS
SELECT
    CASE 
        WHEN startup_age BETWEEN 0 AND 1 THEN 'Early Stage'
        WHEN startup_age BETWEEN 2 AND 4 THEN 'Development Stage'
        WHEN startup_age BETWEEN 5 AND 8 THEN 'Expansion Stage'
        WHEN startup_age BETWEEN 9 AND 15 THEN 'Maturity Stage'
        ELSE 'Established Stage'
    END AS age_group,
    AVG(Risk_Score) AS avg_risk_score,
    COUNT(*) AS startup_count
FROM startup_risk
GROUP BY age_group
ORDER BY avg_risk_score DESC;

#12. AVERAGE RISK SCORE PER RISK CATEGORY
SELECT risk_category,
ROUND(AVG(Risk_Score), 2) AS avg_risk_score
FROM startup_risk
GROUP BY risk_category
ORDER BY avg_risk_score;

#13. DETECTING OUTLIERS
SELECT startup_name
industry,
employees,
profitable,
startup_age,
region,
Risk_Score,
risk_category
FROM startup_risk	
WHERE Risk_Score > (SELECT AVG(Risk_Score) + 2*STDDEV(Risk_Score) FROM startup_risk)
ORDER BY Risk_Score DESC;

#14. "SWEET SPOT" ANALYSIS
SELECT region,
COUNT(*) AS total_startups,
ROUND(AVG(Risk_Score), 3) AS avg_risk_score
FROM startup_risk
GROUP BY region
HAVING avg_risk_score < 0.7
ORDER BY total_startups DESC;
