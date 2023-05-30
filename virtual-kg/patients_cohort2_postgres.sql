CREATE DATABASE mimic_iv;
\c mimic_iv

CREATE TABLE patients (
	subject_id INTEGER NOT NULL,
	gender VARCHAR(128) NOT NULL,
	anchor_age INTEGER NOT NULL,
	anchor_year INTEGER NOT NULL,
	anchor_year_group VARCHAR(128) NOT NULL,
	dod DATE NULL
);

COPY patients FROM '/data/hosp/patients_cohort2.csv' WITH (FORMAT csv, DELIMITER ',', HEADER true);


SELECT * FROM patients LIMIT 3;
