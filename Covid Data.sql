Select *
From Covid_Data_V2 cdv 

Select * 
From Covid_Vaccinations cv 

Select location,date,total_cases, new_cases, total_deaths, population
from Covid_Data_V2 cdv 
order by 1,2

--Calculate Total Cases vs Total Deaths: Likelihood of dying if you contract covid in your country

Select location,date,total_cases, total_deaths, ((1.0* total_deaths/total_cases)*100) as DeathPercentage
from Covid_Data_V2 cdv 
where location like '%states%'
order by 1,2

--Looking at Total cases vs Population: shows what percentage of population got Covid
Select location,date,population, total_cases,((1.0* total_cases /population)*100) as DeathPercentage
from Covid_Data_V2 cdv 
where location like '%states%'
order by 1,2

--Looking at Countries with highest Infection Rate compared to Population
Select location,population, MAX(1.0*total_cases) as HighestInfectionCount, MAX((1.0* total_cases /population)*100) as PercentPopulationInfected
from Covid_Data_V2 cdv 
--where location like '%states%'
Group by Location, Population
order by 1,2


Select location,population, MAX(1.0*total_cases) as HighestInfectionCount, MAX((1.0* total_cases /population)*100) as PercentPopulationInfected
from Covid_Data_V2 cdv 
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected DESC 

--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid_Data_V2 cdv 
Group by location
order by TotalDeathCount DESC 

SELECT Location, MAX(1.0*total_deaths) as TotalDeathCount
From Covid_Data_V2 cdv 
Where continent is not NULL 
Group by location
order by TotalDeathCount DESC 

--Let's break things down by continent
SELECT Location, MAX(1.0*total_deaths) as TotalDeathCount
From Covid_Data_V2 cdv 
Where continent is not NULL 
Group by continent 
order by TotalDeathCount DESC 

--Global Numbers
--New Cases and New Deaths by Date
Select date, SUM(new_cases), SUM(new_deaths) --total_cases,((1.0* total_cases /population)*100) as DeathPercentage
from Covid_Data_V2 cdv 
where continent is not null
Group by date 
order by 1,2

Select date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Death, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from Covid_Data_V2 cdv 
where continent is not null
Group by date 
order by 1,2

--Looking at Total Population vs Vaccinations
Select cdv.continent, cdv.location, cdv.date, cdv.population, cv.new_vaccinations 
From Covid_Data_V2 cdv
Join Covid_Vaccinations cv on cdv.location  = cv.location  and cdv.date = cv.date
Where cdv.continent is not null
order by 2,3

--New vaccinations by date and location (Rolling)
Select cdv.continent, cdv.location, cdv.date, cdv.population, cv.new_vaccinations, SUM(cv.new_vaccinations)
OVER (PARTITION by cdv.location Order by cdv.location, cdv.date) as RollingPeopleVaccinated
From Covid_Data_V2 cdv
Join Covid_Vaccinations cv on cdv.location  = cv.location  and cdv.date = cv.date
Where cdv.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cdv.continent, cdv.location, cdv.date, cdv.population, cv.new_vaccinations, SUM(cv.new_vaccinations)
OVER (PARTITION by cdv.location Order by cdv.location, cdv.date) as RollingPeopleVaccinated
From Covid_Data_V2 cdv
Join Covid_Vaccinations cv on cdv.location  = cv.location  and cdv.date = cv.date
Where cdv.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 --Percentage of people gettting vaccinated by population (rolling)
From PopvsVac


--Temp Table
Drop Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
);

INSERT into PercentPopulationVaccinated
Select cdv.continent, cdv.location, cdv.date, cdv.population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations))
OVER (PARTITION by cdv.location Order by cdv.location, cdv.date) as RollingPeopleVaccinated
From Covid_Data_V2 cdv
Join Covid_Vaccinations cv on cdv.location  = cv.location  and cdv.date = cv.date
Where cdv.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 --Percentage of people gettting vaccinated by population (rolling)
From PercentPopulationVaccinated


--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select cdv.continent, cdv.location, cdv.date, cdv.population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations))
OVER (PARTITION by cdv.location Order by cdv.location, cdv.date) as RollingPeopleVaccinated
From Covid_Data_V2 cdv
Join Covid_Vaccinations cv on cdv.location  = cv.location  and cdv.date = cv.date
Where cdv.continent is not null

