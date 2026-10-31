--liquibase formatted sql


--changeset ecommerce:0201-1
CREATE TABLE brands (
    id          UUID         NOT NULL DEFAULT uuidv7(),

    slug        VARCHAR(255) NOT NULL,
    name        VARCHAR(255) NOT NULL,

    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT pk_brands      PRIMARY KEY (id),

    CONSTRAINT uq_brands_slug UNIQUE (slug)
);
--rollback DROP TABLE IF EXISTS brands CASCADE;

--changeset ecommerce:0201-2
CREATE TABLE sizes (
    id          UUID         NOT NULL DEFAULT uuidv7(),

    label       VARCHAR(100) NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0,

    CONSTRAINT pk_sizes       PRIMARY KEY (id),

    CONSTRAINT uq_sizes_label UNIQUE (label)
);
--rollback DROP TABLE IF EXISTS sizes CASCADE;

--changeset ecommerce:0201-3
CREATE TABLE colors (
    id          UUID         NOT NULL DEFAULT uuidv7(),

    name        VARCHAR(100) NOT NULL,
    hex         CHAR(7)      NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0,

    CONSTRAINT pk_colors      PRIMARY KEY (id),

    CONSTRAINT uq_colors_name UNIQUE (name),
    CONSTRAINT chk_colors_hex CHECK (hex ~ '^#[0-9A-Fa-f]{6}$')
    );
--rollback DROP TABLE IF EXISTS colors CASCADE;


--changeset ecommerce:0201-4
CREATE TABLE categories (
    id          UUID         NOT NULL DEFAULT uuidv7(),

    parent_id   UUID,

    slug        VARCHAR(255) NOT NULL,
    name        VARCHAR(255) NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0,

    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT pk_categories        PRIMARY KEY (id),

    -- deleting a category that has subcategories is not allowed
    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories (id) ON DELETE RESTRICT,

    CONSTRAINT uq_categories_slug   UNIQUE (slug),
    CONSTRAINT chk_categories_no_self_parent CHECK (parent_id IS NULL OR parent_id <> id)
);
--rollback DROP TABLE IF EXISTS categories CASCADE;

--changeset ecommerce:0201-5
CREATE TABLE category_attribute_schemas (
     id            UUID           NOT NULL DEFAULT uuidv7(),

     category_id   UUID           NOT NULL,

     schema        JSONB          NOT NULL DEFAULT '{}'::jsonb,
     status        content_status NOT NULL DEFAULT 'DRAFT',

     activated_at  TIMESTAMPTZ,
     archived_at   TIMESTAMPTZ,
     created_at    TIMESTAMPTZ    NOT NULL DEFAULT now(),

     version       INT            NOT NULL,

     CONSTRAINT pk_category_attribute_schemas PRIMARY KEY (id),

     CONSTRAINT fk_category_schemas_category  FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,

     CONSTRAINT uq_category_schema_version    UNIQUE (category_id, version),
     CONSTRAINT chk_category_schema_version   CHECK (version > 0)
);
--rollback DROP TABLE IF EXISTS category_attribute_schemas CASCADE;


--changeset ecommerce:0201-6
CREATE TABLE products (
    id           UUID           NOT NULL DEFAULT uuidv7(),

    brand_id     UUID,

    slug         VARCHAR(255)   NOT NULL,
    name         VARCHAR(255)   NOT NULL,
    description  TEXT,
    base_price   NUMERIC(12, 2) NOT NULL,
    currency     currency_code  NOT NULL DEFAULT 'LEI',
    gender       gender         NOT NULL DEFAULT 'UNISEX',

    attributes   JSONB          NOT NULL DEFAULT '{}'::jsonb,
    status       content_status NOT NULL DEFAULT 'DRAFT',

    created_at   TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ    NOT NULL DEFAULT now(),

    version      BIGINT         NOT NULL,

    CONSTRAINT pk_products             PRIMARY KEY (id),

    CONSTRAINT fk_products_brand       FOREIGN KEY (brand_id) REFERENCES brands (id) ON DELETE SET NULL,

    CONSTRAINT uq_products_slug        UNIQUE (slug),
    CONSTRAINT chk_products_base_price CHECK (base_price >= 0)
);
--rollback DROP TABLE IF EXISTS products CASCADE;


--changeset ecommerce:0201-7
CREATE TABLE product_categories (
    product_id   UUID NOT NULL,
    category_id  UUID NOT NULL,

    CONSTRAINT pk_product_categories          PRIMARY KEY (product_id, category_id),

    CONSTRAINT fk_product_categories_product  FOREIGN KEY (product_id)  REFERENCES products (id)   ON DELETE CASCADE,
    CONSTRAINT fk_product_categories_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
);
--rollback DROP TABLE IF EXISTS product_categories CASCADE;


--changeset ecommerce:0201-8
CREATE TABLE product_variants (
    id                UUID           NOT NULL DEFAULT uuidv7(),

    product_id        UUID           NOT NULL,
    size_id           UUID,
    color_id          UUID,

    sku               VARCHAR(100)   NOT NULL,
    barcode           VARCHAR(100)   NOT NULL,
    price             NUMERIC(12, 2) NOT NULL,
    compare_at_price  NUMERIC(12, 2),

    is_active         BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ    NOT NULL DEFAULT now(),

    CONSTRAINT pk_product_variants          PRIMARY KEY (id),

    CONSTRAINT fk_product_variants_product  FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    -- size/color reference books: deletion of a used value is prohibited
    CONSTRAINT fk_product_variants_size     FOREIGN KEY (size_id)    REFERENCES sizes (id)    ON DELETE RESTRICT,
    CONSTRAINT fk_product_variants_color    FOREIGN KEY (color_id)   REFERENCES colors (id)   ON DELETE RESTRICT,

    CONSTRAINT uq_product_variants_sku      UNIQUE (sku),
    CONSTRAINT uq_product_variants_barcode  UNIQUE (barcode),
    -- one variant per combination (product, size, color)
    CONSTRAINT uq_product_variants_combination UNIQUE NULLS NOT DISTINCT (product_id, size_id, color_id),

    CONSTRAINT chk_product_variants_price   CHECK (price >= 0),
    CONSTRAINT chk_product_variants_compare CHECK (compare_at_price IS NULL OR compare_at_price >= 0)
);
--rollback DROP TABLE IF EXISTS product_variants CASCADE;


--changeset ecommerce:0201-9
CREATE TABLE product_images (
    id          UUID        NOT NULL DEFAULT uuidv7(),

    product_id  UUID        NOT NULL,

    url         TEXT        NOT NULL,
    alt         TEXT,
    sort_order  INT         NOT NULL DEFAULT 0,

    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT pk_product_images         PRIMARY KEY (id),
    CONSTRAINT fk_product_images_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);
--rollback DROP TABLE IF EXISTS product_images CASCADE;
