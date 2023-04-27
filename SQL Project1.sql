Select *
From Project1..CovidDeaths
Where continent is not null
order by 3,4

Select *
From Project1..CovidVaccinations
order by 3,4

-- Data using
Select location, date, total_cases, new_cases, total_deaths, population
From Project1..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total cases Vs Total Deaths
Select location, date, total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage
From Project1..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total cases Vs Population
Select location, date, total_cases, population, (convert(float,total_cases) / population)*100 as PercentPopulationInfected
From Project1..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max(convert(float,total_cases)/population)*100 as PercentPopulationInfected
From Project1..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(Nullif(new_deaths, 0) as int))/SUM(Nullif(new_cases, 0))*100 as DeathPercentage
From Project1..CovidDeaths
Where continent is not null
--Group By date
order by 1,2

-- looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null	
order by 2,3


-- Use CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null	
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP Table
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
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null	
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--creating view to store date for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null	
--order by 2,3

Select *
From PercentPopulationVaccinated