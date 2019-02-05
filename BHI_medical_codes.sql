/********************************************************************************/
/*																				*/
/*	FILE:			BHI_medical_codes											*/
/*	PROGRAMMED BY:	Will Haight (wthii)											*/
/*	DATE:			October, 2018												*/
/*	NOTES:			The following tables are established in this file:			*/
/*				1.	clean_raw.BHI_cpt_codes_pre			*						*/
/*				2.	clean_raw.BHI_cpt_codes										*/
/*				3.	clean_raw.BHI_ICD9_DX_codes_pre		*						*/
/*				4.	clean_raw.BHI_ICD9_DX_codes									*/
/*				5.	clean_raw.BHI_ICD10_DX_codes_pre	*						*/
/*				6.	clean_raw.BHI_ICD10_DX_codes								*/
/*				7.	clean_raw.BHI_ndc_codes_pre			*						*/
/*				8.	clean_raw.BHI_ndc_codes										*/
/*				9.	clean_raw.BHI_ndc_codes_package		*						*/
/*				10.	clean_raw.BHI_ndc_codes_product		*						*/
/*				11.	clean_raw.BHI_ndc_codes										*/
/*	*	Any table appended with a "_pre" (tables 1, 3, 5, and 7) is deleted		*/
/*		once the table of thesame name but without "_pre" is built.  Also, 		*/
/*		tables 9 and 10 may be deleted once table 11 is built.					*/
/*																				*/
/*	MODIFICATIONS																*/
/*		1.	BY:		wthii														*/
/*			DATE:	12/6/2018													*/
/*			NOTES:	Inserted documentation.										*/
/*																				*/
/*		2.	BY:																	*/
/*			DATE:																*/
/*			NOTES:																*/
/*																				*/
/********************************************************************************/



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the table designed to receive the raw data	*/
/*	for a reference table of CPT codes.  This is not the final table and needs	*/
/*	one additional column.														*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_cpt_codes_pre;
CREATE TABLE			ref.BHI_cpt_codes_pre
(		HCPCS_CPT_Code		VARCHAR( 14 )	ENCODE	RAW
	,	Short_Description	VARCHAR( 28 )	ENCODE	RAW
	,	Year				VARCHAR(  4 )	ENCODE	RAW
)
DISTSTYLE ALL
COMPOUND SORTKEY( HCPCS_CPT_Code );



/********************************************************************************/
/*																				*/
/*	This command copies raw data from an S3 bucket at amazon into the table		*/
/*	ref.BHI_cpt_codes_pre.  													*/
/*																				*/
/********************************************************************************/
COPY		ref.BHI_cpt_codes_pre
FROM		's3://dhp-randlab-s3/users/mpazen/codesets/CPT.txt'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers' COMPUPDATE ON;

--ANALYZE COMPRESSION	ref.BHI_cpt_codes_pre;
ANALYZE				ref.BHI_cpt_codes_pre;
VACUUM SORT ONLY	ref.BHI_cpt_codes_pre;
ANALYZE				ref.BHI_cpt_codes_pre;



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the reference table of CPT codes.			*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_cpt_codes;
CREATE TABLE			ref.BHI_cpt_codes
(		HCPCS_CPT_Code		VARCHAR( 14 )	ENCODE	RAW
	,	short_Desc			VARCHAR( 28 )	ENCODE	RAW
	,	short_Desc_alphanu	VARCHAR( 28 )	ENCODE	RAW
	,	year				VARCHAR(  4 )	ENCODE	RAW
)
DISTSTYLE ALL
COMPOUND SORTKEY( HCPCS_CPT_Code );



/********************************************************************************/
/*																				*/
/*	The INSERT command below populates the table ref.BHI_cpt_codes				*/
/*	based on values in the table ref.BHI_cpt_codes_pre, but with one			*/
/*	extra column which replaces all non-alphanumeric characters in the short	*/
/*	description column with blanks.												*/
/*																				*/
/********************************************************************************/
INSERT INTO	ref.BHI_cpt_codes
(	SELECT DISTINCT
			( HCPCS_CPT_Code )		::	VARCHAR( 14 )	AS	HCPCS_CPT_Code
		,	( Short_Description )	::	VARCHAR( 28 )	AS	short_Desc
		,	( REGEXP_REPLACE( Short_Description, '[^a-zA-Z0-9]+', ' ' ) )
									::	VARCHAR( 28 )	AS	short_Desc_alphanu
		,	( Year )				::	VARCHAR(  4 )	AS	year
	FROM
		ref.BHI_cpt_codes_pre
);
--ANALYZE COMPRESSION	ref.BHI_cpt_codes;
ANALYZE				ref.BHI_cpt_codes;
VACUUM SORT ONLY	ref.BHI_cpt_codes;
ANALYZE				ref.BHI_cpt_codes;



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the table designed to receive the raw data	*/
/*	for a reference table of ICD 9 DX codes.  This is not the final table.		*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_ICD9_DX_codes_pre;
CREATE TABLE			ref.BHI_ICD9_DX_codes_pre
(		dx_code			VARCHAR(   5 )	ENCODE	ZSTD
	,	First			DATE			ENCODE	ZSTD
	,	Last			DATE			ENCODE	ZSTD
	,	dx_short_desc	VARCHAR(  24 )	ENCODE	ZSTD
	,	version			VARCHAR(   1 )	ENCODE	ZSTD
	,	dx_long_desc	VARCHAR( 222 )	ENCODE	ZSTD
	,	CLASS			VARCHAR(  69 )	ENCODE	ZSTD
	,	SubCLASS		VARCHAR( 156 )	ENCODE	ZSTD
	,	SUBSubCLASS		VARCHAR( 156 )	ENCODE	RAW
)
DISTSTYLE ALL
COMPOUND SORTKEY( dx_code );



/********************************************************************************/
/*																				*/
/*	This command copies raw data from an S3 bucket at amazon into the table		*/
/*	ref.BHI_ICD9_DX_codes_pre.  												*/
/*																				*/
/********************************************************************************/
COPY		ref.BHI_ICD9_DX_codes_pre
FROM		's3://dhp-randlab-s3/users/mpazen/codesets/ICD9.txt'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION	ref.BHI_ICD9_codes_pre;
ANALYZE				ref.BHI_ICD9_codes_pre;
VACUUM SORT ONLY	ref.BHI_ICD9_codes_pre;
ANALYZE				ref.BHI_ICD9_codes_pre;



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the reference table of ICD 9 DX codes.		*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_ICD9_DX_codes;
CREATE TABLE			ref.BHI_ICD9_DX_codes
(		ICD9_DX_Code			VARCHAR(   5 )	ENCODE	ZSTD
	,	first_Date				DATE			ENCODE	ZSTD
	,	last_Date				DATE			ENCODE	ZSTD
	,	short_Description		VARCHAR(  24 )	ENCODE	ZSTD
	,	version					VARCHAR(   1 )	ENCODE	ZSTD
	,	long_Description		VARCHAR( 222 )	ENCODE	ZSTD
	,	long_Desc_Alphanu		VARCHAR( 222 )	ENCODE	ZSTD
	,	class					VARCHAR(  69 )	ENCODE	ZSTD
	,	sub_Class				VARCHAR( 156 )	ENCODE	ZSTD
	,	sub_Sub_Class			VARCHAR( 156 )	ENCODE	RAW
)
DISTSTYLE ALL
COMPOUND SORTKEY( ICD9_DX_Code );



/********************************************************************************/
/*																				*/
/*	The INSERT command below populates the table ref.BHI_ICD9_DX_codes			*/
/*	based on values in the table ref.BHI_ICD9_DX_codes_pre, but with one		*/
/*	extra column which replaces all non-alphanumeric characters in the long		*/
/*	description column with blanks.												*/
/*																				*/
/********************************************************************************/
INSERT INTO	ref.BHI_ICD9_DX_codes
(	SELECT DISTINCT
			( dx_code )			::	VARCHAR(   5 )	AS	ICD9_DX_Code
		,	( First )			::	DATE			AS	first_Date
		,	( Last )			::	DATE			AS	last_Date
		,	( dx_short_desc )	::	VARCHAR(  24 )	AS	short_Description
		,	( version )			::	VARCHAR(   1 )	AS	version
		,	( dx_long_desc )	::	VARCHAR( 222 )	AS	long_Description
		,	( REGEXP_REPLACE( dx_long_desc, '[^a-zA-Z0-9]+', ' ' ) )
								::	VARCHAR( 222 )	AS	long_Desc_Alphanu
		,	( CLASS )			::	VARCHAR(  69 )	AS	class
		,	( SubCLASS )		::	VARCHAR( 156 )	AS	sub_Class
		,	( SUBSubCLASS )		::	VARCHAR( 156 )	AS	sub_Sub_Class
	FROM
		ref.BHI_ICD9_DX_codes_pre
);
--ANALYZE COMPRESSION	ref.BHI_ICD9_DX_codes;
ANALYZE				ref.BHI_ICD9_DX_codes;
VACUUM SORT ONLY	ref.BHI_ICD9_DX_codes;
ANALYZE				ref.BHI_ICD9_DX_codes;


/*
This table is constructed to accept the raw data from the copy below.  It's a table of ICD10-CM diagnosis codes
downloaded from the CDC.  It's "pre" because an additional column useful (hopefully) for text searches is to 
be added after the data are loaded.
*/
/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the table designed to receive the raw data	*/
/*	for a reference table of ICD 10 DX codes.  This is not the final table.		*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_ICD10_DX_codes_pre;
CREATE TABLE			ref.BHI_ICD10_DX_codes_pre
(		order_Number		INTEGER			ENCODE	RAW
	,	ICD10_DX_Code		VARCHAR(   7 )	ENCODE	RAW
	,	valid_HIPAA_Flag	VARCHAR(   1 )	ENCODE	RAW
	,	short_Description	VARCHAR(  62 )	ENCODE	ZSTD
	,	long_Description	VARCHAR( 230 )	ENCODE	ZSTD
)
DISTSTYLE ALL
COMPOUND SORTKEY( ICD10_DX_Code );



/********************************************************************************/
/*																				*/
/*	This command copies raw data from an S3 bucket at amazon into the table		*/
/*	ref.BHI_cpt_codes_pre.  													*/
/*																				*/
/********************************************************************************/
COPY		ref.BHI_ICD10_DX_codes_pre
FROM		's3://dhp-randlab-s3/users/whaight/icd10cm_order_2019.txt'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 0 TRIMBLANKS DELIMITER '\t' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION	ref.BHI_ICD10_DX_codes_pre;
ANALYZE				ref.BHI_ICD10_DX_codes_pre;
VACUUM SORT ONLY	ref.BHI_ICD10_DX_codes_pre;
ANALYZE				ref.BHI_ICD10_DX_codes_pre;



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the table designed to receive the raw data	*/
/*	for a reference table of ICD 10 DX codes.  This is not the final table		*/
/*	and needs one additional column.											*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_ICD10_DX_codes;
CREATE TABLE			ref.BHI_ICD10_DX_codes
(		order_Number		INTEGER			ENCODE	RAW
	,	ICD10_DX_Code		VARCHAR(   7 )	ENCODE	RAW
	,	valid_HIPAA_Flag	VARCHAR(   1 )	ENCODE	RAW
	,	short_Description	VARCHAR(  62 )	ENCODE	ZSTD
	,	long_Description	VARCHAR( 230 )	ENCODE	ZSTD
	,	long_Desc_Alphanu	VARCHAR( 230 )	ENCODE	ZSTD
)
DISTSTYLE ALL
COMPOUND SORTKEY( ICD10_DX_Code );



/********************************************************************************/
/*																				*/
/*	The INSERT command below populates the table ref.BHI_ICD10_DX_codes			*/
/*	based on values in the table ref.BHI_ICD10_DX_codes_pre, but with one		*/
/*	extra column which replaces all non-alphanumeric characters in the long		*/
/*	description column with blanks.												*/
/*																				*/
/********************************************************************************/
INSERT INTO	ref.BHI_ICD10_DX_codes
(	SELECT DISTINCT
			( order_Number )		::	INTEGER			AS	order_Number
		,	( ICD10_DX_Code )		::	VARCHAR(   7 )	AS	ICD10_DX_Code
		,	( valid_HIPAA_Flag )	::	VARCHAR(   1 )	AS	valid_HIPAA_Flag
		,	( short_Description )	::	VARCHAR(  62 )	AS	short_Description
		,	( long_Description )	::	VARCHAR( 230 )	AS	long_Description
		,	( REGEXP_REPLACE( long_Description, '[^a-zA-Z0-9]+', ' ' ) )
									::	VARCHAR( 230 )	AS	long_Desc_Alphanu
	FROM
		ref.BHI_ICD10_DX_codes_pre
);
--ANALYZE COMPRESSION	ref.BHI_ICD10_DX_codes;
ANALYZE				ref.BHI_ICD10_DX_codes;
VACUUM SORT ONLY	ref.BHI_ICD10_DX_codes;
ANALYZE				ref.BHI_ICD10_DX_codes;



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the table designed to receive the raw data	*/
/*	for a reference table of NDC codes.  This is not the final table and needs	*/
/*	one additional column.														*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_ndc_codes_pre;
CREATE TABLE			ref.BHI_ndc_codes_pre					/*	package	product	*/
(		product_ID					VARCHAR(  47 )	ENCODE	ZSTD	/*	X		X		*/
	,	product_NDC					VARCHAR(  10 )	ENCODE	ZSTD	/*	X		X		*/
	,	start_mktg_Date				DATE			ENCODE	ZSTD	/*	X		X		*/
	,	end_mktg_Date				DATE			ENCODE	RAW		/*	X		X		*/
	,	NDC_exclude_Flag			VARCHAR(   1 )	ENCODE	ZSTD	/*	X		X		*/
	,	NDC_package_Code			VARCHAR(  12 )	ENCODE	ZSTD	/*	X				*/
	,	package_Desc				VARCHAR( 256 )	ENCODE	ZSTD	/*	X				*/
	,	sample_Package				VARCHAR(   1 )	ENCODE	ZSTD	/*	X				*/
	,	product_Type_Name			VARCHAR(  27 )	ENCODE	ZSTD	/*			X		*/
	,	proprietary_Name			VARCHAR( 226 )	ENCODE	ZSTD	/*			X		*/
	,	proprietary_Name_Suff		VARCHAR( 126 )	ENCODE	ZSTD	/*			X		*/
	,	non_Proprietary_Name		VARCHAR( 256 )	ENCODE	ZSTD	/*			X		*/
	,	dosage_Form_Name			VARCHAR(  46 )	ENCODE	ZSTD	/*			X		*/
	,	route_Name					VARCHAR( 143 )	ENCODE	ZSTD	/*			X		*/
	,	marktg_Category_Name		VARCHAR(  40 )	ENCODE	ZSTD	/*			X		*/
	,	application_Number			VARCHAR(  15 )	ENCODE	ZSTD	/*			X		*/
	,	labeler_Name				VARCHAR( 121 )	ENCODE	ZSTD	/*			X		*/
	,	substance_Name				VARCHAR( 256 )	ENCODE	ZSTD	/*			X		*/
	,	active_Numerator_Strength	VARCHAR( 256 )	ENCODE	ZSTD	/*			X		*/
	,	active_Ingred_Unit			VARCHAR( 256 )	ENCODE	ZSTD	/*			X		*/
	,	pharm_Classes				VARCHAR( 256 )	ENCODE	ZSTD	/*			X		*/
	,	DEA_Schedule				VARCHAR(   4 )	ENCODE	ZSTD	/*			X		*/
	,	listing_Rec_Cert_Through	VARCHAR(  27 )	ENCODE	ZSTD	/*			X		*/
)
DISTSTYLE ALL
COMPOUND SORTKEY( NDC_package_Code );



/********************************************************************************/
/*																				*/
/*	This command copies raw data from an S3 bucket at amazon into the table		*/
/*	ref.BHI_cpt_codes_pre.  													*/
/*																				*/
/********************************************************************************/
COPY		ref.BHI_ndc_codes_pre
FROM		's3://dhp-randlab-s3/users/mpazen/codesets/NDC_Pipe.txt'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0  COMPUPDATE ON;

--ANALYZE COMPRESSION	ref.BHI_ndc_codes_pre;
ANALYZE				ref.BHI_ndc_codes_pre;
VACUUM SORT ONLY	ref.BHI_ndc_codes_pre;
ANALYZE				ref.BHI_ndc_codes_pre;



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the reference table of NDC codes.			*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_ndc_codes;
CREATE TABLE			ref.BHI_ndc_codes						/*	package	product	*/
(		product_ID					VARCHAR(  47 )	ENCODE	ZSTD	/*	X		X		*/
	,	product_NDC					VARCHAR(  10 )	ENCODE	ZSTD	/*	X		X		*/
	,	start_mktg_Date				DATE			ENCODE	ZSTD	/*	X		X		*/
	,	end_mktg_Date				DATE			ENCODE	RAW		/*	X		X		*/
	,	NDC_exclude_Flag			VARCHAR(   1 )	ENCODE	ZSTD	/*	X		X		*/
	,	NDC_package_Code			VARCHAR(  12 )	ENCODE	ZSTD	/*	X				*/
	,	package_Desc				VARCHAR( 256 )	ENCODE	ZSTD	/*	X				*/
	,	package_Desc_alphanu		VARCHAR( 256 )	ENCODE	ZSTD	/*	X				*/
	,	sample_Package				VARCHAR(   1 )	ENCODE	ZSTD	/*			X		*/
	,	product_Type_Name			VARCHAR(  27 )	ENCODE	ZSTD	/*			X		*/
	,	proprietary_Name			VARCHAR( 226 )	ENCODE	ZSTD	/*			X		*/
	,	proprietary_Name_Suff		VARCHAR( 126 )	ENCODE	ZSTD	/*			X		*/
	,	non_Proprietary_Name		VARCHAR( 256 )	ENCODE	ZSTD	/*			X		*/
	,	dosage_Form_Name			VARCHAR(  46 )	ENCODE	ZSTD	/*			X		*/
	,	route_Name					VARCHAR( 143 )	ENCODE	ZSTD	/*			X		*/
	,	marktg_Category_Name		VARCHAR(  40 )	ENCODE	ZSTD	/*			X		*/
	,	application_Number			VARCHAR(  15 )	ENCODE	ZSTD	/*			X		*/
	,	labeler_Name				VARCHAR( 121 )	ENCODE	ZSTD	/*			X		*/
	,	substance_Name				VARCHAR( 256 )	ENCODE	ZSTD	/*			X		*/
	,	active_Numerator_Strength	VARCHAR( 256 )	ENCODE	ZSTD	/*			X		*/
	,	active_Ingred_Unit			VARCHAR( 256 )	ENCODE	ZSTD	/*			X		*/
	,	pharm_Classes				VARCHAR( 256 )	ENCODE	ZSTD	/*			X		*/
	,	DEA_Schedule				VARCHAR(   4 )	ENCODE	ZSTD	/*			X		*/
	,	listing_Rec_Cert_Through	VARCHAR(  27 )	ENCODE	ZSTD	/*			X		*/
)
DISTSTYLE ALL
COMPOUND SORTKEY( NDC_package_Code );



/********************************************************************************/
/*																				*/
/*	The INSERT command below populates the table ref.BHI_ndc_codes				*/
/*	based on values in the table ref.BHI_ndc_codes_pre, but with one			*/
/*	extra column which replaces all non-alphanumeric characters in the short	*/
/*	description column with blanks.												*/
/*																				*/
/********************************************************************************/
INSERT INTO	ref.BHI_ndc_codes
(	SELECT DISTINCT
			( product_ID )					::	VARCHAR(  47 )	AS	product_ID
		,	( product_NDC )					::	VARCHAR(  10 )	AS	product_NDC
		,	( start_mktg_Date )				::	DATE			AS	start_mktg_Date
		,	( end_mktg_Date )				::	DATE			AS	end_mktg_Date
		,	( NDC_exclude_Flag )			::	VARCHAR(   1 )	AS	NDC_exclude_Flag
		,	( NDC_package_Code )			::	VARCHAR(  12 )	AS	NDC_package_Code
		,	( package_Desc )				::	VARCHAR( 256 )	AS	package_Desc
		,	( REGEXP_REPLACE( package_Desc, '[^a-zA-Z0-9]+', ' ' ) )
											::	VARCHAR( 256 )	AS	package_Desc_alphanu
		,	( sample_Package )				::	VARCHAR(   1 )	AS	sample_Package
		,	( product_Type_Name )			::	VARCHAR(  27 )	AS	product_Type_Name
		,	( proprietary_Name )			::	VARCHAR( 226 )	AS	proprietary_Name
		,	( proprietary_Name_Suff )		::	VARCHAR( 126 )	AS	proprietary_Name_Suff
		,	( non_Proprietary_Name )		::	VARCHAR( 256 )	AS	non_Proprietary_Name
		,	( dosage_Form_Name )			::	VARCHAR(  46 )	AS	dosage_Form_Name
		,	( route_Name )					::	VARCHAR( 143 )	AS	route_Name
		,	( marktg_Category_Name )		::	VARCHAR(  40 )	AS	marktg_Category_Name
		,	( application_Number )			::	VARCHAR(  15 )	AS	application_Number
		,	( labeler_Name )				::	VARCHAR( 121 )	AS	labeler_Name
		,	( substance_Name )				::	VARCHAR( 256 )	AS	substance_Name
		,	( active_Numerator_Strength )	::	VARCHAR( 256 )	AS	active_Numerator_Strength
		,	( active_Ingred_Unit )			::	VARCHAR( 256 )	AS	active_Ingred_Unit
		,	( pharm_Classes )				::	VARCHAR( 256 )	AS	pharm_Classes
		,	( DEA_Schedule )				::	VARCHAR(   4 )	AS	DEA_Schedule
		,	( listing_Rec_Cert_Through )	::	VARCHAR(  27 )	AS	listing_Rec_Cert_Through
	FROM
		ref.BHI_ndc_codes_pre
);
--ANALYZE COMPRESSION	ref.BHI_ndc_codes;
ANALYZE				ref.BHI_ndc_codes;
VACUUM SORT ONLY	ref.BHI_ndc_codes;
ANALYZE				ref.BHI_ndc_codes;



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the table designed to receive the raw data	*/
/*	for a reference table of NDC codes.  This table must be joined with another	*/
/*	to construct the final reference table.										*/
/*	Note the in-line comments indicating which columns appear in which tables.	*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_ndc_codes_package;
CREATE TABLE			ref.BHI_ndc_codes_package		/*	package	product	*/
(		product_ID			VARCHAR(  47 )	ENCODE	ZSTD	--	*		*
	,	product_NDC			VARCHAR(  10 )	ENCODE	ZSTD	--	*		*
	,	NDC_package_Code	VARCHAR(  12 )	ENCODE	ZSTD	--	*
	,	package_Desc		VARCHAR( 779 )	ENCODE	ZSTD	--	*
	,	start_mktg_Date		DATE			ENCODE	ZSTD	--	*		*
	,	end_mktg_Date		DATE			ENCODE	RAW		--	*		*
	,	NDC_exclude_Flag	VARCHAR(   1 )	ENCODE	ZSTD	--	*		*
	,	sample_Package		VARCHAR(   1 )	ENCODE	ZSTD	--	*
)
DISTSTYLE ALL
COMPOUND SORTKEY( product_NDC, NDC_package_Code );
;



/********************************************************************************/
/*																				*/
/*	This command copies raw data from an S3 bucket at amazon into the table		*/
/*	ref.BHI_ndc_codes_package.  											*/
/*																				*/
/********************************************************************************/
COPY		ref.BHI_ndc_codes_package
FROM		's3://dhp-randlab-s3/users/whaight/package.txt'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '\t' STATUPDATE ON MAXERROR 2  COMPUPDATE ON;

--ANALYZE COMPRESSION	ref.BHI_ndc_codes_package;
ANALYZE				ref.BHI_ndc_codes_package;
VACUUM SORT ONLY	ref.BHI_ndc_codes_package;
ANALYZE				ref.BHI_ndc_codes_package;



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the table designed to receive the raw data	*/
/*	for a reference table of NDC codes.  This table must be joined with another	*/
/*	to construct the final reference table.										*/
/*	Note the in-line comments indicating which columns appear in which tables.	*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_ndc_codes_product;
CREATE TABLE			ref.BHI_ndc_codes_product				/*	package	product	*/
(		product_ID					VARCHAR(   47 )	ENCODE	ZSTD	--	*		*
	,	product_NDC					VARCHAR(   10 )	ENCODE	ZSTD	--	*		*
	,	product_Type_Name			VARCHAR(   27 )	ENCODE	ZSTD	--			*
	,	proprietary_Name			VARCHAR(  226 )	ENCODE	ZSTD	--			*
	,	proprietary_Name_Suff		VARCHAR(  127 )	ENCODE	ZSTD	--			*
	,	non_Proprietary_Name		VARCHAR(  514 )	ENCODE	ZSTD	--			*
	,	dosage_Form_Name			VARCHAR(   48 )	ENCODE	ZSTD	--			*
	,	route_Name					VARCHAR(  143 )	ENCODE	ZSTD	--			*
	,	start_mktg_Date				DATE			ENCODE	ZSTD	--	*		*
	,	end_mktg_Date				DATE			ENCODE	RAW		--	*		*
	,	marktg_Category_Name		VARCHAR(   40 )	ENCODE	ZSTD	--			*
	,	application_Number			VARCHAR(   17 )	ENCODE	ZSTD	--			*
	,	labeler_Name				VARCHAR(  121 )	ENCODE	ZSTD	--			*
	,	substance_Name				VARCHAR( 3816 )	ENCODE	ZSTD	--			*
	,	active_Numerator_Strength	VARCHAR(  742 )	ENCODE	ZSTD	--			*
	,	active_Ingred_Unit			VARCHAR( 2055 )	ENCODE	ZSTD	--			*
	,	pharm_Classes				VARCHAR( 4000 )	ENCODE	ZSTD	--			*
	,	DEA_Schedule				VARCHAR(    4 )	ENCODE	ZSTD	--			*
	,	NDC_exclude_Flag			VARCHAR(    1 )	ENCODE	ZSTD	--	*		*
	,	listing_Rec_Cert_Through	VARCHAR(    8 )	ENCODE	ZSTD	--			*
)
DISTSTYLE ALL
COMPOUND SORTKEY( product_NDC );
;



/********************************************************************************/
/*																				*/
/*	This command copies raw data from an S3 bucket at amazon into the table		*/
/*	ref.BHI_ndc_codes_product.  												*/
/*																				*/
/********************************************************************************/
COPY		ref.BHI_ndc_codes_product
FROM		's3://dhp-randlab-s3/users/whaight/product.txt'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '\t' STATUPDATE ON MAXERROR 0  COMPUPDATE ON;

--ANALYZE COMPRESSION	ref.BHI_ndc_codes_product;
ANALYZE				ref.BHI_ndc_codes_product;
VACUUM SORT ONLY	ref.BHI_ndc_codes_product;
ANALYZE				ref.BHI_ndc_codes_product;



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the reference table of NDC codes.  The 		*/
/*	previous two tables must be joined to create this final table.				*/
/*	Note the in-line comments indicating which columns appear in which tables.	*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_ndc_codes;
CREATE TABLE			ref.BHI_ndc_codes							/*	package	product	*/
(		product_ID						VARCHAR(   47 )	ENCODE	ZSTD	--	*		*
	,	product_NDC						VARCHAR(   10 )	ENCODE	ZSTD	--	*		*
	,	NDC_package_Code				VARCHAR(   12 )	ENCODE	ZSTD	--	*
	,	package_Desc					VARCHAR(  779 )	ENCODE	ZSTD	--	*
	,	package_Desc_alphanu			VARCHAR(  779 )	ENCODE	ZSTD
	,	prod_start_mktg_Date			DATE			ENCODE	ZSTD	--			*
	,	prod_end_mktg_Date				DATE			ENCODE	RAW		--			*
	,	pkg_start_mktg_Date				DATE			ENCODE	ZSTD	--	*
	,	pkg_end_mktg_Date				DATE			ENCODE	RAW		--	*
	,	NDC_exclude_Flag				VARCHAR(    1 )	ENCODE	ZSTD	--	*		*
	,	sample_Package					VARCHAR(    1 )	ENCODE	ZSTD	--	*
	,	product_Type_Name				VARCHAR(   27 )	ENCODE	ZSTD	--			*
	,	proprietary_Name				VARCHAR(  226 )	ENCODE	ZSTD	--			*
	,	proprietary_Name_Suff			VARCHAR(  127 )	ENCODE	ZSTD	--			*
	,	non_Proprietary_Name			VARCHAR(  514 )	ENCODE	ZSTD	--			*
	,	non_Proprietary_Name_alphanu	VARCHAR(  514 )	ENCODE	ZSTD
	,	dosage_Form_Name				VARCHAR(   48 )	ENCODE	ZSTD	--			*
	,	route_Name						VARCHAR(  143 )	ENCODE	ZSTD	--			*
	,	marktg_Category_Name			VARCHAR(   40 )	ENCODE	ZSTD	--			*
	,	application_Number				VARCHAR(   17 )	ENCODE	ZSTD	--			*
	,	labeler_Name					VARCHAR(  121 )	ENCODE	ZSTD	--			*
	,	substance_Name					VARCHAR( 3816 )	ENCODE	ZSTD	--			*
	,	substance_Name_alphanu			VARCHAR( 3816 )	ENCODE	ZSTD
	,	active_Numerator_Strength		VARCHAR(  742 )	ENCODE	ZSTD	--			*
	,	active_Ingred_Unit				VARCHAR( 2055 )	ENCODE	ZSTD	--			*
	,	active_Ingred_Unit_alphanu		VARCHAR( 2055 )	ENCODE	ZSTD	
	,	pharm_Classes					VARCHAR( 4000 )	ENCODE	ZSTD	--			*
	,	pharm_Classes_alphanu			VARCHAR( 4000 )	ENCODE	ZSTD
	,	DEA_Schedule					VARCHAR(    4 )	ENCODE	ZSTD	--			*
	,	listing_Rec_Cert_Through		VARCHAR(    8 )	ENCODE	ZSTD	--			*
)
DISTSTYLE ALL
COMPOUND SORTKEY( product_NDC, NDC_package_Code )
;



/********************************************************************************/
/*																				*/
/*	The INSERT command below populates the table ref.BHI_ndc_codes based on		*/
/*	values in the tables ref.BHI_ndc_codes_product and							*/
/*	ref.BHI_ndc_codes_package.													*/
/*																				*/
/********************************************************************************/
INSERT INTO	ref.BHI_ndc_codes
(	SELECT DISTINCT
			( BHI_ndc_codes_product.product_ID )				::	VARCHAR(   47 )	AS	product_ID
		,	( BHI_ndc_codes_product.product_NDC )				::	VARCHAR(   10 )	AS	product_NDC
		,	( BHI_ndc_codes_package.NDC_package_Code )			::	VARCHAR(   12 )	AS	NDC_package_Code
		,	( BHI_ndc_codes_package.package_Desc )				::	VARCHAR(  779 )	AS	package_Desc
		,	( REGEXP_REPLACE( BHI_ndc_codes_package.package_Desc, '[^a-zA-Z0-9]+', ' ' ) )
																::	VARCHAR(  779 )	AS	package_Desc_alphanu
		,	( BHI_ndc_codes_product.start_mktg_Date )			::	DATE			AS	prod_start_mktg_Date
		,	( BHI_ndc_codes_product.end_mktg_Date )				::	DATE			AS	prod_end_mktg_Date
		,	( BHI_ndc_codes_package.start_mktg_Date )			::	DATE			AS	pkg_start_mktg_Date
		,	( BHI_ndc_codes_package.end_mktg_Date )				::	DATE			AS	pkg_end_mktg_Date
		,	( BHI_ndc_codes_product.NDC_exclude_Flag )			::	VARCHAR(    1 )	AS	NDC_exclude_Flag
		,	( BHI_ndc_codes_package.sample_Package )			::	VARCHAR(    1 )	AS	sample_Package
		,	( BHI_ndc_codes_product.product_Type_Name )			::	VARCHAR(   27 )	AS	product_Type_Name
		,	( BHI_ndc_codes_product.proprietary_Name )			::	VARCHAR(  226 )	AS	proprietary_Name
		,	( BHI_ndc_codes_product.proprietary_Name_Suff )		::	VARCHAR(  127 )	AS	proprietary_Name_Suff
		,	( BHI_ndc_codes_product.non_Proprietary_Name )		::	VARCHAR(  514 )	AS	non_Proprietary_Name
		,	( REGEXP_REPLACE( BHI_ndc_codes_product.non_Proprietary_Name, '[^a-zA-Z0-9]+', ' ' ) )
																::	VARCHAR(  514 )	AS	non_Proprietary_Name_alphanu
		,	( BHI_ndc_codes_product.dosage_Form_Name )			::	VARCHAR(   48 )	AS	dosage_Form_Name
		,	( BHI_ndc_codes_product.route_Name )				::	VARCHAR(  143 )	AS	route_Name
		,	( BHI_ndc_codes_product.marktg_Category_Name )		::	VARCHAR(   40 )	AS	marktg_Category_Name
		,	( BHI_ndc_codes_product.application_Number )		::	VARCHAR(   17 )	AS	application_Number
		,	( BHI_ndc_codes_product.labeler_Name )				::	VARCHAR(  121 )	AS	labeler_Name
		,	( BHI_ndc_codes_product.substance_Name )			::	VARCHAR( 3816 )	AS	substance_Name
		,	( REGEXP_REPLACE( BHI_ndc_codes_product.substance_Name, '[^a-zA-Z0-9]+', ' ' ) )
																::	VARCHAR( 3816 )	AS	substance_Name_alphanu
		,	( BHI_ndc_codes_product.active_Numerator_Strength )	::	VARCHAR(  742 )	AS	active_Numerator_Strength
		,	( BHI_ndc_codes_product.active_Ingred_Unit )		::	VARCHAR( 2055 )	AS	active_Ingred_Unit
		,	( REGEXP_REPLACE( BHI_ndc_codes_product.active_Ingred_Unit, '[^a-zA-Z0-9]+', ' ' ) )
																::	VARCHAR( 2055 )	AS	active_Ingred_Unit_alphanu
		,	( BHI_ndc_codes_product.pharm_Classes )				::	VARCHAR( 4000 )	AS	pharm_Classes
		,	( REGEXP_REPLACE( BHI_ndc_codes_product.pharm_Classes, '[^a-zA-Z0-9]+', ' ' ) )
																::	VARCHAR( 4000 )	AS	pharm_Classes_alphanu
		,	( BHI_ndc_codes_product.DEA_Schedule )				::	VARCHAR(    4 )	AS	DEA_Schedule
		,	( BHI_ndc_codes_product.listing_Rec_Cert_Through )	::	VARCHAR(    8 )	AS	listing_Rec_Cert_Through
	FROM
		ref.BHI_ndc_codes_product
	LEFT JOIN
		ref.BHI_ndc_codes_package
	ON
		BHI_ndc_codes_package.product_ndc	=	BHI_ndc_codes_product.product_NDC
);
--ANALYZE COMPRESSION	ref.BHI_ndc_codes;
ANALYZE				ref.BHI_ndc_codes;
VACUUM SORT ONLY	ref.BHI_ndc_codes;
ANALYZE				ref.BHI_ndc_codes;



/********************************************************************************/
/*																				*/
/*	Here we drop the tables we only needed temporarily to build the tables		*/
/*	we actually want.															*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	ref.BHI_cpt_codes_pre;
DROP TABLE IF EXISTS	ref.BHI_ICD9_codes_pre;
DROP TABLE IF EXISTS	ref.BHI_ICD10_codes_pre;
DROP TABLE IF EXISTS	ref.BHI_ndc_codes_pre;
DROP TABLE IF EXISTS	ref.BHI_ndc_codes_package;
DROP TABLE IF EXISTS	ref.BHI_ndc_codes_product;


