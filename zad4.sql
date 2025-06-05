INSERT INTO invoices (
    corrected_invoice_id,
    supplier_id,
    client_id,
    issue_date,
    due_date,
    invoice_type,
    order_id,
    total_amount_due,
    payment_received
)
SELECT 
    NULL AS corrected_invoice_id,
    o.supplier_id,
    o.client_id,
    DATE('now') AS issue_date,
    DATE('now', '+7 days') AS due_date,
    'FAK' AS invoice_type,
    o.order_id,
    SUM(oi.quantity * oi.price_per_unit) AS total_amount_due,
    1 AS payment_received
FROM orders o
	LEFT JOIN order_items oi 
    	ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
AND o.order_id NOT IN (
    SELECT DISTINCT i.order_id
    FROM invoices i 
    WHERE i.order_id IS NOT NULL
)
GROUP BY o.order_id, o.client_id, o.supplier_id
HAVING COUNT(oi.order_item_id) > 0;

INSERT INTO invoice_items (
    invoice_id,
    description,
    quantity,
    price_per_unit
)
SELECT 
    i.invoice_id,
    oi.product_name,
    oi.quantity,
    oi.price_per_unit
FROM invoices i
	INNER JOIN orders o 
    	ON i.order_id = o.order_id
	INNER JOIN order_items oi 
    	ON o.order_id = oi.order_id
WHERE i.issue_date = DATE('now')
AND i.invoice_type = 'FAK';
