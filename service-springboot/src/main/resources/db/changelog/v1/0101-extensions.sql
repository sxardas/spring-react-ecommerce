--liquibase formatted sql


--changeset ecommerce:0101-1
CREATE EXTENSION IF NOT EXISTS citext;
--rollback DROP EXTENSION IF EXISTS citext;
