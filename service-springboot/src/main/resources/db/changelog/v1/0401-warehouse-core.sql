--liquibase formatted sql


--changeset ecommerce:0401-1
CREATE TABLE warehouses (
    id           UUID         NOT NULL DEFAULT uuidv7(),

    name         VARCHAR(255) NOT NULL,
    city         VARCHAR(100) NOT NULL,
    street       VARCHAR(255) NOT NULL,
    postal_code  VARCHAR(20)  NOT NULL,
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE,

    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT pk_warehouses PRIMARY KEY (id)
);
--rollback DROP TABLE IF EXISTS warehouses CASCADE;

--changeset ecommerce:0401-2
CREATE TABLE inventories (
    warehouse_id        UUID        NOT NULL,
    product_variant_id  UUID        NOT NULL,

    quantity            INT         NOT NULL DEFAULT 0,
    reserved            INT         NOT NULL DEFAULT 0,

    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT pk_inventories           PRIMARY KEY (warehouse_id, product_variant_id),

    CONSTRAINT fk_inventories_warehouse FOREIGN KEY (warehouse_id)       REFERENCES warehouses (id)       ON DELETE CASCADE,
    CONSTRAINT fk_inventories_variant   FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE CASCADE,

    CONSTRAINT chk_inventories_quantity CHECK (quantity >= 0),
    CONSTRAINT chk_inventories_reserved CHECK (reserved >= 0)
);
--rollback DROP TABLE IF EXISTS inventories CASCADE;

-- NOTE: order_id is a plain column here: the FK to orders is added in 0501, after orders is created
--changeset ecommerce:0401-3
CREATE TABLE inventory_movements (
    id                  UUID             NOT NULL DEFAULT uuidv7(),

    warehouse_id        UUID             NOT NULL,
    product_variant_id  UUID             NOT NULL,
    order_id            UUID,

    delta               INT              NOT NULL,
    reason              inventory_reason NOT NULL,

    created_at          TIMESTAMPTZ      NOT NULL DEFAULT now(),

    CONSTRAINT pk_inventory_movements           PRIMARY KEY (id),

    -- audit log: referenced warehouses and variants must not be deleted
    CONSTRAINT fk_inventory_movements_warehouse FOREIGN KEY (warehouse_id)       REFERENCES warehouses (id)       ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_movements_variant   FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE RESTRICT,

    CONSTRAINT chk_inventory_movements_delta    CHECK (delta <> 0)
);
--rollback DROP TABLE IF EXISTS inventory_movements CASCADE;
