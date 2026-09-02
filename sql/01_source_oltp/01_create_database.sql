/*
    Car Shop - Source OLTP Database
    Create the database in SQL Server before running the remaining scripts.
*/

IF DB_ID('CarShop_OLTP') IS NULL
BEGIN
    CREATE DATABASE CarShop_OLTP;
END;
GO

USE CarShop_OLTP;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dbo')
    EXEC('CREATE SCHEMA dbo');
GO
