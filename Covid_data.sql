--Loooking at total Cases and Total Death 

Select location, date ,total_cases, new_cases,total_deaths, population,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..['CovidDeaths']
order by 1,2 

--Looking at Europep's total cases vs Population
--Shows the percentage of population got covid in Europe

Select continent, date,population,total_cases, new_cases,total_deaths,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS percentage
from PortfolioProject..['CovidDeaths']
where continent like 'Europe'
order by 1,2 

--Looking at the Countries with Highest Infection rate compared to population

Select location,population, MAX(total_cases) as Highest_Infaction_Count, MAX((total_cases/population)) * 100 as Inected_Population_Percentage
from PortfolioProject..['CovidDeaths']
group by location, population
order by Inected_Population_Percentage desc

--Looking at the Counteries with Highest Death count per Population

Select location, population, MAX(total_deaths) As Total_Deathes
from PortfolioProject..['CovidDeaths']
group by location,population
order by Total_Deathes desc


--Global Numbers
-- NULLIF statement for Divieded by zero error

select date,sum(new_cases) as Sum_of_Cases,sum(total_deaths)as Sum_of_deaths, NULLIF(SUM(new_deaths),0)/NULLIF(sum(new_cases),0)*100 as Death_percentage
from PortfolioProject..['CovidDeaths']
where continent is not null	
group by date
order by 1,2

-- Looking at total population vs total vaccination
-- Join  of Covid death table and Covid Vaccination Table
--Use CTE

With PopvsVac(continent,date, location,population,new_vaccinations,Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.date, dea.location,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..['CovidDeaths'] dea
inner join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is  not null
)
SELECT continent,location,new_vaccinations,Rolling_People_Vaccinated, Round((Rolling_People_Vaccinated /population)*100 ,4 ) as Percentage
FROM PopvsVac


--Temp table 

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date Datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated  numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..['CovidDeaths'] dea
inner join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date= vac.date


SELECT *, Round((Rolling_People_Vaccinated /population)*100 ,4 ) as Percentage
FROM #PercentPopulationVaccinated


--Creating view For tableau

Create view PercentPopulationVaccinated as
Select dea.continent, dea.date, dea.location,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..['CovidDeaths'] dea
inner join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is  not null
