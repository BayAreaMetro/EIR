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

/*
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

---based on table creation in Build_Alternative_4_Footprint file...
create view UrbanSim.Alt_4_2040_parcel_units_and_jobs_total as
SELECT
	Cast(2.69*y2040.total_residential_units as numeric(18,0)) as Estimated_Population, 
	Cast(y2040.total_residential_units as numeric(18,0)) as total_residential_units, 
	y2040.total_job_spaces, 
	Round(p.shape.STArea()*0.000247105381,2) as Acres,
	Cast((2.69*y2040.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
	Cast((y2040.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
FROM            
	UrbanSim.Parcels AS p ON y2040.parcel_id = p.PARCEL_ID JOIN
	UrbanSim.RUN7224_PARCEL_DATA_2040 AS y2040 ON p.PARCEL_ID = y2040.parcel_id
Go

create view UrbanSim.Alt_4_2040_parcel_units_and_jobs_total as
SELECT
	y2040.Estimated_Population-t1.Estimated_Population,
	y2040.total_residential_units-t1.total_residential_units, 
	y2040.total_job_spaces-t1.total_job_spaces,
	y2040.Acres-t1.Acres,
	y2040.People_Per_Acre-t1.People_Per_Acre,
	y2040.Jobs_Per_Acre-t1.Jobs_Per_Acre,
FROM            
	UrbanSim.Alt_4_Counties_TPAs_Density as t1 JOIN
	UrbanSim.Alt_4_2040_parcel_units_and_jobs_total AS y2040 ON p.PARCEL_ID = y2040.parcel_id
Go

create view UrbanSim.Alt_4_2040_parcel_units_and_jobs_total as
SELECT
	y2040.Estimated_Population-t1.Estimated_Population,
	y2040.total_residential_units-t1.total_residential_units, 
	y2040.total_job_spaces-t1.total_job_spaces,
	y2040.Acres-t1.Acres,
	y2040.People_Per_Acre-t1.People_Per_Acre,
	y2040.Jobs_Per_Acre-t1.Jobs_Per_Acre,
FROM            
	UrbanSim.Alt_4_Counties_TPAs_Density as t1 JOIN
	UrbanSim.Alt_4_2040_parcel_units_and_jobs_total AS y2040 ON p.PARCEL_ID = y2040.parcel_id
Go

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

/****** Script for SelectTopNRows command from SSMS  ******/

-----------------------
---county summary tables
-----------------------

DROP VIEW UrbanSim.Alt_4_Density_Within_TPAS_By_County;
GO
CREATE VIEW UrbanSim.Alt_4_Density_Within_TPAS_By_County AS
SELECT COUNTYNAME, SUM(t1.total_residential_units) AS sum_total_residential_units, 
				   SUM(t1.total_job_spaces) AS sum_total_job_spaces, 
	               SUM(t1.Acres) AS sum_Acres  
FROM UrbanSim.Alt_4_Counties_TPAs_Density_Distinct as t1
GROUP BY COUNTYNAME;
GO
DROP VIEW UrbanSim.Alt_3_Density_Within_TPAS_By_County;
GO
CREATE VIEW UrbanSim.Alt_3_Density_Within_TPAS_By_County AS
SELECT COUNTYNAME, SUM(t1.total_residential_units) AS sum_total_residential_units, 
				   SUM(t1.total_job_spaces) AS sum_total_job_spaces, 
	               SUM(t1.Acres) AS sum_Acres  
FROM UrbanSim.Alt_3_Counties_TPAs_Density_Distinct as t1
GROUP BY COUNTYNAME;
GO
DROP VIEW UrbanSim.Alt_5_Density_Within_TPAS_By_County;
GO
CREATE VIEW UrbanSim.Alt_5_Density_Within_TPAS_By_County AS
SELECT COUNTYNAME, SUM(t1.total_residential_units) AS sum_total_residential_units, 
				   SUM(t1.total_job_spaces) AS sum_total_job_spaces, 
	               SUM(t1.Acres) AS sum_Acres  
FROM UrbanSim.Alt_5_Counties_TPAs_Density_Distinct as t1
GROUP BY COUNTYNAME;
GO
DROP VIEW UrbanSim.Alt_1_Density_Within_TPAS_By_County;
GO
CREATE VIEW UrbanSim.Alt_1_Density_Within_TPAS_By_County AS
SELECT COUNTYNAME, SUM(t1.total_residential_units) AS sum_total_residential_units, 
				   SUM(t1.total_job_spaces) AS sum_total_job_spaces, 
	               SUM(t1.Acres) AS sum_Acres  
FROM UrbanSim.Alt_1_Counties_TPAs_Density_Distinct as t1
GROUP BY COUNTYNAME;

--Convert Negatives to Zeros
----

DROP VIEW UrbanSim.Alt_4_Density_Within_TPAS_By_County_No_Zero;
GO
CREATE VIEW UrbanSim.Alt_4_Density_Within_TPAS_By_County_No_Zero AS
SELECT COUNTYNAME, CASE WHEN t1.sum_total_residential_units < 0 THEN 0 ELSE t1.sum_total_residential_units END AS sum_total_residential_units, 
				   CASE WHEN t1.sum_total_job_spaces < 0 THEN 0 ELSE t1.sum_total_job_spaces END AS sum_total_job_spaces, 
	               CASE WHEN t1.sum_Acres < 0 THEN 0 ELSE t1.sum_Acres END AS sum_Acres  
FROM UrbanSim.Alt_4_Density_Within_TPAS_By_County as t1;
GO
DROP VIEW UrbanSim.Alt_3_Density_Within_TPAS_By_County_No_Zero;
GO
CREATE VIEW UrbanSim.Alt_3_Density_Within_TPAS_By_County_No_Zero AS
SELECT COUNTYNAME, CASE WHEN t1.sum_total_residential_units < 0 THEN 0 ELSE t1.sum_total_residential_units END AS sum_total_residential_units, 
				   CASE WHEN t1.sum_total_job_spaces < 0 THEN 0 ELSE t1.sum_total_job_spaces END AS sum_total_job_spaces, 
	               CASE WHEN t1.sum_Acres < 0 THEN 0 ELSE t1.sum_Acres END AS sum_Acres  
FROM UrbanSim.Alt_3_Density_Within_TPAS_By_County as t1;
GO
DROP VIEW UrbanSim.Alt_5_Density_Within_TPAS_By_County_No_Zero;
GO
CREATE VIEW UrbanSim.Alt_5_Density_Within_TPAS_By_County_No_Zero AS
SELECT COUNTYNAME, CASE WHEN t1.sum_total_residential_units < 0 THEN 0 ELSE t1.sum_total_residential_units END AS sum_total_residential_units, 
				   CASE WHEN t1.sum_total_job_spaces < 0 THEN 0 ELSE t1.sum_total_job_spaces END AS sum_total_job_spaces, 
	               CASE WHEN t1.sum_Acres < 0 THEN 0 ELSE t1.sum_Acres END AS sum_Acres  
FROM UrbanSim.Alt_5_Density_Within_TPAS_By_County as t1;
GO
DROP VIEW UrbanSim.Alt_1_Density_Within_TPAS_By_County_No_Zero;
GO
CREATE VIEW UrbanSim.Alt_1_Density_Within_TPAS_By_County_No_Zero AS
SELECT COUNTYNAME, CASE WHEN t1.sum_total_residential_units < 0 THEN 0 ELSE t1.sum_total_residential_units END AS sum_total_residential_units, 
				   CASE WHEN t1.sum_total_job_spaces < 0 THEN 0 ELSE t1.sum_total_job_spaces END AS sum_total_job_spaces, 
	               CASE WHEN t1.sum_Acres < 0 THEN 0 ELSE t1.sum_Acres END AS sum_Acres  
FROM UrbanSim.Alt_1_Density_Within_TPAS_By_County as t1;