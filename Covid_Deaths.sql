Select * 
From Portfolio_Project.dbo.CovidDeaths
Where Continent is Not Null
order by 3,4

--Select * 
--From Portfolio_Project.dbo.CovidVaccinations
--order by 3,4

--Select Data that we are going to be using
Select Location, Date, Total_Cases, new_cases, total_deaths, population 
From Portfolio_Project.dbo.CovidDeaths
Where Continent is Not Null
order by 1,2

--Looking at Total Cases Vs. Total Deaths
--Shows the likelihood of dying if you contract Covid in your country
Select Location, Date, Total_Cases, total_deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
From Portfolio_Project.dbo.CovidDeaths
Where Continent is Not Null
Where Location like '%states%'
order by 1,2

--Looking at Total Cases vs. Popluation
Select Location, Date, Total_Cases, Population, (total_cases/Population)*100 as PercentPopulationInfected
From Portfolio_Project.dbo.CovidDeaths
--Where Location like '%states%'
Where Continent is Not Null
order by 1,2

--Looking at Highest Infection rates
Select Location, Population, MAX(Total_Cases) as HighestInfectionCount, (MAX(total_cases/Population))*100 as PercentPopulationInfected
From Portfolio_Project.dbo.CovidDeaths
--Where Location like '%states%'
Where Continent is Not Null
Group by Location, population
order by 4 desc


--Let's Break Things Down by Continent
--Looking at Highest Death rates
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount, (MAX(total_deaths/Population))*100 as PercentPopulationInfected
From Portfolio_Project.dbo.CovidDeaths
--Where Location like '%states%'
Where Continent is Not Null
Group by location
order by HighestDeathCount desc

--Showing Continents with the highest death count per population
--Looking at Highest Death rates
Select Location, Population, MAX(cast(total_deaths as int)) as HighestDeathCount, (MAX(total_deaths/Population))*100 as PercentPopulationInfected
From Portfolio_Project.dbo.CovidDeaths
--Where Location like '%states%'
Where Continent is Not Null
Group by Location, population
order by 3 desc


--Global Numbers
--Global Numbers - By Date
Select Date, Sum(New_Cases) as Total_Cases,  SUM(cast(New_Deaths as int)) as Total_Deaths, SUM(cast(New_Deaths as INT))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_Project.dbo.CovidDeaths
--Where Location like '%states%'
Where Continent is Not Null
Group By date
order by 1,2

--Global Numbers - Total
Select Sum(New_Cases) as Total_Cases,  SUM(cast(New_Deaths as int)) as Total_Deaths, SUM(cast(New_Deaths as INT))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_Project.dbo.CovidDeaths
--Where Location like '%states%'
Where Continent is Not Null
--Group By date
order by 1,2



Select * 
From Portfolio_Project.dbo.CovidDeaths Deaths
Join Portfolio_Project.dbo.CovidVaccinations Vacc
     On Deaths.Location = Vacc.Location
	 and Deaths.Date = Vacc.date

-- Looking at Total Population vs. Vaccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, sum(Convert(int,vacc.new_vaccinations)) OVER (Partition by deaths.location Order By Deaths.Location
, Deaths.Date) as Rolling_Vaccination_Count
,(Rolling_Vaccination_Count/Deaths.population*100
From Portfolio_Project.dbo.CovidDeaths Deaths
Join Portfolio_Project.dbo.CovidVaccinations Vacc
     On Deaths.Location = Vacc.Location
	 and Deaths.Date = Vacc.date
Where deaths.Continent is Not Null
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_Vaccination_Count)
as 
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, sum(Convert(int,vacc.new_vaccinations)) OVER (Partition by deaths.location Order By Deaths.Location
, Deaths.Date) as Rolling_Vaccination_Count
--,(Rolling_Vaccination_Count/Deaths.population*100
From Portfolio_Project.dbo.CovidDeaths Deaths
Join Portfolio_Project.dbo.CovidVaccinations Vacc
     On Deaths.Location = Vacc.Location
	 and Deaths.Date = Vacc.date
Where deaths.Continent is Not Null
--Order by 2,3
)
Select *, (Rolling_Vaccination_Count/Population)*100 as VaccCountvsPop_Percentage
From PopvsVac


--TEMP TABLE
DROP Table If Exists #PercentPopluationVaccinated
Create Table #PercentPopluationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population Numeric, 
New_Vaccinations Numeric, 
Rolling_Vaccination_Count numeric
)

INSERT INTO #PercentPopluationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, sum(Convert(int,vacc.new_vaccinations)) OVER (Partition by deaths.location Order By Deaths.Location
, Deaths.Date) as Rolling_Vaccination_Count
--,(Rolling_Vaccination_Count/Deaths.population*100
From Portfolio_Project.dbo.CovidDeaths Deaths
Join Portfolio_Project.dbo.CovidVaccinations Vacc
     On Deaths.Location = Vacc.Location
	 and Deaths.Date = Vacc.date
Where deaths.Continent is Not Null
--Order by 2,3

Select *, (Rolling_Vaccination_Count/Population)*100 as VaccCountvsPop_Percentage
From #PercentPopluationVaccinated


--Creating View to Store Data for Later Visualizations

Create View PctPopluationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, sum(Convert(int,vacc.new_vaccinations)) OVER (Partition by deaths.location Order By Deaths.Location
, Deaths.Date) as Rolling_Vaccination_Count
--,(Rolling_Vaccination_Count/Deaths.population*100
From Portfolio_Project.dbo.CovidDeaths Deaths
Join Portfolio_Project.dbo.CovidVaccinations Vacc
     On Deaths.Location = Vacc.Location
	 and Deaths.Date = Vacc.date
Where deaths.Continent is Not Null
--Order by 2,3


--View wouldn't populate to Views folder, so I created a delete query.
USE Portfolio_Project
Go

DROP View if exists PctPopulationVaccinated;
Go
--

--Query off of view
Select *
From PctPopluationVaccinated


