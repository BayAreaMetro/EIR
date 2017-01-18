/*S0 No Project: r10
S1 Main Streets: r11
S3 Big Three: r12
S4 Preferred: r7224c
S5 EEJ: r17*/

Create View Analysis.ALT_0_GFP_FC as
SELECT  *
FROM Analysis.run10_parcel_output_eir_footprint_spatial
WHERE (People_Per_Acre >= 8) OR (Jobs_Per_Acre >= 10);

GO

CREATE VIEW Analysis.ALT_5_GFP_FC AS
SELECT  *
FROM Analysis.run17_parcel_output_eir_footprint_spatial
WHERE (People_Per_Acre >= 8) OR (Jobs_Per_Acre >= 10);

GO

CREATE VIEW Analysis.ALT_1_GFP_FC AS
SELECT  *
FROM Analysis.run11_parcel_output_eir_footprint_spatial
WHERE (People_Per_Acre >= 8) OR (Jobs_Per_Acre >= 10);

GO 

CREATE VIEW Analysis.ALT_3_GFP_FC AS
SELECT  *
FROM Analysis.run12_parcel_output_eir_footprint_spatial
WHERE (People_Per_Acre >= 8) OR (Jobs_Per_Acre >= 10);

GO 

/*CREATE VIEW Analysis.ALT_4_GFP_FC AS
SELECT  *
FROM Analysis.run7224_parcel_output_eir_footprint_spatial
WHERE (People_Per_Acre >= 8) OR (Jobs_Per_Acre >= 10);*/
