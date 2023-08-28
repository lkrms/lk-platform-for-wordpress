CREATE
    OR REPLACE VIEW wp_lkwp_subscription_products AS

SELECT s.subscription_id
    ,s.subscription_date
    ,s.last_change_date
    ,s.subscription_status
    ,s.next_payment
    ,oi.item_name
    ,oi.item_type
    ,oi.product_id
    ,oi.variation_id
    ,oi.qty
    ,oi.line_subtotal
    ,oi.line_subtotal_tax
    ,oi.line_total
    ,oi.line_tax
    ,oi.delivery_months
    ,p.product_name
    ,p.sku
    ,p.price
    ,p.regular_price
    ,p.sale_price
    ,pt.product_type
    ,CASE 
        WHEN p.price IS NULL
            THEN NULL
        WHEN pt.product_type = 'subscription'
            THEN p.price
        ELSE CAST(p.regular_price * 0.85 AS DECIMAL(13, 4))
        END member_price
    ,oi.line_subtotal_order_item_meta_id
    ,oi.line_total_order_item_meta_id
FROM wp_lkwp_subscriptions s
LEFT JOIN wp_lkwp_order_items oi ON oi.item_type NOT IN ('line_item_switched', 'shipping')
    AND s.subscription_id = oi.subscription_id
LEFT JOIN wp_lkwp_products p ON oi.product_id = p.product_id
LEFT JOIN wp_lkwp_product_types pt ON oi.product_id = pt.product_id;
