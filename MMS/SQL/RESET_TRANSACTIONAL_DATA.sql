-- ============================================================================
-- SQL SCRIPT: CLEAN / RESET ALL TRANSACTIONAL & USER DATA (KEEP SYSTEM MASTERS)
-- ============================================================================
-- This script will delete data from "Entry", "Transaction", "Customer", and "Merchant" tables.
-- It will PRESERVE System Master Data:
--   - mms.item_master (Gold, Silver definitions)
--   - mms.unit_master (Gram, Kg)
--   - mms.config_property (System Settings)
--   - mms.item_price_history (Daily Rates)
--
-- It will DELETE and RESET IDs for:
--   - All Customers (mms.customer_master)
--   - All Merchants (mms.merchant_master)
--   - All Deposits, Withdrawals, Interest Logs
-- ============================================================================

BEGIN;

-- 1. Truncate Transactional & User Tables & Reset IDs
-- 'RESTART IDENTITY' forces all SERIAL sequences back to 1.
-- 'CASCADE' handles foreign key dependencies automatically.

TRUNCATE TABLE 
    mms.merchant_item_transaction,
    mms.merchant_item_entry,
    mms.merchant_master,
    mms.customer_deposit_transaction,
    mms.customer_deposit_items,
    mms.customer_deposit_entry,
    mms.customer_master
RESTART IDENTITY CASCADE;

-- 2. Explicitly ensure Sequences are reset to 1
-- (Double-check to guarantee auto-generated IDs start from 1)
ALTER SEQUENCE IF EXISTS mms.customer_master_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS mms.merchant_master_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS mms.customer_deposit_entry_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS mms.customer_deposit_items_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS mms.customer_deposit_transaction_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS mms.merchant_item_entry_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS mms.merchant_item_transaction_id_seq RESTART WITH 1;

-- 3. Views (Automatic Reset)
-- Since Views are dynamic queries, they will automatically be empty 
-- because the underlying transaction tables have been truncated.
-- The following views are now reset:
--   - mms.v_customer_deposit_with_total
--   - mms.v_deposit_items_current_value
--   - mms.v_deposit_summary_with_interest

COMMIT;

-- 4. Verification
-- SELECT count(*) as should_be_zero FROM mms.customer_deposit_entry;
