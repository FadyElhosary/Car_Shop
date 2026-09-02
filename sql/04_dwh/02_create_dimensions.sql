/* Car Shop - DWH Dimensions */

CREATE SCHEMA dwh;
GO

CREATE TABLE dwh.DIM_Date
(
    Date_Key INT NOT NULL PRIMARY KEY,
    Full_Date DATE NOT NULL UNIQUE,
    Day_Number TINYINT NOT NULL,
    Day_Name VARCHAR(20) NOT NULL,
    Week_Number TINYINT NOT NULL,
    Month_Number TINYINT NOT NULL,
    Month_Name VARCHAR(20) NOT NULL,
    Quarter_Number TINYINT NOT NULL,
    Quarter_Name VARCHAR(10) NOT NULL,
    Year_Number SMALLINT NOT NULL,
    Is_Weekend BIT NOT NULL
);
GO

CREATE TABLE dwh.DIM_Customer
(
    Customer_Key INT IDENTITY(1,1) PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Customer_Name VARCHAR(150) NOT NULL,
    Email VARCHAR(200) NULL,
    Phone VARCHAR(50) NULL,
    City VARCHAR(100) NULL,
    Country VARCHAR(100) NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NULL,
    Is_Latest BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE dwh.DIM_Product
(
    Product_Key INT IDENTITY(1,1) PRIMARY KEY,
    Product_ID INT NOT NULL,
    Product_Name VARCHAR(200) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Brand VARCHAR(100) NOT NULL,
    Unit_Cost DECIMAL(18,2) NOT NULL,
    Unit_Price DECIMAL(18,2) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NULL,
    Is_Latest BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE dwh.DIM_Store
(
    Store_Key INT IDENTITY(1,1) PRIMARY KEY,
    Store_ID INT NOT NULL,
    Store_Name VARCHAR(150) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Region VARCHAR(100) NULL
);
GO

CREATE TABLE dwh.DIM_Staff
(
    Staff_Key INT IDENTITY(1,1) PRIMARY KEY,
    Staff_ID INT NOT NULL,
    Staff_Name VARCHAR(150) NOT NULL,
    Department VARCHAR(100) NULL,
    Store_ID INT NOT NULL,
    Hire_Date DATE NULL
);
GO
