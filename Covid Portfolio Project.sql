select *
from PortfolioProject..Deaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..Vaccinations

-- Select Data

select location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject..Deaths
order by 1,2

-- Total Cases vs Total Deaths
-- % of Deaths in Colombia

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Deaths
where location like '%Colombia%'
order by 1,2

-- Total Cases vs Population 
-- % of Population infected


select location,date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..Deaths
where location like '%Colombia%'
order by 1,2 

-- Countries with  the highest infection rate 

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..Deaths
Group by location, population
order by 4 DESC

-- Countries with  the highest death rate

Select location, max(total_deaths) as TotalDeathCount
From PortfolioProject..Deaths
where continent is not null 
Group by location
order by TotalDeathCount DESC

-- BY Continent

Select continent, max(total_deaths) as TotalDeathCount
From PortfolioProject..Deaths
where continent is not null
Group by continent
order by TotalDeathCount DESC

--Global Numbers

--Death % per day
SELECT date, SUM(COALESCE(new_cases, 0)) AS total_new_cases, SUM(COALESCE(new_deaths, 0)) AS total_new_deaths,
  SUM(COALESCE(new_deaths, 0)) / NULLIF(SUM(COALESCE(new_cases, 0)), 0)*100 AS DeathPercentage
FROM PortfolioProject..Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

-- Global Death %
SELECT SUM(COALESCE(new_cases, 0)) AS total_new_cases, SUM(COALESCE(new_deaths, 0)) AS total_new_deaths,
  SUM(COALESCE(new_deaths, 0)) / NULLIF(SUM(COALESCE(new_cases, 0)), 0)*100 AS DeathPercentage
FROM PortfolioProject..Deaths
WHERE continent IS NOT NULL
ORDER BY 1

--JOIN Death & Vaccination 

select *
from PortfolioProject..Deaths d
join PortfolioProject..Vaccinations v
	on d.location = v.location
	and d.date = v.date
order by 4

-- Total Population vs Vaccinations 

select d.continent, d.location,d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) OVER (Partition by 
d.location order by d.location,d.date) as PeopleVaccinated 
from PortfolioProject..Deaths d
join PortfolioProject..Vaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 1,2,3

--Use CTE 

With PopvsVac (continent, location, date, population,new_vaccinations, PeopleVaccinated)
as
(
select d.continent, d.location,d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) OVER (Partition by 
d.location order by d.location,d.date) as PeopleVaccinated 
from PortfolioProject..Deaths d
join PortfolioProject..Vaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 1,2,3

)
select *, (PeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(50),
location nvarchar(50), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
PeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select d.continent, d.location,d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) OVER (Partition by 
d.location order by d.location,d.date) as PeopleVaccinated 
from PortfolioProject..Deaths d
join PortfolioProject..Vaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 1,2,3

select *, (PeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Create view to store data for later visualization

Create view PercentPopulationVaccinated	as
select d.continent, d.location,d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) OVER (Partition by 
d.location order by d.location,d.date) as PeopleVaccinated 
from PortfolioProject..Deaths d
join PortfolioProject..Vaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 1,2,3

select *
from PercentPopulationVaccinated

