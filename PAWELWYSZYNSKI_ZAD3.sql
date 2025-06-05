WITH average_amount AS (
    SELECT 
  		AVG(order_total.total_price) as avg_amount
    FROM (
		SELECT 
      		SUM(oi.quantity * oi.price_per_unit) as total_price
        FROM orders o
        	JOIN clients c 
      			ON o.client_id = c.client_id
        	JOIN order_items oi 
      			ON o.order_id = oi.order_id
        WHERE o.supplier_id IS NULL
        	AND TRIM(
              CASE 
              	WHEN instr(c.name, ' ') > 0 THEN substr(c.name, 1, instr(c.name, ' ') - 1)
                ELSE c.name
              END
          ) LIKE '%a'
        GROUP BY o.order_id
    ) order_total
),
all_orders AS (
    SELECT 
        o.order_id,
        o.client_id,
        c.name as client_name,
        TRIM(
          CASE 
            WHEN instr(c.name, ' ') > 0 THEN substr(c.name, 1, instr(c.name, ' ') - 1)
            ELSE c.name
          END
        ) as first_name,
        o.order_date,
        o.delivery_date,
        o.status,
        SUM(oi.quantity * oi.price_per_unit) as total_price
    FROM orders o
    	JOIN clients c 
  			ON o.client_id = c.client_id
    	JOIN order_items oi 
  			ON o.order_id = oi.order_id
    WHERE o.supplier_id IS NULL
      AND TRIM(
          CASE 
            WHEN instr(c.name, ' ') > 0 THEN substr(c.name, 1, instr(c.name, ' ') - 1)
            ELSE c.name
          END
      ) LIKE '%a'
    GROUP BY o.order_id, o.client_id, c.name, o.order_date, o.delivery_date, o.status
)
SELECT 
    ao.order_id,
    ao.client_id,
    ao.client_name,
    ao.first_name,
    ao.order_date,
    ao.delivery_date,
    ao.status,
    ao.total_price
FROM all_orders ao
CROSS JOIN average_amount aa
WHERE ao.total_price > aa.avg_amount
ORDER BY ao.total_price DESC;
