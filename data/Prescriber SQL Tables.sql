SELECT 	p2.total_claim_count/p1.total_claim_count AS claim_proportions
	,	p1.npi
FROM prescription AS p1
	INNER JOIN (SELECT  total_claim_count
					,	npi
				FROM prescription
				WHERE drug_name IN 
					(	SELECT 	drug_name
						FROM 	drug
						WHERE 	opioid_drug_flag = 'Y'))
						AS p2
			ON p1.npi=p2.npi

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

SELECT 	drug_name
FROM 	drug
WHERE 	opioid_drug_flag = 'Y'



SELECT total_claim_count
FROM prescription


















	SELECT 
    od.year,
    SUM(od.overdose_deaths) AS total_deaths,
    SUM(p.population) AS total_population,
	fc.county,
	fc.state
FROM 
    overdose_deaths od
JOIN 
    fips_county fc
ON 
    CAST(od.fipscounty AS TEXT) = fc.fipscounty
JOIN 
    population p
ON 
    CAST(fc.fipscounty AS TEXT) = CAST(p.fipscounty AS TEXT)
WHERE 
    fc.state = 'TN'
    AND od.year BETWEEN 2015 AND 2018
GROUP BY 
    od.year,fc.state,fc.county
ORDER BY 
    od.year;
    AND year BETWEEN 2015 AND 2018
GROUP BY 
    year, opioid_type
ORDER BY 
    year, opioid_type;