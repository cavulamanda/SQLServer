*********************************************************************

Install AdventureWorksDW2014 multidimensional database from a project

*********************************************************************

This sample contains projects used to deploy an Analysis Services multidimensional database 
based on Adventure Works sample data. There are two projects in the sample: 
one for the enterprise edition and one for the standard edition of SQL Server 2014 or later. 
If you are using the Business Intelligence edition of SQL Server, use the enterprise project.

Requirements
Requirements to install and deploy the Adventure Works DW 2014 Multidimensional sample database and project:
1. SQL Server 2014 Analysis Services, deployed in multidimensional mode. For more information on requirements see Hardware and Software Requirements for Installing SQL Server 2014.
2. SQL Server Data Tools, a feature installed when installing SQL Server, used to create Analysis Services projects 
3. Read access to a copy of the AdventureWorksDW2014 database 

Demonstrates
Analysis Services Multidimensional capabilities.

Install the samples
1. Download the "adventure-works-2014-multidimensional-model-project" from https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2014.
2. Unzip the download folder. Note the location where the file was saved.

Test and validate the samples
1. Verify read access to the relational data source AdventureWorksDW2014.
   a. Open SQL Server Management Studio and connect to the Database Engine instance where the AdventureWorksDW2014 is located.
   b. Expand the Databases folder.
   c. Locate the AdventureWorksDW2014 database.
      Note: If the database is not visible try refreshing the database node. If the database is still not available check
	        that the database was installed and that appropriate permissions exist on the database instance. 
   d. Expand the AdventureWorksDW2014 database object and expand the Tables folder.
   e. Choose any table, right click on it, and click on Select Top 1000 rows.
   f. If the select statement successfully returns rows then the privileges needed to read data from
      the data source are appropriately set.
	  
2. Depending on the edition of SQL Server, open the Standard or Enterprise folder.
   If you are using the Business Intelligence, Developer or Evaluation editions choose the Enterprise project.
   
   Note: Admin permissions on the SSAS multidimensional instance are needed to run this solution. 
         For more information, see https://docs.microsoft.com/en-us/sql/analysis-services/instances/grant-server-admin-rights-to-an-analysis-services-instance .
		 
3. Double click the solution file AWDW2014Multidimensional-EE.sln to open the solution in SQL Server Data Tools.

   Note: If SQL Server Data Tools does not open then the feature was not correctly installed.
         Go over the setup process and add the SQL Server Data Tools feature to your installation.
		 
4. In Solution Explorer, locate the Data Source folder. Right click the Adventure Works2014.ds data source and from the context menu select Open.
5. In the connection string area click 'Edit'. The connection manager window will open.
   a. Verify the server name points to the server and instance where AdventureWorksDW2014 database is located.
   b. In the log on to the server area verify that the credentials are correct or update them as necessary.
   c. Verify connect to a database points to AdventureWorksDW2014.
   d. Click on Test Connection, and the connection should succeed
6. In the connection manager window select the Impersonation Information tab

   Note: If the service account does not have sufficient privileges, then choose another option.
   For more information, see https://docs.microsoft.com/en-us/sql/analysis-services/multidimensional-models/set-impersonation-options-ssas-multidimensional.
7. Right click the project object and select Properties.
8. In the navigation tree on the left pane select Deployment and verify the Server property is set to the 
   Analysis Services Multidimensional instance where you have administrator privileges. Click OK to save changes or Cancel to exit without changes.
9. Right click the project object again and select Show Deployment Progress. A Deployment Progress window will open.
10. Right click the project object again and select Deploy.
11. Watch the deployment progress until it comes to a successful end.

To test the deployed instance of the sample model:
1. Open SQL Server Management Studio and connect to the Analysis Services Multidimensional instance where you deployed the database.
2. Expand the Databases folder and locate AdventureWorksDW2014Multidimensional-EE or the AdventureWorksDW2014Multidimensional-SE. 
3. Expand the cubes folder. Right click on the Adventure Works cube, hover over New Query and select MDX. 
   a. Verify that Adventure Works is the selected cube in the query window.
   b. In the query window paste the following MDX expression:
   
      Select Non Empty [Date].[Calendar Year].members on rows,
      Non Empty [Product].[Product Categories].[Category].members on columns
      from [Adventure Works]
      where [Measures].[Sales Amount]

   c. Click the Execute button and results should appear after a moment.


***************************************************************************

Install AdventureWorksDW2014 multidimensional database from a backup file

***************************************************************************

This sample contains backup files used to deploy an Analysis Services multidimensional
database based on Adventure Works sample data. There are two projects in the sample.
One for the enterprise edition and one for the standard edition of SQL Server. If you
are using the Business Intelligence edition of SQL Server, use the enterprise project.

Install the samples

1. Download the "adventure-works-2014-multidimensional-full-database-backup.zip” from https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2014.
2. From File Download, click Save. 
3. Unzip the folder and extract the .abf file to a location that is available to the database instance.

   Note: The default 64-bit path is C:\Program Files\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Backup.
         Use C:\Program Files (x86)\... for 32-bit SQL Server 2014
		 
4. From SQL Server Management Studio connect to the 2014 Analysis Services Multidimensional instance.
5. With the instance selected, in the Standard toolbar click the New Query button. 
6. Execute the following code in the query window:

Note: The file paths in the scripts are the default paths and database names.
      The paths and database names may need to be updated to match your environment.

Enterprise Edition:

<Restore xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
 <File>C:\Program Files\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Backup\AdventureWorksDW2014Multidimensional-EE.abf</File>
 <DatabaseName> AdventureWorksDW2014Multidimensional-EE</DatabaseName>
 <AllowOverwrite>true</AllowOverwrite>
 <DbStorageLocation xmlns="http://schemas.microsoft.com/analysisservices/2008/engine/100/100">C:\Program Files\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Data\</DbStorageLocation>
</Restore>

Standard Edition:

<Restore xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
 <File>C:\Program Files\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Backup\AdventureWorksDW2014Multidimensional-SE.abf</File>
 <DatabaseName> AdventureWorksDW2014Multidimensional-SE</DatabaseName>
 <AllowOverwrite>true</AllowOverwrite>
 <DbStorageLocation xmlns="http://schemas.microsoft.com/analysisservices/2008/engine/100/100">C:\Program Files\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Data\</DbStorageLocation>
</Restore>

To test the deployed instance of the sample model:
1. Open SQL Server Management Studio and connect to the Analysis Services Multidimensional instance where you deployed the database.
2. Expand the Databases folder and locate AdventureWorksDW2014Multidimensional-EE or the AdventureWorksDW2014Multidimensional-SE. 
3. Expand the cubes folder. Right click on the Adventure Works cube, hover over New Query and select MDX. 
a. Verify that Adventure Works is the selected cube in the query window.
b. In the query window paste the following MDX expression:

   Select Non Empty [Date].[Calendar Year].members on rows,
   Non Empty [Product].[Product Categories].[Category].members on columns
   from [Adventure Works]
   where [Measures].[Sales Amount]

c. Click the Execute button and results should appear after a moment.




















