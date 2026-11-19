# Power BI Build Guide

Steps to rebuild the report in Power BI Desktop from this repo. The `.pbix` itself is not included; save yours as
`03. Power BI/File/Supplier_Procurement_Analytics.pbix` once built. The images in `Dashboard Images/` show the target layout.

## 1. Load the data
1. **Home > Get data > Text/CSV**, and load these files from `01. Dataset/Cleaned Dataset/`:
   - `Clean_Suppliers.csv` -> rename the query to `Suppliers`
   - `Clean_Products.csv` -> rename the query to `Products`
   - `Clean_PurchaseOrders.csv` -> rename the query to `PurchaseOrders`
   - `Clean_ChangeRequests.csv` -> rename the query to `ChangeRequests`
2. In Power Query set types: dates to **Date**, money and rates to **Decimal number**, counts to **Whole number**, IDs to **Text**.
3. `SubmittedAt` and `DecisionAt` are date-time: set them to **Date/Time**. `OldValue`/`NewValue` hold costs for cost requests and units for tray requests, so do not sum them across types.
4. Do **not** relate Products to Suppliers. Both facts already carry SupplierID, and a second path would make the model ambiguous.

## 2. Model
Create these relationships (single direction, filter flows from the "1" side):

| From (1) | To (*) |
|---|---|
| Suppliers[SupplierID] | PurchaseOrders[SupplierID] |
| Suppliers[SupplierID] | ChangeRequests[SupplierID] |
| Products[SKU] | PurchaseOrders[SKU] |
| Products[SKU] | ChangeRequests[SKU] |
| Calendar[Date] | PurchaseOrders[OrderDate] |
| Calendar[Date] | ChangeRequests[Submitted Date] (inactive) |

Mark `Calendar` as the date table.

## 3. Add DAX
From `DAX/Measures.dax`, in order: the `Calendar` table, calculated columns (set **Sort by column** on band columns),
then measures in a dedicated `_Measures` table with display folders (Spend, Performance, Change Requests).

## 4. Pages
| Page | Image | Visuals |
|---|---|---|
| 1. Spend Overview | `1.Spend_Overview.png` | KPI cards, top-10 suppliers bar, monthly spend line with 3M average, category column |
| 2. Supplier Performance | `2.Supplier_Performance.png` | OTIF KPIs, lowest-OTIF bar, late % by category, review list table (conditional formatting on OTIF < 75%) |
| 3. Change Requests | `3.Change_Requests.png` | KPI cards, rejection by Change Band, within-24h line, type table, units-per-tray table |
| Model | `4.Data_Model.png` | Relationships to build in Model view |

## 5. Check your numbers
With no slicers applied the report should show:
- Total Spend ≈ ₹50.06 Cr; Spend YoY % (2024) ≈ +0.8%
- OTIF % ≈ 82.0%; Reject % ≈ 1.05%
- Change Requests = 1,500; Within 24h % ≈ 91.3%; Approved % ≈ 91.9%

The full set of reference results is in `02. SQL Scripts/Query Results/`. Anything different means a relationship or a data type is wrong.

## 6. Optional: Power BI Service
Publish to a workspace, set **scheduled refresh** (a gateway is needed for on-premises sources), add **row-level security**
under Modeling > Manage roles, and use a **deployment pipeline** to move the report from Development to Test to Production.
