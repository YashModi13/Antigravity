-- Allow NULL values in mobile_number columns to permit multiple entries without phone numbers
-- while keeping the UNIQUE constraint (Postgres allows multiple NULLs in a unique column)

ALTER TABLE mms.customer_master ALTER COLUMN mobile_number DROP NOT NULL;
ALTER TABLE mms.merchant_master ALTER COLUMN mobile_number DROP NOT NULL;
