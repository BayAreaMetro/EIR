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
                         t1.parcel_id, t1.Estimated_Population AS Estimated_Population,
                          t1.total_residential_units AS total_residential_units, 
                         t1.total_job_spaces AS total_job_spaces, t1.Acres 
                         AS Acres, t1.People_Per_Acre AS People_Per_Acre, 
                         t1.Jobs_Per_Acre AS Jobs_Per_Acre
FROM            UrbanSim.COUNTIES_TPAS_ALT_4_OVERLAY_NO_DUPS as t1
WHERE t1.FID_TPAs = 1
ORDER BY t1.parcel_id
Go
--Drop view UrbanSim.Dup_GrowthParcels 
create view UrbanSim.Dup_GrowthParcels as
SELECT        parcel_id, COUNT(parcel_id) AS Total_Dups
FROM            UrbanSim.COUNTIES_TPAS_ALT_4_OVERLAY
GROUP BY parcel_id
HAVING        (COUNT(parcel_id) > 1)
ORDER BY Total_Dups DESC

--Need to fix parcels that cross county borders. The list below identifies those parcels that cross county borders.  This occurs due to the differences in the geometry between the parcel dataset and the TomTom Basemap County boundaries.
--There are 10 parcels that fit this condition.
SELECT        parcel_id, COUNT(parcel_id) AS Total_Dups
FROM            UrbanSim.Alt_4_Counties_TPAs_Density
GROUP BY parcel_id
HAVING        (COUNT(parcel_id) > 1)
ORDER BY Total_Dups DESC

select * From UrbanSim.Alt_4_Counties_TPAs_Density
Where parcel_id = '1019099'

--create a view that removes the duplicates

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
