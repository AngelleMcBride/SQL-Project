/* Employee Data Analysis Project

Skills used: Creating Tables, Creating Views, Nested Subqueries, Aggregate Functions, Joins, Case
*/

-- Importing Data --
----------------------

-- Create Employee Company Information Table
	CREATE TABLE EmpCompany (
		EmpID serial PRIMARY KEY,
		FirstName text,
		LastName text,
		StartDate date,
		ExitDate date,
		Title text,
		Supervisor text,
		BusinessUnit text,
		EmployeeStatus text,
		EmployeeType text,
		PayZone text,
		EmployeeClassificationType text,
		TerminationType text,
		TerminationDescription text,
		DepartmentType text,
		Division text

	);

	SELECT * FROM EmpCompany;
	
	


-- Create Employee Personal Information Table
	CREATE TABLE EmpPersonal (
		EmpID serial PRIMARY KEY,
		FirstName text,
		LastName text,
		DOB date,
		State text,
		JobFunctionDescription text,
		GenderCode text,
		LocationCode int,
		RaceDesc text,
		MaritalDesc text,
		PerformanceScore text,
		CurrentEmployeeRating int
	);

	SELECT * FROM EmpPersonal;
	
	

-- Views with current employees and ages 
-- Create view of current employees:
	CREAT VIEW currentemp AS
		SELECT * FROM EmpCompany
		WHERE exitdate IS NULL;
		
	SELECT * FROM currentemp;
	
	
	
-- Create view with employee ages:

	CREATE VIEW emppersonalages AS
		SELECT * FROM EmpPersonal,
		EXTRACT(YEAR FROM AGE(CAST(dob AS DATE))) AS age
		FROM emppersonal;
		
	SELECT * FROM emppersonalages;
	
	
	
	
-- Data Analysis --
-------------------

-- 1. What is the count of employees by gender?

	SELECT gendercode, COUNT(*) AS gender_count
	FROM emppersonal
	GROUP BY gendercode
	ORDER BY gender_count DESC;
	
	

-- 2. What is the count of employees classification type?

	SELECT employeeclassificationtype, COUNT(*) AS employee_count
	FROM currentemp
	GROUP BY employeeclassificationtype
	ORDER BY employee_count DESC;
	
	
	
-- 3. What is the distribution of employee peroformance score across different departments?

	SELECT curremp.departmenttype, empper.performancescore, 
		COUNT (*) AS count_of_emp
	FROM currentemp as curremp, emppersonal AS empper
	GROUP BY curremp.departmenttype, empper.performancescore 
	ORDER BY curremp.departmenttype,  
	count_of_emp DESC;
	
	

-- 4. What is the distributribution of current employee age ranges across the different pay zones?

	SELECT CASE
		WHEN age BETWEEN 18 AND 24 THEN '18-24'
		WHEN age BETWEEN 25 AND 34 THEN '25-34'
		WHEN age BETWEEN 35 AND 44 THEN '35-44'
		WHEN age BETWEEN 45 AND 54 THEN '45-54'
		WHEN age BETWEEN 55 AND 60 THEN '55-60'
		ELSE '60+'
		END AS age_ranges,
		payzone,
		COUNT (*) AS count_of_employees
	FROM emppersonalages NATURAL JOIN currentemp
	GROUP BY age_ranges, payzone
	ORDER BY age_ranges;
	
	
		
-- 5. How does the race distribution vary across departments?

	SELECT departmenttype, racedesc, COUNT(*) AS count
	FROM emppersonal NATURAL JOIN currentemp
	GROUP BY departmenttype, racedesc
	ORDER BY departmenttype;
	
	

-- 6. What is the distribution of termination type for employees who no longer work for the company?

	SELECT terminationtype, COUNT(*) AS count
	FROM empcompany
	WHERE exitdate IS NOT NULL
	GROUP BY terminationtype
	ORDER BY count;
	
	
	
-- 7. What is the distribution of employees across the US working remotely?

	SELECT state, COUNT(*) AS count
	FROM emppersonal NATURAL JOIN currentemp
	WHERE state IN (
		SELECT state
		FROM emppersonal
		WHERE state NOT IN ('MA'))
	GROUP BY state
	ORDER BY count DESC;
	
	
	
-- 8. How many employees work at the company headquarters?

	SELECT state, count(*) AS count
	FROM emppersonal NATURAL JOIN currentemp
	WHERE state = 'MA'
	GROUP BY state;
	
	

-- 9. What are the names of the supervisors in the sales department?

	SELECT firstname, lastname, title, departmenttype
	FROM currentemp
	WHERE (title LIKE '%Manager%') AND (departmenttype LIKE '%Sales%');
	
	

-- 10. What is the name of the employee who has been working for the company the longest?

	SELECT firstname, lastname, longest_employee.startdate
	FROM
		(SELECT empid, MAX(startdate) AS startdate
		FROM currentemp
		GROUP BY empid, startdate
		ORDER BY startdate LIMIT 1) AS longest_employee
	INNER JOIN
		currentemp
	ON
		currentemp.empid = longest_employee.empid;
		