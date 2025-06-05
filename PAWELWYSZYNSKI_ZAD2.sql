SELECT
	o.order_id,
    o.total_amount,
    SUM(oi.quantity * oi.price_per_unit) AS total_price
FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount != SUM(oi.quantity * oi.price_per_unit)
ORDER BY o.order_id;

UPDATE orders
SET total_amount = (
	SELECT SUM(oi.quantity * oi.price_per_unit)
  	FROM order_items oi
  	WHERE oi.order_id = orders.order_id
)
WHERE total_amount != (
	SELECT SUM(oi.quantity * oi.price_per_unit)
    FROM order_items oi
    WHERE oi.order_id = orders.order_id
);
