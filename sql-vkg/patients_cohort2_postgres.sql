CREATE DATABASE patients_dataset_cohort2;
\c patients_dataset_cohort2

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

COPY patients FROM '/data/PATIENTS_cohort2.csv' WITH (FORMAT csv, DELIMITER ',', HEADER true);


SELECT * FROM patients LIMIT 3;
