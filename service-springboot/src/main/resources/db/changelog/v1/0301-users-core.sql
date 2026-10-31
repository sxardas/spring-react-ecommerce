--liquibase formatted sql


--changeset ecommerce:0301-1
CREATE TABLE users (
    id           UUID         NOT NULL DEFAULT uuidv7(),

    keycloak_id  UUID,

    email        CITEXT       NOT NULL,
    phone        VARCHAR(50),
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE,

    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    deleted_at   TIMESTAMPTZ,

    CONSTRAINT pk_users             PRIMARY KEY (id),

    CONSTRAINT uq_users_keycloak_id UNIQUE (keycloak_id)
);
--rollback DROP TABLE IF EXISTS users CASCADE;

--changeset ecommerce:0301-2
CREATE TABLE user_addresses (
    id           UUID         NOT NULL DEFAULT uuidv7(),

    user_id      UUID         NOT NULL,

    title        VARCHAR(100),
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    phone        VARCHAR(50)  NOT NULL,
    city         VARCHAR(100) NOT NULL,
    street       VARCHAR(255) NOT NULL,
    postal_code  VARCHAR(20)  NOT NULL,
    is_default   BOOLEAN      NOT NULL DEFAULT FALSE,

    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT pk_user_addresses      PRIMARY KEY (id),

    -- addresses belong to the user and are removed together with them
    CONSTRAINT fk_user_addresses_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);
--rollback DROP TABLE IF EXISTS user_addresses CASCADE;


--changeset ecommerce:0301-3
CREATE TABLE carts (
    id          UUID        NOT NULL DEFAULT uuidv7(),

    user_id     UUID        NOT NULL,

    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT pk_carts      PRIMARY KEY (id),

    CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,

    CONSTRAINT uq_carts_user UNIQUE (user_id)
);
--rollback DROP TABLE IF EXISTS carts CASCADE;


--changeset ecommerce:0301-4
CREATE TABLE cart_items (
    cart_id             UUID        NOT NULL,
    product_variant_id  UUID        NOT NULL,

    quantity            INT         NOT NULL DEFAULT 1,

    added_at            TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT pk_cart_items         PRIMARY KEY (cart_id, product_variant_id),

    CONSTRAINT fk_cart_items_cart    FOREIGN KEY (cart_id)            REFERENCES carts (id)            ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_variant FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE CASCADE,

    CONSTRAINT chk_cart_items_qty    CHECK (quantity > 0)
);
--rollback DROP TABLE IF EXISTS cart_items CASCADE;


--changeset ecommerce:0301-5
CREATE TABLE wishlist_items (
    user_id    UUID                 NOT NULL,
    product_variant_id  UUID        NOT NULL,

    added_at            TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT pk_wishlist_items         PRIMARY KEY (user_id, product_variant_id),

    CONSTRAINT fk_wishlist_items_user    FOREIGN KEY (user_id)            REFERENCES users (id)            ON DELETE CASCADE,
    CONSTRAINT fk_wishlist_items_variant FOREIGN KEY (product_variant_id) REFERENCES product_variants (id) ON DELETE CASCADE
);
--rollback DROP TABLE IF EXISTS wishlist_items CASCADE;
