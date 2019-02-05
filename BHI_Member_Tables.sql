/********************************************************************************/
/*																				*/
/*	FILE:			BHI_Member_Tables											*/
/*	PROGRAMMED BY:	Will Haight (wthii)											*/
/*	DATE:			October, 2018												*/
/*	NOTES:			The following tables are established in this file:			*/
/*					clean_raw.BHI_members										*/
/*					clean_raw.BHI_member_enrollment								*/
/*																				*/
/*	MODIFICATIONS																*/
/*																				*/
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
/*	from the BHI people associated with members or covered individuals.			*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	clean_raw.BHI_members;
CREATE TABLE 			clean_raw.BHI_members
(		member_ID	VARCHAR( 9 )	ENCODE	DELTA32K
	,	birth_Year	INTEGER			ENCODE	DELTA
	,	gender		VARCHAR( 1 )	ENCODE	BYTEDICT
)
DISTSTYLE KEY
DISTKEY( member_ID )
COMPOUND SORTKEY( member_ID, birth_Year, gender );



/********************************************************************************/
/*																				*/
/*	This command isn't part of the standard build process;  I copied the table	*/
/*	of the same name from the cust_abs_raw instance because Carl had made some	*/
/*	changes I wanted.															*/
/*																				*/
/********************************************************************************/
INSERT INTO	clean_raw.BHI_members
(	SELECT
			( member_id )	::	VARCHAR( 9 )	AS	member_ID
		,	( birth_year )	::	INTEGER			AS	birth_Year
		,	( gender )		::	VARCHAR( 1 )	AS	gender
	FROM
		cust_abs_raw.bhi_members
);
--ANALYZE COMPRESSION	clean_raw.BHI_members;
ANALYZE				clean_raw.BHI_members;
VACUUM SORT ONLY	clean_raw.BHI_members;
ANALYZE				clean_raw.BHI_members;



/********************************************************************************/
/*																				*/
/*	This command copies the raw data as received from the good folks at BHI		*/
/*	into the table clean_raw.BHI_members.  This commmand IS part				*/
/*	of the standard build process, to follow the DROP/CREATE command at the		*/
/*	top.  IF you run the INSERT above, this command will eradicate the good		*/
/*	accomplished with that action!  So run one or the other, but not both.		*/
/*																				*/
/********************************************************************************/
/*
COPY		clean_raw.BHI_members
FROM		's3://dhp-rndlab-bhi-data/unzipped/member.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;
*/



/********************************************************************************/
/*																				*/
/*	The DROP & CREATE below define the table designed to receive the raw data	*/
/*	from the BHI people associated with membership enrollment.					*/
/*																				*/
/********************************************************************************/
DROP TABLE IF EXISTS	clean_raw.BHI_member_enrollment;
CREATE TABLE 			clean_raw.BHI_member_enrollment
(		enrollment_ID			VARCHAR( 10 )	ENCODE	LZO
	,	member_ID				VARCHAR(  9 )	ENCODE	LZO
	,	enrollment_Start_Date	DATE			ENCODE	LZO
	,	enrollment_Term_Date	DATE			ENCODE	LZO
	,	zip3_Code				VARCHAR(  3 )	ENCODE	LZO
	,	rx_Benefit_Indicator	VARCHAR(  1 )	ENCODE	LZO
)
DISTSTYLE KEY
DISTKEY( member_ID )
COMPOUND SORTKEY( member_ID, enrollment_Start_Date, enrollment_Term_Date );



/********************************************************************************/
/*																				*/
/*	This command isn't part of the standard build process;  I copied the table	*/
/*	of the same name from the cust_abs_raw instance because Carl had made some	*/
/*	changes I wanted.															*/
/*																				*/
/********************************************************************************/
INSERT INTO	clean_raw.BHI_member_enrollment
(	SELECT
			( enrollment_id )			::	VARCHAR( 9 )	AS	enrollment_ID
		,	( member_id )				::	INTEGER			AS	member_ID
		,	( enrollment_start_date )	::	DATE			AS	enrollment_Start_Date
		,	( enrollment_term_date )	::	DATE			AS	enrollment_Term_Date
		,	( zip3_code )				::	VARCHAR( 3 )	AS	zip3_Code
		,	( rx_benefit_indicator )	::	VARCHAR( 1 )	AS	rx_Benefit_Indicator
	FROM
		cust_abs_raw.BHI_member_enrollment
);
--ANALYZE COMPRESSION	clean_raw.BHI_member_enrollment;
ANALYZE				clean_raw.BHI_member_enrollment;
VACUUM SORT ONLY	clean_raw.BHI_member_enrollment;
ANALYZE				clean_raw.BHI_member_enrollment;



/********************************************************************************/
/*																				*/
/*	This command copies the raw data as received from the good folks at BHI		*/
/*	into the table clean_raw.BHI_member_enrollment.  This commmand IS part		*/
/*	of the standard build process, to follow the DROP/CREATE command at the		*/
/*	top.  IF you run the INSERT above, this command will eradicate the good		*/
/*	accomplished with that action!  So run one or the other, but not both.		*/
/*																				*/
/********************************************************************************/
/*
COPY		clean_raw.BHI_members
FROM		's3://dhp-rndlab-bhi-data/unzipped/member_enrollment.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;
*/



/*	What lies below is at-one-time-and-perhaps-again-but-probably-not useful schmutz.	*/
select			table_name
			,	column_name
			,	ordinal_position
			,	data_type
			,	character_maximum_length
from		information_schema.columns
where			table_schema = 'clean_raw'
			and	table_name = 'BHI_member_enrollment'
order by	ordinal_position;



analyze	compression	clean_raw.bhi_facility_claim_header;



WITH	member_start1	AS
(	select		*
			,	COALESCE( MAX( enrollment_start_date ) OVER (	PARTITION BY member_ID order by enrollment_start_date
													rows between unbounded preceding and 1 preceding ),
													enrollment_start_date )	as prev_month_start_date
			,	ADD_MONTHS( prev_month_start_date, 1 )						as prev_month_plus_1_start_date
			,	CASE	enrollment_start_date = prev_month_plus_1_start_date
					WHEN	TRUE	THEN	'0'
									ELSE	'1'
				END															AS	new_Member_ID
	from	clean_raw.BHI_member_enrollment
	order by member_ID, enrollment_start_date	),
	member_start2	AS
(	select		*
			,	COALESCE( MIN( enrollment_start_date ) OVER (	PARTITION BY member_ID order by enrollment_start_date
													rows between unbounded preceding and 1 preceding ),
													enrollment_start_date )
										as first_month_start_date
			,	CASE	enrollment_start_date = first_month_start_date
					WHEN	TRUE	THEN	'1'
									ELSE	'0'
				END															AS	new_Member_ID
	from	clean_raw.BHI_member_enrollment
	order by member_ID, enrollment_start_date	)
SELECT			ms1.member_ID
			,	ms1.enrollment_start_date
FROM				member_start1	ms1
			JOIN	member_start2	ms2
			ON			ms1.member_ID				=	ms2.member_ID
					AND	ms1.enrollment_start_date	=	ms2.enrollment_start_date
WHERE		ms1.new_Member_ID = '1'	AND	ms2.new_Member_ID = '1'
order by	ms1.member_ID, ms1.enrollment_start_date
limit		10000;


(		enrollment_ID			VARCHAR( 10 )	ENCODE	LZO
	,	member_ID				VARCHAR(  9 )	ENCODE	LZO
	,	enrollment_Start_Date	DATE			ENCODE	LZO
	,	enrollment_Term_Date	DATE			ENCODE	LZO
	,	zip3_Code				VARCHAR(  3 )	ENCODE	LZO
	,	rx_Benefit_Indicator	VARCHAR(  1 )	ENCODE	LZO



SELECT			member_ID
			,	enrollment_ID
			,	enrollment_Start_Date
			,	enrollment_Term_Date
			,	FIRST_VALUE( enrollment_start_date )
					OVER (	PARTITION BY member_ID ORDER BY enrollment_start_date
								ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING )
											AS	very_first_day_of_enrollment
			,	LAST_VALUE( enrollment_start_date )
					OVER (	PARTITION BY member_ID order by enrollment_start_date
								ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING )
											AS	very_last_day_of_enrollment
FROM		clean_raw.BHI_member_enrollment
ORDER BY		member_ID
			,	enrollment_start_date
LIMIT		10000;




SELECT			member_ID
			,	enrollment_ID
			,	enrollment_Start_Date
			,	enrollment_Term_Date
--			,	FIRST_VALUE( enrollment_ID )
--					OVER (	PARTITION BY member_ID ORDER BY enrollment_ID
--								ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING )
--											AS	smallest_enrollment_ID
			,	FIRST_VALUE( enrollment_start_date )
					OVER (	PARTITION BY member_ID ORDER BY enrollment_start_date
								ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING )
											AS	very_first_day_of_enrollment
			,	LAST_VALUE( enrollment_Term_Date )
					OVER (	PARTITION BY member_ID order by enrollment_Term_Date
								ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING )
											AS	very_last_day_of_enrollment
--			,	LAST_VALUE( enrollment_ID )
--					OVER (	PARTITION BY member_ID order by enrollment_ID
--								ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING )
--											AS	largest_enrollment_ID
FROM		clean_raw.BHI_member_enrollment
ORDER BY		very_first_day_of_enrollment	ASC
			,	member_ID
			,	enrollment_start_date
LIMIT		100
;
