setlocal EnableDelayedExpansion
rem "parcel_output runs"
set po_runs=run10_parcel_output run11_parcel_output ^
run12_parcel_output run17_parcel_output run7224_parcel_output
rem "parcel_output query"
set po_query=SELECT cast(parcel_id as integer(40)) ^
as parcel_id, cast(year_built as integer(4)) as year_built

rem "parcel_diff runs"
set pd_runs=run10_parcel_data_diff run11_parcel_data_diff ^
run12_parcel_data_diff run17_parcel_data_diff run7224_parcel_data_diff
rem "parcel_diff query"
set pd_query=SELECT cast(parcel_id as integer(40)) as parcel_id, ^
cast(total_job_spaces as numeric(8,2)) as total_job_spaces, ^
cast(total_residential_units as numeric(8,2)) as total_residential_units

(for %%a in (%po_runs%) do ( 
   ogr2ogr -append ^
   -nln %%a ^
   -f FileGDB ^
   -sql "%po_query% FROM %%a" update_footprints.gdb %%a.csv
))

(for %%a in (%pd_runs%) do ( 
   ogr2ogr -append ^
   -nln %%a ^
   -f FileGDB ^
   -sql "%pd_query% FROM %%a WHERE cast(total_residential_units as numeric(8,2)) > 0 OR cast(total_job_spaces as numeric(8,2))>0" update_footprints.gdb %%a.csv
))
