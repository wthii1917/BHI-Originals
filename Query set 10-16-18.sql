DROP TABLE IF EXISTS	clean_raw.BHI_Facility_Claim_Header;
CREATE TABLE 			clean_raw.BHI_Facility_Claim_Header
(		claim_ID							VARCHAR( 12 )	ENCODE	ZSTD
	,	member_ID							VARCHAR( 12 )	ENCODE	ZSTD
	,	category_Of_Service_Code			VARCHAR(  3 )	ENCODE	ZSTD
	,	place_Of_Service_Code				VARCHAR(  2 )	ENCODE	ZSTD
	,	admission_Source_Code				VARCHAR(  2 )	ENCODE	ZSTD
	,	admission_Type_Code					VARCHAR(  2 )	ENCODE	ZSTD
	,	claimTypeCode						VARCHAR(  2 )	ENCODE	ZSTD
	,	discharge_Status_Code				VARCHAR(  2 )	ENCODE	ZSTD
	,	type_Of_Bill_Code					VARCHAR(  3 )	ENCODE	ZSTD
	,	first_Date_Of_Service				DATE			ENCODE	ZSTD
	,	last_Date_Of_Service				DATE			ENCODE	ZSTD
	,	admitting_DX_Code					VARCHAR(  7 )	ENCODE	ZSTD
	,	primary_DX_Code						VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_DX_Code1					VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_DX_Code2					VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_DX_Code3					VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_DX_Code4					VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_DX_Code5					VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_DX_Code6					VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_DX_Code7					VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_DX_Code8					VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_DX_Code9					VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_DX_Code10					VARCHAR(  7 )	ENCODE	ZSTD
	,	principal_Procedure_Code			VARCHAR(  6 )	ENCODE	ZSTD
	,	secondary_Procedure_Code1			VARCHAR(  6 )	ENCODE	ZSTD
	,	secondary_Procedure_Code2			VARCHAR(  6 )	ENCODE	ZSTD
	,	secondary_Procedure_Code3			VARCHAR(  6 )	ENCODE	ZSTD
	,	secondary_Procedure_Code4			VARCHAR(  6 )	ENCODE	ZSTD
	,	secondary_Procedure_Code5			VARCHAR(  6 )	ENCODE	ZSTD
	,	billing_Provider_NPI				VARCHAR( 10 )	ENCODE	ZSTD
	,	billing_Provider_Specialty_Code		VARCHAR(  2 )	ENCODE	ZSTD
	,	billing_Provider_Zip_Code			VARCHAR(  5 )	ENCODE	ZSTD
	,	billing_Provide_rMedicare_ID		VARCHAR( 20 )	ENCODE	ZSTD
	,	rendering_Provider_NPI				VARCHAR( 10 )	ENCODE	ZSTD
	,	rendering_Provider_Specialty_Code	VARCHAR(  2 )	ENCODE	ZSTD
	,	rendering_Provider_Zip_Code			VARCHAR(  5 )	ENCODE	ZSTD
	,	claims_System_Assigned_DRG_Code		VARCHAR(  4 )	ENCODE	ZSTD
	,	claims_System_Assigned_MDC_Code		VARCHAR(  2 )	ENCODE	ZSTD
	,	ICD_Code_Type						VARCHAR(  1 )	ENCODE	ZSTD
	,	admitting_ICD10_DX_Code				VARCHAR(  8 )	ENCODE	ZSTD
	,	primary_ICD10_DX_Code				VARCHAR(  8 )	ENCODE	ZSTD
	,	secondary_ICD10_DX_Code1			VARCHAR(  8 )	ENCODE	ZSTD
	,	secondary_ICD10_DX_Code2			VARCHAR(  8 )	ENCODE	ZSTD
	,	secondary_ICD10_DX_Code3			VARCHAR(  8 )	ENCODE	ZSTD
	,	secondary_ICD10_DX_Code4			VARCHAR(  8 )	ENCODE	ZSTD
	,	secondary_ICD10_DX_Code5			VARCHAR(  8 )	ENCODE	ZSTD
	,	secondary_ICD10_DX_Code6			VARCHAR(  8 )	ENCODE	ZSTD
	,	secondary_ICD10_DX_Code7			VARCHAR(  8 )	ENCODE	ZSTD
	,	secondary_ICD10_DX_Code8			VARCHAR(  8 )	ENCODE	ZSTD
	,	secondary_ICD10_DX_Code9			VARCHAR(  8 )	ENCODE	ZSTD
	,	secondary_ICD10_DX_Code10			VARCHAR(  8 )	ENCODE	ZSTD
	,	principal_ICD10_Procedure_Code		VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_ICD10_Procedure_Code1		VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_ICD10_Procedure_Code2		VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_ICD10_Procedure_Code3		VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_ICD10_Procedure_Code4		VARCHAR(  7 )	ENCODE	ZSTD
	,	secondary_ICD10_Procedure_Code5		VARCHAR(  7 )	ENCODE	ZSTD
	,	claim_Payment_Status_Code			VARCHAR(  1 )	ENCODE	ZSTD
	,	non_Covered_Reason_Code				VARCHAR(  2 )	ENCODE	ZSTD
)
DISTSTYLE KEY
DISTKEY( member_ID )
COMPOUND SORTKEY(
		member_ID
	,	claim_ID
	,	rendering_Provider_NPI
	,	first_Date_Of_Service
	,	last_Date_Of_Service
	,	primary_DX_Code
);	/*	CREATE			clean_raw.BHI_Facility_Claim_Header		*/



INSERT INTO	clean_raw.BHI_Facility_Claim_Header
(	SELECT	*
	FROM	cust_abs_raw.bhi_facility_claim_header
);
--ANALYZE COMPRESSION	clean_raw.BHI_Facility_Claim_Header;
ANALYZE					clean_raw.BHI_Facility_Claim_Header;
VACUUM SORT ONLY		clean_raw.BHI_Facility_Claim_Header;
ANALYZE					clean_raw.BHI_Facility_Claim_Header;


/*
COPY		clean_raw.BHI_Facility_Claim_Header
FROM		's3://dhp-rndlab-bhi-data/unzipped/facility_claim_header.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;
*/


DROP TABLE IF EXISTS	clean_raw.BHI_Facility_Claim_Detail;
CREATE TABLE 			clean_raw.BHI_Facility_Claim_Detail
(		claim_ID					VARCHAR( 12 )		ENCODE	ZSTD
	,	claim_Line_Num				INTEGER				ENCODE	ZSTD
	,	member_ID					VARCHAR( 12 )		ENCODE	ZSTD
	,	CPT_HCPCS_Code				VARCHAR(  6 )		ENCODE	ZSTD
	,	procedure_Modifier_Code		VARCHAR(  2 )		ENCODE	ZSTD
	,	revenue_Code				VARCHAR(  4 )		ENCODE	BYTEDICT
	,	number_Of_Units				NUMERIC( 10, 3 )	ENCODE	ZSTD
	,	type_Of_Service_Code		VARCHAR(  5 )		ENCODE	ZSTD
	,	claim_Payment_Status_Code	VARCHAR(  1 )		ENCODE	ZSTD
	,	non_Covered_Reason_Code		VARCHAR(  2 )		ENCODE	ZSTD
	,	TCRRV_Amount				NUMERIC( 10, 2 )	ENCODE	ZSTD
)
DISTSTYLE KEY
DISTKEY( member_ID )
COMPOUND SORTKEY(
		member_ID
	,	claim_ID
	,	claim_Line_Num
	,	CPT_HCPCS_Code
	,	procedure_Modifier_Code
);	/*	CREATE			clean_raw.BHI_Facility_Claim_Detail		*/



INSERT INTO	clean_raw.BHI_Facility_Claim_Detail
(	SELECT	*
	FROM	cust_abs_raw.bhi_facility_claim_detail
);
--ANALYZE COMPRESSION	clean_raw.BHI_Facility_Claim_Detail;
ANALYZE					clean_raw.BHI_Facility_Claim_Detail;
VACUUM SORT ONLY		clean_raw.BHI_Facility_Claim_Detail;
ANALYZE					clean_raw.BHI_Facility_Claim_Detail;


/*
COPY		clean_raw.BHI_Facility_Claim_Detail
FROM		's3://dhp-rndlab-bhi-data/unzipped/facility_claim_detail.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;
*/


DROP TABLE IF EXISTS	clean_raw.BHI_Pharmacy_Claims;
CREATE TABLE 			clean_raw.BHI_Pharmacy_Claims
(		claim_ID							VARCHAR( 12 )		ENCODE	ZSTD
	,	claim_Line_Num						INTEGER				ENCODE	ZSTD
	,	member_ID							VARCHAR( 12 )		ENCODE	ZSTD
	,	place_Of_Service_Code				VARCHAR(  2 )		ENCODE	ZSTD
	,	NDC_Code							VARCHAR( 11 )		ENCODE	ZSTD
	,	count_Of_Days_Supply				INTEGER				ENCODE	ZSTD
	,	dispensed_Quantity					NUMERIC( 10, 3 )	ENCODE	ZSTD
	,	prescription_Fill_Date				DATE				ENCODE	ZSTD
	,	billing_Provider_NPI				VARCHAR( 10 )		ENCODE	ZSTD
	,	rendering_Provider_NPI				VARCHAR( 10 )		ENCODE	ZSTD
	,	prescribing_Provider_NPI			VARCHAR( 10 )		ENCODE	ZSTD
	,	prescribing_Provider_DEA_NCPDP_ID	VARCHAR( 27 )		ENCODE	ZSTD
	,	compound_Indicator					VARCHAR(  1 )		ENCODE	ZSTD
	,	DAW_Code							VARCHAR(  2 )		ENCODE	ZSTD
	,	dispensing_Status_Code				VARCHAR(  1 )		ENCODE	ZSTD
	,	plan_Specialty_Drug_Indicator		VARCHAR(  1 )		ENCODE	ZSTD
	,	TCRRV_Amount						NUMERIC( 10, 2 )	ENCODE	ZSTD
)
DISTSTYLE KEY
DISTKEY( member_ID )
COMPOUND SORTKEY(
		member_ID
	,	claim_ID
	,	claim_Line_Num
	,	prescribing_Provider_NPI
	,	NDC_Code
	,	prescription_Fill_Date
);	/*	CREATE			clean_raw.BHI_Pharmacy_Claims		*/



INSERT INTO	clean_raw.BHI_Pharmacy_Claims
(	SELECT	*
	FROM	cust_abs_raw.bhi_pharmacy_claims
);
--ANALYZE COMPRESSION	clean_raw.BHI_Pharmacy_Claims;
ANALYZE					clean_raw.BHI_Pharmacy_Claims;
VACUUM SORT ONLY		clean_raw.BHI_Pharmacy_Claims;
ANALYZE					clean_raw.BHI_Pharmacy_Claims;



/*
COPY		clean_raw.BHI_Pharmacy_Claims
FROM		's3://dhp-rndlab-bhi-data/unzipped/pharmacy_claim.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;
*/


DROP TABLE IF EXISTS	clean_raw.BHI_Professional_Claims;
CREATE TABLE 			clean_raw.BHI_Professional_Claims
(		claim_ID							VARCHAR( 12 )		ENCODE	ZSTD
	,	claim_Line_Num						INTEGER				ENCODE	ZSTD
	,	member_ID							VARCHAR( 12 )		ENCODE	ZSTD
	,	category_Of_Service_Code			VARCHAR(  3 )		ENCODE	ZSTD
	,	place_Of_Service_Code				VARCHAR(  2 )		ENCODE	ZSTD
	,	claim_Type_Code						VARCHAR(  2 )		ENCODE	ZSTD
	,	CPT_HCPCS_Code						VARCHAR(  6 )		ENCODE	ZSTD
	,	CPT_Modifier_Code					VARCHAR(  2 )		ENCODE	ZSTD
	,	number_Of_Units						NUMERIC( 10, 3 )	ENCODE	ZSTD
	,	type_Of_Service_Code				VARCHAR(  5 )		ENCODE	BYTEDICT
	,	first_Date_Of_Service				DATE				ENCODE	ZSTD
	,	last_Date_Of_Service				DATE				ENCODE	ZSTD
	,	primary_DX_Code						VARCHAR(  7 )		ENCODE	ZSTD
	,	secondary_DX_Code1					VARCHAR(  7 )		ENCODE	ZSTD
	,	secondary_DX_Code2					VARCHAR(  7 )		ENCODE	ZSTD
	,	secondary_DX_Code3					VARCHAR(  7 )		ENCODE	ZSTD
	,	billing_Provider_NPI				VARCHAR( 10 )		ENCODE	ZSTD
	,	billing_Provider_Specialty_Code		VARCHAR(  2 )		ENCODE	ZSTD
	,	billing_Provider_Zip_Code			VARCHAR(  5 )		ENCODE	ZSTD
	,	billing_Provider_Medicare_ID		VARCHAR( 20 )		ENCODE	ZSTD
	,	rendering_Provider_NPI				VARCHAR( 10 )		ENCODE	ZSTD
	,	rendering_Provider_Specialty_Code	VARCHAR(  2 )		ENCODE	ZSTD
	,	rendering_Provider_Type_Code		VARCHAR(  2 )		ENCODE	ZSTD
	,	rendering_Provider_Zip_Code			VARCHAR(  5 )		ENCODE	ZSTD
	,	ICD_Code_Type						VARCHAR(  1 )		ENCODE	ZSTD
	,	primary_ICD10_DX_Code				VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code1			VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code2			VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code3			VARCHAR(  8 )		ENCODE	ZSTD
	,	claim_Payment_Status_Code			VARCHAR(  1 )		ENCODE	ZSTD
	,	non_Covered_Reason_Code				VARCHAR(  2 )		ENCODE	ZSTD
	,	TCRRV_Amount						NUMERIC( 10, 2 )	ENCODE	ZSTD
)
DISTSTYLE KEY
DISTKEY( member_ID )
COMPOUND SORTKEY(
		member_ID
	,	claim_ID
	,	claim_Line_Num
	,	rendering_Provider_NPI
	,	primary_DX_Code
	,	CPT_HCPCS_Code
	,	first_Date_Of_Service
	,	last_Date_Of_Service
);	/*	CREATE			clean_raw.BHI_Professional_Claims		*/



INSERT INTO	clean_raw.BHI_Professional_Claims
(	SELECT	*
	FROM	cust_abs_raw.bhi_professional_claims
);
--ANALYZE COMPRESSION	clean_raw.BHI_Professional_Claims;
ANALYZE					clean_raw.BHI_Professional_Claims;
VACUUM SORT ONLY		clean_raw.BHI_Professional_Claims;
ANALYZE					clean_raw.BHI_Professional_Claims;


/*
COPY		clean_raw.BHI_Profesional_Claims
FROM		's3://dhp-rndlab-bhi-data/unzipped/pfo_claim.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;
*/


