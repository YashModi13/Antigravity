-- ============================================================================
-- GUJARATI MORTGAGE MANAGEMENT SYSTEM (MMS) - SIMPLIFIED DATABASE
-- ============================================================================

-- Drop all tables and triggers from public schema
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- Create MMS schema
CREATE SCHEMA IF NOT EXISTS mms;

-- Create extension for UUID if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TRIGGER FUNCTIONS
-- ============================================================================

CREATE OR REPLACE FUNCTION mms.set_created_date_and_active()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_date := CURRENT_TIMESTAMP;
    NEW.is_active := COALESCE(NEW.is_active, true);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mms.set_updated_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_date := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- MASTER DATA TABLES
-- ============================================================================

CREATE TABLE mms.unit_master (
    id SERIAL PRIMARY KEY,
    unit_name VARCHAR(20) NOT NULL UNIQUE,
    unit_in_gram DECIMAL(10, 3) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP,
    updated_date TIMESTAMP
);

CREATE TRIGGER unit_master_insert_trigger
BEFORE INSERT ON mms.unit_master
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

CREATE TRIGGER unit_master_update_trigger
BEFORE UPDATE ON mms.unit_master
FOR EACH ROW
EXECUTE FUNCTION mms.set_updated_date();

-- ============================================================================

CREATE TABLE mms.item_master (
    id SERIAL PRIMARY KEY,
    item_name VARCHAR(50) NOT NULL,
    item_code VARCHAR(20) UNIQUE NOT NULL,
    unit_id INTEGER NOT NULL REFERENCES mms.unit_master(id),
    unit_quantity DECIMAL(10, 3) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP,
    updated_date TIMESTAMP
);

CREATE TRIGGER item_master_insert_trigger
BEFORE INSERT ON mms.item_master
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

CREATE TRIGGER item_master_update_trigger
BEFORE UPDATE ON mms.item_master
FOR EACH ROW
EXECUTE FUNCTION mms.set_updated_date();

-- ============================================================================

CREATE TABLE mms.item_price_history (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES mms.item_master(id),
    price DECIMAL(12, 2) NOT NULL,
    effective_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP
);

CREATE TRIGGER item_price_history_insert_trigger
BEFORE INSERT ON mms.item_price_history
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

-- ============================================================================

CREATE TABLE mms.customer_master (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100),
    address TEXT,
    village VARCHAR(50),
    district VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),
    referral_customer_id INTEGER REFERENCES mms.customer_master(id),
    referral_name VARCHAR(100),
    kyc_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP,
    updated_date TIMESTAMP
);

CREATE TRIGGER customer_master_insert_trigger
BEFORE INSERT ON mms.customer_master
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

CREATE TRIGGER customer_master_update_trigger
BEFORE UPDATE ON mms.customer_master
FOR EACH ROW
EXECUTE FUNCTION mms.set_updated_date();

-- ============================================================================

CREATE TABLE mms.merchant_master (
    id SERIAL PRIMARY KEY,
    merchant_name VARCHAR(100) NOT NULL,
    merchant_type VARCHAR(20) NOT NULL,
    mobile_number VARCHAR(15) UNIQUE NOT NULL,
    address TEXT,
    village VARCHAR(50),
    district VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),
    default_interest_rate DECIMAL(5, 2) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP,
    updated_date TIMESTAMP
);

CREATE TRIGGER merchant_master_insert_trigger
BEFORE INSERT ON mms.merchant_master
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

CREATE TRIGGER merchant_master_update_trigger
BEFORE UPDATE ON mms.merchant_master
FOR EACH ROW
EXECUTE FUNCTION mms.set_updated_date();

-- ============================================================================

CREATE TABLE mms.config_property (
    id SERIAL PRIMARY KEY,
    property_key VARCHAR(100) UNIQUE NOT NULL,
    property_value TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP,
    updated_date TIMESTAMP
);

CREATE TRIGGER config_property_insert_trigger
BEFORE INSERT ON mms.config_property
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

CREATE TRIGGER config_property_update_trigger
BEFORE UPDATE ON mms.config_property
FOR EACH ROW
EXECUTE FUNCTION mms.set_updated_date();

-- ============================================================================
-- TRANSACTION TABLES (CUSTOMER DEPOSITS)
-- ============================================================================

CREATE TABLE mms.customer_deposit_entry (
    id SERIAL PRIMARY KEY,
    token_no INT NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES mms.customer_master(id),
    deposit_date DATE NOT NULL,
    total_interest_rate DECIMAL(5, 2) NOT NULL,
    entry_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP,
    updated_date TIMESTAMP,
    close_date DATE DEFAULT NULL
);

CREATE TRIGGER customer_deposit_entry_insert_trigger
BEFORE INSERT ON mms.customer_deposit_entry
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

CREATE TRIGGER customer_deposit_entry_update_trigger
BEFORE UPDATE ON mms.customer_deposit_entry
FOR EACH ROW
EXECUTE FUNCTION mms.set_updated_date();

-- ============================================================================

CREATE TABLE mms.customer_deposit_items (
    id SERIAL PRIMARY KEY,
    deposit_entry_id INTEGER NOT NULL REFERENCES mms.customer_deposit_entry(id),
    item_id INTEGER NOT NULL REFERENCES mms.item_master(id),
    item_date DATE NOT NULL,
    weight_received DECIMAL(10, 3) NOT NULL,
    weight_unit_id INTEGER NOT NULL REFERENCES mms.unit_master(id),
    fine_weight DECIMAL(10, 3) NOT NULL,
    item_status VARCHAR(30) NOT NULL DEFAULT 'DEPOSITED',
    item_description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP,
    updated_date TIMESTAMP
);

CREATE TRIGGER customer_deposit_items_insert_trigger
BEFORE INSERT ON mms.customer_deposit_items
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

CREATE TRIGGER customer_deposit_items_update_trigger
BEFORE UPDATE ON mms.customer_deposit_items
FOR EACH ROW
EXECUTE FUNCTION mms.set_updated_date();

-- ============================================================================

CREATE TABLE mms.customer_deposit_transaction (
    id SERIAL PRIMARY KEY,
    deposit_entry_id INTEGER NOT NULL REFERENCES mms.customer_deposit_entry(id),
    transaction_type VARCHAR(30) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    transaction_date DATE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP
);

CREATE TRIGGER customer_deposit_transaction_insert_trigger
BEFORE INSERT ON mms.customer_deposit_transaction
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

-- ============================================================================
-- B2B MERCHANT TRANSACTION TABLES
-- ============================================================================

CREATE TABLE mms.merchant_item_entry (
    id SERIAL PRIMARY KEY,
    merchant_id INTEGER NOT NULL REFERENCES mms.merchant_master(id),
    customer_deposit_item_id INTEGER NOT NULL REFERENCES mms.customer_deposit_items(id),
    entry_date DATE NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL,
    entry_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP,
    updated_date TIMESTAMP
);

CREATE TRIGGER merchant_item_entry_insert_trigger
BEFORE INSERT ON mms.merchant_item_entry
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

CREATE TRIGGER merchant_item_entry_update_trigger
BEFORE UPDATE ON mms.merchant_item_entry
FOR EACH ROW
EXECUTE FUNCTION mms.set_updated_date();

-- ============================================================================

CREATE TABLE mms.merchant_item_transaction (
    id SERIAL PRIMARY KEY,
    merchant_item_entry_id INTEGER NOT NULL REFERENCES mms.merchant_item_entry(id),
    transaction_type VARCHAR(30) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    transaction_date DATE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_date TIMESTAMP
);

CREATE TRIGGER merchant_item_transaction_insert_trigger
BEFORE INSERT ON mms.merchant_item_transaction
FOR EACH ROW
EXECUTE FUNCTION mms.set_created_date_and_active();

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_unit_master_active ON mms.unit_master(is_active);
CREATE INDEX idx_customer_master_mobile ON mms.customer_master(mobile_number);
CREATE INDEX idx_customer_master_active ON mms.customer_master(is_active);
CREATE INDEX idx_merchant_master_mobile ON mms.merchant_master(mobile_number);
CREATE INDEX idx_item_master_unit ON mms.item_master(unit_id);
CREATE INDEX idx_item_master_active ON mms.item_master(is_active);
CREATE INDEX idx_customer_deposit_entry_customer ON mms.customer_deposit_entry(customer_id);
CREATE INDEX idx_customer_deposit_items_entry ON mms.customer_deposit_items(deposit_entry_id);
CREATE INDEX idx_customer_deposit_items_weight_unit ON mms.customer_deposit_items(weight_unit_id);
CREATE INDEX idx_customer_deposit_transaction_entry ON mms.customer_deposit_transaction(deposit_entry_id);
CREATE INDEX idx_merchant_item_entry_merchant ON mms.merchant_item_entry(merchant_id);
CREATE INDEX idx_merchant_item_transaction_entry ON mms.merchant_item_transaction(merchant_item_entry_id);
CREATE INDEX idx_config_property_key ON mms.config_property(property_key);

-- ============================================================================
-- HELPER VIEWS FOR EASY QUERIES
-- ============================================================================

CREATE VIEW mms.v_customer_deposit_with_total AS
SELECT 
    cde.id,
    cde.customer_id,
    cde.deposit_date,
    cde.total_interest_rate,
    cde.entry_status,
    cde.notes,
    COALESCE(SUM(CASE WHEN cdt.transaction_type IN ('INITIAL_MONEY', 'EXTRA_WITHDRAWAL') THEN cdt.amount ELSE 0 END), 0) as total_amount_given,
    COALESCE(SUM(CASE WHEN cdt.transaction_type = 'INTEREST_PAYMENT' THEN cdt.amount ELSE 0 END), 0) as total_interest_paid_to_customer,
    COALESCE(SUM(CASE WHEN cdt.transaction_type = 'INTEREST_RECEIVED' THEN ABS(cdt.amount) ELSE 0 END), 0) as total_interest_received_from_customer,
    COALESCE(SUM(CASE WHEN cdt.amount < 0 THEN ABS(cdt.amount) ELSE 0 END), 0) as total_amount_received,
    cde.is_active,
    cde.created_date,
    cde.updated_date
FROM mms.customer_deposit_entry cde
LEFT JOIN mms.customer_deposit_transaction cdt 
    ON cde.id = cdt.deposit_entry_id
GROUP BY cde.id, cde.customer_id, cde.deposit_date, cde.total_interest_rate, 
         cde.entry_status, cde.notes, cde.is_active, cde.created_date, cde.updated_date;

-- ============================================================================
-- SAMPLE DATA
-- ============================================================================

INSERT INTO mms.unit_master (unit_name, unit_in_gram, description) 
VALUES 
    ('GRAM', 1.000, 'Gram unit'),
    ('KG', 1000.000, 'Kilogram unit');

INSERT INTO mms.item_master (item_name, item_code, unit_id, unit_quantity, description) 
VALUES 
    ('GOLD', 'GOLD', 1, 10.000, 'Gold jewelry and items'),
    ('SILVER', 'SILVER', 2, 1.000, 'Silver jewelry and items');

INSERT INTO mms.item_price_history (item_id, price, effective_date) 
VALUES 
    (1, 65000.00, CURRENT_DATE),
    (2, 75000.00, CURRENT_DATE);

INSERT INTO mms.config_property (property_key, property_value, description)
VALUES 
    ('business.name', 'Jay Laxmi Jewellers Dhiran System', 'The official name of the business'),
    ('business.short_name', 'Jay Laxmi', 'Shorter name for sidebar logo'),
    ('business.address', 'Patan, Gujarat', 'Physical address for receipts'),
    ('business.mobile', '+91 99245 80455', 'Primary contact number'),
    ('business.email', 'jaylaxmi@gamil.com', 'Business email address'),
    ('business.gstin', '--------------', 'GST Registration Number'),
    ('default.unit.master.id', '1', 'Default unit ID (1 for GRAM)'),
    ('default.customer.interest.rate', '3.0', 'Default monthly interest rate for new deposits'),
    ('default.fine.percentage', '75.0', 'Average default purity percentage for items'),
    ('system.currency.symbol', '₹', 'Local currency symbol used for display'),
    ('system.risk.threshold.percentage', '100', 'Risk status if Loan > X% of Asset Value'),
    ('system.pagination.default.size', '10', 'Default rows per page in tables'),
    ('system.calendar.months.round_up', 'true', 'Whether to count partial month as full month'),
    ('default.customer.state', 'Gujarat', 'Default state for new customer creation'),
    ('default.giving.percentage', '60.0', 'Default loan-to-value percentage for items');

-- ============================================================================
-- NOTE: Prices are per unit
-- GOLD: 65000 per GRAM
-- SILVER: 75000 per GRAM
-- unit_in_gram in unit_master: Conversion factor to grams
-- ============================================================================

-- To get item with unit details:
-- SELECT im.id, im.item_name, im.item_code, im.unit_quantity, um.unit_name, um.unit_in_gram 
-- FROM mms.item_master im
-- JOIN mms.unit_master um ON im.unit_id = um.id;

-- fine_weight: Pure weight after accounting for purity

-- ============================================================================
-- VIEWS FOR CURRENT PRICE AND INTEREST CALCULATIONS
-- ============================================================================

CREATE VIEW mms.v_deposit_items_current_value AS
SELECT 
    cdi.id,
    cdi.deposit_entry_id,
    cdi.item_id,
    im.item_name,
    cdi.weight_received,
    um_item.unit_name as item_unit,
    cdi.fine_weight,
    iph.price as current_price,
    -- Calculation: (FineWeight / (ItemUnitQty * UnitGramFactor)) * Price
    (cdi.fine_weight / (im.unit_quantity * um_item.unit_in_gram)) * iph.price as current_item_value,
    cdi.item_status,
    cdi.created_date
FROM mms.customer_deposit_items cdi
JOIN mms.item_master im ON cdi.item_id = im.id
JOIN mms.unit_master um_item ON im.unit_id = um_item.id
JOIN LATERAL (
    SELECT price FROM mms.item_price_history 
    WHERE item_id = im.id AND effective_date <= CURRENT_DATE
    ORDER BY effective_date DESC LIMIT 1
) iph ON true;

-- ============================================================================

CREATE VIEW mms.v_deposit_summary_with_interest AS
SELECT 
    cde.id as deposit_id,
    cde.customer_id,
    cde.deposit_date,
    cde.total_interest_rate,
    COALESCE(SUM(cdi_val.current_item_value), 0) as total_current_item_value,
    COALESCE(SUM(CASE WHEN cdt.transaction_type = 'INTEREST_RECEIVED' THEN cdt.amount ELSE 0 END), 0) as total_interest_accrued,
    COALESCE(SUM(CASE WHEN cdt.transaction_type = 'INTEREST_PAYMENT' THEN cdt.amount ELSE 0 END), 0) as total_interest_paid,
    (COALESCE(SUM(CASE WHEN cdt.transaction_type = 'INTEREST_RECEIVED' THEN cdt.amount ELSE 0 END), 0) - 
     COALESCE(SUM(CASE WHEN cdt.transaction_type = 'INTEREST_PAYMENT' THEN cdt.amount ELSE 0 END), 0)) as unpaid_interest,
    cde.entry_status
FROM mms.customer_deposit_entry cde
LEFT JOIN mms.customer_deposit_items cdi ON cde.id = cdi.deposit_entry_id
LEFT JOIN mms.v_deposit_items_current_value cdi_val ON cdi.id = cdi_val.id
LEFT JOIN mms.customer_deposit_transaction cdt ON cde.id = cdt.deposit_entry_id
GROUP BY cde.id, cde.customer_id, cde.deposit_date, cde.total_interest_rate, cde.entry_status;
