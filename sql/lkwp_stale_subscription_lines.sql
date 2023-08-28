CREATE
    OR REPLACE VIEW wp_lkwp_stale_subscription_lines AS

SELECT subscription_id
    ,subscription_status
    ,next_payment
    ,product_name
    ,item_name original_product_name
    ,qty
    ,line_subtotal
    ,line_total
    ,CAST(member_price * qty AS DECIMAL(13, 4)) new_total
    ,line_subtotal_order_item_meta_id
    ,line_total_order_item_meta_id
FROM wp_lkwp_subscription_products
WHERE member_price IS NOT NULL
    AND line_subtotal <> member_price * qty;
