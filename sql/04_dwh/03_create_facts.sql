/* Car Shop - DWH Facts */

CREATE TABLE dwh.Fact_Order
(
    Order_Key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Order_ID INT NOT NULL,
    Date_Key INT NOT NULL,
    Customer_Key INT NOT NULL,
    Product_Key INT NOT NULL,
    Store_Key INT NOT NULL,
    Staff_Key INT NOT NULL,
    Quantity INT NOT NULL,
    Unit_Price DECIMAL(18,2) NOT NULL,
    Discount DECIMAL(18,2) NOT NULL,
    Gross_Sales AS (CONVERT(DECIMAL(18,2), Quantity * Unit_Price)) PERSISTED,
    Net_Sales AS (CONVERT(DECIMAL(18,2), (Quantity * Unit_Price) - Discount)) PERSISTED,
    Cost DECIMAL(18,2) NOT NULL,
    Profit AS (CONVERT(DECIMAL(18,2), ((Quantity * Unit_Price) - Discount) - Cost)) PERSISTED,
    Ship_Date_Key INT NULL,
    Is_Late_Shipment BIT NOT NULL,
    ETL_Load_Date DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT UQ_Fact_Order UNIQUE (Order_ID, Product_Key),
    CONSTRAINT FK_Fact_Order_Date FOREIGN KEY (Date_Key) REFERENCES dwh.DIM_Date(Date_Key),
    CONSTRAINT FK_Fact_Order_Ship_Date FOREIGN KEY (Ship_Date_Key) REFERENCES dwh.DIM_Date(Date_Key),
    CONSTRAINT FK_Fact_Order_Customer FOREIGN KEY (Customer_Key) REFERENCES dwh.DIM_Customer(Customer_Key),
    CONSTRAINT FK_Fact_Order_Product FOREIGN KEY (Product_Key) REFERENCES dwh.DIM_Product(Product_Key),
    CONSTRAINT FK_Fact_Order_Store FOREIGN KEY (Store_Key) REFERENCES dwh.DIM_Store(Store_Key),
    CONSTRAINT FK_Fact_Order_Staff FOREIGN KEY (Staff_Key) REFERENCES dwh.DIM_Staff(Staff_Key),
    CONSTRAINT CK_Fact_Order_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_Fact_Order_Discount CHECK (Discount >= 0),
    CONSTRAINT CK_Fact_Order_Cost CHECK (Cost >= 0)
);
GO

CREATE TABLE dwh.Fact_Stock
(
    Stock_Key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Date_Key INT NOT NULL,
    Product_Key INT NOT NULL,
    Store_Key INT NOT NULL,
    Quantity_On_Hand INT NOT NULL,
    Reorder_Level INT NOT NULL,
    Stock_Value DECIMAL(18,2) NOT NULL,
    ETL_Load_Date DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT UQ_Fact_Stock UNIQUE (Date_Key, Product_Key, Store_Key),
    CONSTRAINT FK_Fact_Stock_Date FOREIGN KEY (Date_Key) REFERENCES dwh.DIM_Date(Date_Key),
    CONSTRAINT FK_Fact_Stock_Product FOREIGN KEY (Product_Key) REFERENCES dwh.DIM_Product(Product_Key),
    CONSTRAINT FK_Fact_Stock_Store FOREIGN KEY (Store_Key) REFERENCES dwh.DIM_Store(Store_Key),
    CONSTRAINT CK_Fact_Stock_Quantity CHECK (Quantity_On_Hand >= 0),
    CONSTRAINT CK_Fact_Stock_Reorder CHECK (Reorder_Level >= 0),
    CONSTRAINT CK_Fact_Stock_Value CHECK (Stock_Value >= 0)
);
GO
