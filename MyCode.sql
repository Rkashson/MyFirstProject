--Where totol death againt the population 
SELECT Location, date , total_cases , total_deaths, population ,( total_deaths / population )
FROM CovidDeaths 
WHERE location = 'India'
Order by 1,2

--Infection rate against the population

SELECT Location, population , SUM (cast (total_cases as Bigint ) )as  Total_cases
FROM CovidDeaths 
Group by location ,population
Order by 1,2

--Sample 
SELECT avg (  CAST (total_cases as bigint ))
FROM CovidDeaths

--infection rate against the population 

SELECT Location, Population , MAX(Cast( total_cases as BIGINT)) as HighestCases ,
MAX( Cast( total_cases as BIGINT))/population as InfectionAgainstPopulation 
From CovidDeaths
Group by Location, population 
Order by InfectionAgainstPopulation desc

--infection rate of India 

SELECT Location, Population , MAX(Cast( total_cases as BIGINT)) as HighestCases ,
MAX( Cast( total_cases as BIGINT))/population as InfectionAgainstPopulation 
From CovidDeaths
WHERE location like '%India%'
Group by Location, population 

--total infection in India till Now 

SELECT Location, Population , SUM(Cast( total_cases as BIGINT)) as TotalCases 
From CovidDeaths
WHERE location like '%India%'
Group by Location, population 

--Showing total death in the country 

SELECT Location, MAX(cast (total_deaths as bigint)) as totaldeath 
From CovidDeaths
WHERE continent is not null
Group by Location 
order by 2 desc

--Showing countries with highest death count per population


SELECT Location, Population , MAX(cast(total_deaths as bigint)) as TotalDeaths ,
MAX((cast(total_deaths as bigint))/population as TotaldeathPercentage 

From CovidDeaths
Group by Location, population 
Order by 1,2

--Showing countries with total death 

SELECT Location,  MAX(cast(total_deaths as bigint)) as TotalDeaths

From CovidDeaths
Where continent is not null
Group by Location

Order by TotalDeaths desc 

-- Showing continets with total death 

SELECT Continent  MAX(cast(total_deaths as int)) as TotalDeaths
From CovidDeaths

Group by Continent 
Order by TotalDeaths desc 

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Showing continets with highest death count 

Select continent , MAX( CAST ( Total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
Where continent is not null 
Group by Continent 
Order by TotalDeathCount desc

--Global Number

SELECT date, SUM(new_cases) as TotalCases , SUM(CAST (total_deaths as int)) as TotalDeaths ,  
SUM(CAST (total_deaths as int))/ SUM(new_cases) *100 as TotalDeathPercentage
FROM CovidDeaths

Group by date 
Order by 1 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Looking total population vs vaccinations in India


SELECT dea.location , dea.date , dea.population , Vac.total_vaccinations
FROM CovidDeaths as Dea
Join CovidVaccinations as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date 
WHERE dea.location  like '%India%'
Order by 4 desc


--Looking total population vs vaccinations

SELECT dea.location , dea.date , dea.population , Vac.total_vaccinations
FROM CovidDeaths as Dea
Join CovidVaccinations as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date 

Order by 1,2

--total population vs New vaccinations

SELECT dea.continent,  dea.location , dea.date , dea.population , Vac.new_vaccinations 
, SUM (CAST (Vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location)
FROM CovidDeaths as Dea
Join CovidVaccinations as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date 
WHERE dea.continent is not NULL

Order by 2,3

-- partiton by location and date 

SELECT dea.continent,  dea.location , dea.date , dea.population , Vac.new_vaccinations 
, SUM (CAST (Vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM CovidDeaths as Dea
Join CovidVaccinations as Vac
     on Dea.location = Vac.location
     and Dea.date = Vac.date 
WHERE dea.continent is not NULL 
Order by 2,3	


--CTE
 
WITH VACvsPOP  ( continent ,location ,date, population, new_vaccinations , RollingPeopleVaccinated )
as
(
SELECT dea.continent,  dea.location , dea.date , dea.population , Vac.new_vaccinations 
, SUM (CAST (Vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM CovidDeaths as Dea
Join CovidVaccinations as Vac
     on Dea.location = Vac.location
     and Dea.date = Vac.date 
WHERE dea.continent is not NULL 
	
)

SELECT * ,(RollingPeopleVaccinated/population)*100 as 
FROM VACvsPOP

--Create Temp Table

DROP TABLE IF EXISTS  #PrecentagePeopleVaccinaated
Create Table #PrecentagePeopleVaccinaated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PrecentagePeopleVaccinaated
SELECT dea.continent,  dea.location , dea.date , dea.population , Vac.new_vaccinations 
, SUM (CAST (Vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM CovidDeaths as Dea
Join CovidVaccinations as Vac
     on Dea.location = Vac.location
     and Dea.date = Vac.date 
WHERE dea.continent is not NULL 
Order by 2,3

SELECT *
FROM #PrecentagePeopleVaccinaated


CREATE VIEW  PrecentagePeopleVaccinaated as
SELECT dea.continent,  dea.location , dea.date , dea.population , Vac.new_vaccinations 
, SUM (CAST (Vac.new_vaccinations as bigint)) OVER (PARTITION by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
FROM CovidDeaths as Dea
Join CovidVaccinations as Vac
     on Dea.location = Vac.location
     and Dea.date = Vac.date 
WHERE dea.continent is not NULL 
--Order by 2,3


SELECT *
FROM PrecentagePeopleVaccinaated