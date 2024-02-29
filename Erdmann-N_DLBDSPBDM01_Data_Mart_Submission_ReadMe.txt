Version Information:
====================
The SQL Scripts were created on MariaDB 10.6.
Compatibility was kept in mind during development so that they will also work on MySQL 8.0. 


Description:
=============
These SQL scripts create the database Rental_Bookings in a MariaDB or MySQL environment.
This includes all necessary tables and their foreign key relations to each other 
as well as mock data to populate the tables and simple queries to test the 
functionality of each table.
In addition, two queries which provide some metadata information about the database itself, are included.
The installation is split in two files. the first file, 01_DDL_DML_Script, creates and fills the database tables.
The second file 02_TestCases_Script provides queries for test cases.


Installation:
=============

1. Connect to MariaDB (or MySQL) in your preferred Database Management System
2. Open the file named "Erdmann-N_DLBDSPBDM01_Data_Mart_Submission_DDL_DML_Script.sql" and copy its complete content
3. Open a console or script window in your DMBS (with connection your database), paste the SQL code there and execute it. 
   The database will be created and filled with data.
4. Repeat steps 2 and 3 with the file "Erdmann-N_DLBDSPBDM01_Data_Mart_Submission_TestCases_Script.sql" to execute 
   the testqueries. 
5. Check the output of the test queries and the metadata

-----------------

2022-12-16, N-Erdmann
