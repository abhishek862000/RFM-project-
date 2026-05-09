--step 1-- Append all the Table in to single table--
CREATE OR REPLACE TABLE `customer-rfm.sales.sales2025` as 
select * from `customer-rfm.sales.sales2025*`
WHERE _TABLE_SUFFIX BETWEEN '01' AND '12';

--step 2:Calculating Recency[Recent purchase gap between dised day],
--Frequency[No of time custmer visted],monitory[The value they Spend] 
--With combine CTE and VEIWS

create or replace view `customer-rfm.sales.rfm_metrics`
AS
With current_date AS(
  Select DATE("2026-03-06") as analysis_date --todays date
),
rfm AS (
  select 
  CustomerID,
  max(OrderDate)AS Last_order_date,
  date_diff((select analysis_date From current_date),max(OrderDate),Day)AS recency,
  count(*) AS frequency,
  sum(OrderValue) AS monetry
  from `customer-rfm.sales.sales2025`
  group by CustomerID

)
SELECT 
  rfm.*,
  row_number() over(order by recency ASC) as r_rank,
  row_number() over(order by frequency DESC) as f_rank,
  row_number() over(order by monetry DESC) as m_rank
FROM rfm;  

--step 3: Assing deciles (10=best, 1=worst)

create or replace view `customer-rfm.sales.rfm_scores`
AS
select
*
,

NTILE(10) over (order by r_rank Desc ) as r_score,
NTILE(10) over (order by f_rank Desc ) as f_score,
NTILE(10) over (order by m_rank Desc ) as m_score,


from `customer-rfm.sales.rfm_metrics`;

--step 4 : Total Score

create or replace view `customer-rfm.sales.rfm_total_scores`
as
select
CustomerID,
recency,
frequency,
monetry,
r_score,
f_score,
m_score,
(r_score+f_score+m_score)as rfm_total_score
from `customer-rfm.sales.rfm_scores`
order by `rfm_total_score`;

--step 5 BI Ready RFM Segment table 
create or replace view `customer-rfm.sales.rfm_segment_final`
as
select 
CustomerID,
recency,
frequency,
monetry,
r_score,
f_score,
m_score,
rfm_total_score,
case
when rfm_total_score>= 28 THEN 'Champion'
when rfm_total_score>= 24 THEN 'Loyal VIPs'
when rfm_total_score>= 20 THEN 'Potential Layalties'
when rfm_total_score>= 16 THEN  'Promising'
when rfm_total_score>= 12 THEN 'Engaged'
when rfm_total_score>= 8 THEN 'Require Attention'
when rfm_total_score>= 4 THEN 'At risk'
else 'lost/Inactive'
END as RFM_segment
from `customer-rfm.sales.rfm_total_scores`
order by rfm_total_score DESC;





















