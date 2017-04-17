-- Matthew Seneque
-- 10401788

--  **************************************************************************************
--  We first check if the database exists, and drop it if it does.

--  Setting the active database to the built in 'master' database ensures that we are not trying to drop the currently active database.
--  Setting the database to 'single user' mode ensures that any other scripts currently using the database will be disconnectetd.
--  This allows the database to be deleted, instead of giving a 'database in use' error when trying to delete it.

IF DB_ID('mrsenequ_CSI5135_TheFirm') IS NOT NULL             
	BEGIN
		PRINT 'Database exists - dropping.';
		
		USE master;		
		ALTER DATABASE mrsenequ_CSI5135_TheFirm SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		
		DROP DATABASE mrsenequ_CSI5135_TheFirm;
	END

GO

--  Now that we are sure the database does not exist, we create it.

PRINT 'Creating database.';

CREATE DATABASE mrsenequ_CSI5135_TheFirm;

GO

--  Now that an empty database has been created, we will make it the active one.
--  The table creation statements that follow will therefore be executed on the newly created database.

USE mrsenequ_CSI5135_TheFirm;

GO

/*	Database Creation & Population Script (8 marks)
	Produce a script to create the database you designed in Task 1 (incorporating any changes you have made since then).  
	Be sure to give your columns the same data types, properties and constraints specified in your data dictionary, and be sure to name tables and columns consistently.  
	Include any logical and correct default values and any check or unique constraints that you feel are appropriate.

	Make sure this script can be run multiple times without resulting in any errors (hint: drop the database if it exists before trying to create it).  
	You can use/adapt the code at the start of the creation scripts of the sample databases available in the unit materials to implement this.

	See the assignment brief for further information. 
*/

-- Write your creation script here


/**********************************************************************************************************************/
/*                                            CREATE TABLES                                                           */
/**********************************************************************************************************************/

-- Create the Branch table. 
CREATE TABLE Branch
(  Branch_id SMALLINT NOT NULL CONSTRAINT branch_pk PRIMARY KEY IDENTITY,
   Branch_Name VARCHAR(50) NOT NULL UNIQUE,
   Branch_Address TEXT NOT NULL,
   Branch_Phone VARCHAR(25) NOT NULL 
);

-- Create the PayLevel table.
CREATE TABLE PayLevel
(  PayLevel_id TINYINT NOT NULL CONSTRAINT paylevel_pk PRIMARY KEY IDENTITY,
   PayLevel_Name VARCHAR(50) NOT NULL UNIQUE,
   PayLevel_Salary MONEY NOT NULL CHECK (PayLevel_Salary >= 0) DEFAULT 45000,
   PayLevel_Experience TINYINT NOT NULL DEFAULT 0
);

-- Create the JobType Table
CREATE TABLE JobType
(  JobType_id SMALLINT NOT NULL CONSTRAINT jobtype_pk PRIMARY KEY IDENTITY, 
   JobType_Name VARCHAR(50) NULL UNIQUE,
   JobType_CostPM MONEY NOT NULL CHECK (JobType_CostPM >= 0) DEFAULT 0
);

-- Create the Accountant table.
CREATE TABLE Accountant
(  Branch_id SMALLINT NOT NULL CONSTRAINT accountant_branch_fk FOREIGN KEY REFERENCES Branch(Branch_id),
   PayLevel_id TINYINT NOT NULL CONSTRAINT accountant_paylevel_fk FOREIGN KEY REFERENCES PayLevel(PayLevel_id),
   Mentor_Accountant SMALLINT NULL CONSTRAINT accountant_accountant_fk FOREIGN KEY REFERENCES Accountant(Accountant_id),
   Accountant_id SMALLINT NOT NULL CONSTRAINT accountant_pk PRIMARY KEY IDENTITY,
   Accountant_Firstname VARCHAR(50) NOT NULL,
   Accountant_Lastname VARCHAR(50) NOT NULL,
   Accountant_Phone VARCHAR(25) NOT NULL,
   Accountant_HireDate DATE NULL
);

-- Create the Client table.
CREATE TABLE Client
(  Preferred_Accountant SMALLINT NULL CONSTRAINT client_prefaccountant_fk FOREIGN KEY REFERENCES Accountant(Accountant_id),
   Client_TFN VARCHAR(15) NOT NULL CONSTRAINT client_pk PRIMARY KEY CHECK (LEN(Client_TFN) = 9 ),
   Client_Firstname VARCHAR(50) NOT NULL,
   Client_Lastname VARCHAR(50) NOT NULL,
   Client_Phone VARCHAR(25) NULL,
   Client_Email VARCHAR(50) NULL CHECK (Client_Email LIKE '_%@_%._%')
);

-- Create the Job table
CREATE TABLE Job
(  JobType_id SMALLINT NOT NULL CONSTRAINT job_jobtype_fk FOREIGN KEY REFERENCES JobType(JobType_id),
   Accountant_id SMALLINT NOT NULL CONSTRAINT job_accountant_fk FOREIGN KEY REFERENCES Accountant(Accountant_id),
   Client_TFN VARCHAR(15) NOT NULL CONSTRAINT job_client_fk FOREIGN KEY REFERENCES Client(Client_TFN),
   Job_id INT NOT NULL CONSTRAINT job_pk PRIMARY KEY IDENTITY,
   Job_DateTime SMALLDATETIME NULL,
   Job_Duration INT NOT NULL CHECK (Job_Duration >= 15),
   Job_Paid CHAR(1) NOT NULL CHECK (Job_Paid IN ('Y', 'N'))
);

-- Create the Specialisations table.
CREATE TABLE Specialisations
(  JobType_id SMALLINT NOT NULL CONSTRAINT spec_jobtype_fk FOREIGN KEY REFERENCES JobType(JobType_id), 
   Accountant_id SMALLINT NOT NULL CONSTRAINT spec_accountant_fk FOREIGN KEY REFERENCES Accountant(Accountant_id)
   CONSTRAINT spec_pk PRIMARY KEY (JobType_id, Accountant_id)
); 


/*  Database Population Statements
    Following the SQL statements to create your database and its tables, you must include statements to populate the database with sufficient test data.

    Add the INSERT statements you write to the end of the create.sql file as you work through the views and queries.  
    The final create.sql should be able to create your database and populate it with enough data to make sure that all views and queries return meaningful results.
*/

-- Write your insert statements here

--  **************************************************************************************
--  Now that the database tables have been created, we can populate them with data
--  **************************************************************************************

-- Populate the Branch table
SET IDENTITY_INSERT Branch ON;
INSERT INTO Branch (Branch_id, Branch_Name, Branch_Address, Branch_Phone)
VALUES ( 1, 'Joondalup', '123 blah blah st', '8008135'),
	   ( 2, 'Mt Lawley', '456 jeepers creepers', '2314-1516');
SET IDENTITY_INSERT Branch OFF;


-- Populate the Paylevel table
SET IDENTITY_INSERT PayLevel ON;
INSERT INTO PayLevel (PayLevel_id, PayLevel_Name, PayLevel_Salary, PayLevel_Experience)
VALUES (1, 'Trainee',           45000, 0),
       (2, 'Junior Accountant', 60000, 1),
	   (3, 'Accountant',        75000, 4),
	   (4, 'Senior Accountant', 95000, 8);
SET IDENTITY_INSERT PayLevel OFF;


-- Populate the JobType table
SET IDENTITY_INSERT JobType ON;
INSERT INTO JobType (JobType_id, JobType_Name, JobType_CostPM)
VALUES (1, 'Tax Return',          4.00),
       (2, 'Financial Planning',  5.00),
	   (3, 'Retirement Planning', 5.00),
	   (4, 'Litigation Support',  7.50),
	   (5, 'Miscellaneous',       6.50);
SET IDENTITY_INSERT JobType OFF;


-- Populate the Accountant table
SET IDENTITY_INSERT Accountant ON;
INSERT INTO Accountant (Branch_id, PayLevel_id, Mentor_Accountant, Accountant_id, Accountant_Firstname, Accountant_Lastname, Accountant_Phone, Accountant_HireDate)
VALUES (1, 4, NULL,  1, 'Wanda',   'Parsons',   '555-681', '2001-01-31'),
       (1, 3, NULL,  2, 'Eleanor', 'Thornton',  '555-672', '2013-02-21'),
	   (1, 3, NULL,  3, 'Rhianna', 'Craig',     '555-684', '2006-02-23'),
	   (1, 2, 2,     4, 'Melody',  'Henderson', '555-544', '2014-03-14'),
	   (1, 1, 3,     5, 'Racheal', 'Buchanan',  '555-899', '2016-04-11'),
       (2, 4, NULL,  6, 'Sheila',  'Stokes',    '555-315', '2012-01-22'),
	   (2, 3, NULL,  7, 'Reagan',  'Bates',     '555-148', '2001-02-17'),
	   (2, 3, NULL,  8, 'Estelle', 'Ruiz',      '555-413', '2012-02-12'),
	   (2, 2, 7,     9, 'Alice',   'Flores',    '555-743', '2014-03-27'),
	   (2, 2, 7,    10, 'Bernard', 'Green',     '555-744', '2014-03-16'),
	   (2, 1, 8,    11, 'Marty',   'Tucker',    '555-448', '2016-03-16');
SET IDENTITY_INSERT Accountant OFF;

-- Populate the Client table
INSERT INTO Client (Preferred_Accountant, Client_TFN, Client_Firstname, Client_Lastname, Client_Phone, Client_Email)
VALUES (2,    111111101, 'Spencer', 'McKinney', '666-6871', 'spence123@email.com'      ),
       (NULL, 111111102, 'Roger',   'Osbourne', '666-6732', 'ridgy123@email.com'       ),
	   (3,    111111103, 'Kristy',  'Hall',     '666-6844', 'krusty-brown123@email.com'),
	   (3,    111111104, 'Heather', 'King',     '666-5434', 'kingggg@email.com'        ),
	   (9,    111111105, 'May',     'Carlson',  '666-8989', 'clackson@email.com'       ),
       (NULL, 111111106, 'Darrin',  'McGee',    '666-3335', 'spf3fds@email.com'        ),
	   (9,    111111107, 'Jeff',    'Day',      '666-1448', 'daisy@email.com'          ),
	   (9,    111111108, 'Jennie',  'Love',     '666-4137', 'j-lo@email.com'           ),
	   (1,    111111109, 'Jon',     'Malone',   '666-7439', 'mr@email.com.au'          ),
	   (1,    111111110, 'Andrew',  'Gardener', '666-7644', 'andy.pansy@email.com'     );


-- Populate the Specialisations table
INSERT INTO Specialisations (JobType_id, Accountant_id)
VALUES (1,  1),
       (2,  1),
	   (5,  1),
	   (3,  2),
	   (4,  3),
       (3,  6),
       (4,  6),
	   (5,  6),
	   (2,  7),
	   (2,  8),
	   (5, 10);

/*  The following statement inserts the details of 100 jobs into a table named "job".  
    It specifies the following column data:
      1) Staff ID numbers between 1 and 10.
      2) Client Tax File Numbers between 111111101 and 111111110.
      3) Job Type ID numbers between 1 and 5.
      4) Job Date/Times roughly within business hours over the last couple of years.
      5) Job Durations between 15 and 360.
      6) Paid values of "Y" or "N".
  
    You will need to insert details of accountants, clients and job types before you can insert job details.
    Make sure that the IDs of your accountants, clients and job types match those specified above so that the foreign key relationships are upheld.
    Make sure that the data types of the columns in your job table are able to store the data being inserted.
    Change the column names in the statement below to match the column names in your job table if needed.
*/


INSERT INTO Job (Accountant_id, Client_TFN, JobType_id, Job_DateTime, Job_Duration, Job_Paid)
VALUES (3,  111111108, 5, '2014-11-02 14:40:00', 47,  'Y'),
       (6,  111111103, 2, '2014-06-28 13:15:00', 68,  'Y'),
       (4,  111111103, 5, '2016-01-14 14:36:00', 277, 'N'),
       (4,  111111102, 2, '2015-08-25 10:53:00', 119, 'N'),
       (5,  111111102, 4, '2014-07-24 13:10:00', 221, 'Y'),
       (10, 111111102, 1, '2015-10-08 15:28:00', 106, 'Y'),
       (1,  111111110, 3, '2014-11-02 16:21:00', 173, 'Y'),
       (5,  111111103, 2, '2014-03-26 11:35:00', 42,  'Y'),
       (5,  111111104, 4, '2014-11-24 10:52:00', 26,  'Y'),
       (3,  111111107, 4, '2015-10-05 11:19:00', 359, 'N'),
       (7,  111111101, 5, '2015-07-17 12:45:00', 253, 'Y'),
       (7,  111111108, 4, '2014-03-11 15:52:00', 216, 'Y'),
       (9,  111111109, 5, '2014-01-31 14:53:00', 118, 'Y'),
       (9,  111111110, 2, '2015-04-24 16:36:00', 180, 'Y'),
       (5,  111111101, 5, '2015-10-07 16:10:00', 342, 'Y'),
       (10, 111111103, 5, '2015-07-12 16:09:00', 126, 'Y'),
       (4,  111111108, 1, '2014-12-26 09:34:00', 298, 'Y'),
       (8,  111111107, 5, '2014-07-11 10:53:00', 25,  'Y'),
       (10, 111111108, 5, '2014-08-06 16:18:00', 272, 'Y'),
       (10, 111111106, 1, '2015-07-25 16:52:00', 87,  'Y'),
       (4,  111111104, 1, '2014-07-07 10:19:00', 136, 'Y'),
       (10, 111111109, 1, '2014-08-27 12:55:00', 48,  'Y'),
       (4,  111111110, 5, '2015-01-03 10:45:00', 339, 'Y'),
       (4,  111111105, 1, '2014-04-02 10:43:00', 330, 'N'),
       (7,  111111101, 5, '2014-04-05 10:04:00', 285, 'Y'),
       (7,  111111103, 1, '2014-11-02 11:13:00', 113, 'Y'),
       (1,  111111101, 4, '2016-04-29 13:14:00', 132, 'Y'),
       (8,  111111109, 1, '2014-07-06 11:02:00', 155, 'Y'),
       (7,  111111108, 3, '2014-11-19 16:35:00', 91,  'Y'),
       (6,  111111108, 3, '2015-02-01 10:50:00', 244, 'Y'),
       (6,  111111104, 1, '2014-07-09 13:09:00', 207, 'Y'),
       (4,  111111109, 2, '2015-01-09 13:20:00', 236, 'Y'),
       (10, 111111109, 2, '2014-07-29 12:25:00', 277, 'Y'),
       (3,  111111107, 3, '2015-07-17 15:00:00', 149, 'Y'),
       (10, 111111105, 2, '2015-12-23 10:55:00', 163, 'Y'),
       (10, 111111104, 2, '2016-04-21 16:53:00', 186, 'N'),
       (7,  111111109, 5, '2014-09-24 17:28:00', 176, 'Y'),
       (3,  111111102, 1, '2014-08-28 17:27:00', 341, 'Y'),
       (10, 111111107, 4, '2016-03-08 14:37:00', 341, 'N'),
       (4,  111111108, 5, '2015-08-18 13:14:00', 59,  'N'),
       (9,  111111108, 1, '2014-10-27 09:48:00', 91,  'Y'),
       (8,  111111110, 2, '2014-09-26 10:09:00', 318, 'Y'),
       (7,  111111105, 4, '2016-03-24 17:36:00', 295, 'N'),
       (5,  111111109, 2, '2014-01-04 12:59:00', 150, 'Y'),
       (4,  111111102, 1, '2014-07-27 11:51:00', 87,  'Y'),
       (3,  111111101, 5, '2014-01-06 15:50:00', 47,  'Y'),
       (9,  111111107, 1, '2015-05-07 11:12:00', 324, 'Y'),
       (7,  111111103, 3, '2015-07-31 17:25:00', 222, 'N'),
       (7,  111111110, 5, '2014-03-01 16:03:00', 236, 'Y'),
       (9,  111111110, 3, '2015-07-01 10:46:00', 48,  'Y'),
       (9,  111111102, 2, '2015-03-28 16:40:00', 245, 'Y'),
       (7,  111111110, 5, '2016-04-08 09:29:00', 294, 'Y'),
       (3,  111111110, 5, '2015-10-26 09:03:00', 293, 'N'),
       (10, 111111104, 5, '2015-09-13 10:08:00', 158, 'Y'),
       (10, 111111110, 1, '2015-11-08 12:41:00', 292, 'Y'),
       (1,  111111103, 5, '2016-03-23 13:48:00', 347, 'Y'),
       (10, 111111102, 3, '2015-12-02 17:08:00', 247, 'Y'),
       (9,  111111105, 1, '2016-04-04 10:19:00', 180, 'Y'),
       (4,  111111102, 2, '2014-03-16 15:49:00', 109, 'Y'),
       (1,  111111101, 5, '2016-01-12 12:42:00', 253, 'N'),
       (3,  111111107, 4, '2014-10-30 15:15:00', 289, 'Y'),
       (9,  111111101, 1, '2015-03-08 17:20:00', 155, 'Y'),
       (3,  111111104, 1, '2014-10-08 09:36:00', 225, 'Y'),
       (7,  111111107, 2, '2014-07-27 12:47:00', 294, 'Y'),
       (3,  111111108, 5, '2016-01-04 10:19:00', 265, 'Y'),
       (5,  111111105, 1, '2016-01-15 17:26:00', 38,  'N'),
       (7,  111111110, 3, '2015-01-20 10:29:00', 72,  'Y'),
       (4,  111111109, 2, '2015-06-25 15:11:00', 75,  'Y'),
       (8,  111111103, 3, '2014-10-23 12:59:00', 148, 'Y'),
       (3,  111111104, 2, '2014-09-04 15:01:00', 229, 'Y'),
       (7,  111111107, 2, '2014-02-22 10:30:00', 251, 'Y'),
       (9,  111111101, 5, '2014-04-29 12:32:00', 334, 'N'),
       (2,  111111109, 2, '2015-11-18 09:58:00', 150, 'Y'),
       (6,  111111107, 4, '2015-06-10 09:41:00', 133, 'Y'),
       (7,  111111107, 5, '2015-01-09 13:43:00', 38,  'Y'),
       (3,  111111109, 2, '2015-02-08 13:38:00', 313, 'Y'),
       (2,  111111108, 2, '2014-07-20 12:29:00', 74,  'Y'),
       (3,  111111104, 2, '2016-04-23 14:48:00', 22,  'Y'),
       (6,  111111109, 2, '2014-12-12 11:02:00', 337, 'Y'),
       (9,  111111104, 1, '2015-03-07 12:10:00', 308, 'Y'),
       (1,  111111108, 4, '2014-03-03 14:14:00', 240, 'Y'),
       (1,  111111102, 5, '2015-08-17 11:34:00', 237, 'Y'),
       (4,  111111107, 4, '2014-05-03 11:50:00', 321, 'Y'),
       (3,  111111107, 5, '2014-04-07 13:40:00', 15,  'N'),
       (4,  111111107, 1, '2015-02-01 11:47:00', 52,  'Y'),
       (9,  111111110, 3, '2016-04-21 13:07:00', 166, 'N'),
       (7,  111111106, 2, '2014-08-30 12:43:00', 15,  'Y'),
       (1,  111111102, 3, '2015-11-19 09:18:00', 150, 'Y'),
       (1,  111111102, 4, '2014-03-12 15:24:00', 112, 'Y'),
       (1,  111111110, 2, '2014-12-31 09:08:00', 141, 'Y'),
       (9,  111111105, 2, '2014-10-29 11:42:00', 270, 'N'),
       (5,  111111110, 2, '2014-01-17 10:54:00', 206, 'Y'),
       (1,  111111103, 3, '2015-02-26 09:50:00', 50,  'Y'),
       (6,  111111101, 1, '2015-07-23 09:58:00', 100, 'Y'),
       (1,  111111102, 5, '2015-10-18 15:41:00', 141, 'Y'),
       (9,  111111105, 2, '2014-09-25 13:44:00', 22,  'Y'),
       (6,  111111105, 2, '2016-02-08 09:16:00', 280, 'Y'),
       (5,  111111106, 1, '2016-04-07 13:34:00', 331, 'Y'),
       (8,  111111108, 3, '2014-12-13 12:27:00', 163, 'Y'),
       (4,  111111110, 5, '2016-02-23 11:52:00', 287, 'N');
