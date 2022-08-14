use [Portfolio Project]

--Total Deaths VS Total Cases --> Death_Percentage!!
Select	
	location,
	date,
	total_cases,
	total_deaths,
	round(total_deaths/total_cases*100,4) as DeathPercentage
from CovidDeaths
where continent is not null
--and location = 'Egypt'
order by 1,2

--Highest DeathPercentage recorded in Egypt!!
Select 
	max(round(total_deaths/total_cases*100,4)) as Max_DeathPercentage
from CovidDeaths
where location = 'Egypt'
and continent is not null

--Total cases VS Total Population --> Infection_Percentage!!
Select location
	,date
	,population
	,total_cases
	,round(total_cases/population*100,4) as Incfected_Percentage
from CovidDeaths
where continent is not null
--and location = 'Egypt'
order by 1,2

--Highest Infection Rates!!
Select 
	location,
	population,
	--date,
	max(total_cases) as InfectedPopulation,
	max(round(total_cases/population*100,4)) as Incfection_Percentage
from CovidDeaths
--where continent is not null
group by
	location,
	population
	--,date
order by Incfection_Percentage desc

--Countries with the Highest Death_Numbers!!
select 
	location,
	max(cast(total_deaths as bigint)) as Highest_Death_Count
from CovidDeaths
where continent is not null
group by location
order by Highest_Death_Count desc

--CONTINENTS with the Highest Death_Numbers!!
select 
	location,
	sum(cast(new_deaths as bigint)) as Highest_Death_Count
from CovidDeaths
where continent is null
and location not in ('World','European Union','International')
group by location
order by Highest_Death_Count desc

--Cases Daily Update!!
select 
	date,
	sum(new_cases) as New_Cases,
	sum(cast(new_deaths as int)) as New_deaths,
	round((sum(cast(new_deaths as int))/sum(new_cases)*100),3) as Death_Percentage
from CovidDeaths
where continent is not null
group by date
order by 1

--Total number of cases and deaths worldwide!!
select 
	top 1 total_cases,
	total_deaths,
	round(total_deaths/total_cases*100,2) as DeathPercentage
from CovidDeaths
where location = 'world'
order by total_cases desc

--Daily update of how many new vaccinations and how many vaccinated people overall!!
select d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(cast(v.new_vaccinations as int)) over (PARTITION by d.location order by d.date) as People_Vaccinated
from dbo.CovidDeaths d
join dbo.CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
order by 2,3

--Daily update of what is the percentage of people vaccinated over total population!!
--Approch one: Using CTE
with Vaccination_Pecentage(continent,location,date,population,new_vaccinations,People_Vaccinated)
as(
select d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(cast(v.new_vaccinations as int)) over (PARTITION by d.location order by d.location , d.date) as People_Vaccinated
from dbo.CovidDeaths d
join dbo.CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
)
select *,(People_Vaccinated/population *100) as People_Vaccinated_Percentage
from Vaccination_Pecentage
order by 2,3

--Approch Two: Temp Table
DROP TABLE IF exists #Vaccination_Pecentage
Create table #Vaccination_Pecentage(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
People_Vaccinated numeric
)
----------
Insert into #Vaccination_Pecentage
select d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(cast(v.new_vaccinations as int)) over (PARTITION by d.location order by d.location , d.date) as People_Vaccinated
from dbo.CovidDeaths d
join dbo.CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
----------
select *,(People_Vaccinated/population *100) as People_Vaccinated_Percentage
from #Vaccination_Pecentage
order by 2,3