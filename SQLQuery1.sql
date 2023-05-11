Select *
From Covid..CovidDeaths
Order by 3,4

--Select *
--From Covid..CovidVaccinations
--Order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
From Covid..CovidDeaths
Order by 1,2

-- Total cases vs Total deaths (shows the likelihood of dying if you get covid in Africa)
Select Location, Date, total_cases, total_deaths, (cast(total_deaths as float)/cast (total_cases as float))*100 as DeathPercentage
From Covid..CovidDeaths
Where location = 'Africa'  -- in Africa
Order by 1,2

-- Total cases vs the population (shows % of population that got covid in US)
Select Location, Date, total_cases, population,(total_cases/cast(population as float))*100 as CovidPercentage
From Covid..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Countries with highest infection rate compared to population (used in Tableau)
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/cast(population as float)))*100 as InfectedPopulationPercentage
From Covid..CovidDeaths
Group by population, location
Order by InfectedPopulationPercentage desc

-- Countries with the highest death count per population
Select Location, MAX(total_deaths) as TotalDeathCount
From Covid..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

-- Break it to continents
Select continent, MAX(total_deaths) as TotalDeathCount
From Covid..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Total deaths vs Total cases globally
Select continent, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as decimal))/SUM(new_cases)*100 as DeathPercentage
From Covid..CovidDeaths
Where continent is not null
Group by continent
Order by 1,2

-- Total population vs vaccinations
With PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/cast(population as decimal))*100
From PopVSVac

-- Creating a temp table (same data as above)
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated

-- SQL Queries for Tableau
-- 1
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as decimal))/SUM(new_cases)*100 as DeathPercentage
From Covid..CovidDeaths
Where continent is not null
Order by 1,2

-- 2
Select continent, SUM(new_deaths) as total_deaths
From Covid..CovidDeaths
Where continent is not null
Group by continent
Order by total_deaths desc

-- 3
Select Location, population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/cast(population as float)))*100 as InfectedPopulationPercentage
From Covid..CovidDeaths
Group by population, location, date
Order by InfectedPopulationPercentage desc