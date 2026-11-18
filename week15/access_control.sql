USE webdev2_week8;

CREATE OR REPLACE SQL SECURITY DEFINER VIEW product_sales_summary AS
SELECT
    p.id AS product_id,
    p.sku,
    p.name AS product_name,
    COALESCE(p.category, 'Uncategorized') AS category,
    p.price AS unit_price,
    p.stock_quantity,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    COALESCE(SUM(oi.quantity * oi.price), 0.00) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
GROUP BY p.id, p.sku, p.name, p.category, p.price, p.stock_quantity;

SHOW CREATE VIEW product_sales_summary\G

CREATE USER IF NOT EXISTS 'webdev2_app'@'localhost' IDENTIFIED BY '<YOUR_LOCAL_APP_PASSWORD>';
REVOKE CREATE, REFERENCES, INDEX, ALTER ON `webdev2_week8`.* FROM 'webdev2_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `webdev2_week8`.* TO 'webdev2_app'@'localhost';

CREATE USER IF NOT EXISTS 'webdev2_report'@'localhost' IDENTIFIED BY '<YOUR_LOCAL_REPORT_PASSWORD>';
GRANT SELECT ON `webdev2_week8`.`product_sales_summary` TO 'webdev2_report'@'localhost';

SHOW GRANTS FOR 'webdev2_app'@'localhost';
SHOW GRANTS FOR 'webdev2_report'@'localhost';