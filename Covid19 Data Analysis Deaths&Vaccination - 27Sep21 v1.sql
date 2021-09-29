select * from covidDeaths
where continent is not null
order by location,date;

--select * from covidVaccinations
--order by location,date;


-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from covidDeaths
where continent is not null
order by location,date;


-- Looking at total cases vs. total deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covidDeaths
where location like '%Egypt%' and continent is not null
order by location,date;


-- Lokking at total cases vs. population
-- Shows what percentage of population had covid
select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
from covidDeaths
where continent is not null
order by location,date;


-- Looking at countries with highest infection rate comapred to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectedPercentage
from covidDeaths
where continent is not null
group by location, population
order by PopulationInfectedPercentage desc;


-- Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from covidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;


-- More in depth query
select location, population, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as PopulationDeathsPercentage
from covidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc;


-- Showing continent with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from covidDeaths
where continent is null
group by location
order by TotalDeathCount desc;


-- Global numbers
select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_death, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from covidDeaths
-- where location like '%Egypt%' 
where continent is not null
group by date
order by date;


-- Global numbers without date
select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from covidDeaths
-- where location like '%Egypt%' 
where continent is not null
--group by date
order by total_cases;


-----------------------------------------------


-- Looking at total population vs. vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from [dbo].[covidDeaths] dea
join [dbo].[covidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by location, date;


-- With CTE

with POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[covidDeaths] dea
join [dbo].[covidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by location, date;
)
select *, (RollingPeopleVaccinated/population)*100
from POPvsVAC;


-- Temp table
drop table if exists #PercentPopulationVaccinated;

create table #PercentPopulationVaccinated
(
	 Continent nvarchar(255),
	 Location nvarchar(255),
	 Date datetime,
	 Population numeric,
	 New_Vaccinations numeric,
	 RollingPeopleVaccinated numeric
 );

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(numeric, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[covidDeaths] dea
join [dbo].[covidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date;

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated;


-- Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [dbo].[covidDeaths] dea
join [dbo].[covidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

select * 
from PercentPopulationVaccinated;