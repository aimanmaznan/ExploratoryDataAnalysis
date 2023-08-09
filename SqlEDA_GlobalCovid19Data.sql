-- EXPLORATORY DATA ANALYSIS
-- Dataset: Covid Deaths and Vaccinations
-- Source: ourworldindata.org

SELECT *
FROM EDA..CovidDeath
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM EDA..CovidVac
WHERE continent is not null
ORDER BY 3,4

-- Selecting Data

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM EDA..CovidDeath
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM EDA..CovidDeath
WHERE location like '%alays%' AND continent is not null
ORDER BY 1,2

-- Total Cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopPercentage
FROM EDA..CovidDeath
WHERE location like '%alays%' AND continent is not null
ORDER BY 1,2

-- Countries with Highest Infection Rates vs Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as MaxPopPercentage
FROM EDA..CovidDeath
WHERE continent is not null
GROUP BY location, population
ORDER BY MaxPopPercentage desc

-- Countries with Highest Death Count 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM EDA..CovidDeath
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Continent with Highest Death Count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM EDA..CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Viewing Total Cases, Total Deaths and Death % per Date

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM EDA..CovidDeath
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Population vs Vaccinations per Date per Countries 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM EDA..CovidDeath dea
JOIN EDA..CovidVac vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE for Viewing Rolling Percentage of People Vaccinated per Date per Country

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM EDA..CovidDeath dea
JOIN EDA..CovidVac vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM PopvsVac

-- Creating Temp Table as Alternative for Above Prompt -> (Viewing Rolling Percentage of People Vaccinated per Date per Country)

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM EDA..CovidDeath dea
JOIN EDA..CovidVac vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

-- Creating View to Store Data for Visualization

CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM EDA..CovidDeath dea
JOIN EDA..CovidVac vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated