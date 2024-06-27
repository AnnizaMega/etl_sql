--Menampilkan perbandingan jumlah Failed dan Succes dari campaign dan Non campaign
with transaction_summary as (
  select
    coalesce(c.campaign_name, 'Non-campaign') AS campaign_name,
    t.transaction_status,
    count(*) as total_transaction
  from "Transaction" t
  left join campaign c on t.id = c.id
  group by c.campaign_name, t.transaction_status
),
failed_transactions as (
  select campaign_name, sum(total_transaction) as total_failed
  from transaction_summary
  where transaction_status = 'FAILED'
  group by campaign_name
),
successful_transactions as (
  select campaign_name, sum(total_transaction) as total_success
  from transaction_summary
  where transaction_status = 'SUCCESS'
  group by campaign_name
)
select
  ft.campaign_name,
  ft.total_failed,
  st.total_success
from failed_transactions ft
full join successful_transactions st on ft.campaign_name = st.campaign_name
order by total_failed desc;

--query mencari username profile 10 besar dengan kategori belanja terbanyak
SELECT
  pr.username,
  COUNT(t.id) AS total_orders
FROM "Transaction" t
INNER JOIN profile pr ON t.username  = pr.username 
INNER JOIN payment p  ON p.id  = t.id 
inner join address a on a.username = t.username 
WHERE t.transaction_status = 'SUCCESS'
GROUP BY pr.username
ORDER BY total_orders DESC
LIMIT 10;


--Perbandingan transaksi yang gagal berdasarkan campaign dan Non campaign. Diurutkan berdasarkan failed transaction
WITH transaction_summary AS (
  SELECT
    coalesce(c.campaign_name, 'Non-campaign') AS campaign_name,
    transaction_status,
    COUNT(*) AS total_transactions
  FROM "Transaction" t
  LEFT JOIN campaign c ON t.id = c.id
  GROUP BY campaign_name, transaction_status
)
SELECT
  ts.campaign_name,
  SUM(CASE WHEN transaction_status = 'FAILED' THEN total_transactions ELSE 0 END) AS failed_transactions,
  SUM(total_transactions) AS total_transactions,
  CASE WHEN SUM(total_transactions) > 0 THEN (SUM(CASE WHEN transaction_status = 'FAILED' THEN total_transactions ELSE 0 END) / SUM(total_transactions)) * 100 ELSE 0 END AS failed_transaction_percentage
FROM transaction_summary ts
GROUP BY ts.campaign_name
ORDER BY failed_transactions DESC;



--Menampilkan data tanggal transaksi terbanyak yang mengalami Failed
with failed_transactions as (
  select
    coalesce(c.campaign_name, 'Non-campaign') AS campaign_name,
    t.transaction_date,
    count(*) as total_failed_transaction
  from "Transaction" t
  left join campaign c on t.id = c.id
  where t.transaction_status = 'FAILED'
  group by c.campaign_name, t.transaction_date
)
select campaign_name, transaction_date, total_failed_transaction
from failed_transactions
order by total_failed_transaction desc;



--Menghitung perbandingan pembelian Succes terbanyak antara campaign dan Non Campiagn
with campaign_summary as (
  select
    coalesce(c.campaign_name, 'Non-campaign') AS campaign_name,
    coalesce(count(*), 0) as total_transaction,
    coalesce(sum(p.revenue), 0) as total_revenue
  from "Transaction" t
  left join campaign c on t.id = c.id
  left join payment p on t.id = p.id
  where t.transaction_status = 'SUCCESS'
  group by c.campaign_name
),
non_campaign_summary as (
  select
    'Non-Campaign' as campaign_name,
    coalesce(count(*), 0) as total_transaction,
    coalesce(sum(p.revenue), 0) as total_revenue
  from "Transaction" t
  left join payment p on t.id = p.id
  where t.id is null
  and t.transaction_status = 'SUCCESS'
),
combined_summary as (
  select * from campaign_summary
  union all
  select * from non_campaign_summary
)
select campaign_name, total_transaction, total_revenue
from combined_summary
order by total_revenue desc;