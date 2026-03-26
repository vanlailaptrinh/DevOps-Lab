WITH vm_ips(vmid, ip) AS (
  VALUES 
    (101, '192.168.200.150'::inet),
    (103, '192.168.200.151'::inet)
)

SELECT
  v.vmid AS "VM_id",
  to_char(MAX(a.stamp_updated) AT TIME ZONE 'Asia/Ho_Chi_Minh', 'YYYY-MM-DD HH24:MI:SS') AS "Thời gian cập nhật",
  concat(a.ip_src, ' ➔ ', a.ip_dst) AS "Luồng kết nối (Flow)",
  CASE 
    WHEN a.ip_proto = 6 THEN 'TCP' 
    WHEN a.ip_proto = 17 THEN 'UDP' 
    WHEN a.ip_proto = 1 THEN 'ICMP' 
    ELSE a.ip_proto::text 
  END AS "Giao thức",
  SUM(a.packets) AS "Packets",
  SUM(a.bytes) AS "Bytes",
  concat(COALESCE(MAX(a.country_ip_src), 'LAN'), ' -> ', COALESCE(MAX(a.country_ip_dst), 'LAN')) AS "Quốc gia"
FROM acct_v4 a

JOIN vm_ips v ON 
  ('${direction}' = 'All' AND (a.ip_src = v.ip OR a.ip_dst = v.ip))
  OR ('${direction}' = 'Outbound' AND a.ip_src = v.ip) 
  OR ('${direction}' = 'Inbound' AND a.ip_dst = v.ip)  

WHERE $__timeFilter(a.stamp_updated AT TIME ZONE 'Asia/Ho_Chi_Minh')
  AND v.vmid IN (${vm:csv})

  AND (
    'All' IN (${country:singlequote})
    OR ('${direction}' = 'Outbound' AND COALESCE(NULLIF(a.country_ip_dst, ''), 'LAN') IN (${country:singlequote}))
    OR ('${direction}' = 'Inbound'  AND COALESCE(NULLIF(a.country_ip_src, ''), 'LAN') IN (${country:singlequote}))
    OR ('${direction}' = 'All'      AND (
         COALESCE(NULLIF(a.country_ip_src, ''), 'LAN') IN (${country:singlequote}) 
         OR COALESCE(NULLIF(a.country_ip_dst, ''), 'LAN') IN (${country:singlequote})
       ))
  )
  
GROUP BY
  v.vmid,
  a.ip_src,
  a.ip_dst,
  a.ip_proto
ORDER BY
  MAX(a.stamp_updated) DESC
LIMIT 50;