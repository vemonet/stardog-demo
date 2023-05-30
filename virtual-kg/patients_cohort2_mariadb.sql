CREATE DATABASE mimic_iv;
USE mimic_iv;

CREATE TABLE patients (
	subject_id INTEGER NOT NULL,
	gender VARCHAR(128) NOT NULL,
	anchor_age INTEGER NOT NULL,
	anchor_year INTEGER NOT NULL,
	anchor_year_group VARCHAR(128) NOT NULL,
	dod DATE NULL
);

LOAD DATA INFILE '/data/hosp/patients_cohort2.csv'
INTO TABLE patients
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SELECT * FROM patients LIMIT 3;
