select
Distinct  
FID_Counties,
FID_TPAs,
FID_Alt,
COUNTYNAME,
CountyFIP,
parcel_id,
Estimated_Population,
total_residential_units,
total_job_spaces,
Acres,
People_Per_Acre,
Jobs_Per_Acre
from UrbanSim.COUNTIES_TPAS_ALT_4_OVERLAY
Order By parcel_id
Go

--------------------------------
-----------Fix Duplicate Parcels
-----------In the household
-----------and employment
-----------change tables, be scenario
--------------------------------


Go
--Drop view UrbanSim.Dup_GrowthParcels 
drop view UrbanSim.County_Dup_Parcels;
go
create view UrbanSim.County_Dup_Parcels as
select distinct q1.parcel_id from 
(SELECT        parcel_id 
FROM            UrbanSim.COUNTIES_TPAS_ALT_4_OVERLAY
GROUP BY parcel_id
HAVING        (COUNT(parcel_id) > 1)
UNION
SELECT        parcel_id
FROM            UrbanSim.COUNTIES_TPAS_ALT_1_OVERLAY
GROUP BY parcel_id
HAVING        (COUNT(parcel_id) > 1)
UNION
SELECT        parcel_id
FROM            UrbanSim.COUNTIES_TPAS_ALT_3_OVERLAY
GROUP BY parcel_id
HAVING        (COUNT(parcel_id) > 1)
UNION
SELECT        parcel_id
FROM            UrbanSim.COUNTIES_TPAS_ALT_5_OVERLAY
GROUP BY parcel_id
HAVING        (COUNT(parcel_id) > 1)) as q1
GO
--result:+106 parcels

--get the centroids and 
--a point on surface for intersection with county resolution
SELECT q2.* INTO UrbanSim.County_Dup_Parcels_POS FROM (
SELECT t1.parcel_id as parcel_id, 
t2.Shape.STPointOnSurface() as PointOnSurface, 
t2.Shape.STCentroid() as Centroid
FROM UrbanSim.County_Dup_Parcels as t1,
UrbanSim.Parcels as t2
WHERE t1.parcel_id = t2.parcel_id) as q2

--create a view based on intersection thats just 
--based on the point in surface
CREATE VIEW UrbanSim.County_Dup_Parcels_Resolved_POS AS
SELECT 
		t2.parcel_id, t3.COUNTYNAME, t3.CountyFIP
FROM 
		UrbanSim.County_Dup_Parcels_POS as t2 
INNER JOIN
		dbo.COUNTIES as t3
ON 
		t2.PointOnSurface.STWithin(t3.Shape) = 1

---then one thats based on both POS and centroid
--this was required because on visual check, POS 
--often seems to stick points on the edges or near
--reulting in non-representative intersections
CREATE VIEW UrbanSim.County_Dup_Parcels_Resolved_Centroid AS
SELECT 
		t2.parcel_id, t3.COUNTYNAME, t3.CountyFIP
FROM 
		UrbanSim.County_Dup_Parcels_POS as t2 
INNER JOIN
		dbo.COUNTIES as t3
ON 
		t2.PointOnSurface.STWithin(t3.Shape) = 1
AND 	t2.Centroid.STWithin(t3.Shape) = 1

--create a view for manual review of those 
--that intersect with POS but not centroid
DROP VIEW Urbansim.County_Dup_Manual_Resolution;
GO
CREATE VIEW Urbansim.County_Dup_Manual_Resolution AS 
SELECT * from UrbanSim.County_Dup_Parcels_Resolved_POS
where parcel_id not in (
select parcel_id from UrbanSim.County_Dup_Parcels_Resolved_Centroid);

GO

DROP VIEW Urbansim.County_Dup_Manual_Resolution_Spatial;
GO
CREATE VIEW Urbansim.County_Dup_Manual_Resolution_Spatial AS
SELECT p.* from UrbanSim.County_Dup_Manual_Resolution as t,
Urbansim.Parcels as p
WHERE p.parcel_id = t.parcel_id;

--build table of corrected values
DROP TABLE UrbanSim.County_Dup_Parcels_Resolved_Centroid_Table;
GO
SELECT q4.* INTO UrbanSim.County_Dup_Parcels_Resolved_Centroid_Table FROM (
SELECT 
		p.PARCEL_ID as parcel_id, c.COUNTYNAME as COUNTYNAME, p.COUNTY_ID as CountyFIP
FROM 
		UrbanSim.County_Dup_Manual_Resolution as t1,
		UrbanSim.parcels as p,
		dbo.COUNTIES as c 
WHERE p.PARCEL_ID = t1.parcel_id AND
c.CountyFIP = p.COUNTY_ID AND
t1.parcel_id <> 1311950
) q4

---only 1 was incorrect on visual inspection on the map 
--(comparing its Parcels table value to its actual placement on the map)
go
INSERT INTO UrbanSim.County_Dup_Parcels_Resolved_Centroid_Table (parcel_id, COUNTYNAME,
    CountyFIP)
VALUES (1311950, 'San Mateo', 81);
GO

--put the values in that had both a centroid and a POS in the county
INSERT INTO UrbanSim.County_Dup_Parcels_Resolved_Centroid_Table (parcel_id, COUNTYNAME,
    CountyFIP)
SELECT 
		parcel_id, COUNTYNAME, CountyFIP
FROM 
		UrbanSim.County_Dup_Parcels_Resolved_Centroid;

GO

--update the county assignments for parcels with duplicate entries
UPDATE
    t1
SET
    t1.COUNTYNAME = t2.COUNTYNAME,
    t1.CountyFIP = t2.CountyFIP
FROM
	UrbanSim.COUNTIES_TPAS_ALT_4_OVERLAY AS t1
    INNER JOIN UrbanSim.County_Dup_Parcels_Resolved_Centroid_Table AS t2
        ON t1.parcel_id = t2.parcel_id
WHERE
    t1.parcel_id = t2.parcel_id;

  GO


UPDATE
    t1
SET
    t1.COUNTYNAME = t2.COUNTYNAME,
    t1.CountyFIP = t2.CountyFIP
FROM
	UrbanSim.COUNTIES_TPAS_ALT_1_OVERLAY AS t1
    INNER JOIN UrbanSim.County_Dup_Parcels_Resolved_Centroid_Table AS t2
        ON t1.parcel_id = t2.parcel_id
WHERE
    t1.parcel_id = t2.parcel_id;

  GO


UPDATE
    t1
SET
    t1.COUNTYNAME = t2.COUNTYNAME,
    t1.CountyFIP = t2.CountyFIP
FROM
	UrbanSim.COUNTIES_TPAS_ALT_3_OVERLAY AS t1
    INNER JOIN UrbanSim.County_Dup_Parcels_Resolved_Centroid_Table AS t2
        ON t1.parcel_id = t2.parcel_id
WHERE
    t1.parcel_id = t2.parcel_id;

  GO


UPDATE
    t1
SET
    t1.COUNTYNAME = t2.COUNTYNAME,
    t1.CountyFIP = t2.CountyFIP
FROM
	UrbanSim.COUNTIES_TPAS_ALT_5_OVERLAY AS t1
    INNER JOIN UrbanSim.County_Dup_Parcels_Resolved_Centroid_Table AS t2
        ON t1.parcel_id = t2.parcel_id
WHERE
    t1.parcel_id = t2.parcel_id;

  GO

--TODO: i may have overestimated the number of county duplicates 
--because there are also tpa duplicates in the table, which i was not aware of
--however, the above should still resolve the county duplicates, so we can move on

/*
GOAL:
3.       Quantify by County the:
a.       2015 and 2040 Dwelling Units per acre within TPAs
b.       2015 and 2040 Employment/Jobs per acre within TPAs
4. Quantify by County the acres of overlap between the Preferred Scenario’s (proposed Plan) land use footprint and transportation footprint.
*/

GO

DROP VIEW UrbanSim.Alt_4_Counties_TPAs_Density;

GO
create view UrbanSim.Alt_4_Counties_TPAs_Density as
SELECT  t1.FID_Counties, t1.FID_TPAs, 
	                     t1.COUNTYNAME, t1.CountyFIP, 
	                     t1.parcel_id, 
	                     t1.Estimated_Population AS Estimated_Population,
	                     t1.total_residential_units AS total_residential_units, 
	                     t1.total_job_spaces AS total_job_spaces, 
	                     t1.Acres AS Acres, 
	                     t1.People_Per_Acre AS People_Per_Acre, 
	                     t1.Jobs_Per_Acre AS Jobs_Per_Acre
FROM            UrbanSim.COUNTIES_TPAS_ALT_4_OVERLAY as t1
WHERE t1.FID_TPAs = 1;

GO

DROP VIEW UrbanSim.Alt_4_Counties_TPAs_Density_Distinct;

GO
---next do a distinct on the above table to drop duplicates
---THE QUERY BELOW NEEDS REVIEW
create view UrbanSim.Alt_4_Counties_TPAs_Density_Distinct as
SELECT  DISTINCT  *
FROM            UrbanSim.Alt_4_Counties_TPAs_Density as t1
WHERE t1.FID_TPAs = 1;

GO

DROP VIEW UrbanSim.Alt_3_Counties_TPAs_Density;

GO
create view UrbanSim.Alt_3_Counties_TPAs_Density as
SELECT  t1.FID_Counties, t1.FID_TPAs, 
	                     t1.COUNTYNAME, t1.CountyFIP, 
	                     t1.parcel_id, 
	                     t1.Estimated_Population AS Estimated_Population,
	                     t1.total_residential_units AS total_residential_units, 
	                     t1.total_job_spaces AS total_job_spaces, 
	                     t1.Acres AS Acres, 
	                     t1.People_Per_Acre AS People_Per_Acre, 
	                     t1.Jobs_Per_Acre AS Jobs_Per_Acre
FROM            UrbanSim.COUNTIES_TPAS_ALT_3_OVERLAY as t1
WHERE t1.FID_TPAs = 1;

GO
DROP VIEW UrbanSim.Alt_3_Counties_TPAs_Density_Distinct;

GO
---next do a distinct on the above table to drop duplicates
---THE QUERY BELOW NEEDS REVIEW
create view UrbanSim.Alt_3_Counties_TPAs_Density_Distinct as
SELECT  DISTINCT     *
FROM            UrbanSim.Alt_3_Counties_TPAs_Density as t1
WHERE t1.FID_TPAs = 1;

GO

DROP VIEW UrbanSim.Alt_1_Counties_TPAs_Density;

GO
create view UrbanSim.Alt_1_Counties_TPAs_Density as
SELECT  DISTINCT t1.FID_Counties, t1.FID_TPAs, 
	                     t1.COUNTYNAME, t1.CountyFIP, 
	                     t1.parcel_id, 
	                     t1.Estimated_Population AS Estimated_Population,
	                     t1.total_residential_units AS total_residential_units, 
	                     t1.total_job_spaces AS total_job_spaces, 
	                     t1.Acres AS Acres, 
	                     t1.People_Per_Acre AS People_Per_Acre, 
	                     t1.Jobs_Per_Acre AS Jobs_Per_Acre
FROM            UrbanSim.COUNTIES_TPAS_ALT_1_OVERLAY as t1
WHERE t1.FID_TPAs = 1;

GO
DROP VIEW UrbanSim.Alt_1_Counties_TPAs_Density_Distinct;

GO
create view UrbanSim.Alt_1_Counties_TPAs_Density_Distinct as
SELECT  DISTINCT  *
FROM            UrbanSim.Alt_1_Counties_TPAs_Density as t1
WHERE t1.FID_TPAs = 1;

GO

DROP VIEW UrbanSim.Alt_5_Counties_TPAs_Density;

GO
create view UrbanSim.Alt_5_Counties_TPAs_Density as
SELECT  DISTINCT t1.FID_Counties, t1.FID_TPAs, 
	                     t1.COUNTYNAME, t1.CountyFIP, 
	                     t1.parcel_id, 
	                     t1.Estimated_Population AS Estimated_Population,
	                     t1.total_residential_units AS total_residential_units, 
	                     t1.total_job_spaces AS total_job_spaces, 
	                     t1.Acres AS Acres, 
	                     t1.People_Per_Acre AS People_Per_Acre, 
	                     t1.Jobs_Per_Acre AS Jobs_Per_Acre
FROM            UrbanSim.COUNTIES_TPAS_ALT_5_OVERLAY as t1
WHERE t1.FID_TPAs = 1;

GO
DROP VIEW UrbanSim.Alt_5_Counties_TPAs_Density_Distinct;
GO

---next do a distinct on the above table to drop duplicates
---THE QUERY BELOW NEEDS REVIEW
create view UrbanSim.Alt_5_Counties_TPAs_Density_Distinct as
SELECT  DISTINCT *
FROM            UrbanSim.Alt_5_Counties_TPAs_Density as t1
WHERE t1.FID_TPAs = 1;

GO

---------------
---------------
-------Begin household and employment 
-------in TPA's work
-------where showing numbers in 2015
-------and in 2040, rather than change
---------------
---------------

/*
Repost of the goal below. Because many parcels are in TPA's 
but not in the growth footprints, by using just the footprint tables above, 
we can't determine what 2040 or 2015 counts look like. 
So, we restate the goal, and back out whats needed.

GOAL:
3.       Quantify by County the:
a.       2015 and 2040 Dwelling Units per acre within TPAs
b.       2015 and 2040 Employment/Jobs per acre within TPAs
4. Quantify by County the acres of overlap between the Preferred Scenario’s (proposed Plan) land use footprint and transportation footprint.

For example:

County|Residential Units in TPA's in 2015|Residential Units in TPA's in 2040|
------|----------------------------------|----------------------------------|
Alameda|300|400|
Marin|100|100|

total_residential_units is sourced from the "Diff" table so it doesn't give us either of the above directly. 
however, we can back the values for 2015 out of the subtraction of the diff values from the 2040 counts.

so, we'll insert that logic below and then output the summary table as spec'ed above.

*/
GO
create view UrbanSim.Alt_4_Counties_TPAs_Density as
SELECT  DISTINCT t1.FID_Counties, t1.FID_TPAs, 
	                     t1.COUNTYNAME, t1.CountyFIP, 
	                     t1.parcel_id, 
	                     t1.Estimated_Population AS Estimated_Population,
	                     t1.total_residential_units AS total_residential_units, 
	                     t1.total_job_spaces AS total_job_spaces, 
	                     t1.Acres AS Acres, 
	                     t1.People_Per_Acre AS People_Per_Acre, 
	                     t1.Jobs_Per_Acre AS Jobs_Per_Acre
FROM            UrbanSim.COUNTIES_TPAS_ALT_4_OVERLAY as t1
WHERE t1.FID_TPAs = 1;


-------------------
-------Put TPA's on 
-------all parcels
-------------------

--we need to know the TPA for every parcel
--So, first we need to assign a TPA value to each parcel

--the UrbanSim.parcels table doesn't have any indexes, 
--so in the interest of expediency, we use an existing parcels
--table that has indexes from the Analysis schema
---we can always come back and setup the UrbanSim.Parcels table later

SELECT q1.* INTO UrbanSim.Parcels_Centroid_Only FROM (
SELECT p1.parcel_id as parcel_id, 
p1.Shape.STCentroid() as Centroid
FROM Analysis.p09_01_2015_parcel_shareable as p1) q1

GO
---
ALTER TABLE UrbanSim.Parcels_Centroid_Only ALTER COLUMN parcel_id INTEGER NOT NULL
--
ALTER TABLE UrbanSim.Parcels_Centroid_Only ADD CONSTRAINT parcel_id_pk
 PRIMARY KEY CLUSTERED (parcel_id);

GO
--Get the required bounding box for the spatial index below
--from https://alastaira.wordpress.com/2011/07/26/determining-the-geographic-extent-of-spatial-features-in-a-sql-server-table/
SELECT
  geometry::EnvelopeAggregate(Shape).STPointN(1).STX AS MinX,
  geometry::EnvelopeAggregate(Shape).STPointN(1).STY AS MinY,
  geometry::EnvelopeAggregate(Shape).STPointN(3).STX AS MaxX,
  geometry::EnvelopeAggregate(Shape).STPointN(3).STY AS MaxY
FROM Analysis.p09_01_2015_parcel_shareable;

GO
--result: 453705.104767737	4083961.21954119		

--xmin=0, ymin=0, xmax=500, ymax=200
CREATE SPATIAL INDEX SIndx_Parcels_Centroid_Only_Centroid_idx   
   ON UrbanSim.Parcels_Centroid_Only(Centroid)  
   WITH ( BOUNDING_BOX = ( 453705.104767737, 4083961.21954119, 659289.046884376, 4301890.14477043 ) );  
GO
ALTER TABLE UrbanSim.Parcels_Centroid_Only ADD tpa_objectid INTEGER NULL;  

GO
UPDATE
    t1
SET
    t1.tpa_objectid = t2.OBJECTID
FROM
    UrbanSim.Parcels_Centroid_Only AS t1
INNER JOIN
	Transportation.TPAS_2016 AS t2
ON 
	t1.Centroid.STWithin(t2.SHAPE) = 1;
GO

GO
--result: 453705.104767737	4083961.21954119		

--it will be cleaner in the future to just set up the parcels table
--as the main one with all the variables, 
--so might as well do so

CREATE INDEX parcel_id_idx ON UrbanSim.Parcels (parcel_id); 

ALTER TABLE UrbanSim.Parcels ADD CONSTRAINT parcels_objectid_idx
 PRIMARY KEY CLUSTERED (OBJECTID);

--xmin=0, ymin=0, xmax=500, ymax=200
CREATE SPATIAL INDEX SIndx_Parcels_Poly   
   ON UrbanSim.Parcels(Shape)  
   WITH ( BOUNDING_BOX = ( 453705.104767737, 4083961.21954119, 659289.046884376, 4301890.14477043 ) );  

ALTER TABLE UrbanSim.Parcels ADD tpa_objectid INTEGER NULL;  

GO
UPDATE
    t1
SET
    t1.tpa_objectid = t2.tpa_objectid
FROM
    UrbanSim.Parcels AS t1
INNER JOIN
	UrbanSim.Parcels_Centroid_Only AS t2
ON 
	t1.parcel_id = t2.parcel_id;
GO

ALTER TABLE UrbanSim.Parcels_Centroid_Only
DROP COLUMN "tpa_objectid";

-----------------
-----------------
--Create Baseline 2050 household and employment numbers from alt 4  
-----------------
-----------------

---based on table creation in Build_Alternative_4_Footprint file
---because alt_4 is the preferred scenario--we will use it as the 
---baseline for 2015
---in theory the scenarios should all be the same for 2015
---but in practice the preferred has had the most review
---and so is probably the most accurate

create view UrbanSim.Alt_4_2040_parcels_in_tpas_units_and_jobs as
SELECT
	p.COUNTY_ID,
	p.parcel_id,
	Cast(2.69*y2040.total_residential_units as numeric(18,0)) as Estimated_Population, 
	Cast(y2040.total_residential_units as numeric(18,0)) as total_residential_units, 
	y2040.total_job_spaces, 
	Round(p.shape.STArea()*0.000247105381,2) as Acres,
	Cast((2.69*y2040.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
	Cast((y2040.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre
FROM            
	(SELECT * FROM UrbanSim.Parcels WHERE tpa_objectid IS NOT NULL) AS p JOIN
	UrbanSim.RUN7224_PARCEL_DATA_2040 AS y2040 ON p.PARCEL_ID = y2040.parcel_id
	--alt_4 is based on simulation run 7224
Go

--------------------------
--------------------
--Create 2015 and 2040 counts from diff and baseline
-------------------
--------------------------


DROP view UrbanSim.Alt_4_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel;
GO
create view UrbanSim.Alt_4_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel as
SELECT
	y2040.parcel_id,
	y2040.COUNTY_ID,
	y2040.Acres,
	y2040.total_residential_units as residential_units_estimate_2040,
	y2040.total_job_spaces as job_spaces_estimate_2040,
		(y2040.total_residential_units-
		CASE WHEN t1.total_residential_units 
			IS NULL THEN 0 ELSE 
			t1.total_residential_units END) 
	AS residential_units_estimate_2015, 
		(y2040.total_job_spaces-
		CASE WHEN t1.total_job_spaces 
			IS NULL THEN 0 ELSE 
			t1.total_job_spaces END) 
	AS job_spaces_estimate_2015
	--y2040.Acres-t1.Acres as acres_estimate_2015,
FROM            
	UrbanSim.Alt_4_2040_parcels_in_tpas_units_and_jobs AS y2040 LEFT JOIN 
	UrbanSim.Alt_4_Counties_TPAs_Density as t1 ON t1.parcel_id = y2040.parcel_id
Go

DROP view UrbanSim.Alt_3_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel;
GO
create view UrbanSim.Alt_3_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel as
SELECT
	y2040.parcel_id,
	y2040.COUNTY_ID,
	y2040.Acres,
	y2040.total_residential_units as residential_units_estimate_2040,
	y2040.total_job_spaces as job_spaces_estimate_2040,
		(y2040.total_residential_units-
		CASE WHEN t1.total_residential_units 
			IS NULL THEN 0 ELSE 
			t1.total_residential_units END) 
	AS residential_units_estimate_2015, 
		(y2040.total_job_spaces-
		CASE WHEN t1.total_job_spaces 
			IS NULL THEN 0 ELSE 
			t1.total_job_spaces END) 
	AS job_spaces_estimate_2015
	--y2040.Acres-t1.Acres as acres_estimate_2015,
FROM            
	UrbanSim.Alt_4_2040_parcels_in_tpas_units_and_jobs AS y2040 LEFT JOIN 
	UrbanSim.Alt_3_Counties_TPAs_Density as t1 ON t1.parcel_id = y2040.parcel_id
Go

DROP view UrbanSim.Alt_5_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel;
GO
create view UrbanSim.Alt_5_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel as
SELECT
	y2040.parcel_id,
	y2040.COUNTY_ID,
	y2040.Acres,
	y2040.total_residential_units as residential_units_estimate_2040,
	y2040.total_job_spaces as job_spaces_estimate_2040,
		(y2040.total_residential_units-
		CASE WHEN t1.total_residential_units 
			IS NULL THEN 0 ELSE 
			t1.total_residential_units END) 
	AS residential_units_estimate_2015, 
		(y2040.total_job_spaces-
		CASE WHEN t1.total_job_spaces 
			IS NULL THEN 0 ELSE 
			t1.total_job_spaces END) 
	AS job_spaces_estimate_2015
	--y2040.Acres-t1.Acres as acres_estimate_2015,
FROM            
	UrbanSim.Alt_4_2040_parcels_in_tpas_units_and_jobs AS y2040 LEFT JOIN 
	UrbanSim.Alt_5_Counties_TPAs_Density as t1 ON t1.parcel_id = y2040.parcel_id
Go

DROP view UrbanSim.Alt_1_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel;
GO
create view UrbanSim.Alt_1_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel as
SELECT
	y2040.parcel_id,
	y2040.COUNTY_ID,
	y2040.Acres,
	y2040.total_residential_units as residential_units_estimate_2040,
	y2040.total_job_spaces as job_spaces_estimate_2040,
		(y2040.total_residential_units-
		CASE WHEN t1.total_residential_units 
			IS NULL THEN 0 ELSE 
			t1.total_residential_units END) 
	AS residential_units_estimate_2015, 
		(y2040.total_job_spaces-
		CASE WHEN t1.total_job_spaces 
			IS NULL THEN 0 ELSE 
			t1.total_job_spaces END) 
	AS job_spaces_estimate_2015
	--y2040.Acres-t1.Acres as acres_estimate_2015,
FROM            
	UrbanSim.Alt_4_2040_parcels_in_tpas_units_and_jobs AS y2040 LEFT JOIN 
	UrbanSim.Alt_1_Counties_TPAs_Density as t1 ON t1.parcel_id = y2040.parcel_id
Go

-----------------------
---county summary tables
-----------------------

DROP VIEW UrbanSim.Alt_4_Density_Within_TPAS_By_County;
GO
CREATE VIEW UrbanSim.Alt_4_Density_Within_TPAS_By_County AS
SELECT COUNTY_ID, SUM(t1.residential_units_estimate_2015) AS sum_residential_units_estimate_2015, 
				   SUM(t1.job_spaces_estimate_2015) AS sum_job_spaces_estimate_2015,
				   SUM(t1.residential_units_estimate_2040) AS sum_residential_units_estimate_2040, 
				   SUM(t1.job_spaces_estimate_2040) AS sum_job_spaces_estimate_2040, 
	               SUM(t1.Acres) AS sum_acres  
FROM UrbanSim.Alt_4_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel as t1
GROUP BY COUNTY_ID;
GO
DROP VIEW UrbanSim.Alt_3_Density_Within_TPAS_By_County;
GO
CREATE VIEW UrbanSim.Alt_3_Density_Within_TPAS_By_County AS
SELECT COUNTY_ID, SUM(t1.residential_units_estimate_2015) AS sum_residential_units_estimate_2015, 
				   SUM(t1.job_spaces_estimate_2015) AS sum_job_spaces_estimate_2015,
				   SUM(t1.residential_units_estimate_2040) AS sum_residential_units_estimate_2040, 
				   SUM(t1.job_spaces_estimate_2040) AS sum_job_spaces_estimate_2040, 
	               SUM(t1.Acres) AS sum_acres
FROM UrbanSim.Alt_3_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel as t1
GROUP BY COUNTY_ID;
GO
DROP VIEW UrbanSim.Alt_5_Density_Within_TPAS_By_County;
GO
CREATE VIEW UrbanSim.Alt_5_Density_Within_TPAS_By_County AS
SELECT COUNTY_ID, SUM(t1.residential_units_estimate_2015) AS sum_residential_units_estimate_2015, 
				   SUM(t1.job_spaces_estimate_2015) AS sum_job_spaces_estimate_2015,
				   SUM(t1.residential_units_estimate_2040) AS sum_residential_units_estimate_2040, 
				   SUM(t1.job_spaces_estimate_2040) AS sum_job_spaces_estimate_2040, 
	               SUM(t1.Acres) AS sum_acres  
FROM UrbanSim.Alt_5_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel as t1
GROUP BY COUNTY_ID;
GO
DROP VIEW UrbanSim.Alt_1_Density_Within_TPAS_By_County;
GO
CREATE VIEW UrbanSim.Alt_1_Density_Within_TPAS_By_County AS
SELECT COUNTY_ID, SUM(t1.residential_units_estimate_2015) AS sum_residential_units_estimate_2015, 
				   SUM(t1.job_spaces_estimate_2015) AS sum_job_spaces_estimate_2015,
				   SUM(t1.residential_units_estimate_2040) AS sum_residential_units_estimate_2040, 
				   SUM(t1.job_spaces_estimate_2040) AS sum_job_spaces_estimate_2040, 
	               SUM(t1.Acres) AS sum_acres  
FROM UrbanSim.Alt_1_2015_and_2040_parcel_units_and_jobs_in_tpas_by_parcel as t1
GROUP BY COUNTY_ID;

----NEXT, create a summary view of all tables and check the numbers and update the below

--Convert Negatives to Zeros
----

DROP VIEW UrbanSim.Alt_4_Density_Within_TPAS_By_County_No_Zero;
GO
CREATE VIEW UrbanSim.Alt_4_Density_Within_TPAS_By_County_No_Zero AS
SELECT COUNTYNAME, CASE WHEN t1.sum_residential_units_estimate_2015 > t1.sum_residential_units_estimate_2040 THEN t1.sum_residential_units_estimate_2015 ELSE t1.sum_residential_units_estimate_2040 END AS sum_residential_units_estimate_2040, 
				   t1.sum_job_spaces_estimate_2015 AS sum_job_spaces_estimate_2015, 
				   t1.sum_residential_units_estimate_2015 AS sum_residential_units_estimate_2015, 
				   CASE WHEN t1.sum_job_spaces_estimate_2040 < t1.sum_job_spaces_estimate_2015 THEN t1.sum_job_spaces_estimate_2015 ELSE t1.sum_job_spaces_estimate_2040 END AS sum_job_spaces_estimate_2040, 
	               CASE WHEN t1.sum_acres < 0 THEN 0 ELSE t1.sum_acres END AS sum_acres  
FROM UrbanSim.Alt_4_Density_Within_TPAS_By_County as t1 INNER JOIN
dbo.Counties as t2 ON 
t1.COUNTY_ID = t2.CountyFIP;
GO
DROP VIEW UrbanSim.Alt_3_Density_Within_TPAS_By_County_No_Zero;
GO
CREATE VIEW UrbanSim.Alt_3_Density_Within_TPAS_By_County_No_Zero AS
SELECT COUNTYNAME, CASE WHEN t1.sum_residential_units_estimate_2015 > t1.sum_residential_units_estimate_2040 THEN t1.sum_residential_units_estimate_2015 ELSE t1.sum_residential_units_estimate_2040 END AS sum_residential_units_estimate_2040, 
				   t1.sum_job_spaces_estimate_2015 AS sum_job_spaces_estimate_2015, 
				   t1.sum_residential_units_estimate_2015 AS sum_residential_units_estimate_2015, 
				   CASE WHEN t1.sum_job_spaces_estimate_2040 < t1.sum_job_spaces_estimate_2015 THEN t1.sum_job_spaces_estimate_2015 ELSE t1.sum_job_spaces_estimate_2040 END AS sum_job_spaces_estimate_2040, 
	               CASE WHEN t1.sum_acres < 0 THEN 0 ELSE t1.sum_acres END AS sum_acres  
FROM UrbanSim.Alt_3_Density_Within_TPAS_By_County as t1 INNER JOIN
dbo.Counties as t2 ON 
t1.COUNTY_ID = t2.CountyFIP;
GO
DROP VIEW UrbanSim.Alt_5_Density_Within_TPAS_By_County_No_Zero;
GO
CREATE VIEW UrbanSim.Alt_5_Density_Within_TPAS_By_County_No_Zero AS
SELECT COUNTYNAME, CASE WHEN t1.sum_residential_units_estimate_2015 > t1.sum_residential_units_estimate_2040 THEN t1.sum_residential_units_estimate_2015 ELSE t1.sum_residential_units_estimate_2040 END AS sum_residential_units_estimate_2040, 
				   t1.sum_job_spaces_estimate_2015 AS sum_job_spaces_estimate_2015, 
				   t1.sum_residential_units_estimate_2015 AS sum_residential_units_estimate_2015, 
				   CASE WHEN t1.sum_job_spaces_estimate_2040 < t1.sum_job_spaces_estimate_2015 THEN t1.sum_job_spaces_estimate_2015 ELSE t1.sum_job_spaces_estimate_2040 END AS sum_job_spaces_estimate_2040, 
	               CASE WHEN t1.sum_acres < 0 THEN 0 ELSE t1.sum_acres END AS sum_acres  
FROM UrbanSim.Alt_5_Density_Within_TPAS_By_County as t1 INNER JOIN
dbo.Counties as t2 ON 
t1.COUNTY_ID = t2.CountyFIP;
GO
DROP VIEW UrbanSim.Alt_1_Density_Within_TPAS_By_County_No_Zero;
GO
CREATE VIEW UrbanSim.Alt_1_Density_Within_TPAS_By_County_No_Zero AS
SELECT COUNTYNAME, CASE WHEN t1.sum_residential_units_estimate_2015 > t1.sum_residential_units_estimate_2040 THEN t1.sum_residential_units_estimate_2015 ELSE t1.sum_residential_units_estimate_2040 END AS sum_residential_units_estimate_2040, 
				   t1.sum_job_spaces_estimate_2015 AS sum_job_spaces_estimate_2015, 
				   t1.sum_residential_units_estimate_2015 AS sum_residential_units_estimate_2015, 
				   CASE WHEN t1.sum_job_spaces_estimate_2040 < t1.sum_job_spaces_estimate_2015 THEN t1.sum_job_spaces_estimate_2015 ELSE t1.sum_job_spaces_estimate_2040 END AS sum_job_spaces_estimate_2040, 
	               CASE WHEN t1.sum_acres < 0 THEN 0 ELSE t1.sum_acres END AS sum_acres  
FROM UrbanSim.Alt_1_Density_Within_TPAS_By_County as t1 INNER JOIN
dbo.Counties as t2 ON 
t1.COUNTY_ID = t2.CountyFIP;


