


DROP TABLE IF EXISTS		clean_raw.BHI_reference_admit_source;
CREATE TABLE				clean_raw.BHI_reference_admit_source
(		code				VARCHAR(  2 )	ENCODE	RAW
	,	description		VARCHAR( 50 )	ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_admit_source	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_admit_source
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_admit_source.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_admit_source;
ANALYZE					clean_raw.BHI_reference_admit_source;
VACUUM SORT ONLY			clean_raw.BHI_reference_admit_source;
ANALYZE					clean_raw.BHI_reference_admit_source;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_admit_type;
CREATE TABLE				clean_raw.BHI_reference_admit_type
(		code				VARCHAR(  2 )	ENCODE	RAW
	,	description		VARCHAR( 26 )	ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_admit_type	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_admit_type
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_admit_type.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_admit_type;
ANALYZE					clean_raw.BHI_reference_admit_type;
VACUUM SORT ONLY			clean_raw.BHI_reference_admit_type;
ANALYZE					clean_raw.BHI_reference_admit_type;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_benefit_payment_status;
CREATE TABLE				clean_raw.BHI_reference_benefit_payment_status
(		code				VARCHAR(  1 )	--ENCODE	RAW
	,	description		VARCHAR( 18 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_benefit_payment_status	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_benefit_payment_status
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_benefit_payment_status.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_benefit_payment_status;
ANALYZE					clean_raw.BHI_reference_benefit_payment_status;
VACUUM SORT ONLY			clean_raw.BHI_reference_benefit_payment_status;
ANALYZE					clean_raw.BHI_reference_benefit_payment_status;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_claim_type;
CREATE TABLE				clean_raw.BHI_reference_claim_type
(		code				VARCHAR(  2 )	--ENCODE	RAW
	,	description		VARCHAR( 20 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_claim_type	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_claim_type
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_claim_type.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_claim_type;
ANALYZE					clean_raw.BHI_reference_claim_type;
VACUUM SORT ONLY			clean_raw.BHI_reference_claim_type;
ANALYZE					clean_raw.BHI_reference_claim_type;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_discharge_status;
CREATE TABLE				clean_raw.BHI_reference_discharge_status
(		code				VARCHAR(  2 )	--ENCODE	RAW
	,	description		VARCHAR( 80 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_discharge_status	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_discharge_status
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_discharge_status.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_discharge_status;
ANALYZE					clean_raw.BHI_reference_discharge_status;
VACUUM SORT ONLY			clean_raw.BHI_reference_discharge_status;
ANALYZE					clean_raw.BHI_reference_discharge_status;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_dispensing_status;
CREATE TABLE				clean_raw.BHI_reference_dispensing_status
(		code				VARCHAR(  2 )	--ENCODE	RAW
	,	description		VARCHAR( 26 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_dispensing_status	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_dispensing_status
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_dispensing_status.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_dispensing_status;
ANALYZE					clean_raw.BHI_reference_dispensing_status;
VACUUM SORT ONLY			clean_raw.BHI_reference_dispensing_status;
ANALYZE					clean_raw.BHI_reference_dispensing_status;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_noncovered_reason;
CREATE TABLE				clean_raw.BHI_reference_noncovered_reason
(		code				VARCHAR(  2 )	--ENCODE	RAW
	,	description		VARCHAR( 48 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_noncovered_reason	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_noncovered_reason
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_noncovered_reason.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_noncovered_reason;
ANALYZE					clean_raw.BHI_reference_noncovered_reason;
VACUUM SORT ONLY			clean_raw.BHI_reference_noncovered_reason;
ANALYZE					clean_raw.BHI_reference_noncovered_reason;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_place_of_service;
CREATE TABLE				clean_raw.BHI_reference_place_of_service
(		code				VARCHAR(  2 )	--ENCODE	RAW
	,	description		VARCHAR( 70 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_place_of_service	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_place_of_service
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_place_of_service.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_place_of_service;
ANALYZE					clean_raw.BHI_reference_place_of_service;
VACUUM SORT ONLY			clean_raw.BHI_reference_place_of_service;
ANALYZE					clean_raw.BHI_reference_place_of_service;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_product;
CREATE TABLE				clean_raw.BHI_reference_product
(		code				VARCHAR(  4 )	--ENCODE	RAW
	,	description		VARCHAR( 32 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_product	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_product
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_product.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_product;
ANALYZE					clean_raw.BHI_reference_product;
VACUUM SORT ONLY			clean_raw.BHI_reference_product;
ANALYZE					clean_raw.BHI_reference_product;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_provider_specialty;
CREATE TABLE				clean_raw.BHI_reference_provider_specialty
(		code				VARCHAR(  2 )	--ENCODE	RAW
	,	description		VARCHAR( 45 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_provider_specialty	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_provider_specialty
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_provider_specialty.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;



ANALYZE COMPRESSION		clean_raw.BHI_reference_provider_specialty;
ANALYZE					clean_raw.BHI_reference_provider_specialty;
VACUUM SORT ONLY			clean_raw.BHI_reference_provider_specialty;
ANALYZE					clean_raw.BHI_reference_provider_specialty;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_provider_type;
CREATE TABLE				clean_raw.BHI_reference_provider_type
(		code				VARCHAR(  2 )	--ENCODE	RAW
	,	description		VARCHAR( 30 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_provider_type	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_provider_type
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_provider_type.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_provider_type;
ANALYZE					clean_raw.BHI_reference_provider_type;
VACUUM SORT ONLY			clean_raw.BHI_reference_provider_type;
ANALYZE					clean_raw.BHI_reference_provider_type;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_reimbursement_type;
CREATE TABLE				clean_raw.BHI_reference_reimbursement_type
(		code				VARCHAR(  5 )	--ENCODE	RAW
	,	description		VARCHAR( 35 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_reimbursement_type	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_reimbursement_type
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_reimbursement_type.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_reimbursement_type;
ANALYZE					clean_raw.BHI_reference_reimbursement_type;
VACUUM SORT ONLY			clean_raw.BHI_reference_reimbursement_type;
ANALYZE					clean_raw.BHI_reference_reimbursement_type;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_type_of_bill;
CREATE TABLE				clean_raw.BHI_reference_type_of_bill
(		code				VARCHAR(  3 )	--ENCODE	RAW
	,	description		VARCHAR( 50 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_type_of_bill	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_type_of_bill
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_type_of_bill.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_type_of_bill;
ANALYZE					clean_raw.BHI_reference_type_of_bill;
VACUUM SORT ONLY			clean_raw.BHI_reference_type_of_bill;
ANALYZE					clean_raw.BHI_reference_type_of_bill;



DROP TABLE IF EXISTS		clean_raw.BHI_reference_type_of_service;
CREATE TABLE				clean_raw.BHI_reference_type_of_service
(		code				VARCHAR(  5 )	--ENCODE	RAW
	,	description		VARCHAR( 35 )	--ENCODE	RAW
)	/*	create			clean_raw.BHI_reference_type_of_service	*/
COMPOUND SORTKEY( code );



COPY		clean_raw.BHI_reference_type_of_service
FROM		's3://dhp-rndlab-bhi-data/unzipped/reference_type_of_service.dat'
credentials 'aws_iam_role=arn:aws:iam::722648170004:role/Data_Wranglers'
ACCEPTANYDATE ACCEPTINVCHARS '^' BLANKSASNULL EMPTYASNULL NULL AS 'NULL' IGNOREBLANKLINES DATEFORMAT 'auto'
IGNOREHEADER 1 TRIMBLANKS DELIMITER '|' STATUPDATE ON MAXERROR 0 COMPUPDATE ON;

--ANALYZE COMPRESSION		clean_raw.BHI_reference_type_of_service;
ANALYZE					clean_raw.BHI_reference_type_of_service;
VACUUM SORT ONLY			clean_raw.BHI_reference_type_of_service;
ANALYZE					clean_raw.BHI_reference_type_of_service;


