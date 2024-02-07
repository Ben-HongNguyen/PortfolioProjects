SELECT *
FROM CovidVaccinations 
ORDER BY 3,4

SELECT *
FROM CovidDeaths 
WHERE continent is not null 
ORDER BY 3,4

--Exec sp_help 'dbo.coviddeaths';

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying percentage if you contract covid in United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM CovidDeaths
WHERE location like 'United States'
ORDER BY date 

-- Looking at Total Cases vs Population
-- Show percentage of US population got infected by Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as infected_percentage
FROM CovidDeaths
--WHERE location like 'United States'
ORDER BY 1,2

-- Looking at country with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as highest_infectioncount_per_country, MAX((total_cases/population))*100 as infected_population_percentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY infected_population_percentage DESC

--Showing country with highest death count per population 

SELECT dea.location, MAX(dea.total_deaths) as total_deaths_count
FROM CovidDeaths as dea
WHERE continent is not null 
GROUP BY location
ORDER BY total_deaths_count DESC

--Showing location with highest death count per population

SELECT location, MAX(total_deaths) as total_deaths_count
FROM CovidDeaths
WHERE continent is not null
	AND location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location 
ORDER BY total_deaths_count DESC

--Showing continent with highest death count per population

SELECT continent, MAX(total_deaths) as total_deaths_count
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY total_deaths_count DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
FROM CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2 

SELECT SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
FROM CovidDeaths
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2 

-- Looking at total population vs vaccinations

-- Create CTE

WITH PopvsVacs (Continent, Location, Date, Population, New_Vaccinations, People_Vaccinated_Count)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as People_Vaccinated_Count
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
SELECT *, (People_Vaccinated_Count/Population)*100 as Vaccinated_Percentage
From PopvsVacs



-- TEMP TABLE

DROP TABLE IF Exists #PopulationVaccinatedPercentage
CREATE TABLE #PopulationVaccinatedPercentage
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
People_Vaccinated_Count numeric
)

INSERT INTO #PopulationVaccinatedPercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as People_Vaccinated_Count
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3

SELECT *, (People_Vaccinated_Count/Population)*100 as Vaccinated_Percentage
From #PopulationVaccinatedPercentage


-- Creating View to store data for later visualizations

CREATE VIEW Country_HighestDeathCount as
SELECT dea.location, MAX(dea.total_deaths) as total_deaths_count
FROM CovidDeaths as dea
WHERE continent is not null 
GROUP BY location
--ORDER BY total_deaths_count DESC

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as People_Vaccinated_Count
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3

SELECT *
FROM Country_HighestDeathCount

SELECT *
FROM PercentPopulationVaccinated