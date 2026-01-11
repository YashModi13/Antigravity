--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: mms; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA mms;


ALTER SCHEMA mms OWNER TO postgres;

--
-- Name: set_created_date_and_active(); Type: FUNCTION; Schema: mms; Owner: postgres
--

CREATE FUNCTION mms.set_created_date_and_active() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.created_date := CURRENT_TIMESTAMP;
    NEW.is_active := COALESCE(NEW.is_active, true);
    RETURN NEW;
END;
$$;


ALTER FUNCTION mms.set_created_date_and_active() OWNER TO postgres;

--
-- Name: set_updated_date(); Type: FUNCTION; Schema: mms; Owner: postgres
--

CREATE FUNCTION mms.set_updated_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_date := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION mms.set_updated_date() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: config_property; Type: TABLE; Schema: mms; Owner: mms
--

CREATE TABLE mms.config_property (
    id integer NOT NULL,
    property_key character varying(100) NOT NULL,
    property_value text NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone,
    updated_date timestamp without time zone
);


ALTER TABLE mms.config_property OWNER TO mms;

--
-- Name: config_property_id_seq; Type: SEQUENCE; Schema: mms; Owner: mms
--

CREATE SEQUENCE mms.config_property_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.config_property_id_seq OWNER TO mms;

--
-- Name: config_property_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: mms
--

ALTER SEQUENCE mms.config_property_id_seq OWNED BY mms.config_property.id;


--
-- Name: customer_deposit_entry; Type: TABLE; Schema: mms; Owner: postgres
--

CREATE TABLE mms.customer_deposit_entry (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    deposit_date date NOT NULL,
    total_interest_rate numeric(5,2) NOT NULL,
    entry_status character varying(30) DEFAULT 'ACTIVE'::character varying NOT NULL,
    notes text,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone,
    updated_date timestamp without time zone,
    token_no integer NOT NULL,
    close_date date
);


ALTER TABLE mms.customer_deposit_entry OWNER TO postgres;

--
-- Name: customer_deposit_entry_id_seq; Type: SEQUENCE; Schema: mms; Owner: postgres
--

CREATE SEQUENCE mms.customer_deposit_entry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.customer_deposit_entry_id_seq OWNER TO postgres;

--
-- Name: customer_deposit_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: postgres
--

ALTER SEQUENCE mms.customer_deposit_entry_id_seq OWNED BY mms.customer_deposit_entry.id;


--
-- Name: customer_deposit_items; Type: TABLE; Schema: mms; Owner: postgres
--

CREATE TABLE mms.customer_deposit_items (
    id integer NOT NULL,
    deposit_entry_id integer NOT NULL,
    item_id integer NOT NULL,
    item_date date NOT NULL,
    weight_received numeric(10,3) NOT NULL,
    weight_unit_id integer NOT NULL,
    fine_weight numeric(10,3) NOT NULL,
    item_status character varying(30) DEFAULT 'DEPOSITED'::character varying NOT NULL,
    item_description text,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone,
    updated_date timestamp without time zone
);


ALTER TABLE mms.customer_deposit_items OWNER TO postgres;

--
-- Name: customer_deposit_items_id_seq; Type: SEQUENCE; Schema: mms; Owner: postgres
--

CREATE SEQUENCE mms.customer_deposit_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.customer_deposit_items_id_seq OWNER TO postgres;

--
-- Name: customer_deposit_items_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: postgres
--

ALTER SEQUENCE mms.customer_deposit_items_id_seq OWNED BY mms.customer_deposit_items.id;


--
-- Name: customer_deposit_transaction; Type: TABLE; Schema: mms; Owner: postgres
--

CREATE TABLE mms.customer_deposit_transaction (
    id integer NOT NULL,
    deposit_entry_id integer NOT NULL,
    transaction_type character varying(30) NOT NULL,
    amount numeric(12,2) NOT NULL,
    transaction_date date NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone
);


ALTER TABLE mms.customer_deposit_transaction OWNER TO postgres;

--
-- Name: customer_deposit_transaction_id_seq; Type: SEQUENCE; Schema: mms; Owner: postgres
--

CREATE SEQUENCE mms.customer_deposit_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.customer_deposit_transaction_id_seq OWNER TO postgres;

--
-- Name: customer_deposit_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: postgres
--

ALTER SEQUENCE mms.customer_deposit_transaction_id_seq OWNED BY mms.customer_deposit_transaction.id;


--
-- Name: customer_master; Type: TABLE; Schema: mms; Owner: postgres
--

CREATE TABLE mms.customer_master (
    id integer NOT NULL,
    customer_name character varying(100) NOT NULL,
    mobile_number character varying(15) NOT NULL,
    email character varying(100),
    address text,
    village character varying(50),
    district character varying(50),
    state character varying(50),
    pincode character varying(10),
    referral_customer_id integer,
    kyc_verified boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone,
    updated_date timestamp without time zone
);


ALTER TABLE mms.customer_master OWNER TO postgres;

--
-- Name: customer_master_id_seq; Type: SEQUENCE; Schema: mms; Owner: postgres
--

CREATE SEQUENCE mms.customer_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.customer_master_id_seq OWNER TO postgres;

--
-- Name: customer_master_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: postgres
--

ALTER SEQUENCE mms.customer_master_id_seq OWNED BY mms.customer_master.id;


--
-- Name: item_master; Type: TABLE; Schema: mms; Owner: postgres
--

CREATE TABLE mms.item_master (
    id integer NOT NULL,
    item_name character varying(50) NOT NULL,
    item_code character varying(20) NOT NULL,
    unit_id integer NOT NULL,
    unit_quantity numeric(10,3) NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone,
    updated_date timestamp without time zone
);


ALTER TABLE mms.item_master OWNER TO postgres;

--
-- Name: item_master_id_seq; Type: SEQUENCE; Schema: mms; Owner: postgres
--

CREATE SEQUENCE mms.item_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.item_master_id_seq OWNER TO postgres;

--
-- Name: item_master_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: postgres
--

ALTER SEQUENCE mms.item_master_id_seq OWNED BY mms.item_master.id;


--
-- Name: item_price_history; Type: TABLE; Schema: mms; Owner: postgres
--

CREATE TABLE mms.item_price_history (
    id integer NOT NULL,
    item_id integer NOT NULL,
    price numeric(12,2) NOT NULL,
    effective_date date NOT NULL,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone
);


ALTER TABLE mms.item_price_history OWNER TO postgres;

--
-- Name: item_price_history_id_seq; Type: SEQUENCE; Schema: mms; Owner: postgres
--

CREATE SEQUENCE mms.item_price_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.item_price_history_id_seq OWNER TO postgres;

--
-- Name: item_price_history_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: postgres
--

ALTER SEQUENCE mms.item_price_history_id_seq OWNED BY mms.item_price_history.id;


--
-- Name: merchant_item_entry; Type: TABLE; Schema: mms; Owner: postgres
--

CREATE TABLE mms.merchant_item_entry (
    id integer NOT NULL,
    merchant_id integer NOT NULL,
    customer_deposit_item_id integer NOT NULL,
    entry_date date NOT NULL,
    interest_rate numeric(5,2) NOT NULL,
    entry_status character varying(30) DEFAULT 'ACTIVE'::character varying NOT NULL,
    notes text,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone,
    updated_date timestamp without time zone,
    principal_amount numeric(19,4)
);


ALTER TABLE mms.merchant_item_entry OWNER TO postgres;

--
-- Name: merchant_item_entry_id_seq; Type: SEQUENCE; Schema: mms; Owner: postgres
--

CREATE SEQUENCE mms.merchant_item_entry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.merchant_item_entry_id_seq OWNER TO postgres;

--
-- Name: merchant_item_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: postgres
--

ALTER SEQUENCE mms.merchant_item_entry_id_seq OWNED BY mms.merchant_item_entry.id;


--
-- Name: merchant_item_transaction; Type: TABLE; Schema: mms; Owner: postgres
--

CREATE TABLE mms.merchant_item_transaction (
    id integer NOT NULL,
    merchant_item_entry_id integer NOT NULL,
    transaction_type character varying(30) NOT NULL,
    amount numeric(12,2) NOT NULL,
    transaction_date date NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone
);


ALTER TABLE mms.merchant_item_transaction OWNER TO postgres;

--
-- Name: merchant_item_transaction_id_seq; Type: SEQUENCE; Schema: mms; Owner: postgres
--

CREATE SEQUENCE mms.merchant_item_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.merchant_item_transaction_id_seq OWNER TO postgres;

--
-- Name: merchant_item_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: postgres
--

ALTER SEQUENCE mms.merchant_item_transaction_id_seq OWNED BY mms.merchant_item_transaction.id;


--
-- Name: merchant_master; Type: TABLE; Schema: mms; Owner: postgres
--

CREATE TABLE mms.merchant_master (
    id integer NOT NULL,
    merchant_name character varying(100) NOT NULL,
    merchant_type character varying(20) NOT NULL,
    mobile_number character varying(15) NOT NULL,
    address text,
    village character varying(50),
    district character varying(50),
    state character varying(50),
    pincode character varying(10),
    default_interest_rate numeric(5,2) NOT NULL,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone,
    updated_date timestamp without time zone
);


ALTER TABLE mms.merchant_master OWNER TO postgres;

--
-- Name: merchant_master_id_seq; Type: SEQUENCE; Schema: mms; Owner: postgres
--

CREATE SEQUENCE mms.merchant_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.merchant_master_id_seq OWNER TO postgres;

--
-- Name: merchant_master_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: postgres
--

ALTER SEQUENCE mms.merchant_master_id_seq OWNED BY mms.merchant_master.id;


--
-- Name: unit_master; Type: TABLE; Schema: mms; Owner: postgres
--

CREATE TABLE mms.unit_master (
    id integer NOT NULL,
    unit_name character varying(20) NOT NULL,
    unit_in_gram numeric(10,3) NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone,
    updated_date timestamp without time zone
);


ALTER TABLE mms.unit_master OWNER TO postgres;

--
-- Name: unit_master_id_seq; Type: SEQUENCE; Schema: mms; Owner: postgres
--

CREATE SEQUENCE mms.unit_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mms.unit_master_id_seq OWNER TO postgres;

--
-- Name: unit_master_id_seq; Type: SEQUENCE OWNED BY; Schema: mms; Owner: postgres
--

ALTER SEQUENCE mms.unit_master_id_seq OWNED BY mms.unit_master.id;


--
-- Name: v_customer_deposit_with_total; Type: VIEW; Schema: mms; Owner: postgres
--

CREATE VIEW mms.v_customer_deposit_with_total AS
 SELECT cde.id,
    cde.customer_id,
    cde.deposit_date,
    cde.total_interest_rate,
    cde.entry_status,
    cde.notes,
    COALESCE(sum(
        CASE
            WHEN ((cdt.transaction_type)::text = ANY (ARRAY[('INITIAL_MONEY'::character varying)::text, ('EXTRA_WITHDRAWAL'::character varying)::text])) THEN cdt.amount
            ELSE (0)::numeric
        END), (0)::numeric) AS total_amount_given,
    COALESCE(sum(
        CASE
            WHEN ((cdt.transaction_type)::text = 'INTEREST_PAYMENT'::text) THEN cdt.amount
            ELSE (0)::numeric
        END), (0)::numeric) AS total_interest_paid_to_customer,
    COALESCE(sum(
        CASE
            WHEN ((cdt.transaction_type)::text = 'INTEREST_RECEIVED'::text) THEN abs(cdt.amount)
            ELSE (0)::numeric
        END), (0)::numeric) AS total_interest_received_from_customer,
    COALESCE(sum(
        CASE
            WHEN (cdt.amount < (0)::numeric) THEN abs(cdt.amount)
            ELSE (0)::numeric
        END), (0)::numeric) AS total_amount_received,
    cde.is_active,
    cde.created_date,
    cde.updated_date
   FROM (mms.customer_deposit_entry cde
     LEFT JOIN mms.customer_deposit_transaction cdt ON ((cde.id = cdt.deposit_entry_id)))
  GROUP BY cde.id, cde.customer_id, cde.deposit_date, cde.total_interest_rate, cde.entry_status, cde.notes, cde.is_active, cde.created_date, cde.updated_date;


ALTER VIEW mms.v_customer_deposit_with_total OWNER TO postgres;

--
-- Name: v_deposit_items_current_value; Type: VIEW; Schema: mms; Owner: postgres
--

CREATE VIEW mms.v_deposit_items_current_value AS
 SELECT cdi.id,
    cdi.deposit_entry_id,
    cdi.item_id,
    im.item_name,
    cdi.weight_received,
    um.unit_name,
    cdi.fine_weight,
    iph.price AS current_price,
    (cdi.fine_weight * iph.price) AS current_item_value,
    cdi.item_status,
    cdi.created_date
   FROM (((mms.customer_deposit_items cdi
     JOIN mms.item_master im ON ((cdi.item_id = im.id)))
     JOIN mms.unit_master um ON ((cdi.weight_unit_id = um.id)))
     JOIN LATERAL ( SELECT item_price_history.price
           FROM mms.item_price_history
          WHERE ((item_price_history.item_id = im.id) AND (item_price_history.effective_date <= CURRENT_DATE))
          ORDER BY item_price_history.effective_date DESC
         LIMIT 1) iph ON (true));


ALTER VIEW mms.v_deposit_items_current_value OWNER TO postgres;

--
-- Name: v_deposit_summary_with_interest; Type: VIEW; Schema: mms; Owner: postgres
--

CREATE VIEW mms.v_deposit_summary_with_interest AS
 SELECT cde.id AS deposit_id,
    cde.customer_id,
    cde.deposit_date,
    cde.total_interest_rate,
    COALESCE(sum(cdi_val.current_item_value), (0)::numeric) AS total_current_item_value,
    COALESCE(sum(
        CASE
            WHEN ((cdt.transaction_type)::text = 'INTEREST_RECEIVED'::text) THEN cdt.amount
            ELSE (0)::numeric
        END), (0)::numeric) AS total_interest_accrued,
    COALESCE(sum(
        CASE
            WHEN ((cdt.transaction_type)::text = 'INTEREST_PAYMENT'::text) THEN cdt.amount
            ELSE (0)::numeric
        END), (0)::numeric) AS total_interest_paid,
    (COALESCE(sum(
        CASE
            WHEN ((cdt.transaction_type)::text = 'INTEREST_RECEIVED'::text) THEN cdt.amount
            ELSE (0)::numeric
        END), (0)::numeric) - COALESCE(sum(
        CASE
            WHEN ((cdt.transaction_type)::text = 'INTEREST_PAYMENT'::text) THEN cdt.amount
            ELSE (0)::numeric
        END), (0)::numeric)) AS unpaid_interest,
    cde.entry_status
   FROM (((mms.customer_deposit_entry cde
     LEFT JOIN mms.customer_deposit_items cdi ON ((cde.id = cdi.deposit_entry_id)))
     LEFT JOIN mms.v_deposit_items_current_value cdi_val ON ((cdi.id = cdi_val.id)))
     LEFT JOIN mms.customer_deposit_transaction cdt ON ((cde.id = cdt.deposit_entry_id)))
  GROUP BY cde.id, cde.customer_id, cde.deposit_date, cde.total_interest_rate, cde.entry_status;


ALTER VIEW mms.v_deposit_summary_with_interest OWNER TO postgres;

--
-- Name: config_property id; Type: DEFAULT; Schema: mms; Owner: mms
--

ALTER TABLE ONLY mms.config_property ALTER COLUMN id SET DEFAULT nextval('mms.config_property_id_seq'::regclass);


--
-- Name: customer_deposit_entry id; Type: DEFAULT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_entry ALTER COLUMN id SET DEFAULT nextval('mms.customer_deposit_entry_id_seq'::regclass);


--
-- Name: customer_deposit_items id; Type: DEFAULT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_items ALTER COLUMN id SET DEFAULT nextval('mms.customer_deposit_items_id_seq'::regclass);


--
-- Name: customer_deposit_transaction id; Type: DEFAULT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_transaction ALTER COLUMN id SET DEFAULT nextval('mms.customer_deposit_transaction_id_seq'::regclass);


--
-- Name: customer_master id; Type: DEFAULT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_master ALTER COLUMN id SET DEFAULT nextval('mms.customer_master_id_seq'::regclass);


--
-- Name: item_master id; Type: DEFAULT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.item_master ALTER COLUMN id SET DEFAULT nextval('mms.item_master_id_seq'::regclass);


--
-- Name: item_price_history id; Type: DEFAULT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.item_price_history ALTER COLUMN id SET DEFAULT nextval('mms.item_price_history_id_seq'::regclass);


--
-- Name: merchant_item_entry id; Type: DEFAULT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.merchant_item_entry ALTER COLUMN id SET DEFAULT nextval('mms.merchant_item_entry_id_seq'::regclass);


--
-- Name: merchant_item_transaction id; Type: DEFAULT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.merchant_item_transaction ALTER COLUMN id SET DEFAULT nextval('mms.merchant_item_transaction_id_seq'::regclass);


--
-- Name: merchant_master id; Type: DEFAULT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.merchant_master ALTER COLUMN id SET DEFAULT nextval('mms.merchant_master_id_seq'::regclass);


--
-- Name: unit_master id; Type: DEFAULT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.unit_master ALTER COLUMN id SET DEFAULT nextval('mms.unit_master_id_seq'::regclass);


--
-- Data for Name: config_property; Type: TABLE DATA; Schema: mms; Owner: mms
--

COPY mms.config_property (id, property_key, property_value, description, is_active, created_date, updated_date) FROM stdin;
2	business.address	Patan, Gujarat	Physical address for receipts	t	2026-01-03 16:01:59.08709	\N
3	business.mobile	+91 99245 80455	Primary contact number	t	2026-01-03 16:01:59.08709	\N
4	business.email	jaylaxmi@gamil.com	Business email address	t	2026-01-03 16:01:59.08709	\N
6	default.unit.master.id	1	Default unit ID (1 for GRAM)	t	2026-01-03 16:01:59.08709	\N
8	default.fine.percentage	75.0	Average default purity percentage for items	t	2026-01-03 16:01:59.08709	\N
9	system.currency.symbol	₹	Local currency symbol used for display	t	2026-01-03 16:01:59.08709	\N
10	system.risk.threshold.percentage	100	Risk status if Loan > X% of Asset Value	t	2026-01-03 16:01:59.08709	\N
11	system.pagination.default.size	10	Default rows per page in tables	t	2026-01-03 16:01:59.08709	\N
12	system.calendar.months.round_up	true	Whether to count partial month as full month	t	2026-01-03 16:01:59.08709	\N
13	default.customer.state	Gujarat	Default state for new customer creation	t	2026-01-03 16:05:28.556124	\N
5	business.gstin	GJ--------------	GST Registration Number	t	2026-01-03 16:01:59.08709	2026-01-03 16:12:42.079886
14	business.short_name	Jay Laxmi	Shorter name for sidebar logo	t	2026-01-03 16:17:25.519422	\N
7	default.customer.interest.rate	3.0	Default monthly interest rate for new deposits	t	2026-01-03 16:01:59.08709	2026-01-03 16:18:34.842951
15	default.giving.percentage	60.0	Default loan-to-value percentage for items	t	2026-01-03 16:31:42.426582	\N
16	system.encryption.secret-key	AntigravitySecretKey2024Secure!!	Secret key for API payload encryption	t	2026-01-10 17:15:54.398128	2026-01-10 17:28:08.937929
17	PG_DUMP_PATH	C:\\Program Files\\PostgreSQL\\17\\bin\\pg_dump.exe	Full path to the pg_dump executable	t	2026-01-10 21:04:44.551119	2026-01-10 21:04:44.551119
18	DB_HOST	localhost	Database server host address	t	2026-01-10 21:04:44.551119	2026-01-10 21:04:44.551119
19	DB_PORT	5432	Database server port number	t	2026-01-10 21:04:44.551119	2026-01-10 21:04:44.551119
20	DB_USER	mms	Username for database connection	t	2026-01-10 21:04:44.551119	2026-01-10 21:04:44.551119
21	DB_PASS	Mms@123	Password for database connection	t	2026-01-10 21:04:44.551119	2026-01-10 21:04:44.551119
22	DB_NAME	postgres	Name of the database	t	2026-01-10 21:04:44.551119	2026-01-10 21:04:44.551119
23	BACKUP_SCHEMA	mms	The specific schema name to backup	t	2026-01-10 21:04:44.551119	2026-01-10 21:04:44.551119
1	business.name	Jay Laxmi Jewellers Dhiran System	The official name of the business 11	t	2026-01-03 16:01:59.08709	2026-01-11 13:14:05.472914
\.


--
-- Data for Name: customer_deposit_entry; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.customer_deposit_entry (id, customer_id, deposit_date, total_interest_rate, entry_status, notes, is_active, created_date, updated_date, token_no, close_date) FROM stdin;
4	4	2025-12-13	2.00	ACTIVE	\N	t	2025-12-27 14:43:32.528827	2026-01-03 23:00:54.613109	4	\N
5	5	2025-12-01	2.00	ACTIVE	\N	t	2025-12-27 14:43:32.528827	2026-01-03 23:00:54.613109	5	\N
6	6	2025-11-28	2.00	ACTIVE	\N	t	2025-12-27 14:43:32.528827	2026-01-03 23:00:54.613109	6	\N
7	7	2025-12-21	2.00	ACTIVE	\N	t	2025-12-27 14:43:32.528827	2026-01-03 23:00:54.613109	7	\N
8	8	2025-12-17	2.00	ACTIVE	\N	t	2025-12-27 14:43:32.528827	2026-01-03 23:00:54.613109	8	\N
9	9	2025-12-11	2.00	ACTIVE	\N	t	2025-12-27 14:43:32.528827	2026-01-03 23:00:54.613109	9	\N
10	10	2025-12-02	2.00	ACTIVE	\N	t	2025-12-27 14:43:32.528827	2026-01-03 23:00:54.613109	10	\N
11	11	2025-12-17	2.00	ACTIVE	\N	t	2025-12-27 23:51:02.936526	2026-01-03 23:00:54.613109	11	\N
12	12	2025-12-07	2.00	ACTIVE	\N	t	2025-12-27 23:51:02.936526	2026-01-03 23:00:54.613109	12	\N
13	13	2025-12-14	2.00	ACTIVE	\N	t	2025-12-27 23:51:02.936526	2026-01-03 23:00:54.613109	13	\N
14	14	2025-12-22	2.00	ACTIVE	\N	t	2025-12-27 23:51:02.936526	2026-01-03 23:00:54.613109	14	\N
15	15	2025-12-10	2.00	ACTIVE	\N	t	2025-12-27 23:51:02.936526	2026-01-03 23:00:54.613109	15	\N
16	16	2025-12-12	2.00	ACTIVE	\N	t	2025-12-27 23:51:02.936526	2026-01-03 23:00:54.613109	16	\N
17	17	2025-12-19	2.00	ACTIVE	\N	t	2025-12-27 23:51:02.936526	2026-01-03 23:00:54.613109	17	\N
18	18	2025-12-24	2.00	ACTIVE	\N	t	2025-12-27 23:51:02.936526	2026-01-03 23:00:54.613109	18	\N
19	19	2025-12-17	2.00	ACTIVE	\N	t	2025-12-27 23:51:02.936526	2026-01-03 23:00:54.613109	19	\N
20	20	2025-12-27	2.00	ACTIVE	\N	t	2025-12-27 23:51:02.936526	2026-01-03 23:00:54.613109	20	\N
1	1	2025-10-01	3.00	ACTIVE	\N	t	2025-12-27 14:43:32.528827	2026-01-03 23:00:54.613109	1	\N
3	3	2025-12-19	2.00	CLOSED	\N	t	2025-12-27 14:43:32.528827	2026-01-03 23:00:54.613109	3	\N
21	22	2025-12-06	2.00	ACTIVE	\N	t	2025-12-31 01:05:00.052444	2026-01-03 23:00:54.613109	21	\N
22	23	2025-12-11	2.00	ACTIVE	\N	t	2025-12-31 01:05:00.052444	2026-01-03 23:00:54.613109	22	\N
23	24	2025-12-05	2.00	ACTIVE	\N	t	2025-12-31 01:05:00.052444	2026-01-03 23:00:54.613109	23	\N
24	25	2025-12-19	2.00	ACTIVE	\N	t	2025-12-31 01:05:00.052444	2026-01-03 23:00:54.613109	24	\N
25	26	2025-12-14	2.00	ACTIVE	\N	t	2025-12-31 01:05:00.052444	2026-01-03 23:00:54.613109	25	\N
26	27	2025-12-16	2.00	ACTIVE	\N	t	2025-12-31 01:05:00.052444	2026-01-03 23:00:54.613109	26	\N
27	28	2025-12-11	2.00	ACTIVE	\N	t	2025-12-31 01:05:00.052444	2026-01-03 23:00:54.613109	27	\N
28	29	2025-12-14	2.00	ACTIVE	\N	t	2025-12-31 01:05:00.052444	2026-01-03 23:00:54.613109	28	\N
29	30	2025-12-15	2.00	ACTIVE	\N	t	2025-12-31 01:05:00.052444	2026-01-03 23:00:54.613109	29	\N
30	31	2025-12-26	2.00	ACTIVE	\N	t	2025-12-31 01:05:00.052444	2026-01-03 23:00:54.613109	30	\N
31	32	2025-12-15	2.00	ACTIVE	\N	t	2025-12-31 01:05:07.332837	2026-01-03 23:00:54.613109	31	\N
32	33	2025-12-09	2.00	ACTIVE	\N	t	2025-12-31 01:05:07.332837	2026-01-03 23:00:54.613109	32	\N
33	34	2025-12-05	2.00	ACTIVE	\N	t	2025-12-31 01:05:07.332837	2026-01-03 23:00:54.613109	33	\N
34	35	2025-12-15	2.00	ACTIVE	\N	t	2025-12-31 01:05:07.332837	2026-01-03 23:00:54.613109	34	\N
35	36	2025-12-18	2.00	ACTIVE	\N	t	2025-12-31 01:05:07.332837	2026-01-03 23:00:54.613109	35	\N
36	37	2025-12-17	2.00	ACTIVE	\N	t	2025-12-31 01:05:07.332837	2026-01-03 23:00:54.613109	36	\N
37	38	2025-12-24	2.00	ACTIVE	\N	t	2025-12-31 01:05:07.332837	2026-01-03 23:00:54.613109	37	\N
38	39	2025-12-24	2.00	ACTIVE	\N	t	2025-12-31 01:05:07.332837	2026-01-03 23:00:54.613109	38	\N
39	40	2025-12-15	2.00	ACTIVE	\N	t	2025-12-31 01:05:07.332837	2026-01-03 23:00:54.613109	39	\N
40	41	2025-12-18	2.00	ACTIVE	\N	t	2025-12-31 01:05:07.332837	2026-01-03 23:00:54.613109	40	\N
41	42	2025-12-22	2.00	ACTIVE	\N	t	2025-12-31 01:05:12.245595	2026-01-03 23:00:54.613109	41	\N
42	43	2025-12-03	2.00	ACTIVE	\N	t	2025-12-31 01:05:12.245595	2026-01-03 23:00:54.613109	42	\N
43	44	2025-12-11	2.00	ACTIVE	\N	t	2025-12-31 01:05:12.245595	2026-01-03 23:00:54.613109	43	\N
44	45	2025-12-07	2.00	ACTIVE	\N	t	2025-12-31 01:05:12.245595	2026-01-03 23:00:54.613109	44	\N
45	46	2025-12-29	2.00	ACTIVE	\N	t	2025-12-31 01:05:12.245595	2026-01-03 23:00:54.613109	45	\N
46	47	2025-12-22	2.00	ACTIVE	\N	t	2025-12-31 01:05:12.245595	2026-01-03 23:00:54.613109	46	\N
47	48	2025-12-20	2.00	ACTIVE	\N	t	2025-12-31 01:05:12.245595	2026-01-03 23:00:54.613109	47	\N
48	49	2025-12-20	2.00	ACTIVE	\N	t	2025-12-31 01:05:12.245595	2026-01-03 23:00:54.613109	48	\N
49	50	2025-12-19	2.00	ACTIVE	\N	t	2025-12-31 01:05:12.245595	2026-01-03 23:00:54.613109	49	\N
50	51	2025-12-19	2.00	ACTIVE	\N	t	2025-12-31 01:05:12.245595	2026-01-03 23:00:54.613109	50	\N
51	52	2025-12-04	2.00	ACTIVE	\N	t	2025-12-31 01:05:13.921353	2026-01-03 23:00:54.613109	51	\N
52	53	2025-12-16	2.00	ACTIVE	\N	t	2025-12-31 01:05:13.921353	2026-01-03 23:00:54.613109	52	\N
53	54	2025-12-05	2.00	ACTIVE	\N	t	2025-12-31 01:05:13.921353	2026-01-03 23:00:54.613109	53	\N
54	55	2025-12-13	2.00	ACTIVE	\N	t	2025-12-31 01:05:13.921353	2026-01-03 23:00:54.613109	54	\N
55	56	2025-12-26	2.00	ACTIVE	\N	t	2025-12-31 01:05:13.921353	2026-01-03 23:00:54.613109	55	\N
56	57	2025-12-20	2.00	ACTIVE	\N	t	2025-12-31 01:05:13.921353	2026-01-03 23:00:54.613109	56	\N
57	58	2025-12-22	2.00	ACTIVE	\N	t	2025-12-31 01:05:13.921353	2026-01-03 23:00:54.613109	57	\N
58	59	2025-12-23	2.00	ACTIVE	\N	t	2025-12-31 01:05:13.921353	2026-01-03 23:00:54.613109	58	\N
59	60	2025-12-26	2.00	ACTIVE	\N	t	2025-12-31 01:05:13.921353	2026-01-03 23:00:54.613109	59	\N
60	61	2025-12-14	2.00	ACTIVE	\N	t	2025-12-31 01:05:13.921353	2026-01-03 23:00:54.613109	60	\N
2	1	2025-12-18	2.00	CLOSED	\N	t	2025-12-27 14:43:32.528827	2026-01-03 23:00:54.613109	2	\N
61	21	2026-01-03	3.00	ACTIVE	adnsadjndkjnd	t	2026-01-03 23:40:59.60946	\N	61	\N
62	21	2026-01-03	3.00	ACTIVE	scdsfdfdfsdfdf	t	2026-01-03 23:45:18.657316	\N	62	\N
64	63	2026-01-10	3.00	CLOSED	hbchbsdhcsjc	t	2026-01-11 00:30:14.664914	2026-01-11 02:22:06.189366	63	\N
\.


--
-- Data for Name: customer_deposit_items; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.customer_deposit_items (id, deposit_entry_id, item_id, item_date, weight_received, weight_unit_id, fine_weight, item_status, item_description, is_active, created_date, updated_date) FROM stdin;
3	3	1	2025-12-19	58.672	1	52.805	DEPOSITED	Gold Ornament Demo 2	t	2025-12-27 14:43:32.528827	\N
4	4	1	2025-12-13	23.150	1	20.835	DEPOSITED	Gold Ornament Demo 3	t	2025-12-27 14:43:32.528827	\N
5	5	1	2025-12-01	46.448	1	41.803	DEPOSITED	Gold Ornament Demo 4	t	2025-12-27 14:43:32.528827	\N
6	6	1	2025-11-28	30.737	1	27.663	DEPOSITED	Gold Ornament Demo 5	t	2025-12-27 14:43:32.528827	\N
7	7	1	2025-12-21	44.440	1	39.996	DEPOSITED	Gold Ornament Demo 6	t	2025-12-27 14:43:32.528827	\N
8	8	1	2025-12-17	23.634	1	21.271	DEPOSITED	Gold Ornament Demo 7	t	2025-12-27 14:43:32.528827	\N
11	11	1	2025-12-17	58.783	1	52.905	DEPOSITED	Gold Ornament Demo 0	t	2025-12-27 23:51:02.936526	\N
12	12	1	2025-12-07	48.700	1	43.830	DEPOSITED	Gold Ornament Demo 1	t	2025-12-27 23:51:02.936526	\N
13	13	1	2025-12-14	41.486	1	37.337	DEPOSITED	Gold Ornament Demo 2	t	2025-12-27 23:51:02.936526	\N
14	14	1	2025-12-22	49.967	1	44.970	DEPOSITED	Gold Ornament Demo 3	t	2025-12-27 23:51:02.936526	\N
15	15	1	2025-12-10	59.076	1	53.168	DEPOSITED	Gold Ornament Demo 4	t	2025-12-27 23:51:02.936526	\N
16	16	1	2025-12-12	11.819	1	10.637	DEPOSITED	Gold Ornament Demo 5	t	2025-12-27 23:51:02.936526	\N
18	18	1	2025-12-24	20.378	1	18.340	DEPOSITED	Gold Ornament Demo 7	t	2025-12-27 23:51:02.936526	\N
20	20	1	2025-12-27	20.800	1	18.720	DEPOSITED	Gold Ornament Demo 9	t	2025-12-27 23:51:02.936526	\N
58	51	1	2025-12-04	48.438	1	43.594	DEPOSITED	Gold Ornament Demo 0	t	2025-12-31 01:05:13.921353	\N
2	2	1	2025-12-18	49.121	1	44.209	PLEDGED_TO_MERCHANT	Gold Ornament Demo 1	t	2025-12-27 14:43:32.528827	2025-12-28 02:04:11.181778
59	52	1	2025-12-16	56.993	1	51.294	DEPOSITED	Gold Ornament Demo 1	t	2025-12-31 01:05:13.921353	\N
17	17	1	2025-12-19	36.564	1	32.908	PLEDGED_TO_MERCHANT	Gold Ornament Demo 6	t	2025-12-27 23:51:02.936526	2025-12-28 02:48:58.432921
60	53	1	2025-12-05	47.065	1	42.359	DEPOSITED	Gold Ornament Demo 2	t	2025-12-31 01:05:13.921353	\N
61	54	1	2025-12-13	46.880	1	42.192	DEPOSITED	Gold Ornament Demo 3	t	2025-12-31 01:05:13.921353	\N
62	55	1	2025-12-26	57.762	1	51.986	DEPOSITED	Gold Ornament Demo 4	t	2025-12-31 01:05:13.921353	\N
41	34	1	2025-12-15	31.272	1	28.145	PLEDGED_TO_MERCHANT	Gold Ornament Demo 3	t	2025-12-31 01:05:07.332837	2025-12-31 03:35:52.629878
19	19	1	2025-12-17	57.988	1	52.189	PLEDGED_TO_MERCHANT	Gold Ornament Demo 8	t	2025-12-27 23:51:02.936526	2025-12-28 03:17:32.199909
10	10	1	2025-12-02	28.722	1	25.850	PLEDGED_TO_MERCHANT	Gold Ornament Demo 9	t	2025-12-27 14:43:32.528827	2025-12-28 03:17:32.199831
56	49	1	2025-12-19	50.850	1	45.765	PLEDGED_TO_MERCHANT	Gold Ornament Demo 8	t	2025-12-31 01:05:12.245595	2025-12-31 03:35:52.629854
63	56	1	2025-12-20	55.309	1	49.778	DEPOSITED	Gold Ornament Demo 5	t	2025-12-31 01:05:13.921353	\N
68	61	1	2026-01-03	15.000	1	11.250	DEPOSITED	ndqbdqdb	t	2026-01-03 23:40:59.60946	\N
28	21	1	2025-12-06	28.785	1	25.906	DEPOSITED	Gold Ornament Demo 0	t	2025-12-31 01:05:00.052444	\N
29	22	1	2025-12-11	31.411	1	28.270	DEPOSITED	Gold Ornament Demo 1	t	2025-12-31 01:05:00.052444	\N
30	23	1	2025-12-05	23.013	1	20.712	DEPOSITED	Gold Ornament Demo 2	t	2025-12-31 01:05:00.052444	\N
31	24	1	2025-12-19	58.683	1	52.815	DEPOSITED	Gold Ornament Demo 3	t	2025-12-31 01:05:00.052444	\N
32	25	1	2025-12-14	30.291	1	27.262	DEPOSITED	Gold Ornament Demo 4	t	2025-12-31 01:05:00.052444	\N
33	26	1	2025-12-16	48.115	1	43.303	DEPOSITED	Gold Ornament Demo 5	t	2025-12-31 01:05:00.052444	\N
34	27	1	2025-12-11	55.136	1	49.622	DEPOSITED	Gold Ornament Demo 6	t	2025-12-31 01:05:00.052444	\N
35	28	1	2025-12-14	35.025	1	31.522	DEPOSITED	Gold Ornament Demo 7	t	2025-12-31 01:05:00.052444	\N
36	29	1	2025-12-15	36.586	1	32.927	DEPOSITED	Gold Ornament Demo 8	t	2025-12-31 01:05:00.052444	\N
37	30	1	2025-12-26	36.235	1	32.612	DEPOSITED	Gold Ornament Demo 9	t	2025-12-31 01:05:00.052444	\N
38	31	1	2025-12-15	38.812	1	34.931	DEPOSITED	Gold Ornament Demo 0	t	2025-12-31 01:05:07.332837	\N
39	32	1	2025-12-09	33.102	1	29.792	DEPOSITED	Gold Ornament Demo 1	t	2025-12-31 01:05:07.332837	\N
40	33	1	2025-12-05	37.030	1	33.327	DEPOSITED	Gold Ornament Demo 2	t	2025-12-31 01:05:07.332837	\N
42	35	1	2025-12-18	53.455	1	48.109	DEPOSITED	Gold Ornament Demo 4	t	2025-12-31 01:05:07.332837	\N
43	36	1	2025-12-17	14.772	1	13.295	DEPOSITED	Gold Ornament Demo 5	t	2025-12-31 01:05:07.332837	\N
44	37	1	2025-12-24	13.032	1	11.729	DEPOSITED	Gold Ornament Demo 6	t	2025-12-31 01:05:07.332837	\N
46	39	1	2025-12-15	48.542	1	43.688	DEPOSITED	Gold Ornament Demo 8	t	2025-12-31 01:05:07.332837	\N
47	40	1	2025-12-18	31.175	1	28.058	DEPOSITED	Gold Ornament Demo 9	t	2025-12-31 01:05:07.332837	\N
48	41	1	2025-12-22	16.028	1	14.425	DEPOSITED	Gold Ornament Demo 0	t	2025-12-31 01:05:12.245595	\N
49	42	1	2025-12-03	49.021	1	44.119	DEPOSITED	Gold Ornament Demo 1	t	2025-12-31 01:05:12.245595	\N
50	43	1	2025-12-11	34.258	1	30.832	DEPOSITED	Gold Ornament Demo 2	t	2025-12-31 01:05:12.245595	\N
51	44	1	2025-12-07	15.868	1	14.281	DEPOSITED	Gold Ornament Demo 3	t	2025-12-31 01:05:12.245595	\N
52	45	1	2025-12-29	13.152	1	11.837	DEPOSITED	Gold Ornament Demo 4	t	2025-12-31 01:05:12.245595	\N
53	46	1	2025-12-22	33.330	1	29.997	DEPOSITED	Gold Ornament Demo 5	t	2025-12-31 01:05:12.245595	\N
54	47	1	2025-12-20	25.937	1	23.344	DEPOSITED	Gold Ornament Demo 6	t	2025-12-31 01:05:12.245595	\N
57	50	1	2025-12-19	15.662	1	14.096	DEPOSITED	Gold Ornament Demo 9	t	2025-12-31 01:05:12.245595	\N
64	57	1	2025-12-22	34.812	1	31.331	DEPOSITED	Gold Ornament Demo 6	t	2025-12-31 01:05:13.921353	\N
65	58	1	2025-12-23	13.642	1	12.278	DEPOSITED	Gold Ornament Demo 7	t	2025-12-31 01:05:13.921353	\N
66	59	1	2025-12-26	39.019	1	35.118	DEPOSITED	Gold Ornament Demo 8	t	2025-12-31 01:05:13.921353	\N
67	60	1	2025-12-14	32.397	1	29.158	DEPOSITED	Gold Ornament Demo 9	t	2025-12-31 01:05:13.921353	\N
9	9	1	2025-12-11	12.554	1	11.298	DEPOSITED	Gold Ornament Demo 8	t	2025-12-27 14:43:32.528827	2025-12-31 02:38:21.380186
22	1	1	2025-10-01	12.711	1	11.440	DEPOSITED	Gold Ornament Demo 0	t	2025-12-28 01:47:56.135694	2025-12-31 03:21:57.07015
69	62	1	2026-01-03	12.000	1	9.000	DEPOSITED	dsfsdfdfdfsdgggs	t	2026-01-03 23:45:18.657316	\N
23	1	2	2025-10-01	120.000	1	112.000	DEPOSITED	silver chen	t	2025-12-28 01:47:56.135694	2026-01-03 18:02:11.451161
45	38	1	2025-12-24	42.975	1	38.677	PLEDGED_TO_MERCHANT	Gold Ornament Demo 7	t	2025-12-31 01:05:07.332837	2026-01-10 18:56:04.658867
55	48	1	2025-12-20	50.192	1	45.172	PLEDGED_TO_MERCHANT	Gold Ornament Demo 7	t	2025-12-31 01:05:12.245595	2026-01-10 18:56:04.658868
72	64	1	2026-01-10	12.000	1	8.400	RETURNED	kala	t	2026-01-11 01:50:25.126285	2026-01-11 02:22:06.189366
73	64	2	2026-01-10	100000.000	2	75000.000	RETURNED	kabli	t	2026-01-11 01:50:25.126285	2026-01-11 02:22:06.189366
\.


--
-- Data for Name: customer_deposit_transaction; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.customer_deposit_transaction (id, deposit_entry_id, transaction_type, amount, transaction_date, description, is_active, created_date) FROM stdin;
2	2	INITIAL_MONEY	171924.01	2025-12-18	\N	t	2025-12-27 14:43:32.528827
3	3	INITIAL_MONEY	205353.34	2025-12-19	\N	t	2025-12-27 14:43:32.528827
4	4	INITIAL_MONEY	81023.77	2025-12-13	\N	t	2025-12-27 14:43:32.528827
5	5	INITIAL_MONEY	162566.72	2025-12-01	\N	t	2025-12-27 14:43:32.528827
6	6	INITIAL_MONEY	107580.00	2025-11-28	\N	t	2025-12-27 14:43:32.528827
7	7	INITIAL_MONEY	155541.19	2025-12-21	\N	t	2025-12-27 14:43:32.528827
8	8	INITIAL_MONEY	82718.97	2025-12-17	\N	t	2025-12-27 14:43:32.528827
9	9	INITIAL_MONEY	43937.72	2025-12-11	\N	t	2025-12-27 14:43:32.528827
10	10	INITIAL_MONEY	100526.22	2025-12-02	\N	t	2025-12-27 14:43:32.528827
11	11	INITIAL_MONEY	205741.12	2025-12-17	\N	t	2025-12-27 23:51:02.936526
12	12	INITIAL_MONEY	170450.65	2025-12-07	\N	t	2025-12-27 23:51:02.936526
13	13	INITIAL_MONEY	145200.10	2025-12-14	\N	t	2025-12-27 23:51:02.936526
14	14	INITIAL_MONEY	174883.85	2025-12-22	\N	t	2025-12-27 23:51:02.936526
15	15	INITIAL_MONEY	206765.34	2025-12-10	\N	t	2025-12-27 23:51:02.936526
16	16	INITIAL_MONEY	41366.25	2025-12-12	\N	t	2025-12-27 23:51:02.936526
17	17	INITIAL_MONEY	127974.59	2025-12-19	\N	t	2025-12-27 23:51:02.936526
18	18	INITIAL_MONEY	71321.71	2025-12-24	\N	t	2025-12-27 23:51:02.936526
19	19	INITIAL_MONEY	202957.70	2025-12-17	\N	t	2025-12-27 23:51:02.936526
20	20	INITIAL_MONEY	72798.41	2025-12-27	\N	t	2025-12-27 23:51:02.936526
1	1	INITIAL_MONEY	44487.41	2025-10-01	\N	t	2025-12-27 14:43:32.528827
21	1	INTEREST_PAYMENT	500.00	2025-12-28	abc	t	2025-12-28 17:56:30.63634
22	1	INTEREST_PAYMENT	1500.00	2025-12-31		t	2025-12-31 00:17:38.822238
23	3	PRINCIPAL_PAYMENT	205353.34	2025-12-31	Final Settlement (Full)	t	2025-12-31 00:36:46.591076
24	3	INTEREST_PAYMENT	4107.07	2025-12-31	Final Settlement (Full)	t	2025-12-31 00:36:46.591076
25	21	INITIAL_MONEY	100746.64	2025-12-06	\N	t	2025-12-31 01:05:00.052444
26	22	INITIAL_MONEY	109938.87	2025-12-11	\N	t	2025-12-31 01:05:00.052444
27	23	INITIAL_MONEY	80545.98	2025-12-05	\N	t	2025-12-31 01:05:00.052444
28	24	INITIAL_MONEY	205392.02	2025-12-19	\N	t	2025-12-31 01:05:00.052444
29	25	INITIAL_MONEY	106016.99	2025-12-14	\N	t	2025-12-31 01:05:00.052444
30	26	INITIAL_MONEY	168400.97	2025-12-16	\N	t	2025-12-31 01:05:00.052444
31	27	INITIAL_MONEY	192974.98	2025-12-11	\N	t	2025-12-31 01:05:00.052444
32	28	INITIAL_MONEY	122586.51	2025-12-14	\N	t	2025-12-31 01:05:00.052444
33	29	INITIAL_MONEY	128050.63	2025-12-15	\N	t	2025-12-31 01:05:00.052444
34	30	INITIAL_MONEY	126822.78	2025-12-26	\N	t	2025-12-31 01:05:00.052444
35	31	INITIAL_MONEY	135842.27	2025-12-15	\N	t	2025-12-31 01:05:07.332837
36	32	INITIAL_MONEY	115856.46	2025-12-09	\N	t	2025-12-31 01:05:07.332837
37	33	INITIAL_MONEY	129604.60	2025-12-05	\N	t	2025-12-31 01:05:07.332837
38	34	INITIAL_MONEY	109453.74	2025-12-15	\N	t	2025-12-31 01:05:07.332837
39	35	INITIAL_MONEY	187090.85	2025-12-18	\N	t	2025-12-31 01:05:07.332837
40	36	INITIAL_MONEY	51701.14	2025-12-17	\N	t	2025-12-31 01:05:07.332837
41	37	INITIAL_MONEY	45611.81	2025-12-24	\N	t	2025-12-31 01:05:07.332837
42	38	INITIAL_MONEY	150411.45	2025-12-24	\N	t	2025-12-31 01:05:07.332837
43	39	INITIAL_MONEY	169897.17	2025-12-15	\N	t	2025-12-31 01:05:07.332837
44	40	INITIAL_MONEY	109112.85	2025-12-18	\N	t	2025-12-31 01:05:07.332837
45	41	INITIAL_MONEY	56097.60	2025-12-22	\N	t	2025-12-31 01:05:12.245595
46	42	INITIAL_MONEY	171572.19	2025-12-03	\N	t	2025-12-31 01:05:12.245595
47	43	INITIAL_MONEY	119903.27	2025-12-11	\N	t	2025-12-31 01:05:12.245595
48	44	INITIAL_MONEY	55538.67	2025-12-07	\N	t	2025-12-31 01:05:12.245595
49	45	INITIAL_MONEY	46031.78	2025-12-29	\N	t	2025-12-31 01:05:12.245595
50	46	INITIAL_MONEY	116654.39	2025-12-22	\N	t	2025-12-31 01:05:12.245595
51	47	INITIAL_MONEY	90781.07	2025-12-20	\N	t	2025-12-31 01:05:12.245595
52	48	INITIAL_MONEY	175670.73	2025-12-20	\N	t	2025-12-31 01:05:12.245595
53	49	INITIAL_MONEY	177975.37	2025-12-19	\N	t	2025-12-31 01:05:12.245595
54	50	INITIAL_MONEY	54817.71	2025-12-19	\N	t	2025-12-31 01:05:12.245595
55	51	INITIAL_MONEY	169531.25	2025-12-04	\N	t	2025-12-31 01:05:13.921353
56	52	INITIAL_MONEY	199476.11	2025-12-16	\N	t	2025-12-31 01:05:13.921353
57	53	INITIAL_MONEY	164728.24	2025-12-05	\N	t	2025-12-31 01:05:13.921353
58	54	INITIAL_MONEY	164079.44	2025-12-13	\N	t	2025-12-31 01:05:13.921353
59	55	INITIAL_MONEY	202166.32	2025-12-26	\N	t	2025-12-31 01:05:13.921353
60	56	INITIAL_MONEY	193581.25	2025-12-20	\N	t	2025-12-31 01:05:13.921353
61	57	INITIAL_MONEY	121841.74	2025-12-22	\N	t	2025-12-31 01:05:13.921353
62	58	INITIAL_MONEY	47747.13	2025-12-23	\N	t	2025-12-31 01:05:13.921353
63	59	INITIAL_MONEY	136568.21	2025-12-26	\N	t	2025-12-31 01:05:13.921353
64	60	INITIAL_MONEY	113390.83	2025-12-14	\N	t	2025-12-31 01:05:13.921353
65	61	INITIAL_MONEY	80000.00	2026-01-03	\N	t	2026-01-03 23:40:59.60946
66	62	INITIAL_MONEY	50000.00	2026-01-03	\N	t	2026-01-03 23:45:18.657316
67	64	INITIAL_MONEY	50000.00	2026-01-10	\N	t	2026-01-11 00:30:14.664914
68	64	INTEREST_PAYMENT	500.00	2026-01-11		t	2026-01-11 01:51:25.077645
69	64	PRINCIPAL_PAYMENT	50000.00	2026-01-11	Final Settlement (Full)	t	2026-01-11 02:22:06.158272
70	64	INTEREST_PAYMENT	1000.00	2026-01-11	Final Settlement (Full)	t	2026-01-11 02:22:06.158272
\.


--
-- Data for Name: customer_master; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.customer_master (id, customer_name, mobile_number, email, address, village, district, state, pincode, referral_customer_id, kyc_verified, is_active, created_date, updated_date) FROM stdin;
2	Anita Mehta 65	9880279889	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 14:43:32.528827	\N
3	Ramesh Gupta 84	9890664810	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 14:43:32.528827	\N
4	Vikram Singh 29	9875728198	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 14:43:32.528827	\N
5	Sanjay Joshi 0	9892083367	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 14:43:32.528827	\N
8	Rajesh Kumar 12	9850832401	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 14:43:32.528827	\N
9	Anita Mehta 53	9882828721	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 14:43:32.528827	\N
10	Meera Iyer 60	9810552858	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 14:43:32.528827	\N
11	Vikram Singh 55	9832148804	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 23:51:02.936526	\N
12	Suresh Patel 94	9843834674	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 23:51:02.936526	\N
13	Priya Desai 9	9848486301	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 23:51:02.936526	\N
14	Suresh Patel 4	9814104984	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 23:51:02.936526	\N
15	Rahul Dravid 17	9882831888	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 23:51:02.936526	\N
16	Sanjay Joshi 94	9836625337	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 23:51:02.936526	\N
17	Anita Mehta 9	9836834353	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 23:51:02.936526	\N
18	Meera Iyer 64	9856153086	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 23:51:02.936526	\N
19	Anita Mehta 45	9888741021	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 23:51:02.936526	\N
20	Rahul Dravid 20	9885565324	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-27 23:51:02.936526	\N
22	Ramesh Gupta 50	9819492104	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:00.052444	\N
23	Anita Mehta 85	9824359157	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:00.052444	\N
24	Suresh Patel 7	9897493133	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:00.052444	\N
25	Priya Desai 97	9866196477	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:00.052444	\N
26	Rajesh Kumar 94	9834709262	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:00.052444	\N
27	Rahul Dravid 80	9892302478	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:00.052444	\N
28	Amit Shah 83	9872817289	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:00.052444	\N
29	Sanjay Joshi 37	9898917384	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:00.052444	\N
30	Vikram Singh 41	9813126667	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:00.052444	\N
31	Suresh Patel 37	9860227040	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:00.052444	\N
32	Sanjay Joshi 18	9815485660	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:07.332837	\N
33	Vikram Singh 73	9871361059	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:07.332837	\N
34	Rajesh Kumar 35	9834496843	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:07.332837	\N
35	Amit Shah 58	9865679315	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:07.332837	\N
36	Vikram Singh 90	9836931058	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:07.332837	\N
37	Sanjay Joshi 71	9826389354	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:07.332837	\N
38	Priya Desai 29	9831525556	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:07.332837	\N
39	Priya Desai 21	9861262564	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:07.332837	\N
40	Amit Shah 58	9839672027	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:07.332837	\N
41	Vikram Singh 15	9858393985	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:07.332837	\N
42	Meera Iyer 80	9825069075	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:12.245595	\N
43	Priya Desai 72	9815827248	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:12.245595	\N
44	Suresh Patel 41	9871308213	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:12.245595	\N
45	Suresh Patel 72	9887640627	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:12.245595	\N
46	Anita Mehta 35	9847506734	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:12.245595	\N
47	Anita Mehta 36	9871528319	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:12.245595	\N
48	Suresh Patel 20	9865073102	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:12.245595	\N
49	Meera Iyer 87	9833867704	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:12.245595	\N
50	Amit Shah 43	9884456486	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:12.245595	\N
51	Ramesh Gupta 26	9845198733	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:12.245595	\N
52	Anita Mehta 59	9882288788	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:13.921353	\N
53	Rahul Dravid 42	9842318111	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:13.921353	\N
54	Amit Shah 92	9887165809	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:13.921353	\N
55	Sanjay Joshi 16	9869281592	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:13.921353	\N
56	Rajesh Kumar 85	9838794075	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:13.921353	\N
57	Sanjay Joshi 15	9821126318	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:13.921353	\N
58	Meera Iyer 39	9842963750	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:13.921353	\N
59	Ramesh Gupta 35	9862526945	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:13.921353	\N
60	Suresh Patel 2	9815458284	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:13.921353	\N
61	Sanjay Joshi 0	9895895510	\N	\N	Demo Village	\N	\N	\N	\N	f	t	2025-12-31 01:05:13.921353	\N
6	Vikram Singh 82	9830614927	\N	\N	Demo Village	\N	\N	\N	2	f	t	2025-12-27 14:43:32.528827	2025-12-31 22:53:25.740327
7	Ramesh Gupta 21	9895591537	abc@gmail.com	Khokhar vado panchal vadi same patan	Demo Village	patan	Gujarat	384265	2	t	t	2025-12-27 14:43:32.528827	2025-12-31 22:57:11.885245
21	yash modi	7984940788	dishvamodi19@gmail.com	Khokhar vado panchal vadi same patan\r\nKhokhar vado panchal vadi same patan	Demo Village	patan	Gujarat	384265	2	t	t	2025-12-28 04:19:28.67154	2025-12-31 22:57:11.888037
1	Vikram Singh 42	9819571357	\N	\N	Demo Village	partg	gj	\N	22	t	t	2025-12-27 14:43:32.528827	2026-01-10 17:01:52.462228
63	Dishva Yash Modi	9987785547		Patan\nPatan38	Patan	patan	Gujarat		21	t	t	2026-01-10 21:35:26.309955	2026-01-10 21:35:26.304805
\.


--
-- Data for Name: item_master; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.item_master (id, item_name, item_code, unit_id, unit_quantity, description, is_active, created_date, updated_date) FROM stdin;
1	GOLD	GOLD	1	10.000	Gold jewelry and items	t	2025-11-16 01:33:04.450334	\N
2	SILVER	SILVER	2	1.000	Silver jewelry and items	t	2025-11-16 01:33:04.450334	\N
\.


--
-- Data for Name: item_price_history; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.item_price_history (id, item_id, price, effective_date, is_active, created_date) FROM stdin;
1	1	65000.00	2025-11-16	t	2025-11-16 01:33:04.450334
2	2	75000.00	2025-11-16	t	2025-11-16 01:33:04.450334
3	1	130000.00	2025-12-27	t	2025-12-27 18:00:27.673488
4	1	130000.00	2025-12-27	t	2025-12-27 18:00:44.421607
5	2	232000.00	2025-12-27	t	2025-12-27 20:26:49.343666
6	2	232000.00	2025-12-27	t	2025-12-27 20:26:53.40542
7	1	144000.00	2025-12-27	t	2025-12-27 20:29:08.278504
8	1	144000.00	2025-12-27	t	2025-12-27 20:38:07.290155
9	1	144000.00	2025-12-27	t	2025-12-27 20:38:23.435032
10	1	10000.00	2025-12-27	t	2025-12-27 20:40:04.071501
11	1	10000.00	2025-12-27	t	2025-12-27 20:40:11.374866
12	1	20000.00	2025-12-27	t	2025-12-27 20:42:06.836812
13	1	200020.00	2025-12-27	t	2025-12-27 20:46:29.90138
14	1	200020.00	2025-12-27	t	2025-12-27 20:46:38.550734
15	1	200020.00	2025-12-27	t	2025-12-27 20:47:00.977015
16	1	222200.00	2025-12-27	t	2025-12-27 20:51:44.33689
17	1	300000.00	2025-12-27	t	2025-12-27 21:37:40.315093
18	1	150000.00	2025-12-27	t	2025-12-27 22:11:28.436036
19	2	190000.00	2025-12-27	t	2025-12-27 23:13:59.883145
20	2	20000.00	2025-12-27	t	2025-12-27 23:14:13.148239
21	2	121212.00	2025-12-27	t	2025-12-27 23:16:46.614014
22	2	242000.00	2025-12-28	t	2025-12-28 00:05:35.46361
23	2	150000.00	2025-12-28	t	2025-12-28 00:17:05.818142
24	2	160000.00	2025-12-28	t	2025-12-28 00:17:17.937259
25	1	10000.00	2025-12-28	t	2025-12-28 00:55:04.074752
26	1	145000.00	2025-12-28	t	2025-12-28 10:10:44.625207
27	1	10000.00	2025-12-28	t	2025-12-28 16:39:08.967833
28	1	144000.00	2025-12-28	t	2025-12-28 17:38:58.607744
29	1	100000.00	2025-12-28	t	2025-12-28 18:32:01.060794
30	1	10000.00	2025-12-28	t	2025-12-28 18:32:30.684541
31	1	145000.00	2025-12-31	t	2025-12-31 01:25:19.335413
32	2	255000.00	2025-12-31	t	2025-12-31 01:25:29.362027
33	1	170000.00	2025-12-31	t	2025-12-31 20:55:10.849532
34	1	20000.00	2025-12-31	t	2025-12-31 20:56:50.241604
35	1	110000.00	2026-01-03	t	2026-01-03 17:57:07.455915
36	2	200000.00	2026-01-03	t	2026-01-03 17:57:55.430889
37	2	150000.00	2026-01-11	t	2026-01-11 02:22:53.366072
\.


--
-- Data for Name: merchant_item_entry; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.merchant_item_entry (id, merchant_id, customer_deposit_item_id, entry_date, interest_rate, entry_status, notes, is_active, created_date, updated_date, principal_amount) FROM stdin;
1	1	2	2025-12-27	1.50	ACTIVE	dfr	t	2025-12-28 02:04:11.181778	\N	\N
2	1	9	2025-12-27	1.50	RETURNED	were	t	2025-12-28 02:48:58.432922	2025-12-28 02:49:15.935648	30000.0000
3	1	19	2025-12-27	1.50	RETURNED	were\n[Redemption] Paid: 30450 (P:30000, I:450) hjhjhj	t	2025-12-28 02:48:58.433076	2025-12-28 02:59:42.846755	30000.0000
4	1	17	2025-08-01	1.50	ACTIVE		t	2025-12-28 02:48:58.432921	2025-12-28 03:37:04.085642	30000.0000
7	1	10	2025-12-27	1.00	ACTIVE		t	2025-12-28 03:17:32.199831	2025-12-28 14:05:46.50358	14467.6898
6	1	19	2025-09-28	1.00	ACTIVE		t	2025-12-28 03:17:32.199909	2025-12-28 15:48:38.723065	600000.0000
10	1	23	2025-12-28	1.00	RETURNED	adknabfdabfb\n[Redemption] Paid: 10100 (P:10000, I:100) 	t	2025-12-28 18:34:12.154725	2025-12-28 18:34:47.127899	10000.0000
5	1	9	2025-12-27	1.50	RETURNED	rgrrtrg	t	2025-12-28 03:17:32.19982	2025-12-31 02:38:21.380186	6218.0979
8	1	22	2025-12-28	1.50	RETURNED	XYZ	t	2025-12-28 10:14:50.297572	2025-12-31 03:21:57.07015	20000.0000
12	2	41	2025-12-30	1.00	ACTIVE		t	2025-12-31 03:35:52.629878	\N	38080.0974
11	2	56	2025-12-30	1.00	ACTIVE		t	2025-12-31 03:35:52.629854	\N	61919.9026
13	2	23	2025-12-31	1.00	RETURNED		t	2025-12-31 21:00:53.147499	2026-01-03 18:02:11.451161	15000.0000
14	2	55	2026-01-10	1.00	ACTIVE	jcbhsbhjdf	t	2026-01-10 18:56:04.658868	\N	538.7303
15	2	45	2026-01-10	1.00	ACTIVE	jcbhsbhjdf	t	2026-01-10 18:56:04.658867	\N	461.2697
16	4	72	2026-01-10	1.00	RETURNED		t	2026-01-11 02:07:46.485901	2026-01-11 02:13:17.803991	70000.0000
17	2	73	2026-01-10	1.00	RETURNED		t	2026-01-11 02:13:57.27402	2026-01-11 02:19:38.136012	1000.0000
\.


--
-- Data for Name: merchant_item_transaction; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.merchant_item_transaction (id, merchant_item_entry_id, transaction_type, amount, transaction_date, description, is_active, created_date) FROM stdin;
2	5	INTEREST_PAYMENT	94.85	2025-12-28	xyz	t	2025-12-28 14:34:00.820913
3	6	INTEREST_PAYMENT	438.14	2025-12-28	xyz	t	2025-12-28 15:25:26.768474
4	5	RETURN	6218.10	2025-12-31	Item Returned to Inventory	t	2025-12-31 02:38:21.380186
5	8	INTEREST_PAYMENT	300.00	2025-12-31	Redeemed during final settlement	t	2025-12-31 03:21:57.07015
6	8	RETURN	20000.00	2025-12-31	Item Returned to Inventory	t	2025-12-31 03:21:57.07015
7	12	PLEDGE	38080.10	2025-12-30		t	2025-12-31 03:35:52.629878
8	11	PLEDGE	61919.90	2025-12-30		t	2025-12-31 03:35:52.629854
9	13	PLEDGE	15000.00	2025-12-31		t	2025-12-31 21:00:53.147499
10	13	INTEREST_PAYMENT	150.00	2026-01-03	Redeemed during final settlement	t	2026-01-03 18:02:11.451161
11	13	RETURN	15000.00	2026-01-03	Item Returned to Inventory	t	2026-01-03 18:02:11.451161
12	15	PLEDGE	461.27	2026-01-10	jcbhsbhjdf	t	2026-01-10 18:56:04.658867
13	14	PLEDGE	538.73	2026-01-10	jcbhsbhjdf	t	2026-01-10 18:56:04.658868
14	16	PLEDGE	78000.00	2026-01-10	njnjn	t	2026-01-11 02:07:46.485901
15	16	INTEREST_PAYMENT	700.00	2026-01-11		t	2026-01-11 02:13:01.778878
16	16	RETURN	70000.00	2026-01-11	Item Returned to Inventory	t	2026-01-11 02:13:17.803991
17	17	PLEDGE	1000.00	2026-01-10		t	2026-01-11 02:13:57.27402
18	17	INTEREST_PAYMENT	10.00	2026-01-11	Redeemed during final settlement	t	2026-01-11 02:19:38.136012
19	17	RETURN	1000.00	2026-01-11	Item Returned to Inventory	t	2026-01-11 02:19:38.136012
\.


--
-- Data for Name: merchant_master; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.merchant_master (id, merchant_name, merchant_type, mobile_number, address, village, district, state, pincode, default_interest_rate, is_active, created_date, updated_date) FROM stdin;
2	Daharati	LENDER	9090898967	Deesa	\N	\N	\N	\N	1.00	t	2025-12-28 10:15:46.679524	2025-12-28 10:15:46.671737
3	chnadrakant bhai 	LENDER	7867986756	patan	\N	\N	\N	\N	2.00	f	2025-12-28 13:06:18.157416	2025-12-28 13:34:40.741076
1	Dishva Modi	JEWELLER	9879854676	patan	\N	\N	\N	\N	1.75	t	2025-12-28 02:03:25.182374	2025-12-28 13:50:08.178269
4	abc	JEWELLER	5456764532		\N	\N	\N	\N	1.00	t	2026-01-11 02:06:59.371457	2026-01-11 02:06:59.340523
\.


--
-- Data for Name: unit_master; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.unit_master (id, unit_name, unit_in_gram, description, is_active, created_date, updated_date) FROM stdin;
1	GRAM	1.000	Gram unit	t	2025-11-16 01:33:04.450334	\N
2	KG	1000.000	Kilogram unit	t	2025-11-16 01:33:04.450334	\N
\.


--
-- Name: config_property_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: mms
--

SELECT pg_catalog.setval('mms.config_property_id_seq', 23, true);


--
-- Name: customer_deposit_entry_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.customer_deposit_entry_id_seq', 64, true);


--
-- Name: customer_deposit_items_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.customer_deposit_items_id_seq', 73, true);


--
-- Name: customer_deposit_transaction_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.customer_deposit_transaction_id_seq', 70, true);


--
-- Name: customer_master_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.customer_master_id_seq', 63, true);


--
-- Name: item_master_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.item_master_id_seq', 2, true);


--
-- Name: item_price_history_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.item_price_history_id_seq', 37, true);


--
-- Name: merchant_item_entry_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.merchant_item_entry_id_seq', 17, true);


--
-- Name: merchant_item_transaction_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.merchant_item_transaction_id_seq', 19, true);


--
-- Name: merchant_master_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.merchant_master_id_seq', 4, true);


--
-- Name: unit_master_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.unit_master_id_seq', 2, true);


--
-- Name: config_property config_property_pkey; Type: CONSTRAINT; Schema: mms; Owner: mms
--

ALTER TABLE ONLY mms.config_property
    ADD CONSTRAINT config_property_pkey PRIMARY KEY (id);


--
-- Name: config_property config_property_property_key_key; Type: CONSTRAINT; Schema: mms; Owner: mms
--

ALTER TABLE ONLY mms.config_property
    ADD CONSTRAINT config_property_property_key_key UNIQUE (property_key);


--
-- Name: customer_deposit_entry customer_deposit_entry_pkey; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_entry
    ADD CONSTRAINT customer_deposit_entry_pkey PRIMARY KEY (id);


--
-- Name: customer_deposit_items customer_deposit_items_pkey; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_items
    ADD CONSTRAINT customer_deposit_items_pkey PRIMARY KEY (id);


--
-- Name: customer_deposit_transaction customer_deposit_transaction_pkey; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_transaction
    ADD CONSTRAINT customer_deposit_transaction_pkey PRIMARY KEY (id);


--
-- Name: customer_master customer_master_mobile_number_key; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_master
    ADD CONSTRAINT customer_master_mobile_number_key UNIQUE (mobile_number);


--
-- Name: customer_master customer_master_pkey; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_master
    ADD CONSTRAINT customer_master_pkey PRIMARY KEY (id);


--
-- Name: item_master item_master_item_code_key; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.item_master
    ADD CONSTRAINT item_master_item_code_key UNIQUE (item_code);


--
-- Name: item_master item_master_pkey; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.item_master
    ADD CONSTRAINT item_master_pkey PRIMARY KEY (id);


--
-- Name: item_price_history item_price_history_pkey; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.item_price_history
    ADD CONSTRAINT item_price_history_pkey PRIMARY KEY (id);


--
-- Name: merchant_item_entry merchant_item_entry_pkey; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.merchant_item_entry
    ADD CONSTRAINT merchant_item_entry_pkey PRIMARY KEY (id);


--
-- Name: merchant_item_transaction merchant_item_transaction_pkey; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.merchant_item_transaction
    ADD CONSTRAINT merchant_item_transaction_pkey PRIMARY KEY (id);


--
-- Name: merchant_master merchant_master_mobile_number_key; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.merchant_master
    ADD CONSTRAINT merchant_master_mobile_number_key UNIQUE (mobile_number);


--
-- Name: merchant_master merchant_master_pkey; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.merchant_master
    ADD CONSTRAINT merchant_master_pkey PRIMARY KEY (id);


--
-- Name: unit_master unit_master_pkey; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.unit_master
    ADD CONSTRAINT unit_master_pkey PRIMARY KEY (id);


--
-- Name: unit_master unit_master_unit_name_key; Type: CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.unit_master
    ADD CONSTRAINT unit_master_unit_name_key UNIQUE (unit_name);


--
-- Name: idx_customer_deposit_entry_customer; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_customer_deposit_entry_customer ON mms.customer_deposit_entry USING btree (customer_id);


--
-- Name: idx_customer_deposit_items_entry; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_customer_deposit_items_entry ON mms.customer_deposit_items USING btree (deposit_entry_id);


--
-- Name: idx_customer_deposit_items_weight_unit; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_customer_deposit_items_weight_unit ON mms.customer_deposit_items USING btree (weight_unit_id);


--
-- Name: idx_customer_deposit_transaction_entry; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_customer_deposit_transaction_entry ON mms.customer_deposit_transaction USING btree (deposit_entry_id);


--
-- Name: idx_customer_master_active; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_customer_master_active ON mms.customer_master USING btree (is_active);


--
-- Name: idx_customer_master_mobile; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_customer_master_mobile ON mms.customer_master USING btree (mobile_number);


--
-- Name: idx_item_master_active; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_item_master_active ON mms.item_master USING btree (is_active);


--
-- Name: idx_item_master_unit; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_item_master_unit ON mms.item_master USING btree (unit_id);


--
-- Name: idx_merchant_item_entry_merchant; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_merchant_item_entry_merchant ON mms.merchant_item_entry USING btree (merchant_id);


--
-- Name: idx_merchant_item_transaction_entry; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_merchant_item_transaction_entry ON mms.merchant_item_transaction USING btree (merchant_item_entry_id);


--
-- Name: idx_merchant_master_mobile; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_merchant_master_mobile ON mms.merchant_master USING btree (mobile_number);


--
-- Name: idx_unit_master_active; Type: INDEX; Schema: mms; Owner: postgres
--

CREATE INDEX idx_unit_master_active ON mms.unit_master USING btree (is_active);


--
-- Name: config_property config_property_insert_trigger; Type: TRIGGER; Schema: mms; Owner: mms
--

CREATE TRIGGER config_property_insert_trigger BEFORE INSERT ON mms.config_property FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: config_property config_property_update_trigger; Type: TRIGGER; Schema: mms; Owner: mms
--

CREATE TRIGGER config_property_update_trigger BEFORE UPDATE ON mms.config_property FOR EACH ROW EXECUTE FUNCTION mms.set_updated_date();


--
-- Name: customer_deposit_entry customer_deposit_entry_insert_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER customer_deposit_entry_insert_trigger BEFORE INSERT ON mms.customer_deposit_entry FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: customer_deposit_entry customer_deposit_entry_update_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER customer_deposit_entry_update_trigger BEFORE UPDATE ON mms.customer_deposit_entry FOR EACH ROW EXECUTE FUNCTION mms.set_updated_date();


--
-- Name: customer_deposit_items customer_deposit_items_insert_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER customer_deposit_items_insert_trigger BEFORE INSERT ON mms.customer_deposit_items FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: customer_deposit_items customer_deposit_items_update_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER customer_deposit_items_update_trigger BEFORE UPDATE ON mms.customer_deposit_items FOR EACH ROW EXECUTE FUNCTION mms.set_updated_date();


--
-- Name: customer_deposit_transaction customer_deposit_transaction_insert_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER customer_deposit_transaction_insert_trigger BEFORE INSERT ON mms.customer_deposit_transaction FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: customer_master customer_master_insert_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER customer_master_insert_trigger BEFORE INSERT ON mms.customer_master FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: customer_master customer_master_update_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER customer_master_update_trigger BEFORE UPDATE ON mms.customer_master FOR EACH ROW EXECUTE FUNCTION mms.set_updated_date();


--
-- Name: item_master item_master_insert_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER item_master_insert_trigger BEFORE INSERT ON mms.item_master FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: item_master item_master_update_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER item_master_update_trigger BEFORE UPDATE ON mms.item_master FOR EACH ROW EXECUTE FUNCTION mms.set_updated_date();


--
-- Name: item_price_history item_price_history_insert_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER item_price_history_insert_trigger BEFORE INSERT ON mms.item_price_history FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: merchant_item_entry merchant_item_entry_insert_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER merchant_item_entry_insert_trigger BEFORE INSERT ON mms.merchant_item_entry FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: merchant_item_entry merchant_item_entry_update_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER merchant_item_entry_update_trigger BEFORE UPDATE ON mms.merchant_item_entry FOR EACH ROW EXECUTE FUNCTION mms.set_updated_date();


--
-- Name: merchant_item_transaction merchant_item_transaction_insert_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER merchant_item_transaction_insert_trigger BEFORE INSERT ON mms.merchant_item_transaction FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: merchant_master merchant_master_insert_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER merchant_master_insert_trigger BEFORE INSERT ON mms.merchant_master FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: merchant_master merchant_master_update_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER merchant_master_update_trigger BEFORE UPDATE ON mms.merchant_master FOR EACH ROW EXECUTE FUNCTION mms.set_updated_date();


--
-- Name: unit_master unit_master_insert_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER unit_master_insert_trigger BEFORE INSERT ON mms.unit_master FOR EACH ROW EXECUTE FUNCTION mms.set_created_date_and_active();


--
-- Name: unit_master unit_master_update_trigger; Type: TRIGGER; Schema: mms; Owner: postgres
--

CREATE TRIGGER unit_master_update_trigger BEFORE UPDATE ON mms.unit_master FOR EACH ROW EXECUTE FUNCTION mms.set_updated_date();


--
-- Name: customer_deposit_entry customer_deposit_entry_customer_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_entry
    ADD CONSTRAINT customer_deposit_entry_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES mms.customer_master(id);


--
-- Name: customer_deposit_items customer_deposit_items_deposit_entry_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_items
    ADD CONSTRAINT customer_deposit_items_deposit_entry_id_fkey FOREIGN KEY (deposit_entry_id) REFERENCES mms.customer_deposit_entry(id);


--
-- Name: customer_deposit_items customer_deposit_items_item_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_items
    ADD CONSTRAINT customer_deposit_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES mms.item_master(id);


--
-- Name: customer_deposit_items customer_deposit_items_weight_unit_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_items
    ADD CONSTRAINT customer_deposit_items_weight_unit_id_fkey FOREIGN KEY (weight_unit_id) REFERENCES mms.unit_master(id);


--
-- Name: customer_deposit_transaction customer_deposit_transaction_deposit_entry_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_deposit_transaction
    ADD CONSTRAINT customer_deposit_transaction_deposit_entry_id_fkey FOREIGN KEY (deposit_entry_id) REFERENCES mms.customer_deposit_entry(id);


--
-- Name: customer_master customer_master_referral_customer_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.customer_master
    ADD CONSTRAINT customer_master_referral_customer_id_fkey FOREIGN KEY (referral_customer_id) REFERENCES mms.customer_master(id);


--
-- Name: item_master item_master_unit_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.item_master
    ADD CONSTRAINT item_master_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES mms.unit_master(id);


--
-- Name: item_price_history item_price_history_item_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.item_price_history
    ADD CONSTRAINT item_price_history_item_id_fkey FOREIGN KEY (item_id) REFERENCES mms.item_master(id);


--
-- Name: merchant_item_entry merchant_item_entry_customer_deposit_item_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.merchant_item_entry
    ADD CONSTRAINT merchant_item_entry_customer_deposit_item_id_fkey FOREIGN KEY (customer_deposit_item_id) REFERENCES mms.customer_deposit_items(id);


--
-- Name: merchant_item_entry merchant_item_entry_merchant_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.merchant_item_entry
    ADD CONSTRAINT merchant_item_entry_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES mms.merchant_master(id);


--
-- Name: merchant_item_transaction merchant_item_transaction_merchant_item_entry_id_fkey; Type: FK CONSTRAINT; Schema: mms; Owner: postgres
--

ALTER TABLE ONLY mms.merchant_item_transaction
    ADD CONSTRAINT merchant_item_transaction_merchant_item_entry_id_fkey FOREIGN KEY (merchant_item_entry_id) REFERENCES mms.merchant_item_entry(id);


--
-- PostgreSQL database dump complete
--

