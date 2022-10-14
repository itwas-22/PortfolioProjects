select *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
FROM PortfolioProject..CovidVaccinations
order by 3,4

-- Select Data that we are going to be using 

select location, date, total_cases, total_deaths, 
FROM PortfolioProject..CovidDeaths
order by 1,2

--A
--Looking at total cases vs Total Deaths
--NOT TO ADD // calculation - the % of people dying who actually get infected or report being infected
--Shows the likelyhood of dying if you contract covid in INDIA

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2


--B
--Looking at Total Cases vs Population

select location, date, total_cases, population, total_deaths, (total_cases/population)*100 as percentpopuinfected
FROM PortfolioProject..CovidDeaths
where location like '%India%' 
order by 1,2


--c
--What contry has the infection rate 
--looking at contries with highest infection rate compared to population 
--why did we add group be??

select location, population, max(total_cases) as Highestinfectioncount,  max((total_cases/population))*100 as percentagepopuinfected
FROM PortfolioProject..CovidDeaths
group by location, population
order by percentagepopuinfected desc

--D
--showing contries with highest death count per location 

select location,  max(cast(total_deaths as int)) as Totaldeathcount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Totaldeathcount desc

--Note : go into coviddeaths column, show total deaths, invarchart 
--still shows issues in data, world,africa, these should not be there these are grouping entrie continents lets go back up this happened because of continent and location is asia 
--select *
--FROM PortfolioProject..CovidDeaths
--where continent is not null
--order by 3,4


--LET'S BREAK THINGS DOWN BY CNTINENT 

select continent,  max(cast(total_deaths as int)) as Totaldeathcount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Totaldeathcount desc

--NOTE : this is not perfect, NA seems to be including only america and not canada, for the purposes of what we are doing and not fac checking 

--for correct number 
--explanations : this is the correct number, looking at the location and it was the contries itself, now we are only looking at those 
select location,  max(cast(total_deaths as int)) as Totaldeathcount
FROM PortfolioProject..CovidDeaths
where continent is null
group by location
order by Totaldeathcount desc




--LET'S BREAK THINGS DOWN BY CONTINENT 

--Showing the continents with the highest death count

select continent,  max(cast(total_deaths as int)) as Totaldeathcount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Totaldeathcount desc


--GLOBAL NUMBERS

--select  date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldesths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
--FROM PortfolioProject..CovidDeaths
--where continent is not null
--group by date
--order by 1,2

select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldesths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--checkng the other data
--joining

--step 1
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidVaccinations vac
join  PortfolioProject..CovidDeaths dea
on dea.location = vac.location
and	dea.date = vac.date

--step 2 adding order 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidVaccinations vac
join  PortfolioProject..CovidDeaths dea
on dea.location = vac.location
and	dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

--step 3 if we need to check afganistan we'll check by 2,3 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidVaccinations vac
join  PortfolioProject..CovidDeaths dea
on dea.location = vac.location
and	dea.date = vac.date
where dea.continent is not null 
order by 2,3

--now we are going to do a rolling count so we take new avvinations
--I'm doing this in Oct 2021 and apparently one of the code chunks where you need to convert new_vaccinations column to integer, the sum value now has exceeded 2,147,483,647. So instead of converting it to "int", you will need to convert to "bigint". Hope this helps everyone.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Note : we need to do the sum as we are adding these together for new vaccinations
-- over/partiion by location because we are breaking it up and also partly by date 
-- why ? every time it gets to new location we need the count to start over 
--we don;t want the aggrigate funtion to run over and over and over and ruien alll are numbers
-- partion should only run through canada
--Convert worksas cast 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Note : date is what sepaarates it out in gruop by 

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


--temp table

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
Rollingpeoplevaccinated numeric,

