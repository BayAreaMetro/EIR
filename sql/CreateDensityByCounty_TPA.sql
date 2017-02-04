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
/*
GOAL:
3.       Quantify by County the:
a.       2015 and 2040 Dwelling Units per acre within TPAs
b.       2015 and 2040 Employment/Jobs per acre within TPAs
4. Quantify by County the acres of overlap between the Preferred Scenario’s (proposed Plan) land use footprint and transportation footprint.
*/ 
create view UrbanSim.Alt_4_Counties_TPAs_Density as
SELECT  Top 50000      t1.FID_Counties, t1.FID_TPAs, 
	                     t1.COUNTYNAME, t1.CountyFIP, 
	                     t1.parcel_id, 
	                     t1.Estimated_Population AS Estimated_Population,
	                     t1.total_residential_units AS total_residential_units, 
	                     t1.total_job_spaces AS total_job_spaces, 
	                     t1.Acres AS Acres, 
	                     t1.People_Per_Acre AS People_Per_Acre, 
	                     t1.Jobs_Per_Acre AS Jobs_Per_Acre,
	                     (t1.total_residential_units/t1.Acres) AS dwelling_units_per_acre
FROM            UrbanSim.COUNTIES_TPAS_ALT_4_OVERLAY_NO_DUPS as t1
WHERE t1.FID_TPAs = 1
ORDER BY t1.parcel_id
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


SELECT q2.* INTO UrbanSim.County_Dup_Parcels_POS FROM (
SELECT t1.parcel_id as parcel_id, t2.Shape.STPointOnSurface() as PointGeom
FROM UrbanSim.County_Dup_Parcels as t1,
UrbanSim.Parcels as t2
WHERE t1.parcel_id = t2.parcel_id) as q2


CREATE VIEW UrbanSim.County_Dup_Parcels_Resolved AS
SELECT 
		t2.parcel_id, t3.COUNTYNAME, t3.CountyFIP
FROM 
		UrbanSim.County_Dup_Parcels_POS as t2 
INNER JOIN
		dbo.COUNTIES as t3
ON 
		t2.PointGeom.STWithin(t3.Shape) = 1

CREATE VIEW UrbanSim.COUNTIES_TPAS_ALT_4_OVERLAY_NO_DUPS AS
select * FROM UrbanSim.COUNTIES_TPAS_ALT_4_OVERLAY 
WHERE NOT 
( (PARCEL_ID = 389059 AND countyFIP <> 1) OR
	(PARCEL_ID = 389065 AND countyFIP <> 1) OR
	(PARCEL_ID = 728181 AND countyFIP <> 13)  OR
	(PARCEL_ID = 729197 AND countyFIP <> 13)  OR
	(PARCEL_ID = 1019099 AND countyFIP <> 75)  OR
	(PARCEL_ID = 1038093 AND countyFIP <> 81)  OR
	(PARCEL_ID = 1050874 AND countyFIP <> 81)  OR
	(PARCEL_ID = 1196423 AND countyFIP <> 81)  OR
	(PARCEL_ID = 1311949 AND countyFIP <> 85)  OR
	(PARCEL_ID = 1311950 AND countyFIP <> 85) )
