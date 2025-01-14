## Files

Rough take on what the SQL scripts do.  

### [AddSummaryClassDescription.sql](https://github.com/MetropolitanTransportationCommission/UrbanSim_Spatial_Analysis/blob/master/sql/AddSummaryClassDescription.sql)   

Output tables summarizing housing and/or employment change in Transit Priority Areas and Priority Development Areas in Alternative 4 (aka land use model run 7224c)

### [eir_summary_tables directory](https://github.com/MetropolitanTransportationCommission/UrbanSim_Spatial_Analysis/tree/master/sql/eir_summary_tables)

Output summaries of acres in Transit Priority Areas and the estimated growth 'footprint' by county for the EIR for all scenarios/alternatives. Footprint has a particular meaning defined in the query but generally means locations where housing or employment changes are estimates to occur.   

### [Build_Alternative_4_Footprint_2015_thru_2040.sql](https://github.com/MetropolitanTransportationCommission/UrbanSim_Spatial_Analysis/blob/master/sql/Build_Alternative_4_Footprint_2015_thru_2040.sql)  

Output the 'footprint' of growth from 2015 to 2040 for the EIR Analysis.  Footprint has a particular meaning defined in the query but generally means locations where housing or employment changes are estimates to occur. 

### [CreateDensityByCounty_TPA.sql](https://github.com/MetropolitanTransportationCommission/UrbanSim_Spatial_Analysis/blob/master/sql/CreateDensityByCounty_TPA.sql)  

Output a table of Land Use density by Transit Priority Areas.  

### [get_far_and_density.sql](https://github.com/MetropolitanTransportationCommission/UrbanSim_Spatial_Analysis/blob/master/sql/get_far_and_density.sql) 

Output the feature class geometry for the 2017 version of Map 7 - Transit Priority Project CEQA Streamlining (PBA '13)   

### eir_pda_tpa_demo_summaries.sql  
 
Summarize demographic data produced by UrbanSim for the following geographies:  
	County  
	PDA   
	TPA   
Utilize UrbanSim output from the following runs:   
	Run 7224 2015 (Baseline)    
	Run 7224 2040 (Plan)   
	Run r10 2040 (No Project)   
	Run r11 (Main Streets)   
	Run r12 (Big Cities)  
	Run r17 (EES)  

### [parcels_setup.sql](https://github.com/MetropolitanTransportationCommission/UrbanSim_Spatial_Analysis/blob/master/sql/parcels_setup.sql) 

Used to setup (index, etc) a parcels table if necessary.
  
