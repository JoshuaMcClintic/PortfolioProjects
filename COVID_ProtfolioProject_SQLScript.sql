/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


--Same Data as above, but just from the United States

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
and location like '%states'
Order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, total_cases, new_cases, total_deaths, population, (total_cases/population)*100 PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
and location like '%states'
Order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, new_cases, total_deaths, population, (cast(total_deaths as numeric)/cast(total_cases as numeric))*100 DeathPercentage
From PortfolioProject..CovidDeaths
--Where continent is not null
--and location like '%states'
Order by 1,2


--Percentage of the US that died from COVID

Select location, date, total_cases, new_cases, total_deaths, population, (total_deaths/population)*100 PercentPopulationDied
From PortfolioProject..CovidDeaths
Where continent is not null
and location like '%states'
Order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(convert(numeric,vacc.new_vaccinations)) over (Partition by deaths.location Order by deaths.location, deaths.date) RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
	on deaths.location = vacc.location
	and deaths.date = vacc.date
Where deaths.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
SUM(convert(numeric,vacc.new_vaccinations)) over (Partition by deaths.location Order by deaths.location, deaths.date) RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
	on deaths.location = vacc.location
	and deaths.date = vacc.date
Where deaths.continent is not null
--Order by 2,3
)

Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
SUM(convert(numeric,vacc.new_vaccinations)) over (Partition by deaths.location Order by deaths.location, deaths.date) RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
	on deaths.location = vacc.location
	and deaths.date = vacc.date
--Where deaths.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationInfected as
Select location, date, total_cases, new_cases, total_deaths, population, (total_cases/population)*100 PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
--and location like '%states'


Create View DeathPercentage as
Select location, date, total_cases, new_cases, total_deaths, population, (cast(total_deaths as numeric)/cast(total_cases as numeric))*100 DeathPercentage
From PortfolioProject..CovidDeaths
--Where continent is not null
--and location like '%states'


Create View HighestInfectionRates as
Select location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population


Create View dbo.PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(convert(numeric,vacc.new_vaccinations)) over (Partition by deaths.location Order by deaths.location, deaths.date) RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
	on deaths.location = vacc.location
	and deaths.date = vacc.date
Where deaths.continent is not null


Select *
From PortfolioProject..PercentPopulationVaccinated