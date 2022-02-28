





--SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM PortfolioProjects..[COVID-Deaths 20-02-22]
--WHERE location = 'Australia'
--ORDER BY 1,2

--Look at Countries with Highest Infection Rate compared to Population

/*
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..[COVID-Deaths 20-02-22]
Group by Location, Population
Order by PercentPopulationInfected desc
*/

-- Showing Countries with Highest Death Count per Population

/*
SELECT Location, Population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 as PercentPopulationDied
FROM PortfolioProjects..[COVID-Deaths 20-02-22]
Where continent is not null
Group by Location, Population
Order by PercentPopulationDied desc
*/


/*
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..[COVID-Deaths 20-02-22]
Where continent is not null
Group by Location
Order by TotalDeathCount desc
*/

--Showing continents with the highest death count

/*
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..[COVID-Deaths 20-02-22]
Where continent is not null
Group by continent
Order by TotalDeathCount desc
*/





-- USE CTE
-- Looking at when Vaccinations rolled out vs Total Population
-- Cast(expression AS datatype(Lenght)) converts a value of any type to a specified type) ... OR...
-- CONVERT(datatype as <field>)
-- OVER (Partition by <column>) we want to SUM to start over every time the <column> field changes i.e. Subtotal
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
From PortfolioProjects..[COVID-Deaths 20-02-22] dth
Join PortfolioProjects..[COVID-Vaccinations 20-02-22] vac
	On dth.location = vac.location
	and dth.date = vac.date
Where dth.continent is not null
--Order by 2,3 --Here 2 refers to location from Select and 3 is Date from Select, not from original table.
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

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
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
From PortfolioProjects..[COVID-Deaths 20-02-22] dth
Join PortfolioProjects..[COVID-Vaccinations 20-02-22] vac
On dth.location = vac.location
and dth.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
USE [PortfolioProjects]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create View [dbo].[PercentPopulationVacced] as
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as RollingPeopleVaccinated
From PortfolioProjects..[COVID-Deaths 20-02-22] dth
Join PortfolioProjects..[COVID-Vaccinations 20-02-22] vac
On dth.location = vac.location
and dth.date = vac.date
Where dth.continent is not null
GO






