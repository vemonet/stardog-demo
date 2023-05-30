CREATE DATABASE patients_dataset_cohort3;
USE patients_dataset_cohort3;

CREATE TABLE patients (
	row_id INTEGER NOT NULL,
	subject_id INTEGER NOT NULL,
	gender VARCHAR(128) NOT NULL,
	dob VARCHAR(128) NULL,
	dod VARCHAR(128) NULL,
	dod_hosp VARCHAR(128) NULL,
	dod_ssn VARCHAR(128) NULL,
	expire_flag VARCHAR(128) NULL
);

LOAD DATA INFILE '/data/PATIENTS_cohort3.csv'
INTO TABLE patients
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SELECT * FROM patients LIMIT 3;
