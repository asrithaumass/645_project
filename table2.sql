-- Step 1: Calculate aggregate values
CREATE TABLE UKaggregateTable AS
SELECT conference, COUNT(*) AS count
FROM universalTable WHERE country = 'United Kingdom'
GROUP BY conference;

-- Step 2: Create data cubes and store aggregate values
CREATE TABLE PodsAggregateCube AS
SELECT COALESCE(author, 'unknown') AS author, 
COALESCE(affiliation, 'unknown') AS affiliation, 
COALESCE(city, 'unknown') AS city, 
COALESCE(conference, 'unknown') AS conference, COUNT(*) AS PodsCount
FROM universalTable WHERE conference = 'PODS' and country = 'United Kingdom'
GROUP BY CUBE(conference, author, affiliation, city);

CREATE TABLE sigmodAggregateCube AS
SELECT COALESCE(author, 'unknown') AS author, 
COALESCE(affiliation, 'unknown') AS affiliation, 
COALESCE(city, 'unknown') AS city, 
COALESCE(conference, 'unknown') AS conference,
COUNT(*) AS sigmodCount
FROM universalTable WHERE conference = 'SIGMOD' and country = 'United Kingdom'
GROUP BY CUBE(conference, author, affiliation, city);

-- Step 3: Perform full outer join
drop table if exists fullouterjoin;
create table fullouterjoin AS
SELECT DISTINCT s.author, s.affiliation, s.city,  PodsCount, sigmodCount
FROM sigmodAggregateCube s
FULL OUTER JOIN PodsAggregateCube p ON s.author = p.author and  s.affiliation = p.affiliation 
AND s.city = p.city;

-- Step 4: Add column for interv and compute its values
drop table if exists fullouterjoinNozero;
create table fullouterjoinNozero AS SELECT * FROM fullouterjoin
WHERE sigmodCount != (select count from UKaggregateTable where conference = 'SIGMOD');

ALTER TABLE fullouterjoinNozero
add COLUMN interv real;

UPDATE fullouterjoinNozero
SET interv = ((CAST((SELECT COUNT FROM UKaggregateTable WHERE conference = 'PODS') AS DECIMAL) - podsCount) / CAST((SELECT COUNT FROM UKaggregateTable WHERE conference = 'SIGMOD') - sigmodCount AS DECIMAL));

-- Step 5: Add column for µaggr and compute its values
ALTER TABLE fullouterjoinNozero
ADD COLUMN aggr INT;

UPDATE fullouterjoinNozero
SET aggr = -(podscount/sigmodCount);