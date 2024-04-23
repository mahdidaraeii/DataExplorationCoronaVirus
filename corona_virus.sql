-- Covid-19 data exploration

SELECT *
FROM coviddeaths
ORDER BY location, date;

SELECT *
FROM covidvaccinations
ORDER BY location, date;


-- Total cases vs total deathes
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Total cases vs total population
SELECT location, date, population, (total_cases/population)*100
FROM coviddeaths
WHERE continent IS NOT NULL 
ORDER BY location, date;

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfection, MAX((total_cases/population))*100 AS  HighestPopulationInfectionRate
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestPopulationInfectionRate DESC;

-- Countries with Highest Death Count per Population
SELECT location, population, MAX(CAST(total_deaths AS UNSIGNED)) AS HighestDeaths, MAX((total_deaths/population))*100 AS  HighestPopulationDeathRate
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeaths DESC;

-- Continent death counts
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS HighestDeaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeaths DESC;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths, SUM(cast(new_deaths AS unsigned))/SUM(New_Cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths;

-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinatedByDate
FROM coviddeaths AS dea
INNER JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

-- CTE to calculate percentage of vaccinated people 
WITH PopulationVacc (Continent, location, date, population, new_vaccinations, TotalVaccinatedByDate)
AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinatedByDate
FROM coviddeaths AS dea
INNER JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date)
SELECT *, (TotalVaccinatedByDate/population)*100 AS vaccinated_percentage
FROM PopulationVacc;

-- calculating using a temp table
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVacc;
CREATE TEMPORARY TABLE PercentPopulationVacc (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date VARCHAR(255),
    Population VARCHAR(255),
    New_vaccinations VARCHAR(255),
    TotalVaccinatedByDate VARCHAR(255)
);

INSERT INTO PercentPopulationVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinatedByDate
FROM coviddeaths AS dea
INNER JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

SELECT *, (TotalVaccinatedByDate/population)*100 AS vaccinated_percentage
FROM PercentPopulationVacc;

-- Create a view to store data

CREATE VIEW PercentPopulationVacc AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinatedByDate
FROM coviddeaths AS dea
INNER JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;













