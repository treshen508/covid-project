select *
from portfolioproject..CovidDeaths
Where continent is not null
order by 3,4 

--select *
--from portfolioproject..CovidVaccinations
--order by 3,4 

select location, date, total_cases, new_cases, total_deaths, population 
from portfolioproject..CovidDeaths
Where continent is not null
order by 1,2


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
where location like '%Australia%' and continent is not null
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths
where location like '%New Zealand%'
order by 1,2

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths
--where location like '%New Zealand%'
group by location, population
order by PercentPopulationInfected DESC

select location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount DESC
-- broken up by continent

select continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount DESC


-- Global Numbers

select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM 
	(new_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
--where location like '%Australia%' 
where continent is not null
order by 1,2

-- total population vs. total weekly_icu_admissions

select deaths.continent, deaths.location, deaths.date, deaths.population, deaths.weekly_icu_admissions,
SUM(cast(deaths.weekly_icu_admissions as int)) over (partition by deaths.location order by deaths.location, deaths.date)
as RollingWeeklyIcuAdmits
--,(RollingWeeklyIcuAdmits/population)*100

from portfolioproject..CovidDeaths deaths
join portfolioproject..CovidVaccinations vaccs
	on deaths.location = vaccs.location 
	and deaths.date = vaccs.date
	where deaths.weekly_icu_admissions is not null
	order by 1,2,3

with PopvsIcu (continent, location, date, population, weekly_icu_admissions, RollingWeeklyIcuAdmits)
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, deaths.weekly_icu_admissions,
SUM(cast(deaths.weekly_icu_admissions as int)) over (partition by deaths.location order by deaths.location, deaths.date)
as RollingWeeklyIcuAdmits
--,(RollingWeeklyIcuAdmits/population)*100

from portfolioproject..CovidDeaths deaths
join portfolioproject..CovidVaccinations vaccs
	on deaths.location = vaccs.location 
	and deaths.date = vaccs.date
	where deaths.weekly_icu_admissions is not null
	)
	select * ,(RollingWeeklyIcuAdmits/population)*100
	from PopvsIcu

-- view for later data visuals
 
 create view RollingWeeklyIcuAdmits as select deaths.continent, deaths.location, deaths.date, deaths.population, deaths.weekly_icu_admissions,
SUM(cast(deaths.weekly_icu_admissions as int)) over (partition by deaths.location order by deaths.location, deaths.date)
as RollingWeeklyIcuAdmits
--,(RollingWeeklyIcuAdmits/population)*100
from portfolioproject..CovidDeaths deaths
join portfolioproject..CovidVaccinations vaccs
	on deaths.location = vaccs.location 
	and deaths.date = vaccs.date
	where deaths.weekly_icu_admissions is not null
	
