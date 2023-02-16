
Select *
From PortProject1..CovidDeaths$
order by 3,4

Select *
From PortProject1..CovidVaccinations$
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortProject1..CovidDeaths$
order by 1, 2

/*Total cases vs Total deaths*/

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortProject1..CovidDeaths$
--Where location like '%States%'
order by 1, 2

/*Countries with highest Infection rate*/
Select location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortProject1..CovidDeaths$
Group by location, population
order by PercentagePopulationInfected desc

/*Countries with highest Death count per Population*/
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortProject1..CovidDeaths$
--Where location like '%States%'
Where continent is not null
Group by location
order by TotalDeathCount desc 


/*By Continent*/
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortProject1..CovidDeaths$
--Where location like '%States%'
Where continent is not null
Group by location
order by TotalDeathCount desc



Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortProject1..CovidDeaths$
--Where location like '%States%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

/*Global numbers*/

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortProject1..CovidDeaths$
Where continent is not null
Group by date
order by 1, 2

-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location, dea.date) as RollingPeopleVaccinated
from  PortProject1..CovidDeaths$ dea
join PortProject1..CovidVaccinations$ vac
	on dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
order by 1,2,3

-- Using CTE

With PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location, dea.date) as RollingPeopleVaccinated
from  PortProject1..CovidDeaths$ dea
join PortProject1..CovidVaccinations$ vac
	on dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Using Temp table

Drop table if exists #PercentPeopleVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortProject1..CovidDeaths$ dea
join PortProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 1,2,3


select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


---Creating View

Create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortProject1..CovidDeaths$ dea
join PortProject1..CovidVaccinations$ vac
	on dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null


Select *
From PercentPopulationVaccinated



