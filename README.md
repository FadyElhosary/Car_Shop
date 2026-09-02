# End-to-End Car Shop Data Engineering & BI Solution

An end-to-end Data Engineering and Business Intelligence solution for a simulated Car Shop business. The project demonstrates how transactional OLTP data can be extracted, transformed through ODS and staging layers, loaded into a dimensional Data Warehouse, exposed through an SSAS Tabular semantic model, and consumed through Power BI.

## Project Information

**Developer:** Fady Mohamed  
**Role:** Data Engineering Trainee at GBG  
**Domain:** Automotive Retail / Car Shop

## Technology Stack

![Azure SQL](https://img.shields.io/badge/Azure%20SQL-0078D4?style=flat&logo=microsoftazure&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)
![SSIS](https://img.shields.io/badge/SSIS-ETL-CC2927?style=flat)
![SSAS](https://img.shields.io/badge/SSAS-Tabular-5C2D91?style=flat)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black)
![SQL Server Agent](https://img.shields.io/badge/SQL%20Server%20Agent-Automation-CC2927?style=flat)

## Architecture

```text
Source OLTP
    |
    v
   ODS
    |
    v
   STG
    |
    v
   DWH Star Schema
    |
    v
SSAS Tabular
    |
    v
 Power BI
```

### Detailed Flow

```text
+-------------------+
|   Source OLTP     |
| Orders            |
| Order_Items       |
| Customers         |
| Products          |
| Stores            |
| Staff             |
| Stocks            |
+---------+---------+
          |
          v
+-------------------+
|       ODS         |
| Operational Copy  |
+---------+---------+
          |
          v
+-------------------+
|       STG         |
| Clean / Validate  |
| Standardize       |
+---------+---------+
          |
          v
+-------------------+
|       DWH         |
|    Star Schema    |
| Facts + Dimensions|
+---------+---------+
          |
          v
+-------------------+
|   SSAS Tabular    |
| Semantic Layer    |
+---------+---------+
          |
          v
+-------------------+
|     Power BI      |
| Analytics / KPIs  |
+-------------------+
```

## Source OLTP Model

The simulated operational system contains:

- `Orders` — order headers and shipment information
- `Order_Items` — products and quantities within each order
- `Customers` — customer master data
- `Staff` — employees processing orders
- `Products` — products, categories, brands and pricing
- `Stores` — shop locations
- `Stocks` — inventory snapshots
- Date information used to populate the warehouse calendar dimension

## Data Warehouse Model

The analytical warehouse follows a Star Schema.

### Fact Tables

#### Fact_Order

Stores order-line level sales events and derived financial values.

Key attributes include:

- `Order_Key`
- `Order_ID`
- `Date_Key`
- `Customer_Key`
- `Product_Key`
- `Store_Key`
- `Staff_Key`
- `Quantity`
- `Unit_Price`
- `Discount`
- `Gross_Sales`
- `Net_Sales`
- `Cost`
- `Profit`
- `Ship_Date_Key`
- `Is_Late_Shipment`

#### Fact_Stock

Stores inventory snapshots by date, product and store.

Key attributes include:

- `Stock_Key`
- `Date_Key`
- `Product_Key`
- `Store_Key`
- `Quantity_On_Hand`
- `Reorder_Level`
- `Stock_Value`

### Dimensions

- `DIM_Date`
- `DIM_Customer`
- `DIM_Product`
- `DIM_Store`
- `DIM_Staff`

## ETL Strategy

The ETL solution uses a multi-layer architecture:

```text
OLTP -> ODS -> STG -> DWH
```

### ODS Layer

The ODS layer receives a controlled copy of operational source data. It separates extraction from downstream transformations and provides an intermediate operational snapshot.

### Staging Layer

The staging layer prepares data for warehouse loading through operations such as:

- Data type conversion
- Null handling
- Standardization
- Duplicate detection
- Validation
- Business-rule checks

### DWH Layer

The DWH layer converts prepared data into dimensions and fact tables using surrogate keys and dimensional modeling principles.

## Initial Load

The initial load processes the available historical source data and establishes the warehouse baseline:

```text
Source
  -> ODS
  -> STG
  -> Dimensions
  -> Facts
```

## Incremental Load

Subsequent executions process new or changed records using business keys, Lookups and Conditional Splits.

```text
STG
 |
 v
Lookup Existing Record
 |
 +-----------------------+
 |                       |
 No Match              Match
 |                       |
 v                       v
 INSERT             Compare Attributes
                         |
                  +------+------+
                  |             |
                Changed      Unchanged
                  |             |
                  v             v
                UPDATE        Ignore
```

This approach reduces unnecessary processing and keeps the warehouse synchronized with source changes.

## SSIS Design

SSIS packages are organized by processing layer:

- `01_ODS_Load` — source extraction and ODS loading
- `02_STG_Load` — cleansing, validation and staging
- `03_DWH_Load` — dimension and fact loading
- `Master_Package` — orchestration of the complete pipeline

The master package is designed to execute the layers in dependency order and can be deployed to SSISDB.

## SSAS Tabular Semantic Layer

The SSAS Tabular model sits between the DWH and Power BI and provides business-friendly analytical objects.

The model contains:

```text
Fact_Order
Fact_Stock
DIM_Date
DIM_Customer
DIM_Product
DIM_Store
DIM_Staff
```

### Row-Level Calculations

```DAX
Total Sales =
Fact_Order[Quantity] * Fact_Order[Unit_Price]
```

```DAX
Net Sales =
Fact_Order[Total Sales] - Fact_Order[Discount]
```

```DAX
Profit =
Fact_Order[Net Sales] - Fact_Order[Cost]
```

Profit Margin is preferably implemented as a measure so it responds correctly to filter context.

### Core Measures

```DAX
Total Sales :=
SUM(Fact_Order[Gross_Sales])
```

```DAX
Net Sales :=
SUM(Fact_Order[Net_Sales])
```

```DAX
Total Profit :=
SUM(Fact_Order[Profit])
```

```DAX
Profit Margin :=
DIVIDE([Total Profit], [Net Sales], 0)
```

```DAX
Late Shipments Count :=
CALCULATE(
    COUNTROWS(Fact_Order),
    Fact_Order[Is_Late_Shipment] = TRUE()
)
```

```DAX
Average Order Value :=
DIVIDE(
    [Net Sales],
    DISTINCTCOUNT(Fact_Order[Order_ID]),
    0
)
```

```DAX
Repeat Customer Rate :=
VAR CustomerOrderCounts =
    ADDCOLUMNS(
        VALUES(DIM_Customer[Customer_Key]),
        "OrderCount",
            CALCULATE(
                DISTINCTCOUNT(Fact_Order[Order_ID])
            )
    )
VAR RepeatCustomers =
    COUNTROWS(
        FILTER(CustomerOrderCounts, [OrderCount] > 1)
    )
VAR TotalCustomers =
    COUNTROWS(CustomerOrderCounts)
RETURN
    DIVIDE(RepeatCustomers, TotalCustomers, 0)
```

## Power BI Dashboard

The reporting layer is designed around interactive business analysis.

### Filters / Slicers

- Date
- Product Category
- Brand
- Store
- Customer
- Staff

### KPI Cards

- Total Sales
- Net Sales
- Total Profit
- Profit Margin
- Average Order Value
- Late Shipments

### Recommended Visuals

- Monthly Sales Trend
- Sales by Category
- Sales by Brand
- Sales by Store
- Top Products
- Customer Sales
- Repeat Customer Rate
- Inventory by Store
- Low Stock Products
- Profit Margin Trend
- Late Shipment Analysis

## SQL Server Agent Automation

The complete ETL workflow can be deployed to SSISDB and scheduled through SQL Server Agent.

```text
SQL Server Agent
       |
       v
CarShop Master ETL
       |
       +--> ODS Load
       |
       +--> STG Load
       |
       +--> Dimension Load
       |
       +--> Fact Load
       |
       +--> SSAS Processing
```

This provides repeatable and automated execution without requiring manual package execution.

## Repository Structure

```text
Car_Shop/
|
+-- sql/
|   +-- 01_source_oltp/
|   +-- 02_ods/
|   +-- 03_staging/
|   +-- 04_dwh/
|   +-- 05_ssas_views/
|
+-- ssis/
|   +-- 01_ODS_Load/
|   +-- 02_STG_Load/
|   +-- 03_DWH_Load/
|   +-- Master_Package/
|
+-- ssas/
|   +-- model/
|   +-- dax/
|
+-- powerbi/
|   +-- screenshots/
|
+-- scripts/
|   +-- sql_agent/
|   +-- deployment/
|
+-- docs/
|   +-- diagrams/
|
+-- README.md
```

## Setup & Deployment

### 1. Prepare the Database Environment

Install or configure:

- SQL Server or compatible Azure SQL environment
- SQL Server Management Studio
- SQL Server Integration Services
- SQL Server Analysis Services in Tabular mode
- SQL Server Agent

### 2. Create the Source Database

Run the scripts under:

```text
sql/01_source_oltp/
```

### 3. Create ODS and Staging

Run:

```text
sql/02_ods/
sql/03_staging/
```

### 4. Create the Data Warehouse

Run the dimension and fact scripts under:

```text
sql/04_dwh/
```

### 5. Configure SSIS

Open the SSIS project and configure connection managers for the source, ODS, STG and DWH databases.

Deploy the project to SSISDB.

### 6. Configure SQL Server Agent

Create the Agent job using the scripts under:

```text
scripts/sql_agent/
```

Configure the required schedule and SSISDB execution parameters.

### 7. Deploy SSAS

Create or deploy the Tabular model, configure relationships and measures, then process the model.

### 8. Build the Power BI Report

Connect Power BI to the SSAS Tabular model and create the dashboard pages, slicers, KPIs and visualizations described above.

## Data Quality Checks

The pipeline should validate:

- Primary-key uniqueness
- Foreign-key integrity
- Duplicate business keys
- Required fields
- Invalid dates
- Invalid prices
- Negative quantities
- Missing dimension references
- Stock consistency
- Late shipment logic

## Project Objectives

This project demonstrates practical experience with:

- SQL Server
- Azure SQL
- SQL
- ETL design
- SSIS
- ODS and staging architecture
- Dimensional Data Warehousing
- Star Schema
- Surrogate Keys
- Incremental Loading
- Lookup transformations
- Conditional Splits
- SSAS Tabular
- DAX
- Power BI
- SQL Server Agent
- SSISDB
- ETL automation

## Disclaimer

This project is based on a simulated Car Shop business scenario and is intended for educational and portfolio purposes. No proprietary GBG data, credentials or internal systems are included.

## Author

**Fady Mohamed**  
Data Engineer | Data Warehousing | ETL | Business Intelligence
