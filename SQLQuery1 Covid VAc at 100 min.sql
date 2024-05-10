Select	*
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select	*
--From PortfolioProject..Covidvaccintions$
--order by 3,4
--select the data
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths
-- shows like hood of dying if u had carona in ur country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From PortfolioProject..CovidDeaths$
Where location like '%saud%'
order by 1,2

--looking at toatl cases vs population

Select location, date,population, total_cases, (total_cases/population)*100 as CovidCover
From PortfolioProject..CovidDeaths$
--Where location like '%h%'
order by 1,2

--looking at countrise woth highest rate of covied ,desc gives the higst

Select location,population, MAX(total_cases) as HighestInfectionCount, 
  MAX((total_cases/population))*100 as CovidCover
From PortfolioProject..CovidDeaths$
--Where location like '%h%'
Group by location, population
order by CovidCover desc

--showing countrise with highest death count per so it gives us a correct number we turned it into int , group it to integreted

Select location, population, MAX(cast(total_cases as int)) as HighsCases ,MAX(cast(total_deaths as int)) as Highstdeaths 
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location, population
order by Highstdeaths desc

Select location,MAX(cast(total_deaths as int)) as Highstdeaths 
From PortfolioProject..CovidDeaths$
where continent is null
Group by location
order by Highstdeaths desc

--break things down by continet
--showing the content with highes deaths

Select continent,MAX(cast(total_deaths as int)) as Highstdeaths 
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by Highstdeaths desc

--global numbers we cant aggregate so we using smaller things to not aggregate

select date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int )) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

select  SUM(new_cases) as totalCases, SUM(cast(new_deaths as int )) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2


Select *
From PortfolioProject..Covidvaccintions$

--join
Select *
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..Covidvaccintions$ vac
  on dea.location=vac.location
     and dea.date=vac.date

--looking at total poplation vs vaction , bigint because the number is big

Select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPLVact  ,--(RollingPPLVact/population)*100 as pplvacction
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..Covidvaccintions$ vac
  on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
	 order by 2,3

--Use a CTE because we cant use a column we just created

with Popvsvac (continent,location,date,population,new_vaccinations,RollingPPLVact)
as
(
Select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPLVact  --,--(RollingPPLVact/population)*100 as pplvacction
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..Covidvaccintions$ vac
  on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null

)
Select *, (RollingPPLVact/population)*100 as pplvacction
from Popvsvac

--temp table
-- if we wanted to change something in the table 

DRop Table if exists #PercentPopulationVacction

Create Table #PercentPopulationVacction
(
continent nvarchar(255),location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,RollingPPLVact numeric
)
insert into #PercentPopulationVacction
Select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPLVact  --,--(RollingPPLVact/population)*100 as pplvacction
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..Covidvaccintions$ vac
  on dea.location=vac.location
     and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPPLVact/population)*100 as pplvacction
from #PercentPopulationVacction


--Creating view to sort data for later for visualtion

Create view PercentPopulationVacction as
Select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPLVact  --,--(RollingPPLVact/population)*100 as pplvacction
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..Covidvaccintions$ vac
  on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVacction