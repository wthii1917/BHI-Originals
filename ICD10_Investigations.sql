


/*
It became useful to identify those ECD10 diagnosis codes present in the BHI claims data which were not actually listed in the CDC table.  Is there a
pattern here?  Were they simply miskeyed?  How much money is there associated with these bogus codes?  Or, is the CDC list of ICD10 diagnosis codes
incomplete?  Are there "folk codes" in broad use due to a need yet to be addressed by the holy keepers of the codes?  The first step lies in identifying
these codes in use not enshrined in the CDC list.  One noteworthy code is "NA".  One has to wonder how a code which so clearly violates the ICD10
pattern came into such widespread use.  Or maybe not.
*/
DROP TABLE IF EXISTS		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC;
CREATE TABLE				whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC
(	ICD10_DX_code	VARCHAR( 7 )		ENCODE	ZSTD	)
DISTSTYLE 			ALL
COMPOUND SORTKEY( ICD10_DX_code );



INSERT INTO		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC
(	SELECT DISTINCT		ICD10_DX_Code	AS	ICD10_DX_Code
	FROM							(	SELECT	ICD10_DX_Code
									FROM		ref.ICD10_DX_Codes_in_paid_BHI_Claims
									WHERE	ICD10_DX_Code IS NOT NULL	
											AND	LEN( BTRIM( ICD10_DX_Code ) ) > 0	)
						MINUS	(	SELECT	ICD10_DX_Code
									FROM		ref.legit_ICD10_DX_Codes	)
	ORDER BY	ICD10_DX_Code
);

--ANALYZE COMPRESSION	whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC;
ANALYZE					whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC;
VACUUM SORT ONLY			whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC;
ANALYZE					whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC;


/*
Still trying to find the total value of claims which name ICD10 codes not fouund in the CDC canonical list.  That process is eased if we can
simply save off the useful columns with the codes cleaned (i.e., all non-alphanumeric characters deleted.)  Beyond that, we only want claims
which have:
	1.	been paid (detail.claim_Payment_Status_Code = 'P');
	2.	record diagnoses in ICD10 codes (header.ICD_Code_Type = '2');  and,
	3.	at least one of the named ICD10 codes is not in the canonical CDC list (this is the final AND in the WHERE clause, the one
		with all the ORs and the ANYs)
The idea is that once these claims are isolated in a single table with all the necessary columns, it should (HAHA!) be a relatively simple
matter to group by the ICD10 codes and add up the money.

Please note that initially (sub_1 stage), facility and professional claims are handled separately.
*/
DROP TABLE IF EXISTS		whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1;
CREATE TABLE				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
(		claim_ID						VARCHAR( 12 )		ENCODE	ZSTD
	,	member_ID					VARCHAR( 12 )		ENCODE	ZSTD
	,	ICD_Code_Type				VARCHAR(  1 )		ENCODE	ZSTD
	,	admitting_ICD10_DX_Code		VARCHAR(  8 )		ENCODE	ZSTD
	,	primary_ICD10_DX_Code		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code1		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code2		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code3		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code4		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code5		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code6		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code7		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code8		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code9		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code10	VARCHAR(  8 )		ENCODE	ZSTD
	,	claim_Payment_Status_Code	VARCHAR(  1 )		ENCODE	ZSTD
	,	TCRRV_Amount					NUMERIC( 10, 2 )		ENCODE	ZSTD
)
DISTKEY( claim_ID )
COMPOUND SORTKEY( claim_ID, member_ID );



INSERT INTO		whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
(	SELECT DISTINCT
			header.claim_ID															AS	claim_ID
		,	header.member_ID															AS	member_ID
		,	header.ICD_Code_Type														AS	ICD_Code_Type
		,	REGEXP_REPLACE( header.admitting_ICD10_DX_Code, '[^A-Z0-9]+', '' )		AS	admitting_ICD10_DX_Code
		,	REGEXP_REPLACE( header.primary_ICD10_DX_Code, '[^A-Z0-9]+', '' )			AS	primary_ICD10_DX_Code
		,	REGEXP_REPLACE( header.secondary_ICD10_DX_Code1, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code1
		,	REGEXP_REPLACE( header.secondary_ICD10_DX_Code2, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code2
		,	REGEXP_REPLACE( header.secondary_ICD10_DX_Code3, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code3
		,	REGEXP_REPLACE( header.secondary_ICD10_DX_Code4, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code4
		,	REGEXP_REPLACE( header.secondary_ICD10_DX_Code5, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code5
		,	REGEXP_REPLACE( header.secondary_ICD10_DX_Code6, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code6
		,	REGEXP_REPLACE( header.secondary_ICD10_DX_Code7, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code7
		,	REGEXP_REPLACE( header.secondary_ICD10_DX_Code8, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code8
		,	REGEXP_REPLACE( header.secondary_ICD10_DX_Code9, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code9
		,	REGEXP_REPLACE( header.secondary_ICD10_DX_Code10, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code10
		,	detail.claim_Payment_Status_Code											AS	claim_Payment_Status_Code
		,	detail.TCRRV_Amount														AS	TCRRV_Amount
	FROM
				clean_raw.BHI_Facility_Claim_Header		header
		JOIN		clean_raw.BHI_Facility_Claim_Detail		detail
		ON			header.member_ID		=	detail.member_ID
				AND	header.claim_ID		=	detail.claim_ID
	WHERE
			detail.claim_Payment_Status_Code		=	'P'
		AND	header.ICD_Code_Type					=	'2'
		AND	(		(	admitting_ICD10_DX_Code		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	primary_ICD10_DX_Code		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code1		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code2		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code3		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code4		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code5		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code6		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code7		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code8		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code9		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code10	=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			)
);

--ANALYZE COMPRESSION	whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1;
ANALYZE				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1;
VACUUM SORT ONLY		whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1;
ANALYZE				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1;


/*
This next DROP-CREATE-POPULATE mimics the above, but for the professional claims table
*/
DROP TABLE IF EXISTS		whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1;
CREATE TABLE				whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1
(		claim_ID						VARCHAR( 12 )		ENCODE	ZSTD
	,	member_ID					VARCHAR( 12 )		ENCODE	ZSTD
	,	ICD_Code_Type				VARCHAR(  1 )		ENCODE	ZSTD
	,	primary_ICD10_DX_Code		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code1		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code2		VARCHAR(  8 )		ENCODE	ZSTD
	,	secondary_ICD10_DX_Code3		VARCHAR(  8 )		ENCODE	ZSTD
	,	claim_Payment_Status_Code	VARCHAR(  1 )		ENCODE	ZSTD
	,	TCRRV_Amount					NUMERIC( 10, 2 )		ENCODE	ZSTD
)
DISTKEY( claim_ID )
COMPOUND SORTKEY( claim_ID, member_ID );



INSERT INTO		whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1
(	SELECT DISTINCT
			claim_ID															AS	claim_ID
		,	member_ID														AS	member_ID
		,	ICD_Code_Type													AS	ICD_Code_Type
		,	REGEXP_REPLACE( primary_ICD10_DX_Code, '[^A-Z0-9]+', '' )		AS	primary_ICD10_DX_Code
		,	REGEXP_REPLACE( secondary_ICD10_DX_Code1, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code1
		,	REGEXP_REPLACE( secondary_ICD10_DX_Code2, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code2
		,	REGEXP_REPLACE( secondary_ICD10_DX_Code3, '[^A-Z0-9]+', '' )		AS	secondary_ICD10_DX_Code3
		,	claim_Payment_Status_Code										AS	claim_Payment_Status_Code
		,	TCRRV_Amount														AS	TCRRV_Amount
	FROM
		clean_raw.BHI_Professional_Claims
	WHERE		
			claim_Payment_Status_Code	=	'P'
		AND	ICD_Code_Type				=	'2'
		AND	(		(	primary_ICD10_DX_Code		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code1		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code2		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
				OR	(	secondary_ICD10_DX_Code3		=	ANY(		SELECT	ICD10_DX_code
																FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			)
);

--ANALYZE COMPRESSION	whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1;
ANALYZE				whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1;
VACUUM SORT ONLY		whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1;
ANALYZE				whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1;


/*
To recap:  thus far we have isolated all claims from the facility and professional claims table in which at least one of the listed
ICD10 DX codes fails to appear on the holy, canonical CDC list of ICD10 DX codes.  All this is in service of addressing the question:  How
much money is there associated with these claims?  Here we form a master list of such claims, with columns as indicated below.  The vision
is that from this list it should (OHHH BABY!) be a relatively straightforward matter to restrict to those rows in which the listed ICD10
DX code sits on the big list of codes in the claims but not on the list, and then aggregate the money by the code.
*/
DROP TABLE IF EXISTS		whaight.BHI_claims_with_unlisted_ICD10_DX_2;
CREATE TABLE				whaight.BHI_claims_with_unlisted_ICD10_DX_2
(		claim_ID			VARCHAR( 12 )		ENCODE	ZSTD
	,	member_ID		VARCHAR( 12 )		ENCODE	ZSTD
	,	ICD10_DX_Code	VARCHAR(  8 )		ENCODE	ZSTD
	,	TCRRV_Amount		NUMERIC( 10, 2 )		ENCODE	ZSTD
)
DISTKEY( ICD10_DX_Code )
COMPOUND SORTKEY( ICD10_DX_Code );



INSERT INTO		whaight.BHI_claims_with_unlisted_ICD10_DX_2
(	SELECT DISTINCT
			BIG_PILE_O_CLAIMS_N_MEMBERS.claim_ID			AS	claim_ID
		,	BIG_PILE_O_CLAIMS_N_MEMBERS.member_ID		AS	member_ID
		,	BIG_PILE_O_CLAIMS_N_MEMBERS.ICD10_DX_Code	AS	ICD10_DX_Code
		,	BIG_PILE_O_CLAIMS_N_MEMBERS.TCRRV_Amount		AS	TCRRV_Amount
	FROM
		(			(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	admitting_ICD10_DX_Code		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	primary_ICD10_DX_Code		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code1		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code2		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code3		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code4		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code5		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code6		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code7		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code8		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code9		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code10	AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_facility_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	primary_ICD10_DX_Code		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code1		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code2		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC )	)
			UNION	(	SELECT DISTINCT		claim_ID						AS	claim_ID
										,	member_ID					AS	member_ID
										,	secondary_ICD10_DX_Code3		AS	ICD10_DX_Code
										,	TCRRV_Amount					AS	TCRRV_Amount
						FROM				whaight.BHI_professional_claims_with_unlisted_ICD10_DX_1
						WHERE			ICD10_DX_Code	=	ANY(		SELECT	ICD10_DX_code
																	FROM		whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC	)	)
		)	BIG_PILE_O_CLAIMS_N_MEMBERS
);

--ANALYZE COMPRESSION	whaight.BHI_claims_with_unlisted_ICD10_DX_2;
ANALYZE				whaight.BHI_claims_with_unlisted_ICD10_DX_2;
VACUUM SORT ONLY		whaight.BHI_claims_with_unlisted_ICD10_DX_2;
ANALYZE				whaight.BHI_claims_with_unlisted_ICD10_DX_2;


/*
OK, so here we are at the end of the trail:  we pull quadruples claims/members/amounts/ICD10_DX_Codes from the last table we built, i.e.
clean_raw.BHI_claims_with_unlisted_ICD10_DX_2, and restrict to those for which the ICD10_DX_Code is in the set of funny claims,
whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC.  Finally we group by the ICD_DX_Code, count the number of patients with that code, add
up the amount spent on claims mentioning that code, sort by the code and stick it in the table.
*/
DROP TABLE IF EXISTS	whaight.BHI_claims_with_unlisted_ICD10_DX_money;
CREATE TABLE			whaight.BHI_claims_with_unlisted_ICD10_DX_money
(		ICD10_DX_Code		VARCHAR( 8 )			ENCODE	RAW
	,	Patient_count		INTEGER				ENCODE	RAW
	,	Total_Spent			NUMERIC( 16, 2 )		ENCODE	RAW
)
DISTKEY( ICD10_DX_Code )
COMPOUND SORTKEY( ICD10_DX_Code );



INSERT INTO		whaight.BHI_claims_with_unlisted_ICD10_DX_money
(	SELECT DISTINCT
			ICD10_DX_Code			AS	ICD10_DX_Code
		,	COUNT( member_ID )		AS	Patient_count
		,	SUM( TCRRV_Amount )		AS	Total_Spent
	FROM
		whaight.BHI_claims_with_unlisted_ICD10_DX_2
	WHERE
		ICD10_DX_Code	=	ANY(	SELECT	ICD10_DX_code
									FROM	whaight.BHI_ICD10_DX_codes_in_paid_claims_not_CDC	)
	GROUP BY
		ICD10_DX_Code
	ORDER BY
		ICD10_DX_Code
);

--ANALYZE COMPRESSION	whaight.BHI_claims_with_unlisted_ICD10_DX_money;
ANALYZE				whaight.BHI_claims_with_unlisted_ICD10_DX_money;
VACUUM SORT ONLY		whaight.BHI_claims_with_unlisted_ICD10_DX_money;
ANALYZE				whaight.BHI_claims_with_unlisted_ICD10_DX_money;




