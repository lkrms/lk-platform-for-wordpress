CREATE
    OR REPLACE VIEW wp_lkwp_product_types AS

SELECT tr.object_id product_id
    ,t.slug product_type
FROM wp_term_taxonomy tt
INNER JOIN wp_terms t ON tt.term_id = t.term_id
INNER JOIN wp_term_relationships tr ON tt.term_taxonomy_id = tr.term_taxonomy_id
WHERE tt.taxonomy = 'product_type';
