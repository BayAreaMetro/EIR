--overall summary table
CREATE VIEW Analysis.parcel_footprint_summary_by_run as
SELECT 'run10' as tablename, 
	count(*) AS parcel_count, 
	ROUND(SUM(Acres),0) as sum_acres,
	ROUND(AVG(Acres),2) as avg_acres,
	ROUND(SUM(total_job_spaces),0) as sum_total_job_spaces,
	ROUND(AVG(People_Per_Acre),2) as avg_people_per_acre,
	ROUND(AVG(Jobs_Per_Acre),2) as avg_jobs_per_acre,
	ROUND(SUM(total_residential_units),0) as sum_total_residential_units,
	ROUND(AVG(people_per_acre),2) as avg_ppl_per_acre
FROM [DEIR2017].[Analysis].run10_parcel_output_eir_footprint_spatial
UNION
SELECT 'run11' as tablename, 
	count(*) AS parcel_count, 
	ROUND(SUM(Acres),0) as sum_acres,
	ROUND(AVG(Acres),2) as avg_acres,
	ROUND(SUM(total_job_spaces),0) as sum_total_job_spaces,
	ROUND(AVG(People_Per_Acre),2) as avg_people_per_acre,
	ROUND(AVG(Jobs_Per_Acre),2) as avg_jobs_per_acre,
	ROUND(SUM(total_residential_units),0) as sum_total_residential_units,
	ROUND(AVG(people_per_acre),2) as avg_ppl_per_acre
FROM [DEIR2017].[Analysis].run11_parcel_output_eir_footprint_spatial
UNION
SELECT 'run12' as tablename, 
	count(*) AS parcel_count, 
	ROUND(SUM(Acres),0) as sum_acres,
	ROUND(AVG(Acres),2) as avg_acres,
	ROUND(SUM(total_job_spaces),0) as sum_total_job_spaces,
	ROUND(AVG(People_Per_Acre),2) as avg_people_per_acre,
	ROUND(AVG(Jobs_Per_Acre),2) as avg_jobs_per_acre,
	ROUND(SUM(total_residential_units),0) as sum_total_residential_units,
	ROUND(AVG(people_per_acre),2) as avg_ppl_per_acre
FROM [DEIR2017].[Analysis].run12_parcel_output_eir_footprint_spatial
UNION
SELECT 'run17' as tablename, 
	count(*) AS parcel_count, 
	ROUND(SUM(Acres),0) as sum_acres,
	ROUND(AVG(Acres),2) as avg_acres,
	ROUND(SUM(total_job_spaces),0) as sum_total_job_spaces,
	ROUND(AVG(People_Per_Acre),2) as avg_people_per_acre,
	ROUND(AVG(Jobs_Per_Acre),2) as avg_jobs_per_acre,
	ROUND(SUM(total_residential_units),0) as sum_total_residential_units,
	ROUND(AVG(people_per_acre),2) as avg_ppl_per_acre
FROM [DEIR2017].[Analysis].run17_parcel_output_eir_footprint_spatial
UNION
SELECT 'run7224' as tablename, 
	count(*) AS parcel_count, 
	ROUND(SUM(Acres),0) as sum_acres,
	ROUND(AVG(Acres),2) as avg_acres,
	ROUND(SUM(total_job_spaces),0) as sum_total_job_spaces,
	ROUND(AVG(People_Per_Acre),2) as avg_people_per_acre,
	ROUND(AVG(Jobs_Per_Acre),2) as avg_jobs_per_acre,
	ROUND(SUM(total_residential_units),0) as sum_total_residential_units,
	ROUND(AVG(people_per_acre),0) as avg_ppl_per_acre
  FROM [DEIR2017].[Analysis].run7224_parcel_output_eir_footprint_spatial
UNION
SELECT 'ALT_4' as tablename, 
	count(*) AS parcel_count, 
	ROUND(SUM(Acres),0) as sum_acres,
	ROUND(AVG(Acres),2) as avg_acres,
	ROUND(SUM(total_job_spaces),0) as sum_total_job_spaces,
	ROUND(AVG(People_Per_Acre),2) as avg_people_per_acre,
	ROUND(AVG(Jobs_Per_Acre),2) as avg_jobs_per_acre,
	ROUND(SUM(total_residential_units),0) as sum_total_residential_units,
	ROUND(AVG(people_per_acre),0) as avg_ppl_per_acre
  FROM [DEIR2017].[Analysis].ALT_4_GFP_FC


--summary view of all scenarios on the parcels
CREATE VIEW Analysis.parcel_summary_runs_10_11_12_17_7224 AS
SELECT  run7224.county_id, 
		run7224.parcel_id as parcel_id_7224,
		run10.parcel_id as parcel_id_10,
		run11.parcel_id as parcel_id_11,
		run12.parcel_id as parcel_id_12,
		run17.parcel_id as parcel_id_17,
		run10.year_built as year_built_10,
		run11.year_built as year_built_11,
		run12.year_built as year_built_12,
		run17.year_built as year_built_17,
		run7224.year_built as year_built_7224,
		run10.year_built as total_job_spaces_10,
		run11.total_job_spaces as total_job_spaces_11,
		run12.total_job_spaces as total_job_spaces_12,
		run17.total_job_spaces as total_job_spaces_17,
		run7224.total_job_spaces as total_job_spaces_7224,
		run10.total_residential_units as total_residential_units_10,
		run11.total_residential_units as total_residential_units_11,
		run12.total_residential_units as total_residential_units_12,
		run17.total_residential_units as total_residential_units_17,
		run7224.total_residential_units as total_residential_units_7224,
		run10.year_built as households_10,
		run11.households as households_11,
		run12.households as households_12,
		run17.households as households_17,
		run7224.households as households_7224,
		run10.jobs as jobs_10,
		run11.jobs as jobs_11,
		run12.jobs as jobs_12,
		run17.jobs as jobs_17,
		run7224.jobs as jobs_7224,
		run10.Acres as Acres_10,
		run11.Acres as Acres_11,
		run12.Acres as Acres_12,
		run17.Acres as Acres_17,
		run7224.Acres as Acres_7224,
		run10.People_Per_Acre as People_Per_Acre_10,
		run11.People_Per_Acre as People_Per_Acre_11,
		run12.People_Per_Acre as People_Per_Acre_12,
		run17.People_Per_Acre as People_Per_Acre_17,
		run7224.People_Per_Acre as People_Per_Acre_7224,
		run10.Jobs_Per_Acre as Jobs_Per_Acre_10,
		run11.Jobs_Per_Acre as Jobs_Per_Acre_11,
		run12.Jobs_Per_Acre as Jobs_Per_Acre_12,
		run17.Jobs_Per_Acre as Jobs_Per_Acre_17,
		run7224.Jobs_Per_Acre as Jobs_Per_Acre_7224
FROM Analysis.run7224_parcel_output_eir_footprint_spatial as run7224
FULL OUTER JOIN Analysis.run12_parcel_output_eir_footprint_spatial as run12 
ON run7224.parcel_id = run12.parcel_id
FULL OUTER JOIN Analysis.run11_parcel_output_eir_footprint_spatial as run11 
ON run12.parcel_id = run11.parcel_id
FULL OUTER JOIN Analysis.run17_parcel_output_eir_footprint_spatial as run17 
ON run11.parcel_id = run17.parcel_id
FULL OUTER JOIN Analysis.run10_parcel_output_eir_footprint_spatial as run10
ON run17.parcel_id = run10.parcel_id
WHERE run7224.parcel_id IS NOT NULL AND
run10.parcel_id IS NOT NULL AND
run11.parcel_id IS NOT NULL AND
run12.parcel_id IS NOT NULL AND
run17.parcel_id IS NOT NULL;