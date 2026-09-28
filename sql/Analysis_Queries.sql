USE medication_adherence;

-- 1. Executive KPIs
SELECT COUNT(DISTINCT patient_id) AS total_patients,
       COUNT(*) AS total_prescriptions,
       ROUND(100 * AVG(dropped_off), 1) AS dropoff_rate_pct
FROM adherence_flat;

-- 2. Drop-off by insurance type
SELECT insurance_type, COUNT(*) AS prescriptions,
       ROUND(100 * AVG(dropped_off), 1) AS dropoff_rate_pct
FROM adherence_flat GROUP BY insurance_type ORDER BY dropoff_rate_pct DESC;

-- 3. Drop-off by patient region
SELECT region_patient, ROUND(100 * AVG(dropped_off), 1) AS dropoff_rate_pct
FROM adherence_flat GROUP BY region_patient ORDER BY dropoff_rate_pct DESC;

-- 4. Drop-off by prescribing channel
SELECT channel, ROUND(100 * AVG(dropped_off), 1) AS dropoff_rate_pct
FROM adherence_flat GROUP BY channel ORDER BY dropoff_rate_pct DESC;

-- 5. Age group x drug class heatmap
SELECT age_band, drug_class, ROUND(100 * AVG(dropped_off), 1) AS dropoff_rate_pct
FROM adherence_flat GROUP BY age_band, drug_class ORDER BY age_band, drug_class;

-- 6. Gender and insurance distribution
SELECT gender, COUNT(DISTINCT patient_id) AS patients FROM adherence_flat GROUP BY gender;
SELECT insurance_type, COUNT(*) AS prescriptions,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS share_pct
FROM adherence_flat GROUP BY insurance_type;

-- 7. Prescription adherence journey (patients remaining at each refill number)
SELECT fill_number, COUNT(DISTINCT prescription_id) AS prescriptions_remaining
FROM fact_refills GROUP BY fill_number ORDER BY fill_number;

-- 8. Drop-off by number of fills
SELECT total_fills, COUNT(*) AS prescriptions,
       ROUND(100 * AVG(dropped_off), 1) AS dropoff_rate_pct
FROM adherence_flat GROUP BY total_fills ORDER BY total_fills;

-- 9. Average refill gap by insurance type
SELECT a.insurance_type, ROUND(AVG(r.gap_days_since_due), 1) AS avg_gap_days
FROM fact_refills r JOIN adherence_flat a USING (prescription_id)
GROUP BY a.insurance_type ORDER BY avg_gap_days DESC;
