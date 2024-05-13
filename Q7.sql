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






-- Drop the table if it already exists
DROP TABLE IF EXISTS Cube1;
DROP TABLE IF EXISTS Cube2;
DROP TABLE IF EXISTS Cube3;
DROP TABLE IF EXISTS Cube4;

-- Create Cube1 from sigmodcom for the period 2000-2004
CREATE TABLE Cube1 AS
SELECT 
    COALESCE(name, 'Unknown Name') AS name,
    COALESCE(homepage, 'Unknown Homepage') AS homepage,
    COUNT(pubid) AS count1,
    COALESCE(booktitle, 'Unknown Booktitle') AS booktitle,
    2000 AS year
FROM sigmodcom WHERE year BETWEEN 2000 AND 2004
GROUP BY CUBE (name, homepage, booktitle);

-- Create Cube2 from sigmodcom for the period 2007-2011
CREATE TABLE Cube2 AS
SELECT 
    COALESCE(name, 'Unknown Name') AS name,
    COALESCE(homepage, 'Unknown Homepage') AS homepage,
    COUNT(pubid) AS count2,
    COALESCE(booktitle, 'Unknown Booktitle') AS booktitle,
    2007 AS year
FROM sigmodcom WHERE year BETWEEN 2007 AND 2011
GROUP BY CUBE (name, homepage, booktitle);

-- Create Cube3 from sigmodedu for the period 2000-2004
CREATE TABLE Cube3 AS
SELECT 
    COALESCE(name, 'Unknown Name') AS name,
    COALESCE(homepage, 'Unknown Homepage') AS homepage,
    COUNT(pubid) AS count3,
    COALESCE(booktitle, 'Unknown Booktitle') AS booktitle,
    2000 AS year
FROM sigmodedu WHERE year BETWEEN 2000 AND 2004
GROUP BY CUBE (name, homepage, booktitle);

-- Create Cube4 from sigmodedu for the period 2007-2011
CREATE TABLE Cube4 AS
SELECT 
    COALESCE(name, 'Unknown Name') AS name,
    COALESCE(homepage, 'Unknown Homepage') AS homepage,
    COUNT(pubid) AS count4,
    COALESCE(booktitle, 'Unknown Booktitle') AS booktitle,
    2007 AS year
FROM sigmodedu WHERE year BETWEEN 2007 AND 2011
GROUP BY CUBE (name, homepage, booktitle);

-- Drop if exists and create a new table fullouterjoin2 combining all cubes
DROP TABLE IF EXISTS fullouterjoin2;
CREATE TABLE fullouterjoin2 AS
SELECT DISTINCT 
    COALESCE(Cube1.name, Cube2.name, Cube3.name, Cube4.name) AS name,
   COALESCE(Cube1.homepage, Cube2.homepage, Cube3.homepage, Cube4.homepage) AS homepage,
    COALESCE(count1, 0) AS count1, COALESCE(count2, 0) AS count2, COALESCE(count3, 0) AS count3, COALESCE(count4, 0) AS count4,
   COALESCE(Cube1.booktitle, Cube2.booktitle, Cube3.booktitle, Cube4.booktitle) AS booktitle
FROM Cube1
FULL OUTER JOIN Cube2 ON Cube1.name = Cube2.name AND Cube1.homepage = Cube2.homepage 
FULL OUTER JOIN Cube3 ON Cube1.name = Cube3.name AND Cube1.homepage = Cube3.homepage
FULL OUTER JOIN Cube4 ON Cube1.name = Cube4.name AND Cube1.homepage = Cube4.homepage;

SELECT * FROM fullouterjoin2 where count3 = 6 AND count2=0 order by count2 LIMIT 10;

drop table if exists fullouterjoinNozero;
create table fullouterjoinNozero AS SELECT * FROM fullouterjoin2
WHERE count2 != (select count from newjoin where page LIKE '%u2') AND count3 != (select count from newjoin where page LIKE '%u3');

-- SELECT * FROM fullouterjoinNozero LIMIT 20;
ALTER TABLE fullouterjoinNozero
add COLUMN interv real;

UPDATE fullouterjoinNozero
SET interv =-(((CAST((select count from newjoin where page LIKE '%u1') AS DECIMAL) - count1)*(CAST((select count from newjoin where page LIKE '%u4') AS DECIMAL) - count4)) / ((CAST((select count from newjoin where page LIKE '%u2') AS DECIMAL) - count2)*(CAST((select count from newjoin where page LIKE '%u3') AS DECIMAL) - count3)));

ALTER TABLE fullouterjoinNozero
ADD COLUMN aggr INT;

UPDATE fullouterjoinNozero
SET aggr = (
    CAST(
        (count1 * count4) / (NULLIF(count2 * count3, 0))
    AS DECIMAL)
);


-- Select the first 10 records from fullouterjoin2 to verify
SELECT * FROM fullouterjoinNozero  WHERE interv is not null order by interv LIMIT 10;
SELECT * FROM fullouterjoinNozero  WHERE interv is not null order by aggr LIMIT 10;


\COPY (SELECT * FROM fullouterjoinNozero  WHERE interv is not null order by interv DESC LIMIT 10) TO 'fig1Interv.csv' WITH (FORMAT CSV, HEADER);
\COPY (SELECT * FROM fullouterjoinNozero  WHERE aggr is not null  order by aggr DESC LIMIT 10) TO 'fig1Aggr.csv' WITH (FORMAT CSV, HEADER);
