--liquibase formatted sql


--changeset ecommerce:0302-1
CREATE UNIQUE INDEX uq_users_email_not_deleted ON users (email) WHERE deleted_at IS NULL;
--rollback DROP INDEX IF EXISTS uq_users_email_not_deleted;

--changeset ecommerce:0302-2
CREATE INDEX idx_user_addresses_user_id ON user_addresses (user_id);
--rollback DROP INDEX IF EXISTS idx_user_addresses_user_id;

--changeset ecommerce:0302-3
CREATE UNIQUE INDEX uq_user_addresses_one_default ON user_addresses (user_id) WHERE is_default;
--rollback DROP INDEX IF EXISTS uq_user_addresses_one_default;


--changeset ecommerce:0302-4
CREATE INDEX idx_cart_items_variant_id ON cart_items (product_variant_id);
--rollback DROP INDEX IF EXISTS idx_cart_items_variant_id;


--changeset ecommerce:0302-5
CREATE INDEX idx_wishlist_items_variant_id ON wishlist_items (product_variant_id);
--rollback DROP INDEX IF EXISTS idx_wishlist_items_variant_id;
