--liquibase formatted sql


--changeset ecommerce:0501-1
CREATE TABLE coupons (
    id                 UUID           NOT NULL DEFAULT uuidv7(),

    code               CITEXT         NOT NULL,
    discount_type      discount_type  NOT NULL,
    discount_value     NUMERIC(12, 2) NOT NULL,
    min_order_amount   NUMERIC(12, 2),
    max_uses           INT,
    max_uses_per_user  INT,
    is_active          BOOLEAN        NOT NULL DEFAULT TRUE,

    starts_at          TIMESTAMPTZ,
    expires_at         TIMESTAMPTZ,

    created_at         TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ    NOT NULL DEFAULT now(),

    CONSTRAINT pk_coupons PRIMARY KEY (id),

    CONSTRAINT uq_coupons_code         UNIQUE (code),
    CONSTRAINT chk_coupons_value       CHECK (discount_value > 0),
    CONSTRAINT chk_coupons_min_order   CHECK (min_order_amount IS NULL OR min_order_amount >= 0),
    CONSTRAINT chk_coupons_max_uses    CHECK (max_uses IS NULL OR max_uses > 0),
    CONSTRAINT chk_coupons_max_per_usr CHECK (max_uses_per_user IS NULL OR max_uses_per_user > 0),
    CONSTRAINT chk_coupons_period      CHECK (starts_at IS NULL OR expires_at IS NULL OR expires_at > starts_at)
);
--rollback DROP TABLE IF EXISTS coupons CASCADE;


--changeset ecommerce:0501-2
CREATE TABLE orders (
    id                UUID           NOT NULL DEFAULT uuidv7(),

    user_id           UUID           NOT NULL,

    order_number      VARCHAR(50)    NOT NULL,
    status            order_status   NOT NULL DEFAULT 'PENDING',
    email             CITEXT         NOT NULL,
    currency          currency_code  NOT NULL DEFAULT 'LEI',

    subtotal          NUMERIC(12, 2) NOT NULL,
    discount_total    NUMERIC(12, 2) NOT NULL DEFAULT 0,
    shipping_total    NUMERIC(12, 2) NOT NULL DEFAULT 0,
    tax_total         NUMERIC(12, 2) NOT NULL DEFAULT 0,
    total             NUMERIC(12, 2) NOT NULL,

    -- snapshots of addresses at the moment of the order
    shipping_address  JSONB          NOT NULL,
    billing_address   JSONB,
    notes             TEXT,

    created_at        TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ    NOT NULL DEFAULT now(),

    version           BIGINT         NOT NULL,

    CONSTRAINT pk_orders          PRIMARY KEY (id),

    -- orders are financial documents: a user who has orders cannot be deleted
    CONSTRAINT fk_orders_user     FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT,

    CONSTRAINT uq_orders_number   UNIQUE (order_number),
    CONSTRAINT chk_orders_amounts CHECK (subtotal >= 0 AND discount_total >= 0 AND shipping_total >= 0
       AND tax_total >= 0 AND total >= 0)
);
--rollback DROP TABLE IF EXISTS orders CASCADE;

--changeset ecommerce:0501-3
CREATE TABLE order_items (
    id                   UUID           NOT NULL DEFAULT uuidv7(),

    order_id             UUID           NOT NULL,
    product_variant_id   UUID           NOT NULL,

    -- snapshot of the variant at the moment of purchase
    product_name         VARCHAR(255)   NOT NULL,
    product_variant_sku  VARCHAR(100)   NOT NULL,
    color_name           VARCHAR(100),
    size_label           VARCHAR(100),

    product_price        NUMERIC(12, 2) NOT NULL,
    quantity             INT            NOT NULL,
    discount             NUMERIC(12, 2) NOT NULL DEFAULT 0,
    line_total           NUMERIC(12, 2) NOT NULL,

    CONSTRAINT pk_order_items           PRIMARY KEY (id),

    CONSTRAINT fk_order_items_order     FOREIGN KEY (order_id)           REFERENCES orders (id)           ON DELETE CASCADE,
    CONSTRAINT fk_order_items_variant   FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE RESTRICT,

    -- target of the composite FK from return_items (the item must belong to the same order)
    CONSTRAINT uq_order_items_id_order  UNIQUE (id, order_id),
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_amounts  CHECK (product_price >= 0 AND discount >= 0 AND line_total >= 0)
);
--rollback DROP TABLE IF EXISTS order_items CASCADE;

--changeset ecommerce:0501-4
CREATE TABLE order_status_history (
    id          UUID         NOT NULL DEFAULT uuidv7(),

    order_id    UUID         NOT NULL,
    changed_by  UUID,

    status      order_status NOT NULL,
    comment     TEXT,

    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT pk_order_status_history PRIMARY KEY (id),

    CONSTRAINT fk_order_history_order  FOREIGN KEY (order_id)   REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT fk_order_history_user   FOREIGN KEY (changed_by) REFERENCES users (id)  ON DELETE SET NULL
);
--rollback DROP TABLE IF EXISTS order_status_history CASCADE;

--changeset ecommerce:0501-5
CREATE TABLE order_coupons (
    order_id         UUID           NOT NULL,
    coupon_id        UUID           NOT NULL,

    discount_amount  NUMERIC(12, 2) NOT NULL,

    applied_at       TIMESTAMPTZ    NOT NULL DEFAULT now(),

    CONSTRAINT pk_order_coupons       PRIMARY KEY (order_id, coupon_id),

    CONSTRAINT fk_order_coupons_order  FOREIGN KEY (order_id)  REFERENCES orders (id)  ON DELETE CASCADE,
    -- an applied coupon cannot be deleted
    CONSTRAINT fk_order_coupons_coupon FOREIGN KEY (coupon_id) REFERENCES coupons (id) ON DELETE RESTRICT,

    CONSTRAINT chk_order_coupons_disc  CHECK (discount_amount >= 0)
);
--rollback DROP TABLE IF EXISTS order_coupons CASCADE;


--changeset ecommerce:0501-6
CREATE TABLE shipments (
      id               UUID            NOT NULL DEFAULT uuidv7(),

      order_id         UUID            NOT NULL,
      warehouse_id     UUID            NOT NULL,

      carrier          VARCHAR(100),
      tracking_number  VARCHAR(100),
      status           shipment_status NOT NULL DEFAULT 'PREPARING',

      shipped_at       TIMESTAMPTZ,
      delivered_at     TIMESTAMPTZ,

      created_at       TIMESTAMPTZ     NOT NULL DEFAULT now(),
      updated_at       TIMESTAMPTZ     NOT NULL DEFAULT now(),

      CONSTRAINT pk_shipments           PRIMARY KEY (id),

      CONSTRAINT fk_shipments_order     FOREIGN KEY (order_id)     REFERENCES orders (id)     ON DELETE CASCADE,
      CONSTRAINT fk_shipments_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses (id) ON DELETE RESTRICT,

      CONSTRAINT uq_shipments_order     UNIQUE (order_id)
);
--rollback DROP TABLE IF EXISTS shipments CASCADE;


-- NOTE: FK for inventory_movements.order_id (the table is created in 0401)
--changeset ecommerce:0501-7
ALTER TABLE inventory_movements
    ADD CONSTRAINT fk_inventory_movements_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE RESTRICT;
--rollback ALTER TABLE inventory_movements DROP CONSTRAINT IF EXISTS fk_inventory_movements_order;
