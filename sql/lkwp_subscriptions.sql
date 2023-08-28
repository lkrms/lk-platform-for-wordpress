CREATE
    OR REPLACE VIEW wp_lkwp_subscriptions AS
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

SELECT o.ID subscription_id
    ,o.post_date subscription_date
    ,o.post_modified last_change_date
    ,o.post_status subscription_status
    ,CASE om.meta_value
        WHEN '0'
            THEN NULL
        ELSE CONVERT_TZ(CAST(om.meta_value AS DATETIME), '+00:00', 'SYSTEM')
        END next_payment
FROM wp_posts o
LEFT JOIN postmeta om ON o.ID = om.post_id
    AND om.meta_key = '_schedule_next_payment'
WHERE o.post_type = 'shop_subscription'
    AND o.post_status NOT IN ('trash');
