-- Products unavailable for purchase but still appearing in active and on-hold
-- subscriptions under 'own selection'
CREATE
    OR REPLACE VIEW wp_lkwp_stale_products AS

SELECT item_name
    ,SUM(qty) bottles
    ,COUNT(DISTINCT subscription_id) subscriptions
    ,DATE (
        MIN(CASE 
                WHEN next_payment > NOW()
                    THEN next_payment
                ELSE NULL
                END)
        ) next_run
    ,MIN(line_subtotal / qty) min_price
    ,MAX(line_subtotal / qty) max_price
FROM wp_lkwp_subscription_products
WHERE subscription_status IN ('wc-active', 'wc-on-hold')
    AND product_id IS NOT NULL
    AND product_name IS NULL
GROUP BY item_name;
