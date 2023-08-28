CREATE
    OR REPLACE VIEW wp_lkwp_products AS
    WITH postmeta AS (
            SELECT meta_id
                ,post_id
                ,meta_key
                ,CASE meta_value
                    WHEN ''
                        THEN NULL
                    ELSE meta_value
                    END meta_value
            FROM wp_postmeta
            )

SELECT ID product_id
    ,post_title product_name
    ,pm_sku.meta_value sku
    ,CAST(pm_price.meta_value AS DECIMAL(13, 4)) price
    ,CAST(COALESCE(pm_regular_price.meta_value, pm_price.meta_value) AS DECIMAL(13, 4)) regular_price
    ,CAST(pm_sale_price.meta_value AS DECIMAL(13, 4)) sale_price
FROM wp_posts p
LEFT JOIN postmeta pm_sku ON p.ID = pm_sku.post_id
    AND pm_sku.meta_key = '_sku'
LEFT JOIN postmeta pm_price ON p.ID = pm_price.post_id
    AND pm_price.meta_key = '_price'
LEFT JOIN postmeta pm_regular_price ON p.ID = pm_regular_price.post_id
    AND pm_regular_price.meta_key = '_regular_price'
LEFT JOIN postmeta pm_sale_price ON p.ID = pm_sale_price.post_id
    AND pm_sale_price.meta_key = '_sale_price'
WHERE p.post_type = 'product'
    AND p.post_status = 'publish';
