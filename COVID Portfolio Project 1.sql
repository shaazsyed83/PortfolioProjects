
-- Query #1: Customized query to look at specific columns from the CovidDeaths table
SELECT location
		,date
		,total_cases
		,new_cases
		,total_deaths
		,population
FROM CovidDeaths
ORDER BY 1, 2

-- Query #2: Looking at Total cases vs. Total Deaths.  Calculating the risk of an individual dying in Afghanistan by finding the death percentage.
--			 Shows the likelihood of you dying if you were to contract covid in your country.
SELECT location
		,date
		,total_cases
		,total_deaths
		,(total_deaths / total_cases) * 100 as DeathPercentage
FROM CovidDeaths
ORDER BY 1, 2

-- Query #3: Looking at Total cases vs. Total Deaths.  Calculating the risk of an individual dying in Afghanistan by finding the death percentage and 
--			 using a WHERE clause to filter the data by a specific location. 
--			 Shows the likelihood of you dying if you were to contract covid in the United States.
SELECT location
		,date
		,total_cases
		,total_deaths
		,(total_deaths / total_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- Query #4: Looking at Total cases vs. Population.  Shows the percentage (portion) of population that got infected with COVID.
--			 The below WHERE clause can be adjusted to look at any other country.  
--			 This will serve as a good practice for data visualization in Tableau.
SELECT location
		,date
		,population
		,total_cases
		,(total_cases / population) * 100 as PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

/* Query #5: Looking at countries with the highest infection rate based on their population.
 *			 OBSERVATIONS:
 *			 After observing the results from Query #6, I ran this query to see if it displays 'continent values' where 'location values' are null
 *			 and it does.  So, we can use the WHERE statement here as well to avoid this.  Following is the WHERE statement:
 *			 WHERE continent IS NOT NULL
 *			 NOTE: Just for future references, if I need to study the code again.  One of the 'continent value' that appears is 'European Union'.
 *			 
 */

SELECT location
		,population
		,MAX(total_cases) AS HighestInfectionCount
		,MAX((total_cases / population)) * 100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

/* Query #6: Looking at countries with the highest death count based on their population.
 *			 CHALLENGE #1:
 *			 When we used this statement:     MAX(total_deaths) AS TotalDeathCount     the results were incorrect and the reason was the data type
 *			 which was nvarchar 255.  So, we had to use the CAST command to convert it into an integer to make it work.
			 CHALLENGE #2:
 *			 Upon execution, the results were actually displaying "Continent" data in the "location" column and the reason for this is when 'location' 
 *			 had 'NULL' values, it was being replaced with the values in the 'Continent' column.  In order to address this issue, we added another
 *			 statement:	WHERE continent is NOT NULL		and this took care of the challenge.
 */

SELECT location
		--,MAX(total_deaths) AS TotalDeathCount
		,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location = 'India'
-- The below WHERE clause can be used in the previous queries as well.  
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

/* Query #7: Breaking data down by continent.
 *			 ATTEMPT #1:
 *			 The results of this query for it's first attempt are not accurate.  For example, the North American total death count seems to only 
 *			 display the count for United States and not Canada.  Also, the values 'World' and 'International' are not showing up.
 *			 ATTEMPT #2:  
 *			 We needed to modify the code to get the accurate results. The statements commented out are the old statements.  The query works with
 *			 the new statements.
 */

-- Query 7 Way #1:
--SELECT continent
SELECT location
		,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
WHERE continent IS NULL
--GROUP BY continent
GROUP BY location
ORDER BY TotalDeathCount DESC

-- This approach was recommended by another person watching the video (@ushnakhan198) Video time: 38:23
-- However, with this way both "World" and "European Union" values are not showing up.  Is this right?
-- Query 7 Way #2:
SELECT continent
--SELECT location
		,SUM(CONVERT(INT, new_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--WHERE continent IS NULL
WHERE continent != ''
GROUP BY continent
--GROUP BY location
--ORDER BY TotalDeathCount DESC

/* Query #8: This query gives us total_cases, total_deaths and DeathPercentage for the whole world by dates.
 *			 ATTEMPT #1:
 *			 We tried querying without the GROUP BY command and it kept repeating the dates.
 *			 ATTEMPT #2:
 *			 We added the GROUP BY command but recieved an error message because there are other columns such as total_cases, total_deaths that
 *			 are not part of any aggregate function.  The other columns have to be part of aggregate functions. So, we tried a nested aggregate 
 *			 function like this:	SUM(MAX(total_cases))	which didn't work.  So we can't use an aggregate function on another aggregate funciton
 *			 or subquery.
 *			 ATTEMPT #3:
 *			 We replaced the column total_cases with new_cases and did a SUM() on it.  So, when we do a sum of all the new_cases for a particular date,
 *			 it'll give us the total_cases for that date.  Thus, tackling the challenge.  We also added added new_deaths column and tried calculating
 *			 it's SUM(), but we received and error message that:  "Operand data type nvarchar is invalid for sum operator".  So, in order to tackle this
 *			 we need to add the CAST() and use "integer" data type.
 *			 NOTE: The reason why new_cases is working with the SUM() is because it's a float data type.
 *			 
 *	

 */

SELECT	date
		--,total_cases
		/* Attempt #2: Using nested aggregate functions. 
		 *SUM(MAX(total_cases))
		 */
		 -- Attempt #3:
		,SUM(new_cases) total_cases
		,SUM(cast (new_deaths AS INT)) as total_deaths
		,SUM(cast (new_deaths AS INT))/ SUM(new_cases) * 100 AS DeathPercentage
		--,total_deaths
		--,(total_deaths / total_cases) * 100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
-- Attempt #2: Using GROUP BY
GROUP BY date
ORDER BY 1, 2

-- Query #9: The following code returns the total_cases, total_deaths and DeathPercentage in 1 row.  So, it's calculating the sum of total_cases
--			 total_deaths and DeathPercentage so far.  It's including all the dates all the continents and locations.
SELECT	SUM(new_cases) total_cases
		,SUM(cast (new_deaths AS INT)) as total_deaths
		,SUM(cast (new_deaths AS INT))/ SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

/* Query #10: Looking at total population vs. new vaccinations per day
 *			  SCENARIO #1: Doing a rolling count of new vaccinations by location.
 *						   CHALLENGE #1: Following is the code we used to calculate the rolling count:
 *										 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location)	
 *										 However, the challenge that we faced is it's giving the total count and not the rolling count of the location.
 *										 This is due to the fact that we also need to order the data by "location and "date" in order for the 
 *										 calculation to generate a sum for every date.  The new code is as follows:
 *										 ,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
 *			  SCENARIO #2: Find out the number of people who got vaccinated by the using the total people vaccinated by dividing total population by
 *						   by RollingPeopleVaccinated. 
 *						   THINKING OUT LOUD!? So, the RollingPeopleVaccinated total count, doesn't this indicated the number of people vaccinated?
 *											   Why are we doing a different calculation to find out how many people got vaccinated? Does this mean 
 *											   that is number also includes people who got vaccinated twice or more (2nd dose and booster shots)?
 *											   But if this is the case then why is it called new_vaccinations? Isn't this referring to the 1st dose?
 *											   NEED MORE CLARIFICATION ON THIS.
 *						   So, we tried using the following code to find the number of people vaccinated:	,(RollingPeopleVaccinated / population) * 100
 *						   However, we found the you can't use a column that you created in the query.  This is a situation that requires us to use
 *						   a CTE or a TEMP table. For now, we are going to use a CTE.
 *						   NOTE: Need to make sure that the number of columns you mention in the CTE match with the number of columns you are using in 
 *								 the query.  Otherwise, you'll get an error message.  Meaning that this:
 *								 WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 *								 has to match with this: SELECT dea.continent ,dea.location ,dea.date ,population ,vac.new_vaccinations
 *								,RollingPeopleVaccinated
 *						  ORDER BY can't be within the CTE.
 * FUTURE ASSIG:		  Alex is recommending us to do the "rolling number" calculation with different values instead of RollingPeopleVaccinated.
 *						
 */

 SELECT dea.continent
		,dea.location
		,dea.date
		,population
		,vac.new_vaccinations
		-- We can convert the data type using two different commands.  CAST() and CONVERT()
		--,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location)
		,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated		
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- SCENARIO #2:
/* OBSERVATION #1: The row information in my CTE doesn't match with Alex's results.  For example, row #852 in his results' window shows "Albania" 
 *					as the "location" but mine is showing as "Andorra".  Why? The code is same. No issues. So, why this anomaly?  This is because
 *					I didn't add the date column in the CTE.  The following statement didn't have the date column:
 *					WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 *					The above observation is incorrect.  The date column is present in the CTE.  The anomaly is something else.
 * OBESERVATION #2. The date values don't match in row #852.  In my results, I have "2020-07-24", whereas in Alex's results the date is "2021-04-19".
 *					But why is this occuring like this?  The ORDER BY statement is commented out in the CTE.
 *					There is a discrepancy in the SELECT statement.  Let's look at it:		
 *					SELECT dea.continent ,dea.location ,dea.date ,population ,vac.new_vaccinations...
 *					I didn't copy all of the SELECT statement because it'll take a lot of space.  The anomaly is being caused by the "population"
 *					column because it's not associated with an alias of a table.  It usually should give an error message but it's not doing it 
 *					in this situation.  Let's make the changes...		The changes didn't help.  The anomaly is being caused by something else.
 * OBSERVATION #3:  Video timestamp 1:05:44 - Alex is looking @ row #863 and the values are as follows: 
 *					"Europe	Albania	2021-04-30 00:00:00.000	2877800	23655	347702	12.0822155813469"
 *					These same values for me are coming up in row #707, not in row #863.  I have still not figured out how this is happening.  
 * NOTE:			We can find the MAX and MIN values also using this code.  We just need to remove the "date" column because that according to
 *					Alex will through off the results.  Let's do this later...
 *					DO THIS LATER!!!
 */					
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent
		,dea.location
		,dea.date
		--,population
		,dea.population
		,vac.new_vaccinations
		--,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated / population) * 100
FROM PopvsVac


/* Query #11: Creating and using a TEMP table.
 *				SCENARIO #1:
 *				OBSERVATION #1: The same thing is happening here. Alex is getting different values in row #1 and I am getting something else.
 *								Continent value is "Europe" in Alex's results and "Asia" in my results.
 *				THINKING LOUDLY:	We are not using ORDER BY or GROUP BY or any other function to organize the data.  Both the codes match 100%.
 *									So, what is causing this anomaly to happen? Intriguing!
 *				Once a temp table is created you can't make changes to it.  You'll have to DROP the table, make the changes and CREATE the table
 *				again.
 *				SCENARIO #2: Add the following statement to overcome the TEMP table challenge:  DROP TABLE IF EXISTS #PercentPopulationVaccinated
 *
 * 
 */

 -- SCENARIO #2:
 DROP TABLE IF EXISTS #PercentPopulationVaccinated
 -- SCENARIO #1:
 CREATE TABLE #PercentPopulationVaccinated
 (
 continent					NVARCHAR(255)
 ,location					NVARCHAR(255)
 ,Date						DATETIME
 ,Population				NUMERIC
 ,new_vaccinations			NUMERIC
 ,RollingPeopleVaccinated	NUMERIC
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated

/* Query #12: Creating a view
 *				Views are not permanent.
 *				Alex is recommending us to do some of these views, so that we can use them for visualizations later.
 *				TIPS!: Work table or Work view.  Views can be connected to Tableau for visualizations.
 *				NOTE: CTRL + SHIFT + R refreshes SQL Server
 */

 CREATE VIEW PercentPopulationVaccinated AS
 SELECT dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3




SELECT * FROM CovidDeaths
SELECT * FROM CovidVaccinations