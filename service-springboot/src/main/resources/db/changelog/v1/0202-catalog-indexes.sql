--liquibase formatted sql


--changeset ecommerce:0202-1
CREATE INDEX idx_categories_parent_sort ON categories (parent_id, sort_order);
--rollback DROP INDEX IF EXISTS idx_categories_parent_sort;

--changeset ecommerce:0202-2
CREATE UNIQUE INDEX uq_category_schemas_one_active ON category_attribute_schemas (category_id) WHERE status = 'ACTIVE';
--rollback DROP INDEX IF EXISTS uq_category_schemas_one_active;


--changeset ecommerce:0202-3
CREATE INDEX idx_products_brand_id ON products (brand_id);
--rollback DROP INDEX IF EXISTS idx_products_brand_id;

--changeset ecommerce:0202-4
CREATE INDEX idx_products_active_created ON products (created_at DESC) WHERE status = 'ACTIVE';
--rollback DROP INDEX IF EXISTS idx_products_active_created;

--changeset ecommerce:0202-5
CREATE INDEX idx_products_attributes_gin ON products USING gin (attributes jsonb_path_ops);
--rollback DROP INDEX IF EXISTS idx_products_attributes_gin;


--changeset ecommerce:0202-6
CREATE INDEX idx_product_categories_category_product ON product_categories (category_id, product_id);
--rollback DROP INDEX IF EXISTS idx_product_categories_category_product;


--changeset ecommerce:0202-7
CREATE INDEX idx_product_variants_size_id ON product_variants (size_id) WHERE size_id IS NOT NULL;
--rollback DROP INDEX IF EXISTS idx_product_variants_size_id;

--changeset ecommerce:0202-8
CREATE INDEX idx_product_variants_color_id ON product_variants (color_id) WHERE color_id IS NOT NULL;
--rollback DROP INDEX IF EXISTS idx_product_variants_color_id;


--changeset ecommerce:0202-9
CREATE INDEX idx_product_images_product_sort ON product_images (product_id, sort_order);
--rollback DROP INDEX IF EXISTS idx_product_images_product_sort;
