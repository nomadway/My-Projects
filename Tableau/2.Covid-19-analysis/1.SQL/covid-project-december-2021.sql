
SELECT *
FROM
	PortfolioProject..CovidDeaths$
ORDER BY 3,4
-----------------------------------
--TOTAL CASES vs TOTAL LIVES LOST
SELECT
	location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 AS percent_lost_lives
FROM
	PortfolioProject..CovidDeaths$
WHERE
	location like '%states%'
ORDER BY
	1,2;
--------------------------------
SELECT
	location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 AS percent_lost_lives
FROM
	PortfolioProject..CovidDeaths$
WHERE
	location = 'Canada'
ORDER BY
	1,2;
--------------------------
---TOTAL COVID CASES vs TOTAL POPULATION
SELECT
	location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM
	PortfolioProject..CovidDeaths$
WHERE
	location = 'Canada'
ORDER BY
	1,2;

-----COUNTRIES WITH HIGHEST COVID RATES vs TOTAL POPULATION
SELECT
	location, population, MAX(total_cases) AS infection_count, 
	MAX(total_cases/population)*100 AS percent_population_infected
FROM
	PortfolioProject..CovidDeaths$
GROUP BY
	location, population
ORDER BY
	percent_population_infected DESC;

-----COUNTRIES WITH HIGHEST LIVES LOSSES PER TOTAL POPULATION
SELECT
	location, MAX(CAST(total_deaths AS int)) AS total_lives_lost
FROM 
	PortfolioProject..CovidDeaths$
GROUP BY
	location
ORDER BY
	total_lives_lost DESC;

---LIVES LOST BY CONTINENTS
SELECT
	location, MAX(CAST(total_deaths AS int)) AS total_lives_lost
FROM 
	PortfolioProject..CovidDeaths$
WHERE
	continent IS NULL
GROUP BY
	location
ORDER BY
	total_lives_lost DESC;
-----------------------------
--GLOBAL COVID NUMBERS
SELECT
	date, SUM(new_cases)AS total_cases, SUM(CAST(new_deaths AS int)) AS total_lives_lost,
	SUM(CAST(new_deaths AS int))/ SUM(new_cases)*100 AS percent_total_deaths
FROM
	PortfolioProject..CovidDeaths$
WHERE 
	continent IS NOT NULL
GROUP BY
	date
ORDER BY
	1,2;
----1-for TABLEAU---------------------------
SELECT
	SUM(new_cases)AS total_cases, SUM(CAST(new_deaths AS int)) AS total_lives_lost,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS percent_total_deaths
FROM
	PortfolioProject..CovidDeaths$
WHERE 
	continent IS NOT NULL

ORDER BY
	1,2;

-----2-for TABLEAU
SELECT
	location, SUM(CAST(new_deaths AS int)) AS total_lives_lost
FROM
	PortfolioProject..CovidDeaths$
WHERE
	continent IS NULL AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'Low income', 'High income')
GROUP BY
	location
ORDER BY
	total_lives_lost DESC;

---3-for TABLEAU---
SELECT
	location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM
	PortfolioProject..CovidDeaths$
GROUP BY 
	location, population
ORDER BY
	percent_population_infected DESC; 

-----4-for TABLEAU-----
SELECT
	location, population, date, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM
	PortfolioProject..CovidDeaths$
GROUP BY 
	location, population, date
ORDER BY
	percent_population_infected DESC;




















--------------TOTAL POPULATION vs TOTAL VACCINATION 
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_num_vac_people
FROM
	PortfolioProject..CovidDeaths$ dea
	JOIN
	PortfolioProject..CovidVaccinations$ vac
	ON
	dea.location = vac.location
	AND
	dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY
	2,3;

----------------------------------
--USING COMMON TABLE EXPRESSION(CTE)

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_num_vac_people)
AS 
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_num_vac_people
FROM
	PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
)
---------------
SELECT *, (rolling_num_vac_people/population)*100
FROM PopvsVac;

-----TEMPORARY TABLE---
CREATE TABLE #percentofvacpeople
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_num_vac_people numeric
)
INSERT INTO #percentofvacpeople
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_num_vac_people
FROM
	PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (rolling_num_vac_people/population)*100
FROM #percentofvacpeople;

--------------------------
DROP TABLE IF EXISTS  #percentofvacpeople
CREATE TABLE #percentofvacpeople
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_num_vac_people numeric
)
INSERT INTO #percentofvacpeople
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_num_vac_people
FROM
	PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (rolling_num_vac_people/population)*100
FROM #percentofvacpeople;


----CREATING VIEW
CREATE VIEW percentofvacpeople AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_num_vac_people
FROM
	PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
--------------------

SELECT *
FROM
	percentofvacpeople;




 






















































