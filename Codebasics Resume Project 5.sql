CREATE DATABASE codebasics_challange5;

USE codebasics_challange5;
CREATE TABLE domestic_visitors(
district VARCHAR(100),
`date` VARCHAR(20),
month_name VARCHAR(30),
year INT,
visitors int
);    

DROP TABLE domestic_visitors;

LOAD DATA INFILE
"C:/DV.csv"
into TABLE domestic_visitors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
lines TERMINATED BY '\n'
IGNORE 1 ROWS;


SELECT * FROM domestic_visitors;

UPDATE domestic_visitors
SET `date` = str_to_date(`date`,"%d/%m/%Y");

SELECT * FROM domestic_visitors;

UPDATE domestic_visitors
SET `date` = DATE_FORMAT(`date`,"%d-%m-%Y");

CREATE TABLE Foreign_visitors(
district VARCHAR(100),
`date` VARCHAR(20),
month_name VARCHAR(30),
year INT,
visitors int
);

SELECT * FROM Foreign_visitors;
LOAD DATA INFILE
"C:/Foreign_visitors.csv"
into TABLE Foreign_visitors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
lines TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM Foreign_visitors;
SELECT * FROM domestic_visitors;


UPDATE Foreign_visitors
SET `date` = str_to_date(`date`,"%d/%m/%Y");


UPDATE Foreign_visitors
SET `date` = DATE_FORMAT(`date`,"%d-%m-%Y");


-- Preliminary Research Questions

-- List the top 10 districts that have the highest number of domestic visitors overall (2016-2019)

SELECT district,ROUND(SUM(visitors)/1000000,0) visitors_in_million
FROM domestic_visitors
GROUP BY district
ORDER BY SUM(visitors) DESC
LIMIT 10;

-- List down the top 3 districts based on the Compounded Annual Growth Rate(CAGR) of visitors between (2016-2019)

-- Top 5

WITH cte_table AS
(SELECT D.district,D.`date`,D.month_name,D.year,D.visitors AS domestic_visitors,F.visitors AS Foreign_visitors,SUM(D.visitors+F.visitors) AS total_visitors
FROM domestic_visitors D
INNER JOIN foreign_visitors F
ON D.`date` = F.`date` AND D.district = F.district
GROUP BY D.district,D.`date`)
, cte_table1 AS
(SELECT district,
SUM(CASE WHEN `year` = (SELECT MIN(`year`) FROM cte_table) THEN total_visitors ELSE 0 END) AS starting_value
,SUM(CASE WHEN `year` = (SELECT MAX(`year`) FROM cte_table) THEN total_visitors ELSE 0 END) AS ending_value
FROM cte_table
GROUP BY district)
SELECT district, ROUND((POWER(ending_value/starting_value,(1/3))-1)*100,2) AS CAGR
FROM cte_table1
ORDER BY CAGR DESC
LIMIT 3;

-- Bottom 3

WITH cte_table AS
(SELECT D.district,D.`date`,D.month_name,D.year,D.visitors AS domestic_visitors,F.visitors AS Foreign_visitors,SUM(D.visitors+F.visitors) AS total_visitors
FROM domestic_visitors D
INNER JOIN foreign_visitors F
ON D.`date` = F.`date` AND D.district = F.district
GROUP BY D.district,D.`date`)
, cte_table1 AS
(SELECT district,
SUM(CASE WHEN `year` = (SELECT MIN(`year`) FROM cte_table) THEN total_visitors ELSE 0 END) AS starting_value
,SUM(CASE WHEN `year` = (SELECT MAX(`year`) FROM cte_table) THEN total_visitors ELSE 0 END) AS ending_value
FROM cte_table
GROUP BY district)
SELECT district, ROUND((POWER(ending_value/starting_value,(1/3))-1)*100,2) AS CAGR
FROM cte_table1
WHERE ROUND((POWER(ending_value/starting_value,(1/3))-1)*100,2) IS NOT NULL
ORDER BY CAGR ASC
LIMIT 3;

-- What are the peak and low season months for Hyderabad based on the data from 2016 to 2019 for hyderabad district


SELECT DV.month_name,(DV.visitors+FV.visitors) AS Total_visitors FROM domestic_visitors DV
INNER JOIN Foreign_visitors FV
ON DV.district = FV.district AND DV.date = FV.date
WHERE DV.district = 'Hyderabad'
GROUP BY DV.month_name
ORDER BY Total_visitors DESC;  -- Peak seasons on top and Low seasons on bottom (since arranged in descending order)

-- Show the top and bottom 3 districts with high domestic to foreign tourist ratio ?

-- Top 3

SELECT DV.district,SUM(DV.visitors) AS domestic_visitors,SUM(FV.visitors) AS Foreign_visitors,IF(SUM(FV.visitors) > 0,SUM(DV.visitors)/SUM(FV.visitors),'NA') Domestic_to_foreign
FROM domestic_visitors DV
INNER JOIN Foreign_visitors FV
ON DV.district = FV.district AND DV.date = FV.date
GROUP BY DV.district
ORDER BY Domestic_to_foreign DESC
LIMIT 3;

-- Bottom 3

SELECT DV.district,SUM(DV.visitors) AS domestic_visitors,SUM(FV.visitors) AS Foreign_visitors,IF(SUM(FV.visitors) > 0,SUM(DV.visitors)/SUM(FV.visitors),'NA') Domestic_to_foreign
FROM domestic_visitors DV
INNER JOIN Foreign_visitors FV
ON DV.district = FV.district AND DV.date = FV.date
GROUP BY DV.district
ORDER BY Domestic_to_foreign ASC
LIMIT 3;



-- Secondary Research Questions

CREATE TABLE district_population(
district VARCHAR(50),
population INT
);


LOAD DATA INFILE
"C:/DPOP.csv"
INTO TABLE district_population
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- List the top and bottom 5 districts based on "Population to tourist footfall ratio" in the year 2019


-- Top 5

WITH visitors_population_data AS
(SELECT DV.district,DV.`date`,DV.month_name,DV.year,(DV.visitors+FV.visitors) AS Total_visitors,DP.population AS district_population FROM domestic_visitors DV
INNER JOIN Foreign_visitors FV
ON FV.`date` = DV.`date`
INNER JOIN district_population DP
ON DP.district = DV.district
WHERE DV.year = 2019)
SELECT district,(Total_visitors/district_population) AS pop_to_tourist_ratio 
FROM visitors_population_data
GROUP BY district
ORDER BY pop_to_tourist_ratio DESC
LIMIT 5;

-- Bottom 5
WITH visitors_population_data AS
(SELECT DV.district,DV.`date`,DV.month_name,DV.year,(DV.visitors+FV.visitors) AS Total_visitors,DP.population AS district_population FROM domestic_visitors DV
INNER JOIN Foreign_visitors FV
ON FV.`date` = DV.`date`
INNER JOIN district_population DP
ON DP.district = DV.district
WHERE DV.year = 2019)
SELECT district,(Total_visitors/district_population) AS pop_to_tourist_ratio 
FROM visitors_population_data
WHERE (Total_visitors/district_population) IS NOT NULL
GROUP BY district
ORDER BY pop_to_tourist_ratio ASC
LIMIT 5;






