--liquibase formatted sql


--changeset ecommerce:0502-1
CREATE INDEX idx_orders_user_created ON orders (user_id, created_at DESC);
--rollback DROP INDEX IF EXISTS idx_orders_user_created;

--changeset ecommerce:0502-2
CREATE INDEX idx_orders_status_created ON orders (status, created_at DESC);
--rollback DROP INDEX IF EXISTS idx_orders_status_created;

--changeset ecommerce:0502-3
CREATE INDEX idx_order_items_order_id ON order_items (order_id);
--rollback DROP INDEX IF EXISTS idx_order_items_order_id;

--changeset ecommerce:0502-4
CREATE INDEX idx_order_items_variant_id ON order_items (product_variant_id);
--rollback DROP INDEX IF EXISTS idx_order_items_variant_id;

--changeset ecommerce:0502-5
CREATE INDEX idx_order_status_history_order_created ON order_status_history (order_id, created_at DESC);
--rollback DROP INDEX IF EXISTS idx_order_status_history_order_created;

--changeset ecommerce:0502-6
CREATE INDEX idx_order_status_history_changed_by ON order_status_history (changed_by) WHERE changed_by IS NOT NULL;
--rollback DROP INDEX IF EXISTS idx_order_status_history_changed_by;

--changeset ecommerce:0502-7
CREATE INDEX idx_order_coupons_coupon_id ON order_coupons (coupon_id);
--rollback DROP INDEX IF EXISTS idx_order_coupons_coupon_id;


--changeset ecommerce:0502-8
CREATE INDEX idx_shipments_warehouse_id ON shipments (warehouse_id);
--rollback DROP INDEX IF EXISTS idx_shipments_warehouse_id;

--changeset ecommerce:0502-9
CREATE INDEX idx_shipments_tracking_number ON shipments (tracking_number) WHERE tracking_number IS NOT NULL;
--rollback DROP INDEX IF EXISTS idx_shipments_tracking_number;
