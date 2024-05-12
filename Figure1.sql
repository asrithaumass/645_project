-- Drop the existing table if it exists and create a new table
DROP TABLE IF EXISTS newjoin;
CREATE TABLE newjoin(count int, year int, page varchar(255));

-- Insert aggregated data from sigmodcom for 2000-2004
INSERT INTO newjoin(count, year, page)
SELECT SUM(count) AS total_count, year, 'u1' AS page FROM (
    SELECT 
        COUNT(pubid) AS count,
        2000 AS year
    FROM 
        sigmodcom
    WHERE 
        year BETWEEN 2000 AND 2004 
    GROUP BY name, homepage, booktitle
) AS subquery_2000_2004
GROUP BY year;

-- Insert aggregated data from sigmodcom for 2007-2011 using similar structure
INSERT INTO newjoin(count, year, page)
SELECT SUM(count) AS total_count, year, 'u2' AS page FROM (
    SELECT 
        COUNT(pubid) AS count,
        2007 AS year
    FROM 
        sigmodcom
    WHERE 
        year BETWEEN 2007 AND 2011 
    GROUP BY name, homepage, booktitle
) AS subquery_2007_2011
GROUP BY year;

-- Repeat for sigmodedu for each period (2000-2004)
INSERT INTO newjoin(count, year, page)
SELECT SUM(count) AS total_count, year, 'u3' AS page FROM (
    SELECT 
        COUNT(pubid) AS count,
        2000 AS year
    FROM 
        sigmodedu
    WHERE 
        year BETWEEN 2000 AND 2004 
    GROUP BY name, homepage, booktitle
) AS subquery_edu_2000_2004
GROUP BY year;

-- Repeat for sigmodedu for each period (2007-2011)
INSERT INTO newjoin(count, year, page)
SELECT SUM(count) AS total_count, year, 'u4' AS page FROM (
    SELECT 
        COUNT(pubid) AS count,
        2007 AS year
    FROM 
        sigmodedu
    WHERE 
        year BETWEEN 2007 AND 2011 
    GROUP BY name, homepage, booktitle
) AS subquery_edu_2007_2011
GROUP BY year;
