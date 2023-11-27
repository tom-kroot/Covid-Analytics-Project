select * from coviddeaths c 
where continent is not null
order by 3,4


-- Select Data That We Are Going To Be Using

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths c 
order by 1,2


-- Looking at Total Cases vs Total Deaths 
-- This shows the likelihood of dying if you contract covid in your country

select location, date, total_cases,  total_deaths, (CAST(total_deaths AS FLOAT) / total_cases)*100 AS mortality_rate_percent
from coviddeaths c 
where location like '%states%'
order by 1,2






-- Looking at Total Cases vs Population
-- Shows the percentage of people that got covid in your country

select location, date, total_cases, population, (CAST(total_cases AS FLOAT) / population)*100 AS PercentPopulationInfected
from coviddeaths c 
--where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(Cast(total_cases AS FLOAT)) as HighestInfectionCount, Max((Cast(total_cases AS FLOAT)/population))*100 as PercentPopulationInfected
from coviddeaths c
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

select location, Max(Cast(total_deaths AS INT)) as TotalDeathCount
from coviddeaths c
--where location like '%states%'
where continent is not null
group by location 
order by TotalDeathCount desc




-- Lets Break it Down by Continent

-- Show the Continents with the highest death count per population

select continent, Max(Cast(total_deaths AS INT)) as TotalDeathCount
from coviddeaths c
--where location like '%states%'
where continent is not null
group by continent 
order by TotalDeathCount desc



-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from coviddeaths c 
order by 1,2




-- Looking at Total Population vs Vaccinations


select dea.continent, dea.location, dea.formatted_date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location 
order by dea.location, dea.formatted_date) as RollingPeopleVaccinated
from covidvaccinations dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Formatted_Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        dea.Continent, 
        dea.Location, 
        dea.Formatted_Date, 
        dea.Population, 
        dea.New_Vaccinations,
        SUM(CAST(dea.New_Vaccinations AS INT)) OVER (
            PARTITION BY dea.Location 
            ORDER BY dea.Formatted_Date
        ) AS RollingPeopleVaccinated
    FROM 
        covidvaccinations dea
    WHERE 
        dea.Continent IS NOT NULL
)
SELECT *, ((Cast(RollingPeopleVaccinated AS FLOAT))/Population)*100 FROM PopvsVac
ORDER BY Location, Formatted_Date;





-- CREATE TEMP TABLE for Percent Population Vaccinated


Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.formatted_date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location 
order by dea.location, dea.formatted_date) as RollingPeopleVaccinated
from covidvaccinations dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *, ((Cast(RollingPeopleVaccinated AS FLOAT))/Population)*100 
FROM PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinatedView AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.formatted_date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.formatted_date
    ) AS RollingPeopleVaccinated
FROM 
    covidvaccinations dea
JOIN 
    covidvaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 2,3;



