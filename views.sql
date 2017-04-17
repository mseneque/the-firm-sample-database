-- Matthew Seneque
-- 10401788

USE mrsenequ_CSI5135_TheFirm;


DROP VIEW accountant_view;
DROP VIEW job_view;
GO

/* Accountant View (2 marks)
   Create a view which shows all details of all accountants.  
   The view should include the full name of their mentor (if they have one), as well as the name of the branch they work in, the name of their pay level and their annual salary.
*/

-- The Accountant View below contains relevant information to each Accountant.
CREATE VIEW accountant_view
AS SELECT a.Accountant_id
         ,a.Accountant_Firstname + ' ' + a.Accountant_Lastname AS 'Accountant_Name'
	     ,a.Accountant_Phone
	     ,a.Accountant_HireDate
		 ,a.Mentor_Accountant
         ,m.Accountant_Firstname + ' ' + m.Accountant_Lastname as 'Mentor_Name'  
	     ,b.Branch_id
		 ,b.Branch_Name
		 ,b.Branch_Address
		 ,b.Branch_Phone
	     ,p.PayLevel_id
		 ,p.PayLevel_Name
	     ,p.PayLevel_Salary
		 ,p.PayLevel_Experience 
	 FROM Accountant as a LEFT JOIN Accountant as m
       ON a.Mentor_Accountant = m.Accountant_id LEFT JOIN Branch as b
	   ON a.Branch_id = b.Branch_id LEFT JOIN PayLevel as p
	   ON a.PayLevel_id = p.PayLevel_id;


GO
/* Job View (2.5 marks)
   Create a view which shows all details of all jobs.  As well as all details of jobs, the view should contain the following columns:
     • The full name of the accountant and the full name of the client.  (Concatenate the first name and last name into one column, e.g. “Joe Bloggs”.)
     • The name of the job type
     • A column named “job_cost”, which multiplies the job duration by the Cost Per Minute in the job type table.
*/

-- The Job View below contains relevant information to each job.

CREATE VIEW job_view
AS SELECT Job.Job_id AS 'Job_id'
         ,Job.Accountant_id
         ,Job.Client_TFN
         ,Job.Job_DateTime
         ,Job.Job_Duration
         ,Job.Job_Paid
	     ,Job.JobType_id
	     ,Accountant.Accountant_Firstname + ' ' + Accountant.Accountant_Lastname AS 'Accountant_Name'
	     ,Client.Client_Firstname + ' ' + Client.Client_Lastname AS 'Client_Name'	
  	     ,JobType.JobType_Name AS 'JobType_Name'
	     ,JobType.JobType_CostPM * Job.Job_Duration AS 'Job_Cost'
     FROM Job LEFT JOIN Accountant 
	   ON Job.Accountant_id = Accountant.Accountant_id LEFT JOIN JobType 
	   ON Job.JobType_id = JobType.JobType_id LEFT JOIN Client
	   ON Job.Client_TFN = Client.Client_TFN;
