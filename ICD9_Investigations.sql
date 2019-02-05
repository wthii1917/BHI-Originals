


/*
It became useful to identify those ICD9 diagnosis codes present in the BHI claims data which were not actually listed in the List.  Is there a
pattern here?  Were they simply miskeyed?  How much money is there associated with these bogus codes?  Or, is the list of ICD9 diagnosis codes
incomplete?  Are there "folk codes" in broad use due to a need yet to be addressed by the holy keepers of the codes?  The first step lies in identifying
these codes in use not enshrined in the list.
*/
DROP TABLE IF EXISTS		clean_raw.BHI_ICD9_codes_in_claims_not_List;
CREATE TABLE				clean_raw.BHI_ICD9_codes_in_claims_not_List
(	ICD9_DX_code		VARCHAR( 7 )		ENCODE	ZSTD		)
DISTSTYLE 				ALL
COMPOUND SORTKEY( ICD9_DX_code );



INSERT INTO		clean_raw.BHI_ICD9_codes_in_claims_not_List
(	SELECT		ICD9_DX_Code		AS	ICD9_DX_Code
	FROM					(	SELECT	ICD9_DX_Code
							FROM		clean_raw.ICD9_DX_Codes_in_paid_BHI_Claims
							WHERE	ICD9_DX_Code IS NOT NULL	
									AND	LEN( BTRIM( ICD9_DX_Code ) ) > 0	)
				MINUS	(	SELECT	ICD9_DX_Code
							FROM		clean_raw.legit_ICD9_DX_Codes	)
	ORDER BY		ICD9_DX_Code
);

--ANALYZE COMPRESSION	clean_raw.BHI_ICD9_codes_in_claims_not_List;
ANALYZE				clean_raw.BHI_ICD9_codes_in_claims_not_List;
VACUUM SORT ONLY		clean_raw.BHI_ICD9_codes_in_claims_not_List;
ANALYZE				clean_raw.BHI_ICD9_codes_in_claims_not_List;



