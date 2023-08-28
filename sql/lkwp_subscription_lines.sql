CREATE
    OR REPLACE VIEW wp_lkwp_order_items AS
    WITH order_itemmeta AS (
            SELECT meta_id
                ,order_item_id
                ,meta_key
                ,CASE meta_value
                    WHEN ''
                        THEN NULL
                    ELSE meta_value
                    END meta_value
            FROM wp_woocommerce_order_itemmeta
            )

SELECT oi.order_id subscription_id
    ,oi.order_item_name item_name
    ,oi.order_item_type item_type
    ,CAST(oim_product_id.meta_value AS INT) product_id
    ,CAST(oim_variation_id.meta_value AS INT) variation_id
    ,CAST(oim_qty.meta_value AS DECIMAL(13, 4)) qty
    ,CAST(oim_line_subtotal.meta_value AS DECIMAL(13, 4)) line_subtotal
    ,CAST(oim_line_subtotal_tax.meta_value AS DECIMAL(13, 4)) line_subtotal_tax
    ,CAST(oim_line_total.meta_value AS DECIMAL(13, 4)) line_total
    ,CAST(oim_line_tax.meta_value AS DECIMAL(13, 4)) line_tax
    ,oim_delivery_months.meta_value delivery_months
    ,oim_line_subtotal.meta_id line_subtotal_order_item_meta_id
    ,oim_line_total.meta_id line_total_order_item_meta_id
FROM wp_woocommerce_order_items oi
LEFT JOIN order_itemmeta oim_product_id ON oi.order_item_id = oim_product_id.order_item_id
    AND oim_product_id.meta_key = '_product_id'
LEFT JOIN order_itemmeta oim_variation_id ON oi.order_item_id = oim_variation_id.order_item_id
    AND oim_variation_id.meta_key = '_variation_id'
LEFT JOIN order_itemmeta oim_qty ON oi.order_item_id = oim_qty.order_item_id
    AND oim_qty.meta_key = '_qty'
LEFT JOIN order_itemmeta oim_line_subtotal ON oi.order_item_id = oim_line_subtotal.order_item_id
    AND oim_line_subtotal.meta_key = '_line_subtotal'
LEFT JOIN order_itemmeta oim_line_subtotal_tax ON oi.order_item_id = oim_line_subtotal_tax.order_item_id
    AND oim_line_subtotal_tax.meta_key = '_line_subtotal_tax'
LEFT JOIN order_itemmeta oim_line_total ON oi.order_item_id = oim_line_total.order_item_id
    AND oim_line_total.meta_key = '_line_total'
LEFT JOIN order_itemmeta oim_line_tax ON oi.order_item_id = oim_line_tax.order_item_id
    AND oim_line_tax.meta_key = '_line_tax'
LEFT JOIN order_itemmeta oim_delivery_months ON oi.order_item_id = oim_delivery_months.order_item_id
    AND oim_delivery_months.meta_key = 'Months for Delivery';
