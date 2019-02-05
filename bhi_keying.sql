CREATE TABLE cust_abs_raw.bhi_member_enrollment
(
	enrollmentid VARCHAR(10) ENCODE lzo,
	memberid VARCHAR(9) ENCODE lzo,
	enrollmentstartdate DATE ENCODE lzo,
	enrollmenttermdate DATE ENCODE lzo,
	zip3code VARCHAR(3) ENCODE lzo,
	rxbenefitindicator VARCHAR(1) ENCODE lzo
)
DISTSTYLE KEY
DISTKEY(memberid)
COMPOUND SORTKEY(memberid,enrollmentstartdate,enrollmenttermdate)
;


CREATE TABLE cust_abs_raw.bhi_members
(
	memberid INTEGER ENCODE delta32k,
	birthyear INTEGER ENCODE delta,
	gender VARCHAR(1) ENCODE bytedict
)
DISTSTYLE KEY
DISTKEY(memberid)
COMPOUND SORTKEY(memberid,birthyear,gender)
;


insert into cust_abs_raw.bhi_member_enrollment
	(
	select * from clean_raw.bhi_member_enrollment
	)
;
analyze cust_abs_raw.bhi_member_enrollment;
vacuum sort only cust_abs_raw.bhi_member_enrollment;
analyze cust_abs_raw.bhi_member_enrollment;

insert into cust_abs_raw.bhi_members
	(
	select * from clean_raw.bhi_members
	)
;
analyze cust_abs_raw.bhi_members;
vacuum sort only cust_abs_raw.bhi_members;
analyze cust_abs_raw.bhi_members;

select table_name, column_name, ordinal_position, data_type, character_maximum_length from information_schema.columns where table_schema = 'clean_raw' and table_name = 'bhi_facility_claim_header'
order by ordinal_position;
analyze compression clean_raw.bhi_facility_claim_header;

create table cust_abs_raw.bhi_facility_claim_header
	(
	  claim_id	varchar(9)	encode	zstd
	,  member_id	varchar(9)	encode	zstd
	,  category_of_service_code	varchar(3)	encode	zstd
	,  place_of_service_code	varchar(2)	encode	zstd
	,  admission_source_code	varchar(2)	encode	zstd
	,  admission_type_code	varchar(2)	encode	zstd
	,  claimtypecode	varchar(2)	encode	zstd
	,  discharge_status_code	varchar(2)	encode	zstd
	,  type_of_bill_code	varchar(3)	encode	zstd
	,  first_date_of_service	date	encode	zstd
	,  last_date_of_service	date	encode	zstd
	,  admitting_dx_code	varchar(7)	encode	zstd
	,  primary_dx_code	varchar(7)	encode	zstd
	,  secondary_dx_code1	varchar(7)	encode	zstd
	,  secondary_dx_code2	varchar(7)	encode	zstd
	,  secondary_dx_code3	varchar(7)	encode	zstd
	,  secondary_dx_code4	varchar(7)	encode	zstd
	,  secondary_dx_code5	varchar(7)	encode	zstd
	,  secondary_dx_code6	varchar(7)	encode	zstd
	,  secondary_dx_code7	varchar(7)	encode	zstd
	,  secondary_dx_code8	varchar(7)	encode	zstd
	,  secondary_dx_code9	varchar(7)	encode	zstd
	,  secondary_dx_code10	varchar(7)	encode	zstd
	,  principal_procedure_code	varchar(6)	encode	zstd
	,  secondary_procedure_code1	varchar(6)	encode	zstd
	,  secondary_procedure_code2	varchar(6)	encode	zstd
	,  secondary_procedure_code3	varchar(6)	encode	zstd
	,  secondary_procedure_code4	varchar(6)	encode	zstd
	,  secondary_procedure_code5	varchar(6)	encode	zstd
	,  billing_provider_npi	varchar(10)	encode	zstd
	,  billing_provider_specialty_code	varchar(2)	encode	zstd
	,  billing_provider_zip_code	varchar(5)	encode	zstd
	,  billing_provide_rmedicare_id	varchar(20)	encode	zstd
	,  rendering_provider_npi	varchar(10)	encode	zstd
	,  rendering_provider_specialty_code	varchar(2)	encode	zstd
	,  rendering_provider_zip_code	varchar(5)	encode	zstd
	,  claims_system_assigned_drg_code	varchar(4)	encode	zstd
	,  claims_system_assigned_mdc_code	varchar(2)	encode	zstd
	,  icd_code_type	varchar(1)	encode	zstd
	,  admitting_icd10_dx_code	varchar(8)	encode	zstd
	,  primary_icd10_dx_code	varchar(8)	encode	zstd
	,  secondary_icd10_dx_code1	varchar(8)	encode	zstd
	,  secondary_icd10_dx_code2	varchar(8)	encode	zstd
	,  secondary_icd10_dx_code3	varchar(8)	encode	zstd
	,  secondary_icd10_dx_code4	varchar(8)	encode	zstd
	,  secondary_icd10_dx_code5	varchar(8)	encode	zstd
	,  secondary_icd10_dx_code6	varchar(8)	encode	zstd
	,  secondary_icd10_dx_code7	varchar(8)	encode	zstd
	,  secondary_icd10_dx_code8	varchar(8)	encode	zstd
	,  secondary_icd10_dx_code9	varchar(8)	encode	zstd
	,  secondary_icd10_dx_code10	varchar(8)	encode	zstd
	,  principal_icd10_procedure_code	varchar(7)	encode	zstd
	,  secondary_icd10_procedure_code1	varchar(7)	encode	zstd
	,  secondary_icd10_procedure_code2	varchar(7)	encode	zstd
	,  secondary_icd10_procedure_code3	varchar(7)	encode	zstd
	,  secondary_icd10_procedure_code4	varchar(7)	encode	zstd
	,  secondary_icd10_procedure_code5	varchar(7)	encode	zstd
	,  claim_payment_status_code	varchar(1)	encode	zstd
	,  non_covered_reason_code	varchar(2)	encode	zstd
	)
diststyle key
distkey(member_id)
compound sortkey(member_id,claim_id,rendering_provider_npi,first_date_of_service,last_date_of_service,primary_dx_code)
;

insert into cust_abs_raw.bhi_facility_claim_header
	(
	select * from clean_raw.bhi_facility_claim_header
	)
;
analyze cust_abs_raw.bhi_facility_claim_header;
vacuum sort only cust_abs_raw.bhi_facility_claim_header;
analyze cust_abs_raw.bhi_facility_claim_header;


select table_name, column_name, ordinal_position, data_type, character_maximum_length from information_schema.columns where table_schema = 'clean_raw' and table_name = 'bhi_facility_claim_detail'
order by ordinal_position;
analyze compression clean_raw.bhi_facility_claim_detail;



create table cust_abs_raw.bhi_facility_claim_detail
	(
	  claim_id	varchar(9)	encode	zstd
	,  claimlinenum	integer	encode	zstd
	,  member_id	varchar(9)	encode	zstd
	,  cpt_hcpcs_code	varchar(6)	encode	zstd
	,  proceduremodifiercode	varchar(2)	encode	zstd
	,  revenuecode	varchar(4)	encode	bytedict
	,  numberofunits	numeric	encode	zstd
	,  typeofservicecode	varchar(5)	encode	zstd
	,  claimpaymentstatuscode	varchar(1)	encode	zstd
	,  noncoveredreasoncode	varchar(2)	encode	zstd
	,  tcrrvamount	numeric	encode	zstd
	)
diststyle key
distkey(member_id)
compound sortkey(member_id,claim_id,claimlinenum,cpt_hcpcs_code,proceduremodifiercode)
;

insert into cust_abs_raw.bhi_facility_claim_detail
	(
	select * from clean_raw.bhi_facility_claim_detail
	)
;
analyze cust_abs_raw.bhi_facility_claim_detail;
vacuum sort only cust_abs_raw.bhi_facility_claim_detail;
analyze cust_abs_raw.bhi_facility_claim_detail;



select table_name, column_name, ordinal_position, data_type, character_maximum_length from information_schema.columns where table_schema = 'clean_raw' and table_name = 'bhi_pharmacy_claims'
order by ordinal_position;
analyze compression clean_raw.bhi_pharmacy_claims;

-- drop table if exists cust_abs_raw.bhi_pharmacy_claims;
create table cust_abs_raw.bhi_pharmacy_claims
	(
	  claimid	varchar(12)	encode	zstd
	,  claimlinenum	integer	encode	zstd
	,  memberid	varchar(9)	encode	zstd
	,  placeofservicecode	varchar(2)	encode	zstd
	,  ndccode	varchar(11)	encode	zstd
	,  countofdayssupply	integer	encode	zstd
	,  dispensedquantity	numeric	encode	zstd
	,  prescriptionfilldate	date	encode	zstd
	,  billingprovidernpi	varchar(10)	encode	zstd
	,  renderingprovidernpi	varchar(10)	encode	zstd
	,  prescribingprovidernpi	varchar(10)	encode	zstd
	,  prescribingproviderdeancpdpid	varchar(27)	encode	zstd
	,  compoundindicator	varchar(1)	encode	zstd
	,  dawcode	varchar(2)	encode	zstd
	,  dispensingstatuscode	varchar(1)	encode	zstd
	,  planspecialtydrugindicator	varchar(1)	encode	zstd
	,  tcrrvamount	numeric	encode	zstd
	)
diststyle key
distkey(memberid)
compound sortkey(memberid,claimid,claimlinenum,prescribingprovidernpi,ndccode,prescriptionfilldate)
;

insert into cust_abs_raw.bhi_pharmacy_claims
	(
	select * from clean_raw.bhi_pharmacy_claims
	)
;
analyze cust_abs_raw.bhi_pharmacy_claims;
vacuum sort only cust_abs_raw.bhi_pharmacy_claims;
analyze cust_abs_raw.bhi_pharmacy_claims;


select table_name, column_name, ordinal_position, data_type, character_maximum_length from information_schema.columns where table_schema = 'clean_raw' and table_name = 'bhi_professional_claims'
order by ordinal_position;
analyze compression clean_raw.bhi_professional_claims;

create table cust_abs_raw.bhi_professional_claims
	(
	  claimid	varchar(12)	encode	zstd
	,  claimlinenum	integer	encode	zstd
	,  memberid	varchar(12)	encode	zstd
	,  categoryofservicecode	varchar(3)	encode	zstd
	,  placeofservicecode	varchar(2)	encode	zstd
	,  claimtypecode	varchar(2)	encode	zstd
	,  cpt_hcpcs_code	varchar(6)	encode	zstd
	,  cptmodifiercode	varchar(2)	encode	zstd
	,  numberofunits	numeric	encode	zstd
	,  typeofservicecode	varchar(5)	encode	bytedict
	,  firstdateofservice	date	encode	zstd
	,  lastdateofservice	date	encode	zstd
	,  primarydxcode	varchar(7)	encode	zstd
	,  secondarydxcode1	varchar(7)	encode	zstd
	,  secondarydxcode2	varchar(7)	encode	zstd
	,  secondarydxcode3	varchar(7)	encode	zstd
	,  billing_providernpi	varchar(10)	encode	zstd
	,  billing_providerspecialtycode	varchar(2)	encode	zstd
	,  billing_providerzipcode	varchar(5)	encode	zstd
	,  billing_providermedicareid	varchar(20)	encode	zstd
	,  renderingprovidernpi	varchar(10)	encode	zstd
	,  renderingproviderspecialtycode	varchar(2)	encode	zstd
	,  renderingprovidertypecode	varchar(2)	encode	zstd
	,  renderingproviderzipcode	varchar(5)	encode	zstd
	,  icdcodetype	varchar(1)	encode	zstd
	,  primaryicd10dxcode	varchar(8)	encode	zstd
	,  secondaryicd10dxcode1	varchar(8)	encode	zstd
	,  secondaryicd10dxcode2	varchar(8)	encode	zstd
	,  secondaryicd10dxcode3	varchar(8)	encode	zstd
	,  claimpaymentstatuscode	varchar(1)	encode	zstd
	,  noncoveredreasoncode	varchar(2)	encode	zstd
	,  tcrrvamount	numeric	encode	zstd
	)
diststyle key
distkey(memberid)
compound sortkey(memberid,claimid,claimlinenum,renderingprovidernpi
,primarydxcode,cpt_hcpcs_code,firstdateofservice,lastdateofservice)
;

insert into cust_abs_raw.bhi_professional_claims
	(
	select * from clean_raw.bhi_professional_claims
	)
;
analyze cust_abs_raw.bhi_professional_claims;
vacuum sort only cust_abs_raw.bhi_professional_claims;
analyze cust_abs_raw.bhi_professional_claims;



