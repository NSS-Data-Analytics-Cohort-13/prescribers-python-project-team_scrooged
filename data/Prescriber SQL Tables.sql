

/*Question 1*/
WITH OpioidClaims AS (SELECT 	SUM(p2.total_claim_count) AS total_claim_opioid,
						        fc.county
					  FROM
						        zip_fips AS zf
					  INNER JOIN
						        prescriber AS p1 
									ON zf.zip = p1.nppes_provider_zip5
				      INNER JOIN (SELECT  	total_claim_count,
						            		npi
						        	FROM prescription
						       		WHERE drug_name IN (
						                	SELECT
						                    	drug_name
						                	FROM
						                    	drug
						                	WHERE
						                    	opioid_drug_flag = 'Y')) AS p2 
												USING (npi)
						    INNER JOIN
						        fips_county AS fc USING (fipscounty)
						    GROUP BY
						        fc.county),

								
TotalClaims AS (
    SELECT
        SUM(p2.total_claim_count) AS total_claim_count,
        fc.county
    FROM
        zip_fips AS zf
    INNER JOIN
        prescriber AS p1 ON zf.zip = p1.nppes_provider_zip5
    INNER JOIN (
        SELECT
            total_claim_count,
            npi
        FROM
            prescription
        WHERE
            drug_name IN (
                SELECT
                    drug_name
                FROM
                    drug
            )
    ) AS p2 USING (npi)
    INNER JOIN
        fips_county AS fc USING (fipscounty)
    GROUP BY
        fc.county
)
SELECT
    tc.county,
    tc.total_claim_count,
    oc.total_claim_opioid,
	
   ROUND((CAST(oc.total_claim_opioid AS INT) / tc.total_claim_count) * 100, 2) AS Percentage_Opiod_Prescription
FROM
    TotalClaims AS tc
INNER JOIN
    OpioidClaims AS oc ON tc.county = oc.county
ORDER BY
    Percentage_Opiod_Prescription DESC
    limit 25



/*Question 2*/
SELECT
    CONCAT(pr.nppes_provider_first_name, ' ', pr.nppes_provider_last_org_name) AS prescriber_name,  -- first & last name of the prescriber
    SUM(p.total_day_supply) AS total_day_supply           -- Total day supply
FROM
    drug d
JOIN
    prescription p
ON
    d.drug_name = p.drug_name
JOIN
    prescriber pr
ON
    p.npi = pr.npi
WHERE
    d.opioid_drug_flag = 'Y'
    AND pr.nppes_provider_state = 'TN'
GROUP BY prescriber_name
	Order by
    total_day_supply DESC





/*Question 3*/

SELECT 	SUM(overdose_deaths) AS Total_ODs
	,	year
FROM overdose_deaths
GROUP BY year






/*QUERY FOR TOTAL CLAIM COUNT BY COUNTY*/
SELECT 	SUM(p2.total_claim_count) AS total_claim_count
	,	fc.county
FROM zip_fips AS zf
	INNER JOIN prescriber AS p1
		ON zf.zip = p1.nppes_provider_zip5
	INNER JOIN (SELECT  total_claim_count
					,	npi
				FROM prescription
				WHERE drug_name IN 
					(	SELECT 	drug_name
						FROM 	drug
						WHERE 	opioid_drug_flag = 'Y'))
						AS p2
					USING (npi)
	INNER JOIN fips_county AS fc
		USING (fipscounty)
GROUP BY fc.county
ORDER BY total_claim_count DESC
LIMIT 10

/*OVERDOSE DEATHS BY COUNTY*/
SELECT	SUM(od.overdose_deaths) AS total_od
	,	fc.county
FROM 	overdose_deaths AS od
INNER JOIN (SELECT 	CAST(fipscounty AS int)
			,		county
			FROM fips_county)  AS fc
	ON fc.fipscounty = od.fipscounty
GROUP BY fc.county
ORDER BY total_od DESC
LIMIT 10

/*Query for list of opioids in the data set*/

SELECT 	DISTINCT(drug_name)
FROM 	drug
WHERE 	opioid_drug_flag = 'Y'





	SELECT
    d.opioid_drug_flag,
	d.drug_name,
    d.long_acting_opioid_drug_flag,
    SUM(od.overdose_deaths) AS total_deaths
FROM
    overdose_deaths AS od
LEFT JOIN
    fips_county AS fc
ON
    CAST(od.fipscounty AS TEXT) = fc.fipscounty
JOIN zip_fips AS zf
ON
    fc.fipscounty =  zf.fipscounty
JOIN
    prescriber AS ps
ON  zf.zip = ps.nppes_provider_zip5
JOIN prescription AS p
ON   p.npi = ps.npi
JOIN
    drug d
ON
    p.drug_name = d.drug_name
WHERE
    fc.state = 'TN'
    AND od.year BETWEEN 2015 AND 2018
    AND d.opioid_drug_flag = 'Y'
GROUP BY
    d.opioid_drug_flag, d.long_acting_opioid_drug_flag,d.drug_name
	ORDER BY total_deaths DESC
    LIMIT 20;




SELECT 	SUM(overdose_deaths) AS total_od
	,	fipscounty
FROM overdose_deaths
GROUP BY fipscounty
ORDER BY total_od DESC

SELECT sum(overdose_deaths)
FROM overdose_deaths

/*Name of Drug with LLO Flag*/
WITH opioid_list_with_flag AS (SELECT DISTINCT(d.drug_name) AS drug_name
	,	d.long_acting_opioid_drug_flag AS llo_flag
FROM drug AS d
WHERE opioid_drug_flag = 'Y')


SELECT 	p.total_claim_count
	,	ol.drug_name
	,	p.npi
	,	ol.llo_flag
FROM prescription AS p
	INNER JOIN opioid_list_with_flag AS ol
		ON p.drug_name = ol.drug_name
ORDER BY total_claim_count DESC
	



SELECT 	COUNT (od.overdose_Deaths) AS deaths
	,	p2.drug_name AS name
FROM overdose_deaths AS od
	INNER JOIN fips_county AS f
		ON CAST(f.fipscounty AS int) = od.fipscounty
	INNER JOIN prescriber AS p1
		ON f.state = p1.nppes_provider_state
	INNER JOIN prescription AS p2
		ON p1.npi=p2.npi
GROUP BY name
ORDER BY deaths DESC
