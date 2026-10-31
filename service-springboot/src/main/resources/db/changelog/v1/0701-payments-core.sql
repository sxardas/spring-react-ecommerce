--liquibase formatted sql


--changeset ecommerce:0701-1
CREATE TABLE payments (
    id               UUID           NOT NULL DEFAULT uuidv7(),

    order_id         UUID           NOT NULL,
    return_id        UUID,

    type             payment_type   NOT NULL,
    status           payment_status NOT NULL DEFAULT 'PENDING',
    provider         VARCHAR(50)    NOT NULL,
    provider_txn_id  VARCHAR(255),
    amount           NUMERIC(12, 2) NOT NULL,
    currency         currency_code  NOT NULL DEFAULT 'LEI',
    raw_response     JSONB,

    created_at       TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ    NOT NULL DEFAULT now(),

    CONSTRAINT pk_payments              PRIMARY KEY (id),

    -- payments are financial documents: an order or a return that has payments cannot be deleted
    CONSTRAINT fk_payments_order        FOREIGN KEY (order_id)            REFERENCES orders (id)            ON DELETE RESTRICT,
    -- composite FK (MATCH SIMPLE): skipped when return_id IS NULL, otherwise the return must belong to the same order
    CONSTRAINT fk_payments_return       FOREIGN KEY (return_id, order_id) REFERENCES returns (id, order_id) ON DELETE RESTRICT,

    CONSTRAINT uq_payments_provider_txn UNIQUE (provider, provider_txn_id),
    CONSTRAINT chk_payments_amount      CHECK (amount > 0)
);
--rollback DROP TABLE IF EXISTS payments CASCADE;
