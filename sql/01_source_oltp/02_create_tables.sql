USE CarShop_OLTP;
GO

CREATE TABLE dbo.Customers
(
    Customer_ID INT IDENTITY(1,1) PRIMARY KEY,
    Customer_Name VARCHAR(150) NOT NULL,
    Email VARCHAR(200) NULL,
    Phone VARCHAR(50) NULL,
    City VARCHAR(100) NULL,
    Country VARCHAR(100) NULL,
    Modified_Date DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.Stores
(
    Store_ID INT IDENTITY(1,1) PRIMARY KEY,
    Store_Name VARCHAR(150) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Region VARCHAR(100) NULL
);
GO

CREATE TABLE dbo.Staff
(
    Staff_ID INT IDENTITY(1,1) PRIMARY KEY,
    Staff_Name VARCHAR(150) NOT NULL,
    Department VARCHAR(100) NULL,
    Store_ID INT NOT NULL,
    Hire_Date DATE NULL,
    Modified_Date DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Staff_Store FOREIGN KEY (Store_ID) REFERENCES dbo.Stores(Store_ID)
);
GO

CREATE TABLE dbo.Products
(
    Product_ID INT IDENTITY(1,1) PRIMARY KEY,
    Product_Name VARCHAR(200) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Brand VARCHAR(100) NOT NULL,
    Unit_Cost DECIMAL(18,2) NOT NULL,
    Unit_Price DECIMAL(18,2) NOT NULL,
    Modified_Date DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_Products_Cost CHECK (Unit_Cost >= 0),
    CONSTRAINT CK_Products_Price CHECK (Unit_Price >= 0)
);
GO

CREATE TABLE dbo.Orders
(
    Order_ID INT IDENTITY(1,1) PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Staff_ID INT NOT NULL,
    Store_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Ship_Date DATE NULL,
    Order_Status VARCHAR(30) NOT NULL,
    Modified_Date DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (Customer_ID) REFERENCES dbo.Customers(Customer_ID),
    CONSTRAINT FK_Orders_Staff FOREIGN KEY (Staff_ID) REFERENCES dbo.Staff(Staff_ID),
    CONSTRAINT FK_Orders_Store FOREIGN KEY (Store_ID) REFERENCES dbo.Stores(Store_ID)
);
GO

CREATE TABLE dbo.Order_Items
(
    Order_Item_ID INT IDENTITY(1,1) PRIMARY KEY,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Unit_Price DECIMAL(18,2) NOT NULL,
    Discount DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_OrderItems_Order FOREIGN KEY (Order_ID) REFERENCES dbo.Orders(Order_ID),
    CONSTRAINT FK_OrderItems_Product FOREIGN KEY (Product_ID) REFERENCES dbo.Products(Product_ID),
    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_Price CHECK (Unit_Price >= 0),
    CONSTRAINT CK_OrderItems_Discount CHECK (Discount >= 0)
);
GO

CREATE TABLE dbo.Stocks
(
    Stock_ID INT IDENTITY(1,1) PRIMARY KEY,
    Store_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Stock_Date DATE NOT NULL,
    Quantity_On_Hand INT NOT NULL,
    Reorder_Level INT NOT NULL,
    Modified_Date DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Stocks_Store FOREIGN KEY (Store_ID) REFERENCES dbo.Stores(Store_ID),
    CONSTRAINT FK_Stocks_Product FOREIGN KEY (Product_ID) REFERENCES dbo.Products(Product_ID),
    CONSTRAINT CK_Stocks_Quantity CHECK (Quantity_On_Hand >= 0),
    CONSTRAINT CK_Stocks_Reorder CHECK (Reorder_Level >= 0)
);
GO
