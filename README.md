#### 🧹 Data Cleaning & SQL Project  
```
Welcom to my portfollio :)
Here I showcase my journey in SQL, Excel, and Data Cleaning projects where I transform raw data into clean, consistent, and analyzable datasets.
  ```

---

#### ✨ Data Cleaning Steps  
```
## ✈ Airports Table  
- Removed spaces from `airport_name` (*TRIM*).  
- Standardized city/state names (*REPLACE + CASE*) → `ch → Chicago`, `nyc → New York`, `FL/fl → Florida`.  
- Handled missing values with *COALESCE* or deleted rows when required.
```

## 🛫 Carriers Table  
`- Cleaned extra spaces in `name` column (*TRIM*).  `

## 👥 Clients Table  
```
- Joined with `clients_split` table.  
- Filled missing values in `city/state` with *COALESCE*.  
- Exported cleaned table to *Excel* for validation.
```

## 🎬 Series Table  
```
- Fixed invalid `rating` (>10 → set to 10).  
- Replaced negative `num_ratings` with the *average*.  
- Corrected invalid `official_site` URLs (`ww.` → `www.`).  
- Standardized `is_adult` column (adult = age ≥ 16).  
- Cleaned invalid contact numbers (starting with `000`).
```

## 👨‍✈ Pilots Table  
` - Standardized `entry_date` format with *CONVERT* & *FORMAT*.  `

## 📊 Flight_Statistics Table  
```
- Detected duplicates using *ROW_NUMBER() + PARTITION BY*.  
- Removed duplicates with *CTE, GROUP BY, HAVING, SELECT DISTINCT*.
```

## 📂 Other Tables  
` - (Episodes, Vendors, Paper Shop Sales) → Verified *cleaned data* with no formatting/duplicates issues. `

---

### 📊 Excel Integration

Exported SQL tables into Excel sheet

---
### 🛠️ Tools & Skills

SQL → Data Cleaning, UPDATE, JOINs, CTE, Aggregations,COALESCE, TRIM , CONVERT , FORMAT
ROW_NUMBER() , PARTITION BY

EXCEL → putting clean data

---
### 📬 Contact & Social Links

✨ Feel free to connect with me and check out more projects:


### 🔗 [LinkedIn](www.linkedin.com/in/alaa-ramadan-)

