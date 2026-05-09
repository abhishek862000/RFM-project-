# Customer RFM Segmentation Analysis (BigQuery)

## 📌 Project Overview
This project implements a **Recency, Frequency, and Monetary (RFM)** analysis framework using Google BigQuery. RFM is a marketing technique used to quantitatively rank and group customers based on the recency, frequency, and monetary total of their recent transactions to identify the best customers and perform targeted marketing campaigns.

## 🚀 Workflow Architecture

The project is structured into a 5-step SQL pipeline, transforming raw transactional data into a BI-ready segmentation table.

### Step 1: Data Consolidation
The raw sales data is stored in partitioned or sharded tables (monthly). We first aggregate all 2025 monthly data into a single unified table.
- **Source:** `customer-rfm.sales.sales2025*`
- **Destination:** `customer-rfm.sales.sales2025`

### Step 2: Metric Calculation
We calculate the three core RFM metrics:
- **Recency:** Days since the last purchase (Relative to a fixed analysis date: 2026-03-06).
- **Frequency:** Total number of orders placed by the customer.
- **Monetary:** Total value spent by the customer.
- **Ranking:** We apply `ROW_NUMBER()` to rank customers across these three dimensions.

### Step 3: Decile Scoring
Using the `NTILE(10)` function, we divide the customer base into 10 equal groups (deciles) for each metric.
- A score of **10** represents the top-performing 10% (e.g., most recent, most frequent, highest spenders).
- A score of **1** represents the bottom 10%.

### Step 4: RFM Total Score
The individual scores (R, F, M) are summed to create a `rfm_total_score` (ranging from 3 to 30).

### Step 5: Customer Segmentation (BI Ready)
Customers are categorized into segments based on their total score to drive business strategy.

## 📊 Segmentation Logic

| Segment | Score Range | Description |
| :--- | :--- | :--- |
| **Champion** | 28 - 30 | Best customers, recent, frequent, and high spenders. |
| **Loyal VIPs** | 24 - 27 | High-value customers who buy regularly. |
| **Potential Loyalties** | 20 - 23 | Recent customers with average frequency. |
| **Promising** | 16 - 19 | New customers with potential for growth. |
| **Engaged** | 12 - 15 | Customers who interact but don't spend much yet. |
| **Require Attention** | 8 - 11 | Customers showing signs of churn. |
| **At Risk** | 4 - 7 | Customers who haven't purchased in a long time. |
| **Lost/Inactive** | < 4 | Lowest performing customers. |

## 🛠️ Tech Stack
- **Database:** Google BigQuery
- **Language:** Standard SQL
- **Concepts:** CTEs, Window Functions (`NTILE`, `ROW_NUMBER`), Table Wildcards, Views.

## 📂 Project Structure
- `rfm_metrics`: Raw calculation of R, F, and M values.
- `rfm_scores`: Decile-based scoring (1-10).
- `rfm_total_scores`: Aggregated score calculation.
- `rfm_segment_final`: Final view mapped to business segments for visualization in tools like Looker or Tableau.

## 📈 Future Enhancements
- Automate the `analysis_date` using `CURRENT_DATE()`.
- Implement weighted RFM (e.g., giving more importance to Recency than Monetary).
- Add Year-over-Year (YoY) segment migration analysis to track customer movement between groups.
