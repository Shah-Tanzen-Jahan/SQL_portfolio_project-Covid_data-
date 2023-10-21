Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccination
--order by 3,4 

--select data that we are going to using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 

--looking at total cases vs total deaths 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
and 
 location ='Bangladesh'
order by 1,2

--looking cases total cases vs population
--Shows ratio of caused covid
select location,date,total_cases,population,(total_cases/population)*100 AS Percent_infection_rate
from PortfolioProject..CovidDeaths
where location like 'Bangladesh'
order by 1,2

--looking at countries with the highest infection rate
select location,population,MAX(total_cases) AS HighestInfectionCount,Max((total_cases/population))*100 AS infection_rate
from PortfolioProject..CovidDeaths
--where location like 'Bangladesh'
Group by location,population
order by infection_rate DESC

--Showing countries with Highest Death Count Per Population

select location,date,Max(cast(total_deaths AS int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'Bangladesh'
where continent is not null
Group by location,date
order by TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population

select continent,Max(cast(total_deaths AS int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'Bangladesh'
where continent is not null
Group by continent
order by TotalDeathCount DESC

--Global number

select sum(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_deaths,sum(cast(new_deaths AS int))/sum(new_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
--where location like 'Bangladesh'
where continent is not null
--Group BY date
order by 1,2


--LOOKING AT TOATAL POPULATION VS VACCINATIONS

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac(continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 AS Percent_RollingPeopleVaccinated
From PopvsVac


--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location= vac.location
	and dea.date= vac.date
--where dea.continent is not null
--order by 2,3
select *,(RollingPeopleVaccinated/population)*100 AS Percent_RollingPeopleVaccinated
From #PercentPopulationVaccinated


--creating view to store data for later visualization

Create view PercentPopulationVaccinated  as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location= vac.location
	and dea.date= vac.date
 where dea.continent is not null
 --order by 2,3
 Select *
 from PercentPopulationVaccinated