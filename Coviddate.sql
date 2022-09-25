USE ProjectCovid
GO

--Вывести процентное соотношение умерших людей от ковида к выявленным случаям заболевания

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS Death_Percentage
FROM dbo.Deaths
WHERE location like 'Rus%' and ( continent IS NOT NULL )
ORDER BY 1,2

--Показать процент заражения населения Covid в России

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,3) AS Covid_Percentage
FROM dbo.Deaths
WHERE location like 'Rus%' and ( continent IS NOT NULL )
ORDER BY 1,2

--Показать Страны с самым высоким уровнем заражения

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
ROUND(MAX((total_cases/population))*100,3) AS Covid_Percentage
FROM dbo.Deaths
WHERE continent IS NOT NULL 
GROUP BY location, population 
ORDER BY Covid_Percentage DESC

--Показать страны с высоким уровнем смертности

SELECT location,  MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM dbo.Deaths
WHERE continent !=''
GROUP BY location 
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Deaths
--Where location like 'Rus%'
where continent !=''
--Group By date
order by 1,2


--Temp Table
DROP TABLE if exists #PercentPoulationVaccinated
CREATE TABLE #PercentPoulationVaccinated
(
	Continent nvarchar (255) ,
	Location nvarchar (255),
	Date time,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPoulationVaccinated
SELECT dbo.Deaths.continent, dbo.Deaths.location, dbo.Deaths.date, dbo.Deaths.population,
dbo.Vaccinations.new_vaccinations, 
SUM( CONVERT (bigint, dbo.Vaccinations.new_vaccinations)) 
OVER (PARTITION BY dbo.Deaths.location ORDER BY dbo.Deaths.location, dbo.Deaths.date) AS RollingPeopleVaccinated
FROM dbo.Deaths
JOIN dbo.Vaccinations
	ON dbo.Deaths.location=dbo.Vaccinations.location
	AND dbo.Deaths.date=dbo.Vaccinations.date
--WHERE dbo.Deaths.continent !=''
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPoulationVaccinated

-- Creating View to store data  for later visualization

CREATE VIEW PercentPoulationVaccinated AS
SELECT dbo.Deaths.continent, dbo.Deaths.location, dbo.Deaths.date, dbo.Deaths.population,
dbo.Vaccinations.new_vaccinations, 
SUM( CONVERT (bigint, dbo.Vaccinations.new_vaccinations)) 
OVER (PARTITION BY dbo.Deaths.location ORDER BY dbo.Deaths.location, dbo.Deaths.date) AS RollingPeopleVaccinated
FROM dbo.Deaths
JOIN dbo.Vaccinations
	ON dbo.Deaths.location=dbo.Vaccinations.location
	AND dbo.Deaths.date=dbo.Vaccinations.date
WHERE dbo.Deaths.continent !=''
--ORDER BY 2,3