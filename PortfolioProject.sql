/* SQL DATA EXPLORATION PROJECT
  ON COVID STATISTICS */

  SELECT *
  FROM PortfolioProject1..CovidDeaths
  WHERE continent is NOT NULL
  ORDER BY 3,4

  SELECT *
  FROM PortfolioProject1..CovidVaccinations
  ORDER BY 3,4

  -- SELECT DATA TO USE

  SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM PortfolioProject1..CovidDeaths
  ORDER BY 1,2

  -- EXPLORE TOTAL CASES VS TOTAL DEATHS
  --Shows Likelyhood of dying if you contract covid in your country

  SELECT location,date,CAST(total_cases AS float) AS total_cases,
  CAST(total_deaths AS float) AS total_deaths,
  (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 AS death_rate
  FROM
  PortfolioProject1..CovidDeaths
  WHERE location like '%Kenya%'
  ORDER BY 1,2


  -- LOOKING AT TOTAL CASES VS POPULATION
  --Shows percentage population that contracted covid

  SELECT location, date, total_cases,population, (total_cases/population)*100 AS DeathPercentage
  FROM PortfolioProject1..CovidDeaths
  WHERE location like '%Kenya%'
  ORDER BY 1,2


  --COUNTRIES WITH A HIGH INFECTION RATE COMPARED TO POPULATION

  SELECT location, MAX(total_cases) AS HighestInfectionCount, 
  MAX((total_cases/population))*100 AS PercentagePopulationInfected
  FROM PortfolioProject1..CovidDeaths
  --WHERE location like '%Kenya%'
  GROUP BY location, population
  ORDER BY PercentagePopulationInfected desc


  -- BREAKING THE DATA DOWN TO CONTINENTS (****)
  
  SELECT location, MAX(total_deaths) as TotalDeathCount
  FROM PortfolioProject1..CovidDeaths
  WHERE continent is NULL
  GROUP BY location
  ORDER BY TotalDeathCount desc

  -- SHOWING COUNTRIES WITH THE HIGHEST DEATHCOUNT PER POPULATION

  SELECT location, MAX(total_deaths) as TotalDeathCount
  FROM PortfolioProject1..CovidDeaths
  WHERE continent is NOT NULL
  GROUP BY location
  ORDER BY TotalDeathCount desc

 
 --SHOWING CONTINENT WITH HIGHEST DEATH COUNT

  SELECT continent, MAX(total_deaths) as TotalDeathCount
  FROM PortfolioProject1..CovidDeaths
  WHERE continent is NOT NULL
  GROUP BY continent
  ORDER BY TotalDeathCount desc


  --GLOBAL COVID NUMBERS

  /* SELECT date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_deaths,
   CASE
     WHEN SUM(new_cases) <> 0 THEN (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100
     ELSE 0
   END as DeathPercentage
  FROM PortfolioProject1..CovidDeaths
  WHERE continent IS NOT NULL
  ROUP BY date
  ORDER BY date; */


 SELECT SUM(new_cases) as Total_Cases,
  SUM(new_deaths) as Total_deaths,
  CASE
    WHEN SUM(new_cases) <> 0 THEN (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100
    ELSE 0
   END as DeathPercentage
 FROM PortfolioProject1..CovidDeaths
 WHERE continent IS NOT NULL
 --GROUP BY date
 ORDER BY 1,2;


 --SHOWING TOTAL POPULATION VS VACCINATIONS BY JOINING COVID DEATHS AND COVID_VACCINATION TABLES

 /* SELECT *
 FROM PortfolioProject1..CovidDeaths dea
 JOIN PortfolioProject1..CovidVaccinations vac
      ON dea.location = vac.location
	  and dea.date = vac.date */


 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject1..CovidDeaths dea
 JOIN PortfolioProject1..CovidVaccinations vac
      ON dea.location = vac.location
	  and dea.date = vac.date
 WHERE dea.continent is not NULL
 ORDER BY 2,3

 /* SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location)
 FROM PortfolioProject1..CovidDeaths dea
 JOIN PortfolioProject1..CovidVaccinations vac
      ON dea.location = vac.location
	  and dea.date = vac.date
 WHERE dea.continent is not NULL
 ORDER BY 2,3 */

 -- USE CTE

 WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVacinated)
 as 
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject1..CovidDeaths dea
 JOIN PortfolioProject1..CovidVaccinations vac
      ON dea.location = vac.location
	  and dea.date = vac.date
 WHERE dea.continent is not NULL
 --ORDER BY 2,3
 )
 SELECT *, (RollingPeopleVacinated/Population)*100
 FROM PopvsVac


 -- CREATE TEMP TABLES

 DROP TABLE if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric
  )
  
  INSERT INTO #PercentPopulationVaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject1..CovidDeaths dea
 JOIN PortfolioProject1..CovidVaccinations vac
      ON dea.location = vac.location
	  and dea.date = vac.date
 --WHERE dea.continent is not NULL

 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM #PercentPopulationVaccinated


 -- CREATE VIEW FOR FUTURE DATA STORAGE

 CREATE VIEW PercentPopulationVaccinated AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
 FROM PortfolioProject1..CovidDeaths dea
 JOIN PortfolioProject1..CovidVaccinations vac
      ON dea.location = vac.location
	  and dea.date = vac.date
 WHERE dea.continent is not NULL


 SELECT *
 FROM PercentPopulationVaccinated