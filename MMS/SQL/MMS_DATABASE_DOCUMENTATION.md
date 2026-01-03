# GUJARATI MORTGAGE MANAGEMENT SYSTEM (MMS) - DATABASE DOCUMENTATION

## Table of Contents
1. [Schema Overview](#schema-overview)
2. [Master Data Tables](#master-data-tables)
3. [Transaction Tables](#transaction-tables)
4. [Views](#views)
5. [Data Types Reference](#data-types-reference)

---

## Schema Overview

**Schema Name:** `mms`

**Purpose:** Centralized database for managing customer deposits, merchant transactions, and item pricing in the MMS system.

---

## Master Data Tables

### 1. unit_master
**Purpose:** Stores unit definitions for weight measurements

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| id | SERIAL | PRIMARY KEY | Unique identifier |
| unit_name | VARCHAR(20) | NOT NULL, UNIQUE | Unit name (e.g., GRAM, KG) |
| unit_in_gram | DECIMAL(10,3) | NOT NULL | Conversion factor to grams |
| description | TEXT | NULL | Unit description |
| is_active | BOOLEAN | DEFAULT true | Active status flag |
| created_date | TIMESTAMP | NULL | Record creation timestamp |
| updated_date | TIMESTAMP | NULL | Record last update timestamp |

**Sample Data:**
```
id | unit_name | unit_in_gram | description
1  | GRAM      | 1.000        | Gram unit
2  | KG        | 1000.000     | Kilogram unit
```

**Triggers:**
- `unit_master_insert_trigger` - Sets created_date and is_active on INSERT
- `unit_master_update_trigger` - Sets updated_date on UPDATE

---

### 2. item_master
**Purpose:** Stores item definitions (gold, silver, etc.)

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| id | SERIAL | PRIMARY KEY | Unique identifier |
| item_name | VARCHAR(50) | NOT NULL | Item name (e.g., GOLD, SILVER) |
| item_code | VARCHAR(20) | NOT NULL, UNIQUE | Unique item code |
| unit_id | INTEGER | NOT NULL, FK(unit_master) | Reference to unit_master |
| unit_quantity | DECIMAL(10,3) | NOT NULL | Standard quantity per unit (e.g., 10 for GOLD=10 GRAM) |
| description | TEXT | NULL | Item description |
| is_active | BOOLEAN | DEFAULT true | Active status flag |
| created_date | TIMESTAMP | NULL | Record creation timestamp |
| updated_date | TIMESTAMP | NULL | Record last update timestamp |

**Sample Data:**
```
id | item_name | item_code | unit_id | unit_quantity | description
1  | GOLD      | GOLD      | 1       | 10.000        | Gold jewelry and items
2  | SILVER    | SILVER    | 2       | 1.000         | Silver jewelry and items
```

**Triggers:**
- `item_master_insert_trigger` - Sets created_date and is_active on INSERT
- `item_master_update_trigger` - Sets updated_date on UPDATE

**Indexes:**
- `idx_item_master_unit` - ON (unit_id)
- `idx_item_master_active` - ON (is_active)

---

### 3. item_price_history
**Purpose:** Maintains historical pricing for items

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| id | SERIAL | PRIMARY KEY | Unique identifier |
| item_id | INTEGER | NOT NULL, FK(item_master) | Reference to item_master |
| price | DECIMAL(12,2) | NOT NULL | Price per unit |
| effective_date | DATE | NOT NULL | Date when price becomes effective |
| is_active | BOOLEAN | DEFAULT true | Active status flag |
| created_date | TIMESTAMP | NULL | Record creation timestamp |

**Sample Data:**
```
id | item_id | price    | effective_date | is_active
1  | 1       | 65000.00 | 2024-01-15     | true
2  | 2       | 75000.00 | 2024-01-15     | true
```

**Triggers:**
- `item_price_history_insert_trigger` - Sets created_date and is_active on INSERT

**Notes:**
- Latest price is determined by MAX(effective_date) <= CURRENT_DATE
- Prices are per unit (e.g., 65000 per GRAM for GOLD)

---

### 4. customer_master
**Purpose:** Stores customer information

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| id | SERIAL | PRIMARY KEY | Unique identifier |
| customer_name | VARCHAR(100) | NOT NULL | Full customer name |
| mobile_number | VARCHAR(15) | NOT NULL, UNIQUE | Mobile number |
| email | VARCHAR(100) | NULL | Email address |
| address | TEXT | NULL | Full address |
| village | VARCHAR(50) | NULL | Village name |
| district | VARCHAR(50) | NULL | District name |
| state | VARCHAR(50) | NULL | State name |
| pincode | VARCHAR(10) | NULL | Postal code |
| referral_customer_id | INTEGER | NULL, FK(customer_master) | Self-referencing for referrals |
| referral_name | VARCHAR(100) | NULL | Name of referrer |
| kyc_verified | BOOLEAN | DEFAULT false | KYC verification status |
| is_active | BOOLEAN | DEFAULT true | Active status flag |
| created_date | TIMESTAMP | NULL | Record creation timestamp |
| updated_date | TIMESTAMP | NULL | Record last update timestamp |

**Triggers:**
- `customer_master_insert_trigger` - Sets created_date and is_active on INSERT
- `customer_master_update_trigger` - Sets updated_date on UPDATE

**Indexes:**
- `idx_customer_master_mobile` - ON (mobile_number)
- `idx_customer_master_active` - ON (is_active)

---

### 5. merchant_master
**Purpose:** Stores merchant/lender information

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| id | SERIAL | PRIMARY KEY | Unique identifier |
| merchant_name | VARCHAR(100) | NOT NULL | Merchant name |
| merchant_type | VARCHAR(20) | NOT NULL | Type of merchant (e.g., GOLD_LENDER, JEWELER) |
| mobile_number | VARCHAR(15) | NOT NULL, UNIQUE | Mobile number |
| address | TEXT | NULL | Full address |
| village | VARCHAR(50) | NULL | Village name |
| district | VARCHAR(50) | NULL | District name |
| state | VARCHAR(50) | NULL | State name |
| pincode | VARCHAR(10) | NULL | Postal code |
| default_interest_rate | DECIMAL(5,2) | NOT NULL | Default interest rate (%) |
| is_active | BOOLEAN | DEFAULT true | Active status flag |
| created_date | TIMESTAMP | NULL | Record creation timestamp |
| updated_date | TIMESTAMP | NULL | Record last update timestamp |

**Triggers:**
- `merchant_master_insert_trigger` - Sets created_date and is_active on INSERT
- `merchant_master_update_trigger` - Sets updated_date on UPDATE

**Indexes:**
- `idx_merchant_master_mobile` - ON (mobile_number)

---

## Transaction Tables

### 6. customer_deposit_entry
**Purpose:** Main transaction record for customer deposits

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| id | SERIAL | PRIMARY KEY | Unique identifier |
| customer_id | INTEGER | NOT NULL, FK(customer_master) | Reference to customer |
| deposit_date | DATE | NOT NULL | Date of deposit |
| total_interest_rate | DECIMAL(5,2) | NOT NULL | Total interest rate (%) |
| entry_status | VARCHAR(30) | NOT NULL, DEFAULT 'ACTIVE' | Status (ACTIVE, CLOSED, PENDING) |
| notes | TEXT | NULL | Additional notes |
| is_active | BOOLEAN | DEFAULT true | Active status flag |
| created_date | TIMESTAMP | NULL | Record creation timestamp |
| updated_date | TIMESTAMP | NULL | Record last update timestamp |

**Triggers:**
- `customer_deposit_entry_insert_trigger` - Sets created_date and is_active on INSERT
- `customer_deposit_entry_update_trigger` - Sets updated_date on UPDATE

**Indexes:**
- `idx_customer_deposit_entry_customer` - ON (customer_id)

---

### 7. customer_deposit_items
**Purpose:** Individual items within a customer deposit

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| id | SERIAL | PRIMARY KEY | Unique identifier |
| deposit_entry_id | INTEGER | NOT NULL, FK(customer_deposit_entry) | Reference to deposit entry |
| item_id | INTEGER | NOT NULL, FK(item_master) | Reference to item |
| item_date | DATE | NOT NULL | Date item was deposited |
| weight_received | DECIMAL(10,3) | NOT NULL | Actual weight received |
| weight_unit_id | INTEGER | NOT NULL, FK(unit_master) | Unit of weight (GRAM, KG) |
| fine_weight | DECIMAL(10,3) | NOT NULL | Pure weight after purity adjustment |
| item_status | VARCHAR(30) | NOT NULL, DEFAULT 'DEPOSITED' | Status (DEPOSITED, WITHDRAWN, PLEDGED) |
| item_description | TEXT | NULL | Item description/notes |
| is_active | BOOLEAN | DEFAULT true | Active status flag |
| created_date | TIMESTAMP | NULL | Record creation timestamp |
| updated_date | TIMESTAMP | NULL | Record last update timestamp |

**Example:**
```
Customer deposits 100 grams of gold (22K purity)
weight_received = 100 (grams)
weight_unit_id = 1 (GRAM)
fine_weight = 91.67 (100 * 22/24 = pure gold weight)
```

**Triggers:**
- `customer_deposit_items_insert_trigger` - Sets created_date and is_active on INSERT
- `customer_deposit_items_update_trigger` - Sets updated_date on UPDATE

**Indexes:**
- `idx_customer_deposit_items_entry` - ON (deposit_entry_id)
- `idx_customer_deposit_items_weight_unit` - ON (weight_unit_id)

---

### 8. customer_deposit_transaction
**Purpose:** Financial transactions related to deposits

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| id | SERIAL | PRIMARY KEY | Unique identifier |
| deposit_entry_id | INTEGER | NOT NULL, FK(customer_deposit_entry) | Reference to deposit entry |
| transaction_type | VARCHAR(30) | NOT NULL | Type (INITIAL_MONEY, INTEREST_RECEIVED, INTEREST_PAYMENT, EXTRA_WITHDRAWAL) |
| amount | DECIMAL(12,2) | NOT NULL | Transaction amount |
| transaction_date | DATE | NOT NULL | Date of transaction |
| description | TEXT | NULL | Transaction description |
| is_active | BOOLEAN | DEFAULT true | Active status flag |
| created_date | TIMESTAMP | NULL | Record creation timestamp |

**Transaction Types:**
- `INITIAL_MONEY` - Initial loan amount given to customer
- `INTEREST_RECEIVED` - Interest charged to customer
- `INTEREST_PAYMENT` - Interest paid to customer
- `EXTRA_WITHDRAWAL` - Additional money given to customer

**Triggers:**
- `customer_deposit_transaction_insert_trigger` - Sets created_date and is_active on INSERT

**Indexes:**
- `idx_customer_deposit_transaction_entry` - ON (deposit_entry_id)

---

### 9. merchant_item_entry
**Purpose:** B2B transaction - merchant receives items from customer deposits

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| id | SERIAL | PRIMARY KEY | Unique identifier |
| merchant_id | INTEGER | NOT NULL, FK(merchant_master) | Reference to merchant |
| customer_deposit_item_id | INTEGER | NOT NULL, FK(customer_deposit_items) | Reference to deposited item |
| entry_date | DATE | NOT NULL | Date merchant received item |
| interest_rate | DECIMAL(5,2) | NOT NULL | Interest rate for this transaction (%) |
| entry_status | VARCHAR(30) | NOT NULL, DEFAULT 'ACTIVE' | Status (ACTIVE, CLOSED, RETURNED) |
| notes | TEXT | NULL | Additional notes |
| is_active | BOOLEAN | DEFAULT true | Active status flag |
| created_date | TIMESTAMP | NULL | Record creation timestamp |
| updated_date | TIMESTAMP | NULL | Record last update timestamp |

**Triggers:**
- `merchant_item_entry_insert_trigger` - Sets created_date and is_active on INSERT
- `merchant_item_entry_update_trigger` - Sets updated_date on UPDATE

**Indexes:**
- `idx_merchant_item_entry_merchant` - ON (merchant_id)

---

### 10. merchant_item_transaction
**Purpose:** Financial transactions between merchant and system

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| id | SERIAL | PRIMARY KEY | Unique identifier |
| merchant_item_entry_id | INTEGER | NOT NULL, FK(merchant_item_entry) | Reference to merchant item entry |
| transaction_type | VARCHAR(30) | NOT NULL | Type of transaction |
| amount | DECIMAL(12,2) | NOT NULL | Transaction amount |
| transaction_date | DATE | NOT NULL | Date of transaction |
| description | TEXT | NULL | Transaction description |
| is_active | BOOLEAN | DEFAULT true | Active status flag |
| created_date | TIMESTAMP | NULL | Record creation timestamp |

**Triggers:**
- `merchant_item_transaction_insert_trigger` - Sets created_date and is_active on INSERT

**Indexes:**
- `idx_merchant_item_transaction_entry` - ON (merchant_item_entry_id)

---

## Views

### 1. v_customer_deposit_with_total
**Purpose:** Summary of customer deposits with transaction totals

**Columns:**
- `id` - Deposit entry ID
- `customer_id` - Customer ID
- `deposit_date` - Deposit date
- `total_interest_rate` - Interest rate (%)
- `entry_status` - Current status
- `notes` - Notes
- `total_amount_given` - Total money given to customer
- `total_interest_paid_to_customer` - Total interest paid to customer
- `total_interest_received_from_customer` - Total interest received from customer
- `total_amount_received` - Total money received back
- `is_active` - Active status
- `created_date` - Creation timestamp
- `updated_date` - Update timestamp

---

### 2. v_deposit_items_current_value
**Purpose:** Current market value of deposited items using latest prices

**Columns:**
- `id` - Item ID
- `deposit_entry_id` - Deposit entry ID
- `item_id` - Item master ID
- `item_name` - Item name (GOLD, SILVER)
- `weight_received` - Weight received
- `unit_name` - Unit name (GRAM, KG)
- `fine_weight` - Pure weight
- `current_price` - Latest price from item_price_history
- `current_item_value` - fine_weight × current_price
- `item_status` - Item status
- `created_date` - Creation timestamp

**Calculation:**
```
current_item_value = fine_weight × current_price
```

---

### 3. v_deposit_summary_with_interest
**Purpose:** Complete deposit summary with interest calculations

**Columns:**
- `deposit_id` - Deposit entry ID
- `customer_id` - Customer ID
- `deposit_date` - Deposit date
- `total_interest_rate` - Interest rate (%)
- `total_current_item_value` - Sum of all items' current values
- `total_interest_accrued` - Total interest charged
- `total_interest_paid` - Total interest paid to customer
- `unpaid_interest` - Interest accrued - Interest paid
- `entry_status` - Deposit status

**Calculations:**
```
total_current_item_value = SUM(fine_weight × current_price) for all items
total_interest_accrued = SUM(amount) WHERE transaction_type = 'INTEREST_RECEIVED'
total_interest_paid = SUM(amount) WHERE transaction_type = 'INTEREST_PAYMENT'
unpaid_interest = total_interest_accrued - total_interest_paid
```

---

## Data Types Reference

| Type | Size | Range | Usage |
|------|------|-------|-------|
| SERIAL | 4 bytes | 1 to 2,147,483,647 | Auto-incrementing IDs |
| VARCHAR(n) | Variable | Up to n characters | Text fields with max length |
| TEXT | Variable | Unlimited | Long text fields |
| DECIMAL(p,s) | Variable | Precision p, Scale s | Monetary/precise values |
| DATE | 4 bytes | 4713 BC to 5874897 AD | Date values |
| TIMESTAMP | 8 bytes | 4713 BC to 5874897 AD | Date and time |
| BOOLEAN | 1 byte | true/false | Boolean flags |
| INTEGER | 4 bytes | -2,147,483,648 to 2,147,483,647 | Whole numbers |

---

## Key Relationships

```
unit_master (1) ──→ (M) item_master
                 ──→ (M) customer_deposit_items

item_master (1) ──→ (M) item_price_history
            ──→ (M) customer_deposit_items

customer_master (1) ──→ (M) customer_deposit_entry
                   ──→ (1) customer_master (self-referencing for referrals)

customer_deposit_entry (1) ──→ (M) customer_deposit_items
                          ──→ (M) customer_deposit_transaction

customer_deposit_items (1) ──→ (M) merchant_item_entry

merchant_master (1) ──→ (M) merchant_item_entry

merchant_item_entry (1) ──→ (M) merchant_item_transaction
```

---

## Sample Queries

### Get current value of all active deposits
```sql
SELECT * FROM mms.v_deposit_summary_with_interest 
WHERE entry_status = 'ACTIVE';
```

### Get unpaid interest for a customer
```sql
SELECT customer_id, SUM(unpaid_interest) as total_unpaid
FROM mms.v_deposit_summary_with_interest
WHERE customer_id = 1
GROUP BY customer_id;
```

### Get item details with current price
```sql
SELECT 
    im.item_name,
    im.item_code,
    um.unit_name,
    iph.price as current_price
FROM mms.item_master im
JOIN mms.unit_master um ON im.unit_id = um.id
JOIN LATERAL (
    SELECT price FROM mms.item_price_history 
    WHERE item_id = im.id AND effective_date <= CURRENT_DATE
    ORDER BY effective_date DESC LIMIT 1
) iph ON true;
```

### Get deposit items with current market value
```sql
SELECT * FROM mms.v_deposit_items_current_value
WHERE deposit_entry_id = 1;
```

---

## Audit Trail

All tables include audit columns:
- `created_date` - Automatically set on INSERT
- `updated_date` - Automatically set on UPDATE
- `is_active` - Soft delete flag (default: true)

Triggers ensure these columns are maintained automatically.

---

## Notes

1. **Soft Deletes:** Records are not physically deleted; `is_active` is set to false
2. **Price History:** Latest price is determined by MAX(effective_date) <= CURRENT_DATE
3. **Fine Weight:** Calculated based on purity (e.g., 22K gold = 22/24 of total weight)
4. **Interest Calculation:** Tracked via transaction_type in customer_deposit_transaction
5. **Unit Conversion:** All weights can be converted to grams using unit_master.unit_in_gram

---

**Last Updated:** 2024
**Version:** 1.0
