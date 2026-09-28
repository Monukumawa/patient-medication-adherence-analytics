-- Patient Medication Adherence Analytics : MySQL setup
CREATE DATABASE IF NOT EXISTS medication_adherence;
USE medication_adherence;

DROP TABLE IF EXISTS fact_refills;
DROP TABLE IF EXISTS adherence_flat;

CREATE TABLE adherence_flat (
    prescription_id         VARCHAR(10) PRIMARY KEY,
    patient_id              VARCHAR(10),
    doctor_id               VARCHAR(10),
    drug_name               VARCHAR(50),
    drug_class              VARCHAR(30),
    prescription_start_date DATE,
    channel                 VARCHAR(30),
    days_supply_per_fill    INT,
    total_fills             INT,
    dropped_off             TINYINT,
    last_fill_date          DATE,
    age                     INT,
    gender                  VARCHAR(10),
    region_patient          VARCHAR(20),
    insurance_type          VARCHAR(30),
    has_comorbidity         TINYINT,
    age_band                VARCHAR(10),
    specialty               VARCHAR(30),
    region_doctor           VARCHAR(20),
    years_practicing        INT
);

CREATE TABLE fact_refills (
    refill_id          VARCHAR(12) PRIMARY KEY,
    prescription_id    VARCHAR(10),
    patient_id         VARCHAR(10),
    fill_number        INT,
    fill_date          DATE,
    days_supply        INT,
    gap_days_since_due INT,
    FOREIGN KEY (prescription_id) REFERENCES adherence_flat(prescription_id)
);

-- Load data (adjust the path; enable local_infile if needed)
LOAD DATA LOCAL INFILE 'Dataset/adherence_flat.csv'
INTO TABLE adherence_flat FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'Dataset/fact_refills.csv'
INTO TABLE fact_refills FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- Sanity check
SELECT COUNT(*) AS prescriptions, COUNT(DISTINCT patient_id) AS patients FROM adherence_flat;
