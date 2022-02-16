-- Portfolio Project on Covid Data

-- Main functions used : Aggregate Function, Windows Function, Temp Table, CTE's, Joins, Converting Data Types, Creating Views


-- Importing Data 
SELECT *
FROM CovidDeaths
where continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1, 2

--Comparing Total Deaths vs Total Cases
--Shows likehood of dying due to Covid in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
where location = 'India'
order by 1, 2

--Comparing Total Cases vs Population
--Shows what % of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM CovidDeaths
where location = 'India'
order by 1, 2

--Finding highest infection rate across countries
SELECT Location, population, max(total_cases)as MaxCaseCount,max(total_cases/population)*100 as InfectionRateMax
FROM CovidDeaths
--where location = 'India'
Group by Location, population
order by InfectionRateMax desc

-- Segregation by continent- location
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
--, max(total_deaths/population)*100 as PercentageDeathbyPop
FROM CovidDeaths
where continent is null and location not like '%income%'
--where location = 'India'
Group by Location
order by 2 desc

-- Segregation by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--, max(total_deaths/population)*100 as PercentageDeathbyPop
FROM CovidDeaths
where continent is not null and location not like '%income%'
--where location = 'India'
Group by continent
order by 2 desc

--Segregation by level of income
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
--, max(total_deaths/population)*100 as PercentageDeathbyPop
FROM CovidDeaths
where continent is null and location like '%income%'
Group by Location
order by 2 desc

--Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount, 
max(cast(total_deaths as int)/population)*100 as PercentageDeathbyPop
FROM CovidDeaths
where continent is not null
--where location = 'India'
Group by Location
order by 3 desc


--Global numbers

--Datewise

SELECT date, sum(new_cases) as Worldcases, sum(cast(new_deaths as int)) as Worlddeaths, 
(sum(cast(new_deaths as int))/ sum(new_cases))*100 as DeathPercentageWorld
FROM CovidDeaths
Where continent is not NULL
group by date
order by 1


--Global Numbers without date
SELECT sum(new_cases) as Worldcases, sum(cast(new_deaths as int)) as Worlddeaths, 
(sum(cast(new_deaths as int))/ sum(new_cases))*100 as DeathPercentageWorld
FROM CovidDeaths
Where continent is not NULL
order by 1

--- Looking at Total People vs Vaccinations

With PopvsVac (continent, Location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations, 
SUM (convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date	
where dea.continent is not null 
--and dea.location = 'India'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercPeopleVaccinated
From PopvsVac


---Using CTE



---Using Temp Table
Drop table if exists #PercentPopulationVaccinated
Create  Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations, 
SUM (convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date	
where dea.continent is not null 
--and dea.location = 'India'
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercPeopleVaccinated
From #PercentPopulationVaccinated

---Two different values for India??
Select location, date, total_vaccinations
from CovidVaccinations
where location = 'India' and continent is not null
order by date asc

--Creating View to store data for visulations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations, 
SUM (convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date	
where dea.continent is not null 
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated


