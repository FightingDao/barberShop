-- 查看最新的预约记录和关联数据
SELECT 
  a.id as appointment_id,
  a.appointment_date,
  a.appointment_time,
  a.shop_id,
  s.name as shop_name,
  a.service_id,
  sv.name as service_name,
  sv.price as service_price,
  a.stylist_id,
  st.name as stylist_name
FROM appointments a
LEFT JOIN shops s ON a.shop_id = s.id
LEFT JOIN services sv ON a.service_id = sv.id
LEFT JOIN stylists st ON a.stylist_id = st.id
ORDER BY a.created_at DESC
LIMIT 5;
