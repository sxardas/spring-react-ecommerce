--liquibase formatted sql


--changeset ecommerce:0602-1
CREATE INDEX idx_returns_order_id ON returns (order_id);
--rollback DROP INDEX IF EXISTS idx_returns_order_id;

--changeset ecommerce:0602-2
CREATE INDEX idx_returns_status_created ON returns (status, created_at DESC);
--rollback DROP INDEX IF EXISTS idx_returns_status_created;

--changeset ecommerce:0602-3
CREATE INDEX idx_return_items_order_item_id ON return_items (order_item_id, order_id);
--rollback DROP INDEX IF EXISTS idx_return_items_order_item_id;


--changeset ecommerce:0602-4
CREATE INDEX idx_reviews_product_created ON reviews (product_id, created_at DESC);
--rollback DROP INDEX IF EXISTS idx_reviews_product_created;

--changeset ecommerce:0602-5
CREATE INDEX idx_reviews_order_item_id ON reviews (order_item_id) WHERE order_item_id IS NOT NULL;
--rollback DROP INDEX IF EXISTS idx_reviews_order_item_id;
