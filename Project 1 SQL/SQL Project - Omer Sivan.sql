-- Create Sales DB in master
use master
create database SalesTest
GO

/* PART 1 */
-- Use Sales DB for next code
use SalesTest

-- Start by creating a table which does not rely on any other tables for FK, like SalesTerritory
-- Then create the secondary tables which rely ONLY on the first table (SalesTerritory)

-- Create SalesTerritory Table
create table SalesTerritory (
	TerritoryID int not null Primary Key, --PK TerritoryID
	Name nvarchar(50) not null,
	CountryRegionCode nvarchar(3) not null,
	[Group] nvarchar(50) not null,
	SalesYTD money not null,
	SalesLastYear money not null,
	CostYTD money not null,
	CostLastYear money not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null
)

-- Create Customer Table
create table Customer (
	CustomerID int not null Primary Key, -- PK CustomerID
	PersonID int null,
	StoreID int null,
	TerritoryID int null, -- FK TerritoryID from SalesTerritory
	AccountNumber nvarchar(20) not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null,
	CONSTRAINT FK_TerritoryID_Customer FOREIGN KEY (TerritoryID)
	REFERENCES SalesTerritory(TerritoryID) -- connect TerritoryID FK from Salesterritory 
)

-- Create SalesPerson table
create table SalesPerson ( 
	BusinessEntityID int not null Primary Key, -- PK BusinessEntityID 
	TerritoryID int null, -- FK TerritoryID from SalesTerritory
	SalesQuota money null,
	Bonus money not null,
	CommissionPct smallmoney not null,
	SalesYTD money not null,
	SalesLastYear money not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null,
	CONSTRAINT FK_TerrotoryID_SalesPerson FOREIGN KEY (TerritoryID)
	REFERENCES SalesTerritory(TerritoryID) -- connect TerritoryID FK from SalesTerritory
)


-- Then create another table which does not rely on any other tables for FK
-- Create CreditCard TABLE 
create table CreditCard ( 
	CreditCardID int not null Primary Key, -- PK CreditCardID
	CardType nvarchar(50) not null,
	CardNumber nvarchar(25) not null,
	ExpMonth tinyint not null,
	ExpYear smallint not null,
	ModifiedDate datetime not null
)

-- Create SpecialOfferProduct table
create table SpecialOfferProduct (
	SpecialOfferID int not null, --PK parameter
	ProductID int not null, --PK parameter
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null,
	Primary Key(SpecialOfferID, ProductID) -- PK creation
)

-- Create CurrencyRate table
create table CurrencyRate ( 
	CurrencyRateID int not null Primary Key, -- PK for CUrrencyRate
	CurrencyRateDate datetime not null,
	FromCurrencyCode nchar(3) not null,
	ToCurrencyCode nchar(3) not null,
	AverageRate money not null,
	EndOfDayRate money not null,
	ModifiedDate datetime not null
)

-- Create ShipMethod(Purchasing) table
create table ShipMethod ( 
	ShipMethodID int not null Primary Key, -- PK for ShipMethod
	Name nvarchar(50) not null,
	ShipBase money not null,
	ShipRate money not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null
)

-- Create Address(Person) table
create table Address ( 
	AddressID int not null Primary Key, -- PK for Address
	AddressLine1 nvarchar(60) not null,
	AddressLine2 nvarchar(60) null,
	City nvarchar(30) not null,
	StateProvinceID int not null,
	PostalCode nvarchar(15) not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null
)

-- Create the final tables which rely on the tables created before.

-- Create SalesOrderHeader table
create table SalesOrderHeader ( 
	SalesOrderID int not null Primary Key, -- PK for SalesOrderHeader
	RevisionNumber tinyint not null,
	OrderDate datetime not null,
	DueDate datetime not null,
	ShipDate datetime null,
	Status tinyint not null,
	OnlineOrderFlag nvarchar(6) null, -- will be altered to bit not null as requested. at the end of the script.
	SalesOrderNumber nvarchar(50) not null,
	PurchaseOrderNumber nvarchar(50) null,
	AccountNumber nvarchar(50) null,
	CustomerID int not null, -- FK Customer
	SalesPersonID int null, -- FK SalesPerson
	TerritoryID int null, -- FK TerritoryID
	BillToAddressID int not null, -- FK From Address table
	ShipToAddressID int not null, -- FK From Address table
	ShipMethodID int not null, -- FK for ShipMethod
	CreditCardID int null, -- FK CreditCard
	CreditCardApprovalCode nvarchar(15) null,
	CurrencyRateID int null, -- FK CurrencyRate
	SubTotal money not null,
	TaxAmt money not null,
	Freight money not null,
	TotalDue money not null,
	Comment nvarchar(60) null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null,
	-- Constraints: Connect all foreign keys from tables as written below.
	CONSTRAINT FK_CustomerID_SOH FOREIGN KEY (CustomerID)
	REFERENCES Customer(CustomerID),
	CONSTRAINT FK_SalesPersonID_SOH FOREIGN KEY (SalesPersonID)
	REFERENCES SalesPerson(BusinessEntityID),
	CONSTRAINT FK_TerritoryID_SOH FOREIGN KEY (TerritoryID)
	REFERENCES SalesTerritory(TerritoryID),
	CONSTRAINT FK_CredotCardID_SOH FOREIGN KEY (CreditCardID)
	REFERENCES CreditCard(CreditCardID),
	CONSTRAINT FK_CurrencyRateID_SOH FOREIGN KEY (CurrencyRateID)
	REFERENCES CurrencyRate(CurrencyRateID),
	CONSTRAINT FK_B2Address_SOH FOREIGN KEY (BillToAddressID)
	REFERENCES Address(AddressID),
	CONSTRAINT FK_S2Address_SOH FOREIGN KEY (ShipToAddressID)
	REFERENCES Address(AddressID),
	CONSTRAINT FK_ShipMethodID_SOH FOREIGN KEY (ShipMethodID)
	REFERENCES ShipMethod(ShipMethodID)
)


-- Create SalesOrderDetails table
create table SalesOrderDetails( 
	SalesOrderID int not null, -- PK Parameter 1 and FK from SalesOrderHeader
	SalesOrderDetailID int not null, -- PK Parameter 2
	CarrierTrackingNumber nvarchar(25) null,
	OrderQty smallint not null,
	ProductID int not null, -- FK ProductID from SpecialOfferProduct
	SpecialOfferID int not null, -- FK SpecialOfferID from SpecialOfferProduct
	UnitPrice money not null,
	UnitPriceDiscount money not null,
	LineTotal money not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null,
	-- Constraints: Connect all foreign keys from tables as written below.
	CONSTRAINT FK_SalesOrderID_SalesOrderDetails FOREIGN KEY (SalesOrderID)
	REFERENCES SalesOrderHeader(SalesOrderID),
	CONSTRAINT FK_ProductIDandSpecialOfferID_SalesOrderDetails FOREIGN KEY (SpecialOfferID, ProductID)
	REFERENCES SpecialOfferProduct(SpecialOfferID, ProductID),
	Primary Key (SalesOrderID, SalesOrderDetailID), -- Create PK Paramters, one of which is the FK SalesOrderID
)


/* PART 2 - Import data from csv */

-- In this part I will create temporary tables to insert into them the data ->  
-- then I will insert the data from the temporary table to the original table ->
-- then I will drop the temp table.

-- I got a problem importing the OnlineOrderFlag into a bit column (mismatched variables error), so I imported the data as nvarchar(6) and then altered the column.

--Create a @path variable, type varchar(100) and hold the static url of the folder which we want to take the csv files from.
DECLARE @path varchar(100) = 'C:\Users\Omer David\Documents\John Bryce\SQL\'; -- Change path to the folder which the csv files are located in


-- Import Address.csv
-- Create a temp table to store data
create table #TempAddress (	
	AddressID int not null Primary Key, -- PK for Address
	AddressLine1 nvarchar(60) not null,
	AddressLine2 nvarchar(60) null,
	City nvarchar(30) not null,
	StateProvinceID int not null,
	PostalCode nvarchar(15) not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null
)


DECLARE @bulkAddress NVARCHAR(MAX) = -- Create a variable named bulk with the type nvarchar and maximum length. Insert to it a string
'BULK INSERT #TempAddress FROM ''' + -- Bulk Insert to #Temp table
@path + 'Address.csv' + -- Take the information from this file path
''' WITH (FIELDTERMINATOR = '';'', ROWTERMINATOR = ''\n'', FIRSTROW = 2);'; -- Indicators to read the csv
EXEC sp_executesql @bulkAddress; -- Execute the bulk function


-- Insert the data from the temp table to the real table
INSERT INTO Address
SELECT *
FROM #TempAddress ;

-- Delete the temp table 
DROP TABLE #TempAddress;



-- Import SalesTerritory.csv
-- Create a temp table to store data
create table #TempSalesTerritory (
	TerritoryID int not null Primary Key,
	Name nvarchar(50) not null,
	CountryRegionCode nvarchar(3) not null,
	[Group] nvarchar(50) not null,
	SalesYTD money not null,
	SalesLastYear money not null,
	CostYTD money not null,
	CostLastYear money not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null
)

DECLARE @bulkSalesTerritory NVARCHAR(MAX) = -- Create a variable named bulk with the type nvarchar and maximum length. Insert to it a string
'BULK INSERT #TempSalesTerritory FROM ''' + -- Bulk Insert to #Temp table
@path + 'SalesTerritory.csv' + -- Take the information from this file path
''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);'; -- Indicators to read the csv
EXEC sp_executesql @bulkSalesTerritory; -- Execute the bulk function


-- Insert the data from the temp table to the real table
INSERT INTO SalesTerritory(TerritoryID , Name , CountryRegionCode , [Group], SalesYTD, SalesLastYear, CostYTD, CostLastYear , rowguid , ModifiedDate)
SELECT *
FROM #TempSalesTerritory ;

-- Delete the temp table 
DROP TABLE #TempSalesTerritory;


-- Import Customer.csv
-- Create a temp table to store data
create table #TempCustomer (
	CustomerID int not null Primary Key, -- PK CustomerID
	PersonID int null,
	StoreID int null,
	TerritoryID int null, -- FK TerritoryID from SalesTerritory
	AccountNumber nvarchar(20) not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null,
)



DECLARE @bulkCustomer NVARCHAR(MAX) = -- Create a variable named bulk with the type nvarchar and maximum length. Insert to it a string
'BULK INSERT #TempCustomer FROM ''' + -- Bulk Insert to #Temp table
@path + 'Customer.csv' + -- Take the information from this file path
''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);'; -- Indicators to read the csv
EXEC sp_executesql @bulkCustomer; -- Execute the bulk function


-- Insert the data from the temp table to the real table
INSERT INTO Customer
SELECT *
FROM #TempCustomer ;

-- Delete the temp table 
DROP TABLE #TempCustomer;




-- Import SalesPerson.csv
-- Create a temp table to store data
create table #TempSalesPerson (
	BusinessEntityID int not null Primary Key, -- PK BusinessEntityID 
	TerritoryID int null, -- FK TerritoryID from SalesTerritory
	SalesQuota money null,
	Bonus money not null,
	CommissionPct smallmoney not null,
	SalesYTD money not null,
	SalesLastYear money not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null
)


DECLARE @bulkSalesPerson NVARCHAR(MAX) = -- Create a variable named bulk with the type nvarchar and maximum length. Insert to it a string
'BULK INSERT #TempSalesPerson FROM ''' + -- Bulk Insert to #Temp table
@path + 'SalesPerson.csv' + -- Take the information from this file path
''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);'; -- Indicators to read the csv
EXEC sp_executesql @bulkSalesPerson; -- Execute the bulk function



-- Insert the data from the temp table to the real table
INSERT INTO SalesPerson
SELECT *
FROM #TempSalesPerson ;

-- Delete the temp table 
DROP TABLE #TempSalesPerson;


-- Import CreditCard.csv
-- Create a temp table to store data
create table #TempCreditCard (
	CreditCardID int not null Primary Key, -- PK CreditCardID
	CardType nvarchar(50) not null,
	CardNumber nvarchar(25) not null,
	ExpMonth tinyint not null,
	ExpYear smallint not null,
	ModifiedDate datetime not null
)


DECLARE @bulkCreditCard NVARCHAR(MAX) = -- Create a variable named bulk with the type nvarchar and maximum length. Insert to it a string
'BULK INSERT #TempCreditCard FROM ''' + -- Bulk Insert to #Temp table
@path + 'CreditCard.csv' + -- Take the information from this file path
''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);'; -- Indicators to read the csv
EXEC sp_executesql @bulkCreditCard; -- Execute the bulk function


-- Insert the data from the temp table to the real table
INSERT INTO CreditCard
SELECT *
FROM #TempCreditCard ;

-- Delete the temp table 
DROP TABLE #TempCreditCard;


--*
-- Import SpecialOfferProduct.csv
-- Create a temp table to store data
create table #TempSOP (
	SpecialOfferID int not null, --PK parameter
	ProductID int not null, --PK parameter
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null,
	Primary Key(SpecialOfferID, ProductID) -- PK creation
)


DECLARE @bulkSOP NVARCHAR(MAX) = -- Create a variable named bulk with the type nvarchar and maximum length. Insert to it a string
'BULK INSERT #TempSOP FROM ''' + -- Bulk Insert to #Temp table
@path + 'SpecialOfferProduct.csv' + -- Take the information from this file path
''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);'; -- Indicators to read the csv
EXEC sp_executesql @bulkSOP; -- Execute the bulk function


-- Insert the data from the temp table to the real table
INSERT INTO SpecialOfferProduct
SELECT *
FROM #TempSOP ;

-- Delete the temp table 
DROP TABLE #TempSOP;


--*
-- Import CurrencyRate.csv
-- Create a temp table to store data
create table #TempCurrencyRate (
	CurrencyRateID int not null Primary Key, -- PK for CUrrencyRate
	CurrencyRateDate datetime not null,
	FromCurrencyCode nchar(3) not null,
	ToCurrencyCode nchar(3) not null,
	AverageRate money not null,
	EndOfDayRate money not null,
	ModifiedDate datetime not null
)


DECLARE @CurrencyRate NVARCHAR(MAX) = -- Create a variable named bulk with the type nvarchar and maximum length. Insert to it a string
'BULK INSERT #TempCurrencyRate FROM ''' + -- Bulk Insert to #Temp table
@path + 'CurrencyRate.csv' + -- Take the information from this file path
''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);'; -- Indicators to read the csv
EXEC sp_executesql @CurrencyRate; -- Execute the bulk function


-- Insert the data from the temp table to the real table
INSERT INTO CurrencyRate
SELECT *
FROM #TempCurrencyRate ;

-- Delete the temp table 
DROP TABLE #TempCurrencyRate;


--*
-- Import ShipMethod.csv
-- Create a temp table to store data
create table #TempShipMethod (
	ShipMethodID int not null Primary Key, -- PK for ShipMethod
	Name nvarchar(50) not null,
	ShipBase money not null,
	ShipRate money not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null
)


DECLARE @bulkShipMethod NVARCHAR(MAX) = -- Create a variable named bulk with the type nvarchar and maximum length. Insert to it a string
'BULK INSERT #TempShipMethod FROM ''' + -- Bulk Insert to #Temp table
@path + 'ShipMethod.csv' + -- Take the information from this file path
''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);'; -- Indicators to read the csv
EXEC sp_executesql @bulkShipMethod; -- Execute the bulk function

-- Insert the data from the temp table to the real table
INSERT INTO ShipMethod
SELECT *
FROM #TempShipMethod ;

-- Delete the temp table 
DROP TABLE #TempShipMethod;


--*
-- Import SalesOrderHeader.csv
-- Create a temp table to store data
create table #TempSOH (
	SalesOrderID int not null Primary Key, -- PK for SalesOrderHeader
	RevisionNumber tinyint not null,
	OrderDate datetime not null,
	DueDate datetime not null,
	ShipDate datetime null,
	Status tinyint not null,
	OnlineOrderFlagTEMP nvarchar(6) null,
	SalesOrderNumber nvarchar(50) not null,
	PurchaseOrderNumber nvarchar(50) null,
	AccountNumber nvarchar(50) null,
	CustomerID int not null, -- FK Customer
	SalesPersonID int null, -- FK SalesPerson
	TerritoryID int null, -- FK TerritoryID
	BillToAddressID int not null, -- FK From Address table
	ShipToAddressID int not null, -- FK From Address table
	ShipMethodID int not null, -- FK for ShipMethod
	CreditCardID int null, -- FK CreditCard
	CreditCardApprovalCode nvarchar(15) null,
	CurrencyRateID int null, -- FK CurrencyRate
	SubTotal money not null,
	TaxAmt money not null,
	Freight money not null,
	TotalDue money not null,
	Comment nvarchar(60) null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null
)


DECLARE @bulkSOH NVARCHAR(MAX) = -- Create a variable named bulk with the type nvarchar and maximum length. Insert to it a string
'BULK INSERT #TempSOH FROM ''' + -- Bulk Insert to #Temp table
@path + 'SalesOrderHeader.csv' + -- Take the information from this file path
''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);'; -- Indicators to read the csv
EXEC sp_executesql @bulkSOH; -- Execute the bulk function


-- Insert the data from the temp table to the real table
INSERT INTO SalesOrderHeader
SELECT *
FROM #TempSOH ;

-- Delete the temp table 
DROP TABLE #TempSOH


--*
-- Import SalesOrderDetail.csv
-- Create a temp table to store data
create table #TempSOD (
	SalesOrderID int not null, -- PK Parameter 1 and FK from SalesOrderHeader
	SalesOrderDetailID int not null, -- PK Parameter 2
	CarrierTrackingNumber nvarchar(25) null,
	OrderQty smallint not null,
	ProductID int not null, -- FK ProductID from SpecialOfferProduct
	SpecialOfferID int not null, -- FK SpecialOfferID from SpecialOfferProduct
	UnitPrice money not null,
	UnitPriceDiscount money not null,
	LineTotal money not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null
)


DECLARE @bulkSOD NVARCHAR(MAX) = -- Create a variable named bulk with the type nvarchar and maximum length. Insert to it a string
'BULK INSERT #TempSOD FROM ''' + -- Bulk Insert to #Temp table
@path + 'SalesOrderDetail.csv' + -- Take the information from this file path
''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);'; -- Indicators to read the csv
EXEC sp_executesql @bulkSOD; -- Execute the bulk function

-- Insert the data from the temp table to the real table
INSERT INTO SalesOrderDetails
SELECT *
FROM #TempSOD ;

-- Delete the temp table 
DROP TABLE #TempSOD
GO

-- Alter the column OnlineOrderFlag from the SalesOrderHeader table from nvarchar to bit as asked by the question. 
-- (DIDNT WORK TO IMPORT IT STRAIGHT TO BIT FOR SOME REASON, ONLY IMPORT STRING THEN ALTER LIKE I DID)
ALTER TABLE SalesOrderHeader ALTER COLUMN OnlineOrderFlag bit not null;
GO

/* Testing Lines
select * from SalesOrderHeader
--
select * from SalesOrderDetails
--
select * from Address
--
select * from CreditCard
--
select * from Customer
--
select * from SalesPerson
--
select * from SalesTerritory
--
select * from ShipMethod
--
select * from SpecialOfferProduct
*/