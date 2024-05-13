
DROP TABLE IF EXISTS sigmodcom;
DROP TABLE IF EXISTS sigmodedu;

CREATE TABLE sigmodcom(id int,name varchar(255),homepage varchar(255),pubid int,pubkey varchar(255),booktitle varchar(255),editor varchar(255),year int,title varchar(255));

INSERT INTO sigmodcom(id,name,homepage,pubid,pubkey,booktitle,editor,year,title) 
SELECT DISTINCT
    x.id,
    x.name, 
    x.homepage,
    y.pubid,
    z.pubkey, 
    i.booktitle,
    i.editor, 
    z.year,
    title
FROM Author x
JOIN Authored y ON x.id = y.id
JOIN Publication z ON y.pubid = z.pubid
JOIN Inproceedings i ON z.pubid = i.pubid 
WHERE i.booktitle LIKE '%SIGMOD%' AND x.homepage LIKE '%com%';

CREATE TABLE sigmodedu(id int,name varchar(255),homepage varchar(255),pubid int,pubkey varchar(255),booktitle varchar(255),editor varchar(255),year int,title varchar(255));
INSERT INTO sigmodedu(id,name,homepage,pubid,pubkey,booktitle,editor,year,title) 
SELECT DISTINCT
    x.id,
    x.name, 
    x.homepage,
    y.pubid,
    z.pubkey, 
    i.booktitle,
    i.editor, 
    z.year,
    title
FROM Author x
JOIN Authored y ON x.id = y.id
JOIN Publication z ON y.pubid = z.pubid
JOIN Inproceedings i ON z.pubid = i.pubid 
WHERE i.booktitle LIKE '%SIGMOD%' AND x.homepage LIKE '%edu%';

\COPY (SELECT * FROM sigmodcom) TO 'sigmodcom.csv' WITH (FORMAT CSV, HEADER);
\COPY (SELECT * FROM sigmodedu) TO 'sigmodedu.csv' WITH (FORMAT CSV, HEADER);
