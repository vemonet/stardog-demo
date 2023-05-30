CREATE DATABASE patients_dataset_cohort2;
\c patients_dataset_cohort2

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

COPY patients FROM '/data/PATIENTS_cohort2.csv' WITH (FORMAT csv, DELIMITER ',', HEADER true);


SELECT * FROM patients LIMIT 3;
