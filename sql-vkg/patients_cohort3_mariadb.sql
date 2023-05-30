CREATE DATABASE patients_dataset_cohort3;
USE patients_dataset_cohort3;

CREATE TABLE patients (
	row_id INTEGER NOT NULL,
	subject_id INTEGER NOT NULL,
	gender VARCHAR(128),
	dob VARCHAR(128),
	dod VARCHAR(128),
	dod_hosp VARCHAR(128),
	dod_ssn VARCHAR(128),
	expire_flag VARCHAR(128),
);

LOAD DATA INFILE '/data/PATIENTS_cohort3.csv'
INTO TABLE patients
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SELECT * FROM patients LIMIT 3;
