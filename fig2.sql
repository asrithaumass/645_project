-- Table to store all SIGMOD publications from 2001 - 2011
create table sigmod0111 (pubkey text);
insert into sigmod0111(pubkey)
SELECT pubkey
FROM author a
JOIN authored au ON a.id = au.id
JOIN publication p ON au.pubid = p.pubid
LEFT JOIN inproceedings ip ON p.pubid = ip.pubid
WHERE (p.year BETWEEN 2001 AND 2011)
AND (ip.booktitle like '%SIGMOD%');

-- Table to store all PODS publications from 2001 - 2011
create table pods111 (pubkey text);
insert into pods111(pubkey)
SELECT pubkey
FROM author a
JOIN authored au ON a.id = au.id
JOIN publication p ON au.pubid = p.pubid
LEFT JOIN inproceedings ip ON p.pubid = ip.pubid
WHERE (p.year BETWEEN 2001 AND 2011)
AND (ip.booktitle like '%PODS%');

-- Table to store all publications in SIGMOD group by countries
create table sigmodCount(country text, count integer);
insert into sigmodCount(country, count)
select dc.name, count(*)
from sigmod0111 sm, data_pub dp, data_pub_author dpa, data_author_affiliation daa, data_affiliation da, data_country dc 
where da.country_id = dc.id and daa.affiliation = da.id and dpa.authoraffiliation_id = daa.id
and (dc.name = 'United States' or dc.name = 'Canada' or dc.name = 'Hong Kong' or dc.name = 'Germany' 
or dc.name = 'India' or dc.name = 'Italy' or dc.name = 'United Kingdom')
and sm.pubkey = dp.dblp_key and dp.id = dpa.publication_id group by dc.name;

-- Table to store all publications in PODS group by countries
create table podsCount(country text, count integer);
insert into podsCount(country, count)
select dc.name, count(*)
from pods111 sm, data_pub dp, data_pub_author dpa, data_author_affiliation daa, data_affiliation da, data_country dc 
where da.country_id = dc.id and daa.affiliation = da.id and dpa.authoraffiliation_id = daa.id 
and sm.pubkey = dp.dblp_key and dp.id = dpa.publication_id and (dc.name = 'United States' 
or dc.name = 'Canada' or dc.name = 'Hong Kong' or dc.name = 'Germany' or dc.name = 'India' 
or dc.name = 'Italy' or dc.name = 'United Kingdom') group by dc.name;

-- Generate CSV file from PodsCount table
\COPY podsCount TO './podsCount.csv' WITH (FORMAT CSV, HEADER);

-- Generate CSV file from PodsCount table
\COPY sigmodCount TO './sigmodCount.csv' WITH (FORMAT CSV, HEADER);

-- Create the universal table for SIGMOD table
create table sigmodUniversalTable(author text, affiliation text, city text, country text, count integer);
insert into sigmodUniversalTable(author, affiliation, city, country,  count)
select dta.name as author, da.name as affiliation, da.city as city, dc.name as country, count(*)
from sigmod0111 sm, data_pub dp, data_pub_author dpa, data_author_affiliation daa, 
data_affiliation da, data_country dc, data_author dta
where da.country_id = dc.id and daa.affiliation = da.id and dpa.authoraffiliation_id = daa.id 
and daa.author_id = dta.id and sm.pubkey = dp.dblp_key and dp.id = dpa.publication_id and 
(dc.name = 'United States' or dc.name = 'Canada' or dc.name = 'Hong Kong' or dc.name = 'Germany' or 
dc.name = 'India' or dc.name = 'Italy' or dc.name = 'United Kingdom') 
group by dta.name, da.name, da.city, dc.name;

-- Create the universal table for PODS table
create table podsUniversalTable(author text, affiliation text, city text, country text, count integer);
insert into podsUniversalTable(author, affiliation, city, country, count)
select dta.name as author, da.name as affiliation, da.city as city, dc.name as country, count(*)
from pods111 sm, data_pub dp, data_pub_author dpa, data_author_affiliation daa, 
data_affiliation da, data_country dc, data_author dta
where da.country_id = dc.id and daa.affiliation = da.id and dpa.authoraffiliation_id = daa.id 
and daa.author_id = dta.id and sm.pubkey = dp.dblp_key and dp.id = dpa.publication_id and 
(dc.name = 'United States' or dc.name = 'Canada' or dc.name = 'Hong Kong' or dc.name = 'Germany' or 
dc.name = 'India' or dc.name = 'Italy' or dc.name = 'United Kingdom') 
group by dta.name, da.name, da.city, dc.name;

\COPY podsUniversalTable TO './podsUniversalTable.csv' WITH (FORMAT CSV, HEADER);
\COPY sigmodUniversalTable TO './sigmodUniversalTable.csv' WITH (FORMAT CSV, HEADER);
