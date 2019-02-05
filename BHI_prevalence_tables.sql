


DROP TABLE IF EXISTS		ref.BHI_prevalence_NDC;
CREATE TABLE				ref.BHI_prevalence_NDC
(		NDC_Code							VARCHAR( 12 )		ENCODE	ZSTD
	,	patients_With_NDC_Code_Count		INTEGER				ENCODE	ZSTD
	,	NDC_Code_Prevalence_in_BHI		DOUBLE PRECISION		ENCODE	ZSTD
)
DISTKEY( NDC_Code )
COMPOUND SORTKEY( NDC_Code );



INSERT INTO				ref.BHI_prevalence_NDC
(	WITH				Aggregate		AS
						(	SELECT	COUNT( member_ID )	AS	member_count
							FROM		clean_raw.bhi_members
						)
				,	pharm_Claims		AS
						(	SELECT DISTINCT		member_ID
											,	NDC_Code
							FROM				clean_raw.BHI_Pharmacy_Claims
						)
	SELECT			pharm_Claims.NDC_Code				AS	NDC_Code
				,	COUNT( pharm_Claims.member_ID )		AS	patients_With_NDC_Code_Count
				,	CONVERT( DOUBLE PRECISION, 1.0*COUNT( pharm_Claims.member_ID )/Aggregate.member_count )
														AS	NDC_Code_Prevalence_in_BHI
	FROM				pharm_Claims
				,	Aggregate
	GROUP BY			NDC_Code
				,	Aggregate.member_count
	ORDER BY		NDC_Code
);

--ANALYZE COMPRESSION	ref.BHI_prevalence_NDC;
ANALYZE					ref.BHI_prevalence_NDC;
VACUUM SORT ONLY			ref.BHI_prevalence_NDC;
ANALYZE					ref.BHI_prevalence_NDC;



DROP TABLE IF EXISTS		ref.BHI_prevalence_CPT;
CREATE TABLE				ref.BHI_prevalence_CPT
(		CPT_Code							VARCHAR( 14 )		ENCODE	RAW
	,	patients_With_CPT_Code_Count		INTEGER				ENCODE	RAW
	,	CPT_Code_Prevalence_in_BHI		DOUBLE PRECISION		ENCODE	RAW
)
DISTKEY( CPT_Code )
COMPOUND SORTKEY( CPT_Code );



INSERT INTO		ref.BHI_prevalence_CPT
(	WITH				Aggregate	AS
						(	SELECT	COUNT( member_ID )	AS	member_count
							FROM		clean_raw.bhi_members
						)
				,	Claims		AS
						(	SELECT DISTINCT		CPT_Code
											,	member_ID
							FROM			(	SELECT		CPT_HCPCS_Code	AS	CPT_Code
														,	member_ID
												FROM		clean_raw.bhi_facility_claim_detail	)
									UNION	(	SELECT		CPT_HCPCS_Code	AS	CPT_Code
														,	member_ID
												FROM		clean_raw.bhi_Professional_Claims	)
						)
	SELECT			Claims.CPT_Code					AS	CPT_Code
				,	COUNT( Claims.member_ID )		AS	patients_With_CPT_Code_Count
				,	CONVERT( DOUBLE PRECISION, 1.0*COUNT( Claims.member_ID )/Aggregate.member_count )
													AS	CPT_Code_Prevalence_in_BHI
	FROM				Claims
				,	Aggregate
	GROUP BY			CPT_Code
				,	Aggregate.member_count
	ORDER BY		CPT_Code
);

--ANALYZE COMPRESSION	ref.BHI_prevalence_CPT;
ANALYZE					ref.BHI_prevalence_CPT;
VACUUM SORT ONLY			ref.BHI_prevalence_CPT;
ANALYZE					ref.BHI_prevalence_CPT;



/*
It is useful in subsequent queries to have a single column table containing only the straight-up ICD9 diagnosis codes from
the table of ICD9 diagnosis codes.
*/
DROP TABLE IF EXISTS		ref.legit_ICD9_DX_Codes;
CREATE TABLE				ref.legit_ICD9_DX_Codes
(	ICD9_DX_Code		VARCHAR( 5 )		ENCODE	ZSTD		)
DISTKEY( ICD9_DX_Code )
COMPOUND SORTKEY( ICD9_DX_Code );



INSERT INTO				ref.legit_ICD9_DX_Codes
(	SELECT DISTINCT		ICD9_DX_Code		AS	ICD9_DX_Code
	FROM					ref.BHI_ICD9_DX_codes
	WHERE					ICD9_DX_Code					IS NOT	NULL
						AND	LEN( BTRIM( ICD9_DX_Code ) )		>		0
	ORDER BY				ICD9_DX_Code
);

--ANALYZE COMPRESSION	ref.legit_ICD9_DX_Codes;
ANALYZE				ref.legit_ICD9_DX_Codes;
VACUUM SORT ONLY		ref.legit_ICD9_DX_Codes;
ANALYZE				ref.legit_ICD9_DX_Codes;



/*
OK, so this one is going to take some explanation.  I wanted to get an exhaustive list of ICD9 diagnosis codes as listed in the BHI claims data
along with the raw count of patients who have been issued the diagnosis code at some point in their history, such as we have it.  ICD9 diagnosis
codes appear in BHI claims data in BHI_Facility_Claim_Header (twelve possible columns) and BHI_Professional_Claims (four possible columns).  Member
IDs per (cleaned) ICD9 diagnosis code are gathered from each column;  then the column information is aggregated and the counts are calculated so
that the rows of the table contain all present ICD 10 diagnosis codes listed separately, together with a count of all patients who have been so
diagnosed at least once.
*/
DROP TABLE IF EXISTS		ref.ICD9_DX_Codes_in_paid_BHI_Claims;
CREATE TABLE				ref.ICD9_DX_Codes_in_paid_BHI_Claims
(		ICD9_DX_Code					VARCHAR( 7 )		ENCODE	ZSTD
	,	count_Of_Patients_per_Code	INTEGER			ENCODE	ZSTD
)
DISTKEY( ICD9_DX_Code )
COMPOUND SORTKEY( ICD9_DX_Code );



INSERT INTO				ref.ICD9_DX_Codes_in_paid_BHI_Claims
(	SELECT DISTINCT
			DX_Code				AS	ICD9_DX_Code
		,	COUNT( member_ID )	AS	count_Of_Patients_per_Code
	FROM
		(		(	SELECT DISTINCT
							( REGEXP_REPLACE( header.admitting_ICD9_DX_Code, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.primary_ICD9_DX_Code, '[^A-Z0-9]+', '' ) )		AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.secondary_ICD9_DX_Code1, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.secondary_ICD9_DX_Code2, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.secondary_ICD9_DX_Code3, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.secondary_ICD9_DX_Code4, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.secondary_ICD9_DX_Code5, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.secondary_ICD9_DX_Code6, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.secondary_ICD9_DX_Code7, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.secondary_ICD9_DX_Code8, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.secondary_ICD9_DX_Code9, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( header.secondary_ICD9_DX_Code10, '[^A-Z0-9]+', '' ) )	AS	DX_Code
						,	header.member_ID															AS	member_ID
					FROM	
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON			header.claim_ID				=	detail.claim_ID
								AND	header.member_ID				=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'1'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( primary_ICD9_DX_Code, '[^A-Z0-9]+', '' ) )				AS	DX_Code
						,	member_ID																AS	member_ID
					FROM
						clean_raw.BHI_Professional_Claims
					WHERE
							ICD_Code_Type				=		'1'
						AND	claim_Payment_Status_Code	=		'P'
						AND	DX_Code						IS NOT	NULL
						AND	DX_Code						!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( secondary_ICD9_DX_Code1, '[^A-Z0-9]+', '' ) )			AS	DX_Code
						,	member_ID																AS	member_ID
					FROM
						clean_raw.BHI_Professional_Claims
					WHERE
							ICD_Code_Type				=		'1'
						AND	claim_Payment_Status_Code	=		'P'
						AND	DX_Code						IS NOT	NULL
						AND	DX_Code						!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( secondary_ICD9_DX_Code2, '[^A-Z0-9]+', '' ) )			AS	DX_Code
						,	member_ID																AS	member_ID
					FROM
						clean_raw.BHI_Professional_Claims
					WHERE
							ICD_Code_Type				=		'1'
						AND	claim_Payment_Status_Code	=		'P'
						AND	DX_Code						IS NOT	NULL
						AND	DX_Code						!=		''		)
			UNION
				(	SELECT DISTINCT
							( REGEXP_REPLACE( secondary_ICD9_DX_Code3, '[^A-Z0-9]+', '' ) )			AS	DX_Code
						,	member_ID																AS	member_ID
					FROM
						clean_raw.BHI_Professional_Claims
					WHERE
							ICD_Code_Type				=		'1'
						AND	claim_Payment_Status_Code	=		'P'
						AND	DX_Code						IS NOT	NULL
						AND	DX_Code						!=		''		)
		)	BIG_PILE_O_MEMBERS_N_CODES
	GROUP BY		BIG_PILE_O_MEMBERS_N_CODES.DX_Code
	ORDER BY		BIG_PILE_O_MEMBERS_N_CODES.DX_Code
);

--ANALYZE COMPRESSION	ref.ICD9_DX_Codes_in_paid_BHI_Claims;
ANALYZE				ref.ICD9_DX_Codes_in_paid_BHI_Claims;
VACUUM SORT ONLY		ref.ICD9_DX_Codes_in_paid_BHI_Claims;
ANALYZE				ref.ICD9_DX_Codes_in_paid_BHI_Claims;


/*
Here the prevalences are actually calculated and stored off in a table.  Included are the ICD9 diagnosis codes (in order), a count of patients who
have at least one claim in the data including the stated diagnosis, and a third column containing the proportion of all members which have received 
such diagnosis (or, equivalently, the probability that a randomly selected member has received said diagnosis at some point during coverage).
*/
DROP TABLE IF EXISTS		ref.BHI_prevalence_ICD9_DX;
CREATE TABLE				ref.BHI_prevalence_ICD9_DX
(		ICD9_DX_Code							VARCHAR( 7 )			ENCODE	RAW
	,	patients_With_ICD9_DX_Code_Count		INTEGER				ENCODE	RAW
	,	ICD9_DX_Code_Prevalence_in_BHI		DOUBLE PRECISION		ENCODE	RAW
)
DISTKEY( ICD9_DX_Code )
COMPOUND SORTKEY( ICD9_DX_Code );



INSERT INTO		ref.BHI_prevalence_ICD9_DX
(	WITH			Aggregate	AS
					(	SELECT	COUNT( member_ID )		AS	member_count
						FROM		clean_raw.bhi_members						)
	SELECT			codes.ICD9_DX_Code					AS	this_ICD9_DX_Code
				,	codes.count_Of_Patients_per_Code		AS	patients_With_ICD9_DX_Code_Count
				,	CONVERT(		DOUBLE PRECISION, 1.0*codes.count_Of_Patients_per_Code/Aggregate.member_count	)
														AS	ICD9_DX_Code_Prevalence_in_BHI
	FROM				ref.ICD9_DX_Codes_in_paid_BHI_Claims	codes
				,	Aggregate
	WHERE		ICD9_DX_Code		=	ANY(		SELECT	ICD9_DX_Code
											FROM		ref.legit_ICD9_DX_Codes	)
	GROUP BY			this_ICD9_DX_Code
				,	patients_With_ICD9_DX_Code_Count
				,	Aggregate.member_count
	ORDER BY		this_ICD9_DX_Code
);

--ANALYZE COMPRESSION	ref.BHI_prevalence_ICD9_DX;
ANALYZE				ref.BHI_prevalence_ICD9_DX;
VACUUM SORT ONLY		ref.BHI_prevalence_ICD9_DX;
ANALYZE				ref.BHI_prevalence_ICD9_DX;


/*
It is useful in subsequent queries to have a single column table containing only the straight-up ICD10-CM codes from
the CDC table
*/
DROP TABLE IF EXISTS		ref.legit_ICD10_DX_Codes;
CREATE TABLE				ref.legit_ICD10_DX_Codes
(	ICD10_DX_Code	VARCHAR( 7 )		ENCODE	ZSTD	)
DISTKEY( ICD10_DX_Code )
COMPOUND SORTKEY( ICD10_DX_Code );



INSERT INTO				ref.legit_ICD10_DX_Codes
(	SELECT DISTINCT		ICD10_DX_Code	AS	ICD10_DX_Code
	FROM					ref.BHI_ICD10_DX_Codes
	WHERE				ICD10_DX_Code						IS NOT	NULL
						AND	LEN( BTRIM( ICD10_DX_Code ) )	>		0
	ORDER BY				ICD10_DX_Code
);

--ANALYZE COMPRESSION		ref.legit_ICD10_DX_Codes;
ANALYZE					ref.legit_ICD10_DX_Codes;
VACUUM SORT ONLY			ref.legit_ICD10_DX_Codes;
ANALYZE					ref.legit_ICD10_DX_Codes;


/*
OK, so this one is going to take some explanation.  I wanted to get an exhaustive list of ICD10 diagnosis codes as listed in the BHI claims data
along with the raw count of patients who have been issued the diagnosis code at some point in their history, such as we have it.  ICD10 diagnosis codes
appear in BHI claims data in BHI_Facility_Claim_Header (twelve possible columns) and BHI_Professional_Claims (four possible columns).  Member IDs per
(cleaned) ICD10 diagnosis code are gathered from each column;  then the column information is aggregated and the counts are calculated so
that the rows of the table contain all present ICD 10 diagnosis codes listed separately, together with a count of all patients who have been so
diagnosed at least once.
*/
DROP TABLE IF EXISTS		ref.ICD10_DX_Codes_in_paid_BHI_Claims;
CREATE TABLE				ref.ICD10_DX_Codes_in_paid_BHI_Claims
(		ICD10_DX_Code				VARCHAR( 7 )		ENCODE	ZSTD
	,	count_Of_Patients_per_Code	INTEGER			ENCODE	ZSTD
)
DISTKEY( ICD10_DX_Code )
COMPOUND SORTKEY( ICD10_DX_Code );



INSERT INTO				ref.ICD10_DX_Codes_in_paid_BHI_Claims
(	SELECT DISTINCT
			DX_Code				AS	ICD10_DX_Code
		,	COUNT( member_ID )	AS	count_Of_Patients_per_Code
	FROM
		(		(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.admitting_ICD10_DX_Code, '[^A-Z0-9]+', '' ) )		AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.primary_ICD10_DX_Code, '[^A-Z0-9]+', '' ) )		AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.secondary_ICD10_DX_Code1, '[^A-Z0-9]+', '' ) )	AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.secondary_ICD10_DX_Code2, '[^A-Z0-9]+', '' ) )	AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.secondary_ICD10_DX_Code3, '[^A-Z0-9]+', '' ) )	AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.secondary_ICD10_DX_Code4, '[^A-Z0-9]+', '' ) )	AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.secondary_ICD10_DX_Code5, '[^A-Z0-9]+', '' ) )	AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID	=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.secondary_ICD10_DX_Code6, '[^A-Z0-9]+', '' ) )	AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.secondary_ICD10_DX_Code7, '[^A-Z0-9]+', '' ) )	AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.secondary_ICD10_DX_Code8, '[^A-Z0-9]+', '' ) )	AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.secondary_ICD10_DX_Code9, '[^A-Z0-9]+', '' ) )	AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( header.secondary_ICD10_DX_Code10, '[^A-Z0-9]+', '' ) )	AS	DX_Code
							,	header.member_ID															AS	member_ID
					FROM
								clean_raw.BHI_Facility_Claim_Header		header
						JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
						ON		header.claim_ID		=	detail.claim_ID
							AND	header.member_ID		=	detail.member_ID
					WHERE
							header.ICD_Code_Type					=		'2'
						AND	detail.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( pro.primary_ICD10_DX_Code, '[^A-Z0-9]+', '' ) )			AS	DX_Code
							,	pro.member_ID															AS	member_ID
					FROM
						clean_raw.BHI_Professional_Claims		pro
					WHERE
							pro.ICD_Code_Type					=		'2'
						AND	pro.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( pro.secondary_ICD10_DX_Code1, '[^A-Z0-9]+', '' ) )		AS	DX_Code
							,	pro.member_ID															AS	member_ID
					FROM
						clean_raw.BHI_Professional_Claims		pro
					WHERE
							pro.ICD_Code_Type					=		'2'
						AND	pro.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( pro.secondary_ICD10_DX_Code2, '[^A-Z0-9]+', '' ) )		AS	DX_Code
							,	pro.member_ID															AS	member_ID
					FROM
						clean_raw.BHI_Professional_Claims		pro
					WHERE
							pro.ICD_Code_Type					=		'2'
						AND	pro.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
			UNION
				(	SELECT DISTINCT
						(		REGEXP_REPLACE( pro.secondary_ICD10_DX_Code3, '[^A-Z0-9]+', '' ) )		AS	DX_Code
							,	pro.member_ID															AS	member_ID
					FROM
						clean_raw.BHI_Professional_Claims		pro
					WHERE
							pro.ICD_Code_Type					=		'2'
						AND	pro.claim_Payment_Status_Code		=		'P'
						AND	DX_Code								IS NOT	NULL
						AND	DX_Code								!=		''		)
		)	BIG_PILE_O_MEMBERS_N_CODES
	GROUP BY		BIG_PILE_O_MEMBERS_N_CODES.DX_Code
	ORDER BY		BIG_PILE_O_MEMBERS_N_CODES.DX_Code
);

--ANALYZE COMPRESSION	ref.ICD10_DX_Codes_in_paid_BHI_Claims;
ANALYZE					ref.ICD10_DX_Codes_in_paid_BHI_Claims;
VACUUM SORT ONLY			ref.ICD10_DX_Codes_in_paid_BHI_Claims;
ANALYZE					ref.ICD10_DX_Codes_in_paid_BHI_Claims;


/*
Here the prevalences are actually calculated and stored off in a table.  Included are the ICD10 diagnosis codes (in order), a count of patients who
have at least one claim in the data including the stated diagnosis, and a third column containing the proportion of all members which have received 
such diagnosis (or, equivalently, the probability that a randomly selected member has received said diagnosis at some point during coverage).
*/
DROP TABLE IF EXISTS		ref.BHI_prevalence_ICD10_DX;
CREATE TABLE				ref.BHI_prevalence_ICD10_DX
(		ICD10_DX_Code						VARCHAR( 7 )			ENCODE	RAW
	,	patients_With_ICD10_DX_Code_Count	INTEGER				ENCODE	RAW
	,	ICD10_DX_Code_Prevalence_in_BHI		DOUBLE PRECISION		ENCODE	RAW
)
DISTKEY( ICD10_DX_Code )
COMPOUND SORTKEY( ICD10_DX_Code );



INSERT INTO		ref.BHI_prevalence_ICD10_DX
(	WITH			Aggregate	AS
					(	SELECT	COUNT( member_ID )	AS	member_count
						FROM		clean_raw.BHI_members
					)
	SELECT			Claims.ICD10_DX_Code					AS	this_ICD10_DX_Code
				,	Claims.count_Of_Patients_per_Code	AS	patients_With_ICD10_DX_Code_Count
				,	CONVERT( DOUBLE PRECISION, 1.0*Claims.count_Of_Patients_per_Code/Aggregate.member_count )
														AS	ICD10_DX_Code_Prevalence_in_BHI
	FROM				ref.ICD10_DX_Codes_in_paid_BHI_Claims 		Claims
				,	Aggregate
	WHERE		Claims.ICD10_DX_Code		=	ANY(		SELECT	ICD10_DX_Code
													FROM		ref.legit_ICD10_DX_Codes	)
	GROUP BY			this_ICD10_DX_Code
				,	patients_With_ICD10_DX_Code_Count
				,	Aggregate.member_count
	ORDER BY		this_ICD10_DX_Code
);

--ANALYZE COMPRESSION	ref.BHI_prevalence_ICD10_DX;
ANALYZE					ref.BHI_prevalence_ICD10_DX;
VACUUM SORT ONLY			ref.BHI_prevalence_ICD10_DX;
ANALYZE					ref.BHI_prevalence_ICD10_DX;


