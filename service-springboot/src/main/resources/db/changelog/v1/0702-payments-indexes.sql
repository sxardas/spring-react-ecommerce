--liquibase formatted sql


--changeset ecommerce:0702-1
CREATE INDEX idx_payments_order_created ON payments (order_id, created_at DESC);
--rollback DROP INDEX IF EXISTS idx_payments_order_created;

--changeset ecommerce:0702-2
CREATE INDEX idx_payments_return_id ON payments (return_id) WHERE return_id IS NOT NULL;
--rollback DROP INDEX IF EXISTS idx_payments_return_id;

--changeset ecommerce:0702-3
CREATE INDEX idx_payments_pending_created ON payments (created_at) WHERE status = 'PENDING';
--rollback DROP INDEX IF EXISTS idx_payments_pending_created;
