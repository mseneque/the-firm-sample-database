-- Matthew Seneque
-- 10401788

USE mrsenequ_CSI5135_TheFirm;

/* Query 1 – Accountant Search (2 marks)
   Write a query that selects all details of accountants who were hired before January 1st 2010, have a first name starting with “R”, and do not have a mentor.
*/

-- Write Query 1 here
SELECT Accountant_id
      ,Accountant_Name
	  ,Accountant_Phone
      ,ISNULL(Accountant_HireDate, 'n/a')
	  ,Branch_Name
      ,PayLevel_Name 
	  ,PayLevel_Salary 
	  ,ISNULL(Mentor_Name, 'n/a') AS 'Mentor_Name'
  FROM accountant_view 
 WHERE (Accountant_HireDate < '2010-01-01') AND (Accountant_Name LIKE 'R%') AND (Mentor_Name is NULL);


/* Query 2 – Job Type Statistics (2.5 marks)
   Write a query that selects the job type name, average cost, total cost and number of jobs, grouped by job type name.  
   Order the results by total cost (highest to lowest) and be sure to give all columns appropriate aliases.  
   Using your job view in this query is strongly recommended.
*/

-- Write Query 2 here
SELECT JobType_Name
	  ,COUNT(Jobtype_Name) AS 'Number_of_Jobs'
	  ,AVG(Job_Cost) AS 'Average_Job_Cost'
	  ,SUM(Job_Cost) AS 'Total_Job_Cost'
  FROM job_view
  GROUP BY JobType_Name
  ORDER BY Total_Job_Cost DESC;


/* Query 3 – Jobs Per Accountant (3 marks)
   Write a query that selects the accountant ID, accountant name and number of jobs done for all accountants.  
   Ensure that you results include accountants who have not done any jobs (they should have a count of 0).  
   Order the results by the number of jobs done, in descending order.
*/

-- Write Query 3 here
         
SELECT a.Accountant_id 
      ,Accountant_Firstname + ' ' + Accountant_Lastname AS 'Accountant_Name'
      ,COUNT(Job_id) AS 'Jobs_Done'		
  FROM Accountant AS a LEFT JOIN Job AS j
    ON a.Accountant_id = j.Accountant_id
 GROUP BY Accountant_Firstname, Accountant_Lastname, a.Accountant_id
 ORDER BY 'Jobs_Done' DESC


/* Query 4 – Overpaid Accountants (3 marks)
   Write a query that selects the accountant name, hire date, pay level name and expected experience of any accountants who have been working at the firm for less than the number of years expected for their pay level.  
   For example, an accountant at the “Senior Accountant” pay level who was hired less than 8 years ago would appear in the results of this query.
*/

-- Write Query 4 here
SELECT Accountant_Firstname + ' ' + Accountant_Lastname AS 'Accountant_Name'
	  ,Accountant_HireDate
	  ,PayLevel_Name
	  ,PayLevel_Experience 
  FROM Accountant AS a INNER JOIN PayLevel AS p
    ON a.PayLevel_id = p.PayLevel_id 
   AND PayLevel_Experience > DATEDIFF(YEAR, Accountant_HireDate, GETDATE());



/* Query 5 – Specialisations Available At Branch 2 (3.5 marks)
   Write a query that selects a distinct list of the job types specialised in by all accountants who work at branch number 2.  
   Since there are only 5 job types and accountants must specialise in at least 1 of them, your results should consist of between 1 and 5 job type names, depending on your data.  
   The same job type name should not appear multiple times in the results, even if multiple accountants specialise in it.  
   Order the results by job type name.
*/

-- Write Query 5 here
 SELECT DISTINCT JobType_Name	
  FROM Accountant AS a INNER JOIN Specialisations AS s
    ON a.Accountant_id = s.Accountant_id AND a.Branch_id = 2 JOIN JobType AS j 
    ON s.JobType_id = j.JobType_id
 ORDER BY JobType_Name


/* Query 6 – Job Descriptions (3.5 marks)
  Write a query that concatenates text and data from various columns to produce a single column that describes all jobs in the following way (column data has been indicated [like this]):
    “The [job type name] job for [client name] on [job date] took [job duration in hours] hours.”
  The job duration should be shown in hours, rounded to one decimal place – e.g.  A duration of 90 minutes would be shown as 1.5 hours.  
  Order the results by the job date.  Using your job view in this query is strongly recommended.  You will need to CAST/CONVERT the data type of some columns.

*/

-- Write Query 6 here

SELECT 'The ' + v.JobType_Name + ' job for ' + Client_Name + ' on ' + Cast(Job_DateTime AS varchar) + ' took ' + Cast(Convert(decimal(10,1), (Job_Duration/60.0)) AS varchar) + ' hours.' AS 'Job_Description'
FROM job_view As v LEFT JOIN JobType
ON v.JobType_id = JobType.JobType_id


/* Query 7 – Most Popular Accountants (4 marks)
   Write a query that selects the staff ID number and full name of the three most popular accountants, based upon how many clients prefer them 
   (i.e.  The three accountants who are most frequently listed by clients as their preferred accountant).  
   Your results should include the number of preferences they have received.
*/

-- Write Query 7 here
SELECT TOP 3 WITH TIES 
       Accountant_id
      ,Accountant_Firstname + ' ' + Accountant_Lastname AS 'Accountant_Name'
      ,Count(Preferred_Accountant) AS 'Preferences'		
FROM Accountant INNER JOIN Client
ON Accountant_id = Preferred_Accountant 
GROUP BY Accountant_id, Accountant_Firstname, Accountant_Lastname
ORDER BY 'Preferences' DESC



/* Query 8 – Clients Owing Payment (4 marks)
   Write a query that selects the client names, phone numbers, email addresses and total unpaid job costs of any clients who have a total (sum) of at least $1000 in unpaid jobs.  
   Order the results so that the largest amount owing is at the top.  Using your job view in this query is strongly recommended.

   Optional:  For an extra challenge, only include jobs that occurred over 1 month ago when determining the sum of unpaid jobs.  You can receive full marks for this query without doing this.
*/

-- Write Query 8 here
SELECT Client_Name 
      ,Client_Phone AS 'Phone_Number'
	  ,Client_Email AS 'E-mail'
	  ,Sum(Job_Cost) AS 'Payment_Owing'
  FROM job_view AS j INNER JOIN Client AS c
    ON j.Client_TFN = c.Client_TFN 
   AND Job_Paid = 'N' 
   AND DATEDIFF(MONTH, Job_DateTime, GETDATE()) > 1 -- This shows payments owing at jobs greater than 1 month old. 
 GROUP BY Client_Name, Client_Phone, Client_Email
HAVING Sum(Job_Cost) > 1000
 ORDER BY 'Payment_Owing' DESC;