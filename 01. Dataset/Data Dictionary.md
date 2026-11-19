# Data Dictionary

Synthetic data, seed 21. Amounts in INR. Purchase orders: Jan 2023 - Dec 2024. Change requests: Jan - Dec 2024.

## Suppliers
| Column | Type | Description |
|---|---|---|
| SupplierID | Text (PK) | SUP001 - SUP028 |
| SupplierName | Text | Invented supplier name |
| Category | Text | Food, Dairy, Fresh Produce, Beverages, Packaging, Cleaning, Equipment, Logistics |
| Region | Text | Supplier's state |
| PaymentTermsDays | Integer | 15 / 30 / 45 / 60 |
| OnboardDate | Date | Date added to the supplier master |

## Products
| Column | Type | Description |
|---|---|---|
| SKU | Text (PK) | Product code |
| SupplierID | Text (FK) | Supplying vendor |
| Category | Text | Same as supplier category |
| Description | Text | Generic description |
| UnitsPerTray | Integer | Units in one tray / case (1 for equipment and logistics) |
| ContractCost | Decimal | Agreed unit cost at the start of 2023 |

## PurchaseOrders
| Column | Type | Description |
|---|---|---|
| POID | Text (PK) | Purchase order line |
| SupplierID | Text (FK) |  |
| SKU | Text (FK) |  |
| OrderDate / PromisedDate / ReceivedDate | Date | ReceivedDate is blank when the PO was still open at 31 Dec 2024 |
| QtyOrdered / QtyReceived / QtyRejected | Integer | Units |
| UnitCost | Decimal | Price paid per unit |
| IsOpen | Integer | Added in cleaning: 1 = not received by 31 Dec 2024 |

## ChangeRequests
| Column | Type | Description |
|---|---|---|
| RequestID | Text (PK) |  |
| SupplierID / SKU | Text (FK) |  |
| ChangeType | Text | Cost Change, Equipment Price Change, Units per Tray Update, New Product Listing |
| OldValue / NewValue | Decimal | Cost (cost requests) or units per tray (tray requests); OldValue blank for new listings |
| SubmittedAt / DecisionAt | Date-time | DecisionAt blank when still pending |
| Decision | Text | Approved / Rejected / Pending |
| Approver | Text | Buyer or Category Manager (increases of 8%+ go to the Category Manager) |
| HoursToDecision | Decimal | Added in cleaning |
| DecidedWithin24h | Integer | Added in cleaning: 1 = met the 24-hour target |
| ChangePct | Decimal | Added in cleaning: % change in cost, cost requests only |
