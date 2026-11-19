"""
Generate the SYNTHETIC raw dataset for the Supplier & Procurement Analytics project.

All suppliers, products, purchase orders and change requests are randomly generated (seed 21) for
learning. Supplier names are invented. No real company data is used. Amounts in INR.
Period: Jan 2023 - Dec 2024 (purchase orders) and Jan-Dec 2024 (supplier change requests).

Run:  python generate_dataset.py
Output: ./Raw Dataset/{Suppliers,Products,PurchaseOrders,ChangeRequests}.csv
(The raw files deliberately contain data-quality problems that clean_dataset.py fixes.)
"""
import os
import numpy as np
import pandas as pd

rng = np.random.default_rng(21)
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Raw Dataset")
os.makedirs(OUT, exist_ok=True)

# ---------------------------------------------------------------- suppliers
names = ["Kaveri Agro", "Coromandel Foods", "Nilgiri Dairy", "Deccan Packaging", "Malabar Spices", "Palar Fresh",
         "Bharat Cold Chain", "Sundaram Equipment", "Vellore Plastics", "Tanjore Grains", "Konkan Beverages",
         "Annapurna Oils", "Pondy Bakeware", "Chola Hygiene", "Cauvery Fruits", "Eastern Machinery",
         "Madras Cartons", "Ooty Tea Traders", "Sri Lakshmi Foods", "Arcot Snacks", "Mysore Sweets",
         "Kongu Textiles", "Hosur Refrigeration", "Vaigai Pulses", "Salem Steelware", "Trichy Paper",
         "Karaikal Seafood", "Thanjavur Rice Mills"]
cats = ["Food", "Food", "Dairy", "Packaging", "Food", "Fresh Produce", "Logistics", "Equipment", "Packaging", "Food",
        "Beverages", "Food", "Equipment", "Cleaning", "Fresh Produce", "Equipment", "Packaging", "Beverages", "Food",
        "Food", "Food", "Cleaning", "Equipment", "Food", "Equipment", "Packaging", "Fresh Produce", "Food"]
NS = len(names)
quality = rng.uniform(0.6, 1.0, NS)            # hidden supplier quality: drives OTIF, rejects, approvals
sup = pd.DataFrame({
    "SupplierID": [f"SUP{i:03d}" for i in range(1, NS + 1)],
    "SupplierName": [n + (" Pvt Ltd" if i % 3 else " & Co") for i, n in enumerate(names)],
    "Category": cats,
    "Region": rng.choice(["Tamil Nadu", "Puducherry", "Karnataka", "Kerala"], NS, p=[0.55, 0.15, 0.18, 0.12]),
    "PaymentTermsDays": rng.choice([15, 30, 45, 60], NS, p=[0.15, 0.45, 0.25, 0.15]),
    "OnboardDate": (pd.Timestamp("2016-01-01") + pd.to_timedelta(rng.integers(0, 365 * 7, NS), unit="D")).strftime("%Y-%m-%d"),
})

# ----------------------------------------------------------------- products
prod_rows = []
cost_rng = {"Food": (40, 600), "Dairy": (30, 400), "Packaging": (2, 60), "Fresh Produce": (15, 250),
            "Logistics": (800, 6000), "Equipment": (6000, 90000), "Beverages": (20, 300), "Cleaning": (40, 900)}
sku = 1
for i, s in sup.iterrows():
    for _ in range(int(rng.integers(4, 11))):
        cost = round(float(rng.uniform(*cost_rng[s.Category])), 2)
        prod_rows.append({"SKU": f"SKU{sku:04d}", "SupplierID": s.SupplierID, "Category": s.Category,
                          "Description": f"{s.Category} item {sku:04d}",
                          "UnitsPerTray": int(rng.choice([6, 8, 10, 12, 24, 36])) if s.Category not in ("Equipment", "Logistics") else 1,
                          "ContractCost": cost})
        sku += 1
prod = pd.DataFrame(prod_rows)

# ---------------------------------------------------------- purchase orders
po_rows = []
po = 1
for _ in range(9000):
    p = prod.iloc[int(rng.integers(0, len(prod)))]
    q = quality[int(p.SupplierID[3:]) - 1]
    od = pd.Timestamp("2023-01-01") + pd.Timedelta(days=int(rng.integers(0, 730)))
    lead = int(rng.integers(3, 15)) if p.Category != "Equipment" else int(rng.integers(20, 60))
    late = 1 + int(rng.exponential(1.5 + (1 - q) * 5)) if rng.random() < 0.04 + (1 - q) * 0.55 else 0
    qty = int(rng.integers(1, 4)) if p.Category == "Equipment" else int(rng.integers(2, 25)) if p.Category == "Logistics" \
        else int(rng.integers(5, 400))
    infl = 1 + 0.06 * (od - pd.Timestamp("2023-01-01")).days / 365
    unit = round(p.ContractCost * infl * rng.uniform(0.97, 1.06), 2)
    rec = qty if rng.random() < 0.85 + 0.12 * q else int(qty * rng.uniform(0.6, 0.98))
    rej = int(rec * max(0, rng.normal((1 - q) * 0.06, 0.01)))
    po_rows.append({"POID": f"PO{po:06d}", "SupplierID": p.SupplierID, "SKU": p.SKU, "OrderDate": od.strftime("%Y-%m-%d"),
                    "PromisedDate": (od + pd.Timedelta(days=lead)).strftime("%Y-%m-%d"),
                    "ReceivedDate": (od + pd.Timedelta(days=lead + late)).strftime("%Y-%m-%d"),
                    "QtyOrdered": qty, "QtyReceived": rec, "QtyRejected": rej, "UnitCost": unit})
    po += 1
pos = pd.DataFrame(po_rows)
pos.loc[pos.ReceivedDate > "2024-12-31", "ReceivedDate"] = ""          # still open at the cut-off

# ------------------------------------------------- supplier change requests
types = ["Cost Change", "Equipment Price Change", "Units per Tray Update", "New Product Listing"]
cr_rows = []
for r in range(1, 1501):
    p = prod.iloc[int(rng.integers(0, len(prod)))]
    q = quality[int(p.SupplierID[3:]) - 1]
    t = "Equipment Price Change" if p.Category == "Equipment" and rng.random() < 0.8 else \
        rng.choice(types, p=[0.55, 0.0, 0.3, 0.15]) if p.Category != "Equipment" else "Cost Change"
    if t == "Units per Tray Update" and p.UnitsPerTray == 1:
        t = "Cost Change"
    sub = pd.Timestamp("2024-01-01") + pd.Timedelta(minutes=int(rng.integers(0, 365 * 24 * 60)))
    if t in ("Cost Change", "Equipment Price Change"):
        old = p.ContractCost
        new = round(old * (1 + rng.normal(0.045 + (1 - q) * 0.05, 0.035)), 2)
    elif t == "Units per Tray Update":
        old = p.UnitsPerTray
        new = int(rng.choice([v for v in [6, 8, 10, 12, 24, 36] if v != old]))
    else:
        old, new = "", round(p.ContractCost * rng.uniform(0.9, 1.2), 2)
    # most requests are decided within a day; big cost increases take longer and are rejected more
    pct = (new - old) / old if t in ("Cost Change", "Equipment Price Change") else 0
    hours = rng.exponential(5) if rng.random() < 0.93 - max(0, pct - 0.08) * 3 else rng.uniform(24, 160)
    dec_at = sub + pd.Timedelta(hours=float(hours))
    decision = "Rejected" if rng.random() < 0.06 + max(0, pct - 0.07) * 4 else "Approved"
    if dec_at > pd.Timestamp("2024-12-31 23:59"):
        decision, dec_at = "Pending", None
    cr_rows.append({"RequestID": f"CR{r:05d}", "SupplierID": p.SupplierID, "SKU": p.SKU, "ChangeType": t,
                    "OldValue": old, "NewValue": new, "SubmittedAt": sub.strftime("%Y-%m-%d %H:%M"),
                    "DecisionAt": dec_at.strftime("%Y-%m-%d %H:%M") if dec_at is not None else "",
                    "Decision": decision, "Approver": rng.choice(["Buyer", "Category Manager"], p=[0.7, 0.3])
                    if pct < 0.08 else "Category Manager"})
crs = pd.DataFrame(cr_rows)

# ----------------------------------------------- deliberate data-quality issues
m = rng.choice(NS, 5, replace=False)
sup.loc[m, "SupplierName"] = sup.loc[m, "SupplierName"].str.upper() + "  "        # inconsistent case / spaces
pos["UnitCost"] = pos["UnitCost"].astype(object)
i = rng.choice(len(pos), 120, replace=False)
pos.loc[i, "UnitCost"] = pos.loc[i, "UnitCost"].map(lambda v: f"₹{v:,.2f}")           # cost stored as text
pos = pd.concat([pos, pos.sample(45, random_state=1)], ignore_index=True)             # duplicate POs
j = rng.choice(len(pos), 25, replace=False)
pos.loc[j, "QtyReceived"] = -pos.loc[j, "QtyReceived"]                                 # sign error
k = rng.choice(len(pos), 60, replace=False)
pos.loc[k, "OrderDate"] = pd.to_datetime(pos.loc[k, "OrderDate"]).dt.strftime("%d/%m/%Y")  # mixed date format
crs = pd.concat([crs, crs.sample(30, random_state=2)], ignore_index=True)             # duplicate requests
crs.loc[rng.choice(len(crs), 40, replace=False), "ChangeType"] = crs["ChangeType"].str.lower()

sup.to_csv(os.path.join(OUT, "Suppliers.csv"), index=False)
prod.to_csv(os.path.join(OUT, "Products.csv"), index=False)
pos.sample(frac=1, random_state=3).to_csv(os.path.join(OUT, "PurchaseOrders.csv"), index=False)
crs.to_csv(os.path.join(OUT, "ChangeRequests.csv"), index=False)
print(f"suppliers {len(sup)}  products {len(prod)}  POs {len(pos):,}  change requests {len(crs):,}")
