
--Build All Scenario Growth Footprint Tables using rules defined below:
--Select parcels where year built is greater than or equal to 2016. 
--Join to parcel geometry using parcel_id in parcel_shareable_09_01_2016 https://github.com/MetropolitanTransportationCommission/bayarea_urbansim#parcel-geometries
--To get the total res and jobs units, join to parcel_output.csv files from urbansim
--The footprint uses a threshold of greatet than 8 ppl per acre or 10 jobs per acre.
--Because the urbansim output does not contain ppl per parcel, an average hhsize of 2.69 was used to estimate population for each parcel based upon nthe number of res. units on that parcel.
--Because the alt output does not contain ppl per parcel, an average hhsize of 2.69 was used to estimate population for each parcel based upon nthe number of res. units on that parcel.
--select count(objectid) From Analysis.Analysis_Parcels
--Total Parcels (1956208)
Create View Analysis.run10_parcel_output_eir_footprint_spatial as
SELECT  p.COUNTY_ID as county_id, 
		r.parcel_id as parcel_id, 
		cast(r.year_built as float) as year_built,
		cast(pd.total_job_spaces as float) as total_job_spaces,
		cast(pd.total_residential_units as float) as total_residential_units,
		Round(p.shape.STArea()*0.000247105381,2) as Acres,
		Cast((2.69*pd.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
		Cast((pd.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
		p.Shape as Shape
FROM Analysis.run10_parcel_data_diff_eirslct as pd
left join Analysis.run10_parcel_output_eirslct as r
on pd.parcel_id = r.parcel_id
LEFT JOIN Analysis.p09_01_2015_parcel_shareable as p
ON p.parcel_id = r.parcel_id
WHERE cast(r.year_built AS float)>2015;

GO

CREATE VIEW Analysis.run17_parcel_output_eir_footprint_spatial AS
SELECT  p.COUNTY_ID as county_id, 
		r.parcel_id as parcel_id, 
		cast(r.year_built as integer) as year_built,
		cast(pd.total_job_spaces as integer) as total_job_spaces,
		cast(pd.total_residential_units as integer) as total_residential_units,
		Round(p.shape.STArea()*0.000247105381,2) as Acres,
		Cast((2.69*pd.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
		Cast((pd.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
		p.Shape as Shape
FROM Analysis.run17_parcel_data_diff_eirslct as pd
left join Analysis.run17_parcel_output_eirslct as r
on pd.parcel_id = r.parcel_id
left join Analysis.p09_01_2015_parcel_shareable as p
on p.parcel_id = r.parcel_id
WHERE cast(r.year_built as integer)>2015;

GO

CREATE VIEW Analysis.run11_parcel_output_eir_footprint_spatial AS
SELECT  p.COUNTY_ID as county_id, 
		r.parcel_id as parcel_id, 
		cast(r.year_built as integer) as year_built,
		cast(pd.total_job_spaces as integer) as total_job_spaces,
		cast(pd.total_residential_units as integer) as total_residential_units,
		Round(p.shape.STArea()*0.000247105381,2) as Acres,
		Cast((2.69*pd.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
		Cast((pd.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
		p.Shape as Shape
FROM Analysis.run11_parcel_data_diff_eirslct as pd
left join Analysis.run11_parcel_output_eirslct as r
on pd.parcel_id = r.parcel_id
left join Analysis.p09_01_2015_parcel_shareable as p
on p.parcel_id = r.parcel_id
WHERE cast(r.year_built as integer)>2015;

GO 

CREATE VIEW Analysis.run12_parcel_output_eir_footprint_spatial AS
SELECT  p.COUNTY_ID as county_id, 
		r.parcel_id as parcel_id, 
		cast(r.year_built as integer) as year_built,
		cast(pd.total_job_spaces as integer) as total_job_spaces,
		cast(pd.total_residential_units as integer) as total_residential_units,
		Round(p.shape.STArea()*0.000247105381,2) as Acres,
		Cast((2.69*pd.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
		Cast((pd.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
		p.Shape as Shape
FROM Analysis.run12_parcel_data_diff_eirslct as pd
left join Analysis.run12_parcel_output_eirslct as r
on pd.parcel_id = r.parcel_id
left join Analysis.p09_01_2015_parcel_shareable as p
on p.parcel_id = r.parcel_id
WHERE cast(r.year_built as integer)>2015;

GO 

CREATE VIEW Analysis.run7224_parcel_output_eir_footprint_spatial AS
SELECT  p.COUNTY_ID as county_id, 
		r.parcel_id as parcel_id, 
		cast(r.year_built as integer) as year_built,
		cast(pd.total_job_spaces as integer) as total_job_spaces,
		cast(pd.total_residential_units as integer) as total_residential_units,
		Round(p.shape.STArea()*0.000247105381,2) as Acres,
		Cast((2.69*pd.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
		Cast((pd.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
		p.Shape as Shape
FROM Analysis.run7224_parcel_data_diff_eirslct as pd
left join Analysis.run7224_parcel_output_eirslct as r
on pd.parcel_id = r.parcel_id
left join Analysis.p09_01_2015_parcel_shareable as p
on p.parcel_id = r.parcel_id
WHERE cast(r.year_built as integer)>2015;

/*Cast(2.69*alt_4_Diff.total_residential_units as numeric(18,0)) as Estimated_Population, 
Round(p.shape.STArea()*0.000247105381,2) as Acres,
Cast((2.69*alt_4_Diff.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
Cast((alt_4_Diff.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
WHERE        (People_Per_Acre >= 8) OR
                         (Jobs_Per_Acre >= 10)*/


