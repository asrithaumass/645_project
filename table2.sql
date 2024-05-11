-- Step 1: Calculate aggregate values
CREATE TABLE UKaggregateTable AS
SELECT conference, COUNT(*) AS count
FROM universalTable WHERE country = 'United Kingdom'
GROUP BY conference;

-- Step 2: Create data cubes and store aggregate values
CREATE TABLE ukaggregateCube AS
SELECT author, affiliation, city, conference, COUNT(*) AS cubeCount
FROM universalTable WHERE country = 'United Kingdom'
GROUP BY CUBE(conference, author, affiliation, city);

-- Step 3: Perform full outer join
-- Only have 1 query, no need for an outer join

-- Step 4: Add column for interv and compute its values
ALTER TABLE ukaggregateCube
ADD COLUMN dir text;

UPDATE ukaggregateCube
SET dir = CASE
WHEN conference='PODS' THEN 'low' 
WHEN conference = 'SIGMOD' THEN 'high'
END;

ALTER TABLE ukaggregateCube
ADD COLUMN interv text;

UPDATE fullouterjoin
SET interv = CASE
WHEN dir = 'low' THEN ((select count from UKaggregateTable where conference = 'PODS') - cubeCount)
WHEN dir = 'high' THEN (cubeCount - (select count from UKaggregateTable where conference = 'SIGMOD'))
END;

-- Step 5: Add column for µaggr and compute its values
ALTER TABLE fullouterjoin
ADD COLUMN aggr INT;

UPDATE fullouterjoin
SET aggr = CASE
WHEN dir = 'high' THEN cubeCount
WHEN dir = 'low' THEN -cubeCount
END;