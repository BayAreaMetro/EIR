Create View Analysis.compare_footprint_output as
SELECT  p1.parcel_id as gfpid,
   		p2.parcel_id as runpid,
		p1.year_built-p2.year_built as diff_year_built,
		p1.total_job_spaces-p2.total_job_spaces as diff_job_spaces,
		p1.total_residential_units-p2.total_residential_units as diff_total_residential_units,
		p1.Acres-p2.Acres as diff_Acres,
		p1.People_Per_Acre-p2.People_Per_Acre as diff_People_Per_Acre,
		p1.Jobs_Per_Acre-p2.Jobs_Per_Acre as diff_Jobs_Per_Acre,
		p1.Shape
FROM Analysis.ALT_4_GFP_FC as p1
LEFT JOIN Analysis.run7224_parcel_output_spatial as p2
ON p1.parcel_id = p2.parcel_id;