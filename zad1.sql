SELECT
	o.order_id,
    o.total_amount,
    SUM(oi.quantity * oi.price_per_unit) AS TotalPrice
FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
ORDER BY o.order_id