--liquibase formatted sql


--changeset ecommerce:0102-1
CREATE TYPE content_status AS ENUM ('DRAFT', 'ACTIVE', 'ARCHIVED');
--rollback DROP TYPE IF EXISTS content_status;

--changeset ecommerce:0102-2
CREATE TYPE gender AS ENUM ('MEN', 'WOMEN', 'UNISEX', 'KIDS');
--rollback DROP TYPE IF EXISTS gender;


--changeset ecommerce:0102-3
CREATE TYPE inventory_reason AS ENUM ('RECEIPT', 'SALE', 'RETURN', 'ADJUSTMENT', 'TRANSFER');
--rollback DROP TYPE IF EXISTS inventory_reason;


--changeset ecommerce:0102-4
CREATE TYPE order_status AS ENUM ('PENDING', 'PAID', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'REFUNDED');
--rollback DROP TYPE IF EXISTS order_status;


--changeset ecommerce:0102-5
CREATE TYPE shipment_status AS ENUM ('PREPARING', 'IN_TRANSIT', 'DELIVERED', 'RETURNED');
--rollback DROP TYPE IF EXISTS shipment_status;


--changeset ecommerce:0102-6
CREATE TYPE return_reason AS ENUM ('TOO_SMALL', 'TOO_LARGE', 'NOT_AS_DESCRIBED', 'DEFECTIVE', 'WRONG_ITEM', 'CHANGED_MIND');
--rollback DROP TYPE IF EXISTS return_reason;

--changeset ecommerce:0102-7
CREATE TYPE return_status AS ENUM ('REQUESTED', 'APPROVED', 'RECEIVED', 'REFUNDED', 'REJECTED');
--rollback DROP TYPE IF EXISTS return_status;


--changeset ecommerce:0102-8
CREATE TYPE currency_code AS ENUM ('LEI', 'USD', 'EUR');
--rollback DROP TYPE IF EXISTS currency_code;

--changeset ecommerce:0102-9
CREATE TYPE discount_type AS ENUM ('PERCENT', 'FIXED');
--rollback DROP TYPE IF EXISTS discount_type;

--changeset ecommerce:0102-10
CREATE TYPE payment_type AS ENUM ('CHARGE', 'REFUND');
--rollback DROP TYPE IF EXISTS payment_type;

--changeset ecommerce:0102-11
CREATE TYPE payment_status AS ENUM ('PENDING', 'SUCCEEDED', 'FAILED');
--rollback DROP TYPE IF EXISTS payment_status;
