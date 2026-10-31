--liquibase formatted sql


--changeset ecommerce:0601-1
CREATE TABLE returns (
    id             UUID           NOT NULL DEFAULT uuidv7(),

    order_id       UUID           NOT NULL,

    status         return_status  NOT NULL DEFAULT 'REQUESTED',
    refund_amount  NUMERIC(12, 2) NOT NULL,
    resolved_at    TIMESTAMPTZ,

    created_at     TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ    NOT NULL DEFAULT now(),

    CONSTRAINT pk_returns          PRIMARY KEY (id),

    -- an order that has returns cannot be deleted
    CONSTRAINT fk_returns_order    FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE RESTRICT,

    -- target of the composite FKs from return_items and payments
    CONSTRAINT uq_returns_id_order UNIQUE (id, order_id),
    CONSTRAINT chk_returns_refund  CHECK (refund_amount >= 0)
);
--rollback DROP TABLE IF EXISTS returns CASCADE;


--changeset ecommerce:0601-2
CREATE TABLE return_items (
    id             UUID           NOT NULL DEFAULT uuidv7(),

    return_id      UUID           NOT NULL,
    order_id       UUID           NOT NULL,
    order_item_id  UUID           NOT NULL,

    quantity       INT            NOT NULL,
    refund_amount  NUMERIC(12, 2) NOT NULL,
    reason         return_reason  NOT NULL,
    comment        TEXT,

    CONSTRAINT pk_return_items            PRIMARY KEY (id),

    CONSTRAINT fk_return_items_return     FOREIGN KEY (return_id, order_id)     REFERENCES returns (id, order_id)     ON DELETE CASCADE,
    CONSTRAINT fk_return_items_order_item FOREIGN KEY (order_item_id, order_id) REFERENCES order_items (id, order_id) ON DELETE RESTRICT,

    CONSTRAINT uq_return_items_item       UNIQUE (return_id, order_item_id),
    CONSTRAINT chk_return_items_quantity  CHECK (quantity > 0),
    CONSTRAINT chk_return_items_refund    CHECK (refund_amount >= 0)
);
--rollback DROP TABLE IF EXISTS return_items CASCADE;


--changeset ecommerce:0601-3
CREATE TABLE reviews (
    id             UUID         NOT NULL DEFAULT uuidv7(),

    user_id        UUID         NOT NULL,
    product_id     UUID         NOT NULL,
    order_item_id  UUID,

    title          VARCHAR(255),
    body           TEXT,
    rating         SMALLINT     NOT NULL,
    is_published   BOOLEAN      NOT NULL DEFAULT FALSE,

    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT pk_reviews              PRIMARY KEY (id),

    CONSTRAINT fk_reviews_user         FOREIGN KEY (user_id)       REFERENCES users (id)       ON DELETE CASCADE,
    CONSTRAINT fk_reviews_product      FOREIGN KEY (product_id)    REFERENCES products (id)    ON DELETE CASCADE,
    CONSTRAINT fk_reviews_order_item   FOREIGN KEY (order_item_id) REFERENCES order_items (id) ON DELETE SET NULL,

    CONSTRAINT uq_reviews_user_product UNIQUE (user_id, product_id),
    CONSTRAINT chk_reviews_rating      CHECK (rating BETWEEN 1 AND 5)
);
--rollback DROP TABLE IF EXISTS reviews CASCADE;
