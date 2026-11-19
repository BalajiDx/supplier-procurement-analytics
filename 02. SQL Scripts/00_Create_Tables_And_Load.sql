-- 00_Create_Tables_And_Load.sql
-- Purpose : Create the 4 procurement tables and load the cleaned CSVs
-- Dialect : SQLite 3.32+ (run from the repo root:  sqlite3 project.db < "02. SQL Scripts/00_Create_Tables_And_Load.sql")
-- Data    : Synthetic data (generate_dataset.py, seed 21), cleaned by clean_dataset.py

DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS PurchaseOrders;
DROP TABLE IF EXISTS ChangeRequests;

CREATE TABLE Suppliers (
    SupplierID TEXT PRIMARY KEY,
    SupplierName TEXT,
    Category TEXT,
    Region TEXT,
    PaymentTermsDays INTEGER,
    OnboardDate TEXT
);
CREATE TABLE Products (
    SKU TEXT PRIMARY KEY,
    SupplierID TEXT REFERENCES Suppliers(SupplierID),
    Category TEXT,
    Description TEXT,
    UnitsPerTray INTEGER,
    ContractCost REAL
);
CREATE TABLE PurchaseOrders (
    POID TEXT PRIMARY KEY,
    SupplierID TEXT REFERENCES Suppliers(SupplierID),
    SKU TEXT REFERENCES Products(SKU),
    OrderDate TEXT,
    PromisedDate TEXT,
    ReceivedDate TEXT,
    QtyOrdered INTEGER,
    QtyReceived INTEGER,
    QtyRejected INTEGER,
    UnitCost REAL,
    IsOpen INTEGER
);
CREATE TABLE ChangeRequests (
    RequestID TEXT PRIMARY KEY,
    SupplierID TEXT REFERENCES Suppliers(SupplierID),
    SKU TEXT REFERENCES Products(SKU),
    ChangeType TEXT,
    OldValue REAL,
    NewValue REAL,
    SubmittedAt TEXT,
    DecisionAt TEXT,
    Decision TEXT,
    Approver TEXT,
    HoursToDecision REAL,
    DecidedWithin24h INTEGER,
    ChangePct REAL
);

.mode csv
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_Suppliers.csv" Suppliers
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_Products.csv" Products
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_PurchaseOrders.csv" PurchaseOrders
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_ChangeRequests.csv" ChangeRequests

-- SQL Server: load with BULK INSERT / the Import Flat File wizard; MySQL: LOAD DATA INFILE.
-- Date functions differ: strftime('%Y-%m', d) -> FORMAT(d,'yyyy-MM') (SQL Server) / DATE_FORMAT(d,'%Y-%m') (MySQL);
-- julianday(a) - julianday(b) -> DATEDIFF(day, b, a) / DATEDIFF(a, b).
