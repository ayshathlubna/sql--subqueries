create database subqueries;
use subqueries;

create table department
(
	dept_id		int ,
	dept_name	varchar(50) PRIMARY KEY,
	location	varchar(100)
);
insert into department values (1, 'Admin', 'Bangalore');
insert into department values (2, 'HR', 'Bangalore');
insert into department values (3, 'IT', 'Bangalore');
insert into department values (4, 'Finance', 'Mumbai');
insert into department values (5, 'Marketing', 'Bangalore');
insert into department values (6, 'Sales', 'Mumbai');

CREATE TABLE EMPLOYEE
(
    EMP_ID      INT PRIMARY KEY,
    EMP_NAME    VARCHAR(50) NOT NULL,
    DEPT_NAME   VARCHAR(50) NOT NULL,
    SALARY      INT,
    constraint fk_emp foreign key(dept_name) references department(dept_name)
);
insert into employee values(101, 'Mohan', 'Admin', 4000);
insert into employee values(102, 'Rajkumar', 'HR', 3000);
insert into employee values(103, 'Akbar', 'IT', 4000);
insert into employee values(104, 'Dorvin', 'Finance', 6500);
insert into employee values(105, 'Rohit', 'HR', 3000);
insert into employee values(106, 'Rajesh',  'Finance', 5000);
insert into employee values(107, 'Preet', 'HR', 7000);
insert into employee values(108, 'Maryam', 'Admin', 4000);
insert into employee values(109, 'Sanjay', 'IT', 6500);
insert into employee values(110, 'Vasudha', 'IT', 7000);
insert into employee values(111, 'Melinda', 'IT', 8000);
insert into employee values(112, 'Komal', 'IT', 10000);
insert into employee values(113, 'Gautham', 'Admin', 2000);
insert into employee values(114, 'Manisha', 'HR', 3000);
insert into employee values(115, 'Chandni', 'IT', 4500);
insert into employee values(116, 'Satya', 'Finance', 6500);
insert into employee values(117, 'Adarsh', 'HR', 3500);
insert into employee values(118, 'Tejaswi', 'Finance', 5500);
insert into employee values(119, 'Cory', 'HR', 8000);
insert into employee values(120, 'Monica', 'Admin', 5000);
insert into employee values(121, 'Rosalin', 'IT', 6000);
insert into employee values(122, 'Ibrahim', 'IT', 8000);
insert into employee values(123, 'Vikram', 'IT', 8000);
insert into employee values(124, 'Dheeraj', 'IT', 11000);


CREATE TABLE employee_history
(
    emp_id      INT PRIMARY KEY,
    emp_name    VARCHAR(50) NOT NULL,
    dept_name   VARCHAR(50),
    salary      INT,
    location    VARCHAR(100),
    constraint fk_emp_hist_01 foreign key(dept_name) references department(dept_name),
    constraint fk_emp_hist_02 foreign key(emp_id) references employee(emp_id)
);

create table sales
(
	store_id  		int,
	store_name  	varchar(50),
	product_name	varchar(50),
	quantity		int,
	price	     	int
);
insert into sales values
(1, 'Apple Store 1','iPhone 13 Pro', 1, 1000),
(1, 'Apple Store 1','MacBook pro 14', 3, 6000),
(1, 'Apple Store 1','AirPods Pro', 2, 500),
(2, 'Apple Store 2','iPhone 13 Pro', 2, 2000),
(3, 'Apple Store 3','iPhone 12 Pro', 1, 750),
(3, 'Apple Store 3','MacBook pro 14', 1, 2000),
(3, 'Apple Store 3','MacBook Air', 4, 4400),
(3, 'Apple Store 3','iPhone 13', 2, 1800),
(3, 'Apple Store 3','AirPods Pro', 3, 750),
(4, 'Apple Store 4','iPhone 12 Pro', 2, 1500),
(4, 'Apple Store 4','MacBook pro 16', 1, 3500);

SELECT * FROM EMPLOYEE;
SELECT * FROM DEPARTMENT;
SELECT * FROM SALES;

-- SUBQUERIES
-- Find the employees who's salary is more than the average salary earned by all employees.
/* here we cannot directly extract the employees whose salary is greater than average salary.
so we find avg salary using a query and using that query as a subquery to the main query) */

SELECT * FROM EMPLOYEE
WHERE SALARY> (SELECT AVG(salary) AS avg_salary FROM employee);

-- scalar subquery 
-- Find the employees who's salary is more than the average salary earned by all employees.
SELECT *
FROM EMPLOYEE E
JOIN (SELECT AVG(salary) AS avg_salary FROM employee) AVERAGE
ON E.SALARY > AVERAGE.avg_salary;

-- multiple row subquery

-- MULTIPLE COLUMN , MULTIPLE ROW
-- Find the employees who earn the highest salary in each department. 

SELECT DEPT_NAME,MAX(SALARY) AS MAX_SALARY 
FROM EMPLOYEE 
GROUP BY DEPT_NAME;

SELECT * FROM EMPLOYEE
WHERE (DEPT_NAME,SALARY) IN (SELECT DEPT_NAME,MAX(SALARY) AS MAX_SALARY 
	FROM EMPLOYEE 
	GROUP BY DEPT_NAME);

-- SINGLE COLUMN MULTIPLE ROW
-- Find department who do not have any employees

SELECT DEPT_NAME FROM DEPARTMENT
WHERE DEPT_NAME NOT IN (SELECT DISTINCT DEPT_NAME FROM EMPLOYEE);

-- correlated subquery
-- Find the employees in each department who earn more than the average salary in that department. 

SELECT * 
FROM EMPLOYEE E1
WHERE SALARY > (SELECT AVG(SALARY) 
				FROM EMPLOYEE E2
                WHERE E1.DEPT_NAME = E2.DEPT_NAME);
                
-- Find department who do not have any employees using correlated sub query

select dept_name 
from department d
where not exists (select dept_name
				from employee e
                where e.dept_name=d.dept_name);
                
-- nested subquery
-- Find stores who's sales where better than the average sales accross all stores 

select *
from (select store_name, sum(price) as total_sales
from sales
group by store_name) sales
where sales.total_sales >(
select avg(total.total_sales)
from 
(select store_name, sum(price) as total_sales
from sales
group by store_name) total);

select *
from (select store_name, sum(price) as total_sales
from sales
group by store_name) sales
join (
select avg(total.total_sales) as avg_sales
from 
(select store_name, sum(price) as total_sales
from sales
group by store_name) total) average
on sales.total_sales>average.avg_sales;

(select *
from (select store_name, sum(price) as total_sales
from sales
group by store_name) sales
join (
select avg(total.total_sales) as avg_sales
from 
(select store_name, sum(price) as total_sales
from sales
group by store_name) total) average
on sales.total_sales>average.avg_sales);


-- the difference in the result of above 2 queries is that when you use join clause , it will consider the result of subquery as table and will be joined with the result of main query,

-- USING SUBQUERY IN SELECT CLAUSE 

-- Fetch all employee details and add remarks to those employees who earn more than the average pay.
SELECT E.*, CASE WHEN E.SALARY > (SELECT AVG(SALARY) FROM EMPLOYEE)
				THEN 'Above average salary'
				ELSE NULL
			END REMARKS		
FROM EMPLOYEE E;
                
-- USING SUBQUERY IN HAVING CLAUSE
-- Find the stores who have sold more units than the average units sold by all stores. 

SELECT STORE_NAME, SUM(QUANTITY) AS TOTAL_QTY
FROM SALES
GROUP BY STORE_NAME
HAVING TOTAL_QTY> (SELECT AVG(QUANTITY) FROM SALES);

-- IN INSERT COMMAND
-- Insert data to employee history table. Make sure not insert duplicate records

INSERT INTO EMPLOYEE_HISTORY
SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_NAME, E.SALARY, D.LOCATION
FROM EMPLOYEE E
JOIN DEPARTMENT D
ON E.DEPT_NAME = D.DEPT_NAME
WHERE NOT EXISTS (SELECT 1 
					FROM EMPLOYEE_HISTORY EH
                    WHERE EH.EMP_ID = E.EMP_ID);
                    
SELECT * FROM EMPLOYEE_HISTORY;

-- WITH UPDATE STATEMENT
/* Give 10% increment to all employees in Bangalore location based on the maximum
salary earned by an emp in each dept. Only consider employees in employee_history table. */

UPDATE EMPLOYEE E
SET SALARY = (SELECT MAX(SALARY)+ (MAX(SALARY)* 0.1)
			  FROM EMPLOYEE_HISTORY EH
              WHERE EH.EMP_ID = E.EMP_ID)
WHERE DEPT_NAME IN (SELECT DEPT_NAME 
					FROM DEPARTMENT)
	  AND E.EMP_ID IN (SELECT EMP_ID FROM EMPLOYEE_HISTORY);
      
SELECT * FROM EMPLOYEE;

-- DELETE STATEMENT
-- Delete all departments who do not have any employees. 

DELETE FROM DEPARTMENT D1
WHERE DEPT_NAME IN (SELECT DEPT_NAME 
					FROM DEPARTMENT D2
					WHERE NOT EXISTS (SELECT 1
									 FROM EMPLOYEE E
                                     WHERE E.DEPT_NAME = D2.DEPT_NAME));


DELETE FROM department
WHERE dept_name IN (
    SELECT dept_name FROM (
        SELECT dept_name 
        FROM department d
        WHERE NOT EXISTS (
            SELECT 1 
            FROM employee e
            WHERE e.dept_name = d.dept_name
        )
    ) AS derived_table
);

SELECT * FROM DEPARTMENT;