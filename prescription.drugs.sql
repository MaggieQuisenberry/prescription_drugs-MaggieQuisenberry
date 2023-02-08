-- --  a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS total_claim_count
FROM prescriber
INNER JOIN prescription
USING (npi)
GROUP BY npi
ORDER BY total_claim_count DESC;

    
-- --     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS total_claim_count
FROM prescription
INNER JOIN prescriber 
USING (npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_claim_count DESC;



SELECT *
FROM prescriber;

-- -- 2. 
-- --     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count) AS total_claim_count
FROM prescription
INNER JOIN prescriber 
USING (npi)
GROUP BY specialty_description
ORDER BY total_claim_count DESC;



-- --     b. Which specialty had the most total number of claims for opioids?

SELECT specialty_description, SUM(total_claim_count), opioid_drug_flag
FROM prescriber 
INNER JOIN prescription 
USING (npi)
INNER JOIN drug 
USING(drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description, opioid_drug_flag
ORDER BY SUM(total_claim_count) DESC;


;
								

-- --     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table? NO

SELECT specialty_description, SUM(total_claim_count)
FROM prescriber
INNER JOIN prescription
USING (npi)
GROUP BY specialty_description
ORDER BY SUM(total_claim_count);

-- --     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- -- 3. 
-- --     a. Which drug (generic_name) had the highest total drug cost?

SELECT *
FROM prescription;


SELECT SUM(total_drug_cost), generic_name
FROM prescription
INNER JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY SUM(total_drug_cost)DESC
LIMIT 1;




-- --     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.** oxycodone $151.30/day

SELECT generic_name, ROUND(total_30_day_fill_count/30,2) AS cost_per_day
FROM prescription
INNER JOIN drug
USING (drug_name)
ORDER BY cost_per_day DESC;


-- -- 4. 
-- --     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	 ELSE 'neither' END AS drug_type
FROM drug;

-- --     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT SUM(total_drug_cost::MONEY), opioid_drug_flag, antibiotic_drug_flag,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'END
FROM drug
LEFT JOIN prescription
USING(drug_name)
GROUP BY opioid_drug_flag, antibiotic_drug_flag
ORDER BY SUM(total_drug_cost) DESC;

-- try to come back and add sum in the case statement



-- -- 5. 
-- --     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT (DISTINCT cbsa)
FROM cbsa
INNER JOIN fips_county
USING (fipscounty)
WHERE state ilike '%TN%';


-- --     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT MAX(population), cbsaname, cbsa
FROM cbsa
INNER JOIN population
USING (fipscounty)
GROUP by cbsa, cbsaname
Order by MAX(population)
LIMIT 1;

SELECT MIN(population), cbsaname, cbsa
FROM cbsa
INNER JOIN population
USING (fipscounty)
GROUP by cbsa, cbsaname
Order by MIN(population)
LIMIT 1;

-- i feel like there is no way that this is correct




-- --     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

Sohams answer

SELECT *
FROM cbsa
INNER JOIN population
USING (fipscounty)
ORDER BY cbsa;

NO idea

-- -- 6. 
-- --     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, SUM(total_claim_count) AS total_claim_count
FROM drug
INNER JOIN prescription
USING (drug_name)
GROUP BY drug_name
HAVING SUM(total_claim_count) > 3000
ORDER BY total_claim_count DESC;

--I feel like this is correct. She was wrong. This answer above was not correct. She was making life harder than it ever needed to be

SELECT DISTINCT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count > 3000;

-- --     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
CANNOT GET THIS STATEMENT TO RUN. LOOK AT IT AGAIN

SELECT DISTINCT drug_name, total_claim_count
	CASE WHEN opioid_drug_flag = 'Y' THEN 'yes'
		WHEN opioid_drug_flag = 'N' THEN 'no' END AS opioid
FROM drug
INNER JOIN prescription
USING (drug_name)
GROUP BY drug_name, opioid, total_claim_count
WHERE total_claim_count > 3000;



--- INCORRECT---- INCORRECT but beautiful so I cannot delete______
SELECT drug_name, SUM(total_claim_count) AS total_claim_count,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'yes'
		WHEN opioid_drug_flag = 'N' THEN 'no' END AS opioid
FROM drug
INNER JOIN prescription
USING (drug_name)
GROUP BY drug_name, opioid
HAVING SUM(total_claim_count) > 3000
ORDER BY total_claim_count DESC;


CASE WHEN opioid_drug_flag = 'y' THEN 'yes'
		WHEN opioid_drug_flag = 'n' THEN 'no' END AS opioid

-- --     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

-- -- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.




-- --     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

----THIS IS WRONG-----
SELECT prescriber.npi, drug.drug_name
FROM prescriber
INNER JOIN prescription
USING (npi)
INNER JOIN drug
USING (drug_name)
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city = 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y';

--THIS IS RIGHT. THIS IS RIGHT. 
SELECT prescriber.npi, drug.drug_name
FROM prescriber
CROSS JOIN drug
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city = 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y';

SELECT *
FROM prescription;



-- --     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT prescriber.npi, prescriber.nppes_provider_last_org_name, prescriber.nppes_provider_first_name, drug.drug_name, prescription.total_claim_count
FROM prescriber
CROSS JOIN drug
INNER JOIN prescription
ON (prescription.drug_name = drug.drug_name AND prescriber.npi = prescription.npi)
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city = 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y'
ORDER by prescriber.nppes_provider_last_org_name;
    
-- --     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.