
--Shows what percentage of population got covid
select location, date, population,total_cases, CAST(total_cases AS float) / CAST(population AS float) * 100 AS division_result -- (total_deaths/total_cases)*100
From [Portfolio project]..CovidDeaths
--where location like '%india%'
order by 1,2;


--looking at Total cases vs total deaths in India

select location, date, population,total_cases, CAST(total_deaths AS float) / CAST(total_cases AS float) * 100 AS DeathPercentage
From [Portfolio project]..CovidDeaths
where location like '%india%'
order by 1,2;

--Looking at countries with highest infection rate compared to population

select location, population,max(total_cases) as Highestinfectioncount, max(CAST(total_cases AS float) / CAST(population AS float)) * 100 AS PercentagepopulationInfected
From [Portfolio project]..CovidDeaths
--where location like '%india%'
group by location, population
order by PercentagepopulationInfected desc;

--Showing countries highest DeathHcount per population

select location, max(cast(total_deaths as int)) as Totaldeathcount
From [Portfolio project]..CovidDeaths
where continent is not null
group by location
order by Totaldeathcount desc

--Showing continent with the highest deaths per count population

select continent, max(cast(total_deaths as int)) as Totaldeathcount
From [Portfolio project]..CovidDeaths
where continent is not null
group by continent
order by Totaldeathcount desc


--Showing total_cases and total_deaths and deathperpercentage

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int )) /sum(new_cases)*100 as Deathpercentage
from [Portfolio project]..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccination

with PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated )
as 
(

select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dae.location order by dae.location,
dae.date) as Rollingpeoplevaccinated
from [Portfolio project]..CovidDeaths dae
join [Portfolio project]..CovidVaccinations vac
on dae.location = vac.location
and dae.date = vac.date
where dae.continent is not null
)
select *, (Rollingpeoplevaccinated / population)*100 
from PopvsVac

-- Temp table
Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date  datetime,
population numeric,
new_vaccination numeric,
Rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dae.location order by dae.location,
dae.date) as Rollingpeoplevaccinated
from [Portfolio project]..CovidDeaths dae
join [Portfolio project]..CovidVaccinations vac
on dae.location = vac.location
and dae.date = vac.date
where dae.continent is not null

select *, (Rollingpeoplevaccinated / population)*100 
from #percentpopulationvaccinated

--Createing A view

create view Percentpopulationvaccinated as 
select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dae.location order by dae.location,
dae.date) as Rollingpeoplevaccinated
from [Portfolio project]..CovidDeaths dae
join [Portfolio project]..CovidVaccinations vac
on dae.location = vac.location
and dae.date = vac.date
where dae.continent is not null