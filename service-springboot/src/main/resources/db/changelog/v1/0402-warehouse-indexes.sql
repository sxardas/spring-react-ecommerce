--liquibase formatted sql


--changeset ecommerce:0402-1
CREATE INDEX idx_inventories_variant_id ON inventories (product_variant_id);
--rollback DROP INDEX IF EXISTS idx_inventories_variant_id;


--changeset ecommerce:0402-2
CREATE INDEX idx_inventory_movements_warehouse_created ON inventory_movements (warehouse_id, created_at DESC);
--rollback DROP INDEX IF EXISTS idx_inventory_movements_warehouse_created;

--changeset ecommerce:0402-3
CREATE INDEX idx_inventory_movements_variant_created ON inventory_movements (product_variant_id, created_at DESC);
--rollback DROP INDEX IF EXISTS idx_inventory_movements_variant_created;

--changeset ecommerce:0402-4
CREATE INDEX idx_inventory_movements_order_id ON inventory_movements (order_id) WHERE order_id IS NOT NULL;
--rollback DROP INDEX IF EXISTS idx_inventory_movements_order_id;
