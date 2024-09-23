select *
from sql_project..['covid deaths$']
where continent = 'Asia'
and location = 'India'
order by 4;

-- Looking at total cases of continents

select continent, sum(total_cases) as total_cases
from sql_project..['covid deaths$']
where continent is NOT NULL
group by continent
order by 2 desc;

select *
from sql_project..['covid deaths$']
where continent is NULL;

select location, date, total_cases, new_cases, total_deaths, population
from sql_project..['covid deaths$']
order by 1,2;

-- looking at total cases vs total deaths

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from sql_project..['covid deaths$']
order by 1,2;

select location, date, total_cases, total_deaths,
(convert(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 as Death_percentage
from sql_project..['covid deaths$']
where location = 'India'
order by 1,2;

-- Highest deaths/per day in India

select location, date, total_cases, new_deaths, total_deaths,
(convert(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 as Death_percentage
from sql_project..['covid deaths$']
where location = 'India'
order by 4 desc;

-- looling at totalcases vs population

select location, date, new_cases, total_cases, population, (total_cases/population) * 100 as covid_percentage
from sql_project..['covid deaths$']
where location like '%India%'
order by 6 desc;

select continent, location, (total_cases/population) * 100 as covid_percentage
from sql_project..['covid deaths$']
--where location like '%India%'
order by 3 desc;

with cte
AS (select continent, location, population, max(total_cases) as HighestInfectCount, 
max((total_cases/population)) * 100 as PercentPopulationInfect
from sql_project..['covid deaths$']
where continent is not null
group by continent, location, population
)
select *
from cte
order by 4 desc;

--looking at Highest deaths count by countries

select location, population, Max(total_deaths) as TotalDeathsCount
from sql_project..['covid deaths$']
where continent is not null
group by location, population
order by 3 desc;

-- looking at covid death by continents 

with cte_1 as(
select continent, location, population, Max(total_deaths) as TotalDeathsCount
from sql_project..['covid deaths$']
where continent is not null
group by continent, location, population
)
select continent, sum(TotalDeathsCount) as covid_deaths
from cte_1
group by continent
order by covid_deaths;

-- Global numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
(convert(float, sum(new_deaths)) / NULLIF(convert(float, sum(new_cases)), 0)) * 100 as deathpercentage
from sql_project..['covid deaths$']
where continent is not null
--group by date
order by 1,2;

-- Looking at total population vs vaccination

with cte as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from sql_project..['covid deaths$'] as dea
join sql_project..['covid vaccination$'] as vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null 
)
select location, population, max(RollingPeopleVaccinated) as Total_vaccinated, 
(max(RollingPeopleVaccinated)/population) * 100 vaccinationPercentage
from cte
group by location, population
order by 1;

-- TEMP TABLE

drop table if exists PrcentagePeopleVaccinated
create table PrcentagePeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into PrcentagePeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from sql_project..['covid deaths$'] as dea
join sql_project..['covid vaccination$'] as vac
 on dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null 

select *, (RollingPeopleVaccinated/population)*100 as vaccinationPercentage
from PrcentagePeopleVaccinated;

-- Creating views to store data for later visualization

create view  PrcentagePeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from sql_project..['covid deaths$'] as dea
join sql_project..['covid vaccination$'] as vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 select*
 from  PrcentagePeopleVaccinated;