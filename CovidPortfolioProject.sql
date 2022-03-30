select * from [portfolio project].dbo.CovidDeaths

-- order by 3,4

 --select *
 --from [portfolio project]..CovidVacination

 --order by 3,4
 select location, date, total_cases, new_cases, total_deaths, population
 from [portfolio project]..CovidDeaths
 order by 1,2
 --looking at total cases vs total deaths 
 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from [portfolio project]..CovidDeaths
 where location like '%states%'
 order by 2desc

 --%age of population got covid
 select location, date, total_cases,population, (total_cases/population)*100 as InfectedPergentage
 from [portfolio project]..CovidDeaths
 order by 1, 2

 --looking for countries with highest infected rate wrt population
 select location,population, MAX(total_cases) as highestInfectedCount,
 max((total_cases/population))*100 as percentpopulationInfected
 from [portfolio project]..CovidDeaths
 group by location,population
 order by percentpopulationInfected desc

 --countries with highest death count per population
 select location, max(cast(total_deaths as int)) as totaldeathcount
 from [portfolio project]..CovidDeaths
 where continent is not null  
  group by location
  order by totaldeathcount desc

  --breaking by continent
select location, max(cast(total_deaths as int)) as totaldeathcount
from [portfolio project]..CovidDeaths
where continent is null  
group by location
order by totaldeathcount desc
 
-- showing totaldeath percentage cases across the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from [portfolio project].dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



