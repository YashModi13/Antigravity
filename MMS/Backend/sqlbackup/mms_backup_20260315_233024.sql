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
    close_date date,
    is_verified boolean DEFAULT false NOT NULL
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
    mobile_number character varying(15),
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
    mobile_number character varying(15),
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
1	business.name	Jay Laxmi Jewellers Dhiran System	The official name of the business	t	2026-01-03 16:01:59.08709	2026-01-11 13:12:59.368581
\.


--
-- Data for Name: customer_deposit_entry; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.customer_deposit_entry (id, customer_id, deposit_date, total_interest_rate, entry_status, notes, is_active, created_date, updated_date, token_no, close_date, is_verified) FROM stdin;
3	8	2020-07-25	3.00	ACTIVE		t	2026-02-03 20:52:05.024615	2026-03-01 10:34:32.282269	105	\N	t
18	23	2021-06-16	3.00	ACTIVE	5000+25000=30000 Jama 29/01/2026\n20000 nu dhiran lidhu hatu\n23500 baki	t	2026-02-03 22:10:38.214613	2026-03-15 14:59:39.303276	313	\N	t
16	21	2021-04-24	3.00	ACTIVE		t	2026-02-03 21:56:06.77965	2026-03-01 11:18:15.094815	286	\N	t
1	1	2020-12-24	3.00	ACTIVE		t	2026-02-01 14:36:05.39046	2026-03-01 10:30:07.632117	25	\N	t
2	2	2020-01-18	3.00	ACTIVE		t	2026-02-01 17:06:39.834298	2026-03-01 10:32:21.674156	43	\N	t
6	11	2020-10-28	3.00	ACTIVE		t	2026-02-03 21:04:04.148368	2026-03-01 10:41:27.974772	175	\N	t
9	14	2020-10-13	3.00	ACTIVE		t	2026-02-03 21:15:54.812681	2026-03-01 11:10:29.869458	192	\N	t
11	37	2021-02-27	3.00	ACTIVE		t	2026-02-03 21:29:05.181516	2026-03-01 11:11:47.644712	250	\N	t
13	18	2021-03-18	3.00	ACTIVE		t	2026-02-03 21:34:25.970568	2026-03-01 11:13:23.551295	264	\N	t
14	19	2021-04-12	3.00	ACTIVE		t	2026-02-03 21:36:35.148215	2026-03-01 11:14:46.313633	277	\N	t
15	20	2021-04-16	3.00	ACTIVE	10000+6000=16000\n21/06/2021  \n3000+3000=6000\nTotal=22000\n\nwith tambu WT: 96 Gram	t	2026-02-03 21:48:18.351984	2026-03-01 11:17:06.344178	279	\N	t
19	24	2021-07-22	3.00	ACTIVE		t	2026-02-03 22:13:41.857354	2026-03-01 11:23:20.105574	330	\N	t
33	38	2022-07-05	3.00	ACTIVE		t	2026-02-04 21:07:29.303267	2026-03-01 11:39:48.21044	608	\N	t
34	39	2022-08-30	3.00	ACTIVE		t	2026-02-04 21:09:42.958453	2026-03-01 11:40:31.701716	673	\N	t
35	17	2022-09-07	3.00	ACTIVE		t	2026-02-04 21:11:57.49946	2026-03-01 11:43:11.977573	686	\N	t
56	66	2023-02-22	3.00	CLOSED		t	2026-02-09 22:42:49.158064	2026-03-01 11:56:38.738804	861	2026-02-23	t
58	17	2023-03-23	3.00	ACTIVE		t	2026-02-09 22:58:19.573654	2026-03-01 11:58:58.441969	878	\N	t
61	13	2023-05-28	3.00	ACTIVE		t	2026-02-09 23:05:26.395832	2026-03-01 12:00:47.930578	935	\N	t
68	76	2023-07-06	3.00	ACTIVE		t	2026-02-10 22:00:35.703167	2026-03-01 12:02:28.175188	977	\N	t
70	78	2023-07-13	3.00	ACTIVE		t	2026-02-10 22:05:19.103269	2026-03-01 12:03:31.195704	986	\N	t
74	81	2023-11-22	3.00	ACTIVE		t	2026-02-11 21:16:03.908982	2026-03-15 19:25:55.242803	1106	\N	f
21	26	2021-07-28	3.00	CLOSED		t	2026-02-03 22:17:36.269683	2026-03-01 10:28:25.911579	345	2026-02-07	f
77	72	2024-02-26	3.00	ACTIVE	9978701185	t	2026-02-11 21:28:04.179787	2026-03-01 10:28:25.911579	1212	\N	f
80	86	2024-10-21	3.00	ACTIVE		t	2026-02-11 21:42:48.722376	2026-03-01 10:28:25.911579	1399	\N	f
83	89	2024-11-16	3.00	ACTIVE		t	2026-02-11 21:46:19.960898	2026-03-01 10:28:25.911579	1419	\N	f
88	80	2024-12-05	3.00	ACTIVE		t	2026-02-11 21:53:03.016464	2026-03-01 10:28:25.911579	1430	\N	f
89	94	2024-12-12	3.00	ACTIVE		t	2026-02-11 21:57:39.656908	2026-03-01 10:28:25.911579	1434	\N	f
72	79	2023-08-07	3.00	ACTIVE		t	2026-02-11 21:00:27.061917	2026-03-01 10:28:25.911579	1021	\N	f
112	109	2025-03-10	3.00	ACTIVE		t	2026-02-12 20:38:54.778872	2026-03-01 10:28:25.911579	1492	\N	f
113	110	2025-03-12	3.00	ACTIVE		t	2026-02-12 20:41:27.660786	2026-03-01 10:28:25.911579	1494	\N	f
115	106	2025-03-26	3.00	ACTIVE		t	2026-02-12 20:45:03.225059	2026-03-01 10:28:25.911579	1503	\N	f
84	90	2024-11-23	3.00	ACTIVE		t	2026-02-11 21:47:26.741414	2026-03-01 10:28:25.911579	1423	\N	f
90	90	2024-12-20	3.00	ACTIVE		t	2026-02-11 21:58:49.604985	2026-03-01 10:28:25.911579	1441	\N	f
117	38	2025-03-26	3.00	ACTIVE		t	2026-02-12 20:48:17.249956	2026-03-01 10:28:25.911579	1506	\N	f
118	113	2025-03-27	3.00	ACTIVE		t	2026-02-12 20:49:56.139652	2026-03-01 10:28:25.911579	1507	\N	f
64	72	2023-12-22	3.00	ACTIVE		t	2026-02-10 21:03:04.020293	2026-03-01 10:28:25.911579	1154	\N	f
120	115	2025-04-16	3.00	ACTIVE		t	2026-02-12 20:53:10.711751	2026-03-01 10:28:25.911579	1523	\N	f
91	71	2024-12-25	3.00	ACTIVE		t	2026-02-11 22:00:14.026323	2026-03-01 10:28:25.911579	1443	\N	f
92	95	2024-12-26	3.00	ACTIVE		t	2026-02-11 22:04:15.288049	2026-03-01 10:28:25.911579	1445	\N	f
93	85	2024-08-19	3.00	ACTIVE		t	2026-02-11 22:05:22.925925	2026-03-01 10:28:25.911579	1446	\N	f
95	96	2025-01-06	3.00	ACTIVE		t	2026-02-11 22:08:07.040165	2026-03-01 10:28:25.911579	1453	\N	f
96	97	2024-07-06	3.00	ACTIVE		t	2026-02-11 22:14:50.244512	2026-03-01 10:28:25.911579	1314	\N	f
99	100	2024-08-03	3.00	ACTIVE		t	2026-02-11 22:19:17.553746	2026-03-01 10:28:25.911579	1340	\N	f
100	101	2024-08-09	3.00	ACTIVE		t	2026-02-11 22:21:20.636454	2026-03-01 10:28:25.911579	1346	\N	f
101	17	2024-09-05	3.00	ACTIVE		t	2026-02-11 22:22:42.058446	2026-03-01 10:28:25.911579	1365	\N	f
102	102	2024-09-16	3.00	ACTIVE		t	2026-02-11 22:24:07.619729	2026-03-01 10:28:25.911579	1375	\N	f
104	104	2024-10-08	3.00	ACTIVE		t	2026-02-11 22:26:44.35576	2026-03-01 10:28:25.911579	1389	\N	f
105	105	2024-10-18	3.00	ACTIVE		t	2026-02-11 22:28:13.281443	2026-03-01 10:28:25.911579	1397	\N	f
123	118	2025-05-02	3.00	ACTIVE		t	2026-02-12 21:04:31.513346	2026-03-01 10:28:25.911579	1531	\N	f
107	53	2023-11-03	3.00	ACTIVE		t	2026-02-11 22:32:21.768893	2026-03-01 10:28:25.911579	1094	\N	f
86	92	2024-11-28	3.00	ACTIVE		t	2026-02-11 21:50:25.629301	2026-03-01 10:28:25.911579	1427	\N	f
82	88	2024-11-14	3.00	ACTIVE		t	2026-02-11 21:45:08.754657	2026-03-01 10:28:25.911579	1414	\N	f
109	107	2025-02-22	3.00	ACTIVE		t	2026-02-12 20:34:20.588306	2026-03-01 10:28:25.911579	1482	\N	f
110	88	2025-02-22	3.00	ACTIVE		t	2026-02-12 20:35:46.584357	2026-03-01 10:28:25.911579	1483	\N	f
111	108	2025-02-28	3.00	ACTIVE		t	2026-02-12 20:37:14.396118	2026-03-01 10:28:25.911579	1488	\N	f
128	53	2025-05-14	3.00	ACTIVE		t	2026-02-12 21:10:53.619603	2026-03-01 10:28:25.911579	1542	\N	f
129	99	2025-05-17	3.00	ACTIVE		t	2026-02-12 21:11:58.265949	2026-03-01 10:28:25.911579	1544	\N	f
130	121	2025-05-23	3.00	ACTIVE		t	2026-02-12 21:12:56.047659	2026-03-01 10:28:25.911579	1546	\N	f
132	122	2025-06-12	3.00	ACTIVE		t	2026-02-12 21:19:28.813314	2026-03-01 10:28:25.911579	1563	\N	f
133	123	2025-06-17	3.00	ACTIVE		t	2026-02-12 21:21:48.519899	2026-03-01 10:28:25.911579	1567	\N	f
136	124	2025-07-12	3.00	ACTIVE		t	2026-02-12 21:30:08.93781	2026-03-01 10:28:25.911579	1583	\N	f
137	74	2025-07-16	3.00	ACTIVE		t	2026-02-12 21:30:55.898927	2026-03-01 10:28:25.911579	1584	\N	f
138	125	2025-07-22	3.00	ACTIVE		t	2026-02-12 21:33:03.992922	2026-03-01 10:28:25.911579	1588	\N	f
140	126	2025-08-05	3.00	ACTIVE		t	2026-02-12 21:36:07.763173	2026-03-01 10:28:25.911579	1600	\N	f
141	127	2025-08-06	3.00	ACTIVE		t	2026-02-12 21:37:07.393133	2026-03-01 10:28:25.911579	1602	\N	f
143	83	2025-08-08	3.00	ACTIVE		t	2026-02-12 21:45:17.636215	2026-03-01 10:28:25.911579	1607	\N	f
144	128	2025-08-18	3.00	ACTIVE		t	2026-02-12 21:47:08.933552	2026-03-01 10:28:25.911579	1612	\N	f
145	129	2025-08-19	3.00	ACTIVE		t	2026-02-12 21:50:37.878587	2026-03-01 10:28:25.911579	1615	\N	f
146	129	2025-08-19	3.00	ACTIVE		t	2026-02-12 21:53:28.021143	2026-03-01 10:28:25.911579	1616	\N	f
142	90	2025-08-07	3.00	ACTIVE	300 ml Weight chhe real ma	t	2026-02-12 21:40:11.941863	2026-03-01 10:28:25.911579	1603	\N	f
52	60	2024-06-06	3.00	CLOSED		t	2026-02-05 14:00:41.969322	2026-03-01 10:28:25.911579	1286	2026-02-07	f
47	55	2024-04-26	3.00	ACTIVE		t	2026-02-05 13:45:14.740238	2026-03-01 10:28:25.911579	1250	\N	f
48	56	2024-05-04	3.00	ACTIVE		t	2026-02-05 13:47:39.775322	2026-03-01 10:28:25.911579	1255	\N	f
49	57	2024-05-13	3.00	ACTIVE	11000hata +2000(23/08/2024) e lai gaya bija	t	2026-02-05 13:52:48.055153	2026-03-01 10:28:25.911579	1260	\N	f
50	58	2024-05-17	3.00	ACTIVE		t	2026-02-05 13:56:06.215085	2026-03-01 10:28:25.911579	1266	\N	f
51	59	2024-05-27	3.00	ACTIVE		t	2026-02-05 13:58:37.323582	2026-03-01 10:28:25.911579	1274	\N	f
53	61	2024-06-17	3.00	ACTIVE		t	2026-02-05 14:02:27.111177	2026-03-01 10:28:25.911579	1292	\N	f
54	62	2024-06-17	3.00	ACTIVE	Dora Sathe weight 12 Gram 	t	2026-02-05 14:05:46.728472	2026-03-01 10:28:25.911579	1293	\N	f
55	63	2024-06-20	3.00	ACTIVE	105 gram weight with Copper \n\n30 gram Silver	t	2026-02-08 18:16:54.665747	2026-03-01 10:28:25.911579	1297	\N	f
147	124	2025-07-12	3.00	ACTIVE		t	2026-02-16 20:41:04.904967	2026-03-01 10:28:25.911579	1683	\N	f
148	74	2025-07-16	3.00	ACTIVE		t	2026-02-16 20:42:20.089291	2026-03-01 10:28:25.911579	1684	\N	f
149	125	2025-07-22	3.00	ACTIVE		t	2026-02-16 20:44:55.545534	2026-03-01 10:28:25.911579	1688	\N	f
73	80	2023-09-04	3.00	ACTIVE		t	2026-02-11 21:02:23.108175	2026-03-01 10:28:25.911579	1034	\N	f
75	83	2023-11-28	3.00	ACTIVE		t	2026-02-11 21:21:30.616272	2026-03-01 10:28:25.911579	1113	\N	f
76	84	2023-11-28	3.00	ACTIVE		t	2026-02-11 21:24:43.625773	2026-03-01 10:28:25.911579	1116	\N	f
78	71	2024-03-14	3.00	ACTIVE	Patan\n	t	2026-02-11 21:29:20.179974	2026-03-01 10:28:25.911579	1224	\N	f
85	91	2024-11-23	3.00	ACTIVE		t	2026-02-11 21:48:22.947828	2026-03-01 10:28:25.911579	1424	\N	f
87	93	2024-12-02	3.00	ACTIVE		t	2026-02-11 21:52:10.795627	2026-03-01 10:28:25.911579	1429	\N	f
94	34	2024-12-26	3.00	ACTIVE		t	2026-02-11 22:06:41.70886	2026-03-01 10:28:25.911579	1447	\N	f
97	98	2024-07-08	3.00	ACTIVE		t	2026-02-11 22:16:58.320507	2026-03-01 10:28:25.911579	1315	\N	f
98	99	2024-07-12	3.00	ACTIVE		t	2026-02-11 22:18:03.353435	2026-03-01 10:28:25.911579	1320	\N	f
103	103	2024-09-21	3.00	ACTIVE		t	2026-02-11 22:25:12.775904	2026-03-01 10:28:25.911579	1378	\N	f
106	87	2024-10-19	3.00	ACTIVE		t	2026-02-11 22:29:19.773055	2026-03-01 10:28:25.911579	1398	\N	f
81	87	2024-11-07	3.00	ACTIVE		t	2026-02-11 21:43:56.062672	2026-03-01 10:28:25.911579	1409	\N	f
65	73	2024-01-19	3.00	ACTIVE	146 weight	t	2026-02-10 21:56:12.353083	2026-03-01 10:28:25.911579	1173	\N	f
66	74	2024-02-17	3.00	ACTIVE		t	2026-02-10 21:57:28.70484	2026-03-01 10:28:25.911579	1197	\N	f
63	71	2024-03-22	3.00	ACTIVE		t	2026-02-10 20:51:36.823842	2026-03-01 10:28:25.911579	1133	\N	f
4	8	2020-09-10	3.00	ACTIVE		t	2026-02-03 20:57:17.06682	2026-03-01 10:36:14.484873	145	\N	t
5	10	2020-09-30	3.00	ACTIVE		t	2026-02-03 21:00:04.391964	2026-03-01 10:38:16.74809	155	\N	t
7	12	2020-11-06	3.00	ACTIVE		t	2026-02-03 21:09:41.460348	2026-03-01 11:08:57.999173	177	\N	t
8	13	2020-10-24	3.00	ACTIVE		t	2026-02-03 21:12:09.300888	2026-03-01 11:09:52.334068	187	\N	t
10	15	2021-02-02	3.00	ACTIVE		t	2026-02-03 21:25:36.199899	2026-03-01 11:11:10.090627	232	\N	t
12	17	2021-02-27	3.00	ACTIVE		t	2026-02-03 21:32:13.294967	2026-03-01 11:12:38.567071	251	\N	t
17	22	2021-06-08	3.00	ACTIVE	ex no: 7069608441	t	2026-02-03 22:01:12.369566	2026-03-01 11:19:08.516572	304	\N	t
20	25	2021-07-24	3.00	ACTIVE		t	2026-02-03 22:15:17.281776	2026-03-01 11:29:59.409112	341	\N	t
24	29	2021-08-10	3.00	ACTIVE		t	2026-02-04 00:08:03.435881	2026-03-01 11:30:43.6619	358	\N	t
25	30	2021-10-22	3.00	ACTIVE		t	2026-02-04 20:47:12.912341	2026-03-01 11:31:17.643482	418	\N	t
26	31	2021-11-11	3.00	ACTIVE		t	2026-02-04 20:50:04.678597	2026-03-01 11:31:51.552702	426	\N	t
27	32	2022-01-12	3.00	ACTIVE		t	2026-02-04 20:52:51.435267	2026-03-01 11:32:47.138337	476	\N	t
28	33	2022-01-24	3.00	ACTIVE		t	2026-02-04 20:55:07.327558	2026-03-01 11:33:34.941626	485	\N	t
29	34	2022-04-04	3.00	ACTIVE		t	2026-02-04 20:58:37.590448	2026-03-01 11:34:22.818006	531	\N	t
30	35	2022-04-25	3.00	ACTIVE		t	2026-02-04 21:00:50.519457	2026-03-01 11:36:10.947768	547	\N	t
31	36	2022-06-07	3.00	ACTIVE		t	2026-02-04 21:02:43.966989	2026-03-01 11:38:31.656742	579	\N	t
32	37	2022-07-04	3.00	ACTIVE		t	2026-02-04 21:05:01.84594	2026-03-01 11:39:14.377857	605	\N	t
38	43	2022-10-07	3.00	ACTIVE		t	2026-02-04 21:19:10.626923	2026-03-01 11:45:20.820544	729	\N	t
40	53	2022-11-14	3.00	ACTIVE		t	2026-02-04 21:22:42.269164	2026-03-01 11:46:34.669072	764	\N	t
41	46	2022-12-02	3.00	ACTIVE		t	2026-02-04 21:24:47.982321	2026-03-01 11:47:15.817135	771	\N	t
42	47	2022-12-03	3.00	ACTIVE		t	2026-02-04 21:26:55.128854	2026-03-01 11:48:25.674189	775	\N	t
43	53	2022-12-09	3.00	ACTIVE		t	2026-02-04 21:28:37.727801	2026-03-01 11:49:51.290984	781	\N	t
46	53	2023-02-13	3.00	ACTIVE		t	2026-02-04 21:46:29.345673	2026-03-01 11:54:24.615797	851	\N	t
22	64	2023-02-18	3.00	ACTIVE		t	2026-02-03 22:20:31.302824	2026-03-01 11:55:03.30863	853	\N	t
57	68	2023-03-09	3.00	ACTIVE	With Copper 130 Gram Weight	t	2026-02-09 22:51:04.96761	2026-03-01 11:58:14.860465	868	\N	t
59	53	2023-04-11	3.00	ACTIVE		t	2026-02-09 23:00:45.469382	2026-03-01 11:59:36.212276	899	\N	t
60	69	2023-05-23	3.00	ACTIVE		t	2026-02-09 23:03:51.448184	2026-03-01 12:00:09.599534	930	\N	t
62	70	2023-05-31	3.00	ACTIVE		t	2026-02-09 23:08:11.435174	2026-03-01 12:01:21.668614	936	\N	t
67	75	2023-06-03	3.00	ACTIVE		t	2026-02-10 21:59:11.138549	2026-03-01 12:01:56.756759	966	\N	t
69	77	2023-07-10	3.00	ACTIVE	1000 Jama 17/11/2024	t	2026-02-10 22:02:33.705744	2026-03-01 12:03:01.416964	979	\N	t
71	53	2023-07-20	3.00	ACTIVE		t	2026-02-10 22:06:32.955666	2026-03-01 12:04:12.122	997	\N	t
79	85	2024-04-20	3.00	ACTIVE		t	2026-02-11 21:30:47.270767	2026-03-01 10:28:25.911579	1243	\N	f
108	106	2025-02-03	3.00	ACTIVE		t	2026-02-12 20:32:30.532845	2026-03-01 10:28:25.911579	1464	\N	f
114	111	2025-03-22	3.00	ACTIVE		t	2026-02-12 20:43:57.562498	2026-03-01 10:28:25.911579	1501	\N	f
116	112	2025-03-26	3.00	ACTIVE		t	2026-02-12 20:46:38.397365	2026-03-01 10:28:25.911579	1504	\N	f
119	114	2025-03-28	3.00	ACTIVE		t	2026-02-12 20:51:52.727589	2026-03-01 10:28:25.911579	1509	\N	f
121	116	2025-04-24	3.00	ACTIVE		t	2026-02-12 20:58:22.120491	2026-03-01 10:28:25.911579	1526	\N	f
122	117	2025-05-01	3.00	ACTIVE		t	2026-02-12 21:02:34.678927	2026-03-01 10:28:25.911579	1530	\N	f
124	119	2025-05-02	3.00	ACTIVE		t	2026-02-12 21:06:09.518865	2026-03-01 10:28:25.911579	1532	\N	f
125	77	2025-05-06	3.00	ACTIVE		t	2026-02-12 21:07:36.930843	2026-03-01 10:28:25.911579	1536	\N	f
126	53	2025-05-06	3.00	ACTIVE		t	2026-02-12 21:08:39.854878	2026-03-01 10:28:25.911579	1538	\N	f
127	120	2025-05-12	3.00	ACTIVE		t	2026-02-12 21:09:52.037651	2026-03-01 10:28:25.911579	1540	\N	f
131	122	2025-06-04	3.00	ACTIVE		t	2026-02-12 21:15:14.705492	2026-03-01 10:28:25.911579	1558	\N	f
134	97	2025-06-27	3.00	ACTIVE		t	2026-02-12 21:23:42.871476	2026-03-01 10:28:25.911579	1573	\N	f
135	42	2025-06-12	3.00	ACTIVE		t	2026-02-12 21:26:18.52702	2026-03-01 10:28:25.911579	1561	\N	f
139	123	2025-07-24	3.00	ACTIVE		t	2026-02-12 21:34:15.43469	2026-03-01 10:28:25.911579	1589	\N	f
150	123	2025-07-24	3.00	ACTIVE		t	2026-02-16 20:46:35.677851	2026-03-01 10:28:25.911579	1689	\N	f
151	126	2025-08-05	3.00	ACTIVE		t	2026-02-16 20:49:50.053168	2026-03-01 10:28:25.911579	1700	\N	f
152	127	2025-08-06	3.00	ACTIVE		t	2026-02-16 20:50:57.879972	2026-03-01 10:28:25.911579	1702	\N	f
153	90	2026-02-16	3.00	ACTIVE		t	2026-02-16 20:51:59.445544	2026-03-01 10:28:25.911579	1703	\N	f
154	83	2025-08-08	3.00	ACTIVE		t	2026-02-16 20:54:35.35084	2026-03-01 10:28:25.911579	1707	\N	f
155	128	2025-08-18	3.00	ACTIVE		t	2026-02-16 20:55:30.67504	2026-03-01 10:28:25.911579	1712	\N	f
156	129	2025-08-19	3.00	ACTIVE		t	2026-02-16 20:58:29.39282	2026-03-01 10:28:25.911579	1715	\N	f
157	129	2025-08-19	3.00	ACTIVE		t	2026-02-16 20:59:18.616398	2026-03-01 10:28:25.911579	1716	\N	f
158	123	2025-08-20	3.00	ACTIVE		t	2026-02-16 21:00:13.356605	2026-03-01 10:28:25.911579	1717	\N	f
159	89	2025-08-22	3.00	ACTIVE		t	2026-02-16 21:01:04.264929	2026-03-01 10:28:25.911579	1719	\N	f
161	134	2025-09-03	3.00	ACTIVE		t	2026-02-16 21:05:12.080002	2026-03-01 10:28:25.911579	1731	\N	f
162	135	2025-09-04	3.00	ACTIVE		t	2026-02-16 21:06:34.324595	2026-03-01 10:28:25.911579	1733	\N	f
163	136	2025-09-04	3.00	ACTIVE		t	2026-02-16 21:07:42.13826	2026-03-01 10:28:25.911579	1734	\N	f
164	114	2025-09-09	3.00	ACTIVE		t	2026-02-16 21:09:14.079051	2026-03-01 10:28:25.911579	1735	\N	f
165	137	2025-09-11	3.00	ACTIVE		t	2026-02-16 21:10:29.616566	2026-03-01 10:28:25.911579	1738	\N	f
166	138	2025-09-27	3.00	ACTIVE		t	2026-02-16 21:14:24.857269	2026-03-01 10:28:25.911579	1753	\N	f
167	138	2025-10-04	3.00	ACTIVE		t	2026-02-16 21:19:37.334448	2026-03-01 10:28:25.911579	1757	\N	f
168	99	2025-10-06	3.00	ACTIVE		t	2026-02-16 21:21:26.112682	2026-03-01 10:28:25.911579	1759	\N	f
169	139	2025-10-10	3.00	ACTIVE		t	2026-02-16 21:24:10.374332	2026-03-01 10:28:25.911579	1762	\N	f
170	140	2025-10-31	3.00	ACTIVE		t	2026-02-16 21:26:25.632876	2026-03-01 10:28:25.911579	1770	\N	f
171	141	2025-10-01	3.00	ACTIVE		t	2026-02-16 21:27:39.887837	2026-03-01 10:28:25.911579	1772	\N	f
172	19	2025-11-03	3.00	ACTIVE		t	2026-02-16 21:31:27.068849	2026-03-01 10:28:25.911579	1773	\N	f
173	110	2025-11-10	3.00	ACTIVE		t	2026-02-16 21:33:24.788651	2026-03-01 10:28:25.911579	1780	\N	f
174	142	2025-11-10	3.00	ACTIVE		t	2026-02-16 21:35:16.741118	2026-03-01 10:28:25.911579	1782	\N	f
175	88	2025-11-19	3.00	ACTIVE		t	2026-02-16 21:35:56.230578	2026-03-01 10:28:25.911579	1786	\N	f
176	129	2025-11-20	3.00	ACTIVE		t	2026-02-16 21:38:24.581012	2026-03-01 10:28:25.911579	1788	\N	f
177	143	2025-11-22	3.00	ACTIVE		t	2026-02-16 21:39:56.499058	2026-03-01 10:28:25.911579	1789	\N	f
178	105	2025-11-25	3.00	ACTIVE		t	2026-02-16 21:40:54.501848	2026-03-01 10:28:25.911579	1791	\N	f
179	111	2025-11-29	3.00	ACTIVE		t	2026-02-16 21:43:07.492671	2026-03-01 10:28:25.911579	1793	\N	f
180	144	2025-12-05	3.00	ACTIVE		t	2026-02-16 21:44:30.063874	2026-03-01 10:28:25.911579	1797	\N	f
181	145	2025-12-06	3.00	ACTIVE		t	2026-02-17 20:29:13.771343	2026-03-01 10:28:25.911579	1798	\N	f
182	146	2025-12-07	3.00	ACTIVE		t	2026-02-17 20:30:12.323877	2026-03-01 10:28:25.911579	1799	\N	f
183	147	2025-12-08	3.00	ACTIVE		t	2026-02-17 20:31:23.440034	2026-03-01 10:28:25.911579	1801	\N	f
184	148	2025-12-08	3.00	ACTIVE		t	2026-02-17 20:32:24.460181	2026-03-01 10:28:25.911579	1802	\N	f
185	149	2025-12-09	3.00	ACTIVE		t	2026-02-17 20:33:37.549466	2026-03-01 10:28:25.911579	1803	\N	f
186	150	2025-12-09	3.00	ACTIVE		t	2026-02-17 20:34:52.20209	2026-03-01 10:28:25.911579	1805	\N	f
187	151	2025-12-12	3.00	ACTIVE	Tamba Sathe 142/700 weight	t	2026-02-17 20:37:14.871469	2026-03-01 10:28:25.911579	1806	\N	f
188	99	2025-12-16	3.00	ACTIVE		t	2026-02-17 20:38:35.230156	2026-03-01 10:28:25.911579	1808	\N	f
189	152	2025-12-18	3.00	ACTIVE		t	2026-02-17 20:41:19.519955	2026-03-01 10:28:25.911579	1809	\N	f
190	12	2025-12-22	3.00	ACTIVE		t	2026-02-17 20:42:19.952718	2026-03-01 10:28:25.911579	1812	\N	f
191	138	2025-12-24	3.00	ACTIVE		t	2026-02-17 20:44:20.372862	2026-03-01 10:28:25.911579	1813	\N	f
192	153	2025-12-24	3.00	ACTIVE		t	2026-02-17 20:45:35.808134	2026-03-01 10:28:25.911579	1814	\N	f
193	105	2025-12-25	3.00	ACTIVE		t	2026-02-17 20:46:18.535047	2026-03-01 10:28:25.911579	1815	\N	f
194	154	2025-12-30	3.00	ACTIVE		t	2026-02-17 20:47:28.199322	2026-03-01 10:28:25.911579	1817	\N	f
195	155	2025-12-30	3.00	ACTIVE		t	2026-02-17 20:48:22.023815	2026-03-01 10:28:25.911579	1818	\N	f
196	156	2026-01-03	3.00	ACTIVE		t	2026-02-17 20:49:40.339287	2026-03-01 10:28:25.911579	1820	\N	f
197	141	2026-01-03	3.00	ACTIVE		t	2026-02-17 20:50:56.511723	2026-03-01 10:28:25.911579	1821	\N	f
198	123	2026-01-05	3.00	ACTIVE		t	2026-02-17 20:51:46.970889	2026-03-01 10:28:25.911579	1822	\N	f
199	157	2026-01-05	3.00	ACTIVE		t	2026-02-17 20:53:11.952111	2026-03-01 10:28:25.911579	1823	\N	f
200	93	2026-01-05	3.00	ACTIVE		t	2026-02-17 20:54:02.128926	2026-03-01 10:28:25.911579	1824	\N	f
201	126	2026-01-05	3.00	ACTIVE		t	2026-02-17 20:55:41.85883	2026-03-01 10:28:25.911579	1825	\N	f
202	158	2026-01-06	3.00	ACTIVE		t	2026-02-17 20:57:23.621566	2026-03-01 10:28:25.911579	1828	\N	f
203	159	2026-01-07	3.00	ACTIVE		t	2026-02-17 20:58:43.573694	2026-03-01 10:28:25.911579	1829	\N	f
204	12	2026-01-07	3.00	ACTIVE		t	2026-02-17 21:00:29.226743	2026-03-01 10:28:25.911579	1830	\N	f
205	160	2026-01-09	3.00	ACTIVE		t	2026-02-17 21:01:37.868478	2026-03-01 10:28:25.911579	1831	\N	f
206	161	2026-01-12	3.00	ACTIVE	Tamba Sathe 148	t	2026-02-17 21:03:51.507453	2026-03-01 10:28:25.911579	1832	\N	f
207	162	2026-01-16	3.00	ACTIVE		t	2026-02-17 21:05:22.465596	2026-03-01 10:28:25.911579	1835	\N	f
208	163	2026-01-17	3.00	ACTIVE		t	2026-02-17 21:06:53.227636	2026-03-01 10:28:25.911579	1836	\N	f
209	129	2026-01-17	3.00	ACTIVE		t	2026-02-17 21:12:03.975618	2026-03-01 10:28:25.911579	1837	\N	f
210	164	2026-01-19	3.00	ACTIVE		t	2026-02-17 21:13:26.17183	2026-03-01 10:28:25.911579	1838	\N	f
211	17	2026-01-24	3.00	ACTIVE		t	2026-02-17 21:14:40.546046	2026-03-01 10:28:25.911579	1839	\N	f
212	165	2026-01-24	3.00	ACTIVE		t	2026-02-17 21:16:42.241168	2026-03-01 10:28:25.911579	1840	\N	f
213	166	2025-12-25	3.00	ACTIVE		t	2026-02-17 21:18:25.17409	2026-03-01 10:28:25.911579	1841	\N	f
214	53	2026-01-24	3.00	ACTIVE		t	2026-02-17 22:44:00.70068	2026-03-01 10:28:25.911579	1842	\N	f
215	167	2026-01-24	3.00	ACTIVE		t	2026-02-18 20:12:34.3597	2026-03-01 10:28:25.911579	1843	\N	f
216	129	2026-01-28	3.00	ACTIVE		t	2026-02-18 20:13:39.200105	2026-03-01 10:28:25.911579	1846	\N	f
36	39	2022-09-14	3.00	ACTIVE		t	2026-02-04 21:14:14.074786	2026-03-01 11:43:53.971917	694	\N	t
37	42	2022-09-24	3.00	ACTIVE		t	2026-02-04 21:16:36.237523	2026-03-01 11:44:46.606144	723	\N	t
39	53	2022-11-08	3.00	ACTIVE		t	2026-02-04 21:20:44.788966	2026-03-01 11:45:59.452187	757	\N	t
44	51	2023-01-18	3.00	ACTIVE		t	2026-02-04 21:42:58.983161	2026-03-01 11:53:01.098178	827	\N	t
45	52	2023-02-03	3.00	ACTIVE		t	2026-02-04 21:44:34.142218	2026-03-01 11:53:52.100466	842	\N	t
160	133	2025-08-30	3.00	ACTIVE		t	2026-02-16 21:03:05.699457	2026-03-15 19:15:40.035207	1728	\N	f
217	138	2026-01-30	3.00	ACTIVE	Tamba Sathe 68.470 Weight	t	2026-02-18 20:14:48.628281	2026-03-01 10:28:25.911579	1847	\N	f
218	168	2026-01-31	3.00	ACTIVE		t	2026-02-18 20:15:41.361955	2026-03-01 10:28:25.911579	1848	\N	f
219	169	2026-01-31	3.00	ACTIVE		t	2026-02-18 20:16:32.879738	2026-03-01 10:28:25.911579	1850	\N	f
220	141	2026-02-02	3.00	ACTIVE		t	2026-02-18 20:17:24.968382	2026-03-01 10:28:25.911579	1851	\N	f
221	170	2026-02-02	3.00	ACTIVE		t	2026-02-18 20:20:26.084507	2026-03-01 10:28:25.911579	1852	\N	f
222	17	2026-02-02	3.00	ACTIVE		t	2026-02-18 20:21:14.325941	2026-03-01 10:28:25.911579	1853	\N	f
223	171	2026-02-02	3.00	ACTIVE		t	2026-02-18 20:21:58.329936	2026-03-01 10:28:25.911579	1854	\N	f
224	19	2026-02-03	3.00	ACTIVE		t	2026-02-18 20:23:25.525391	2026-03-01 10:28:25.911579	1855	\N	f
225	129	2026-02-07	3.00	ACTIVE		t	2026-02-18 20:24:16.355705	2026-03-01 10:28:25.911579	1856	\N	f
226	172	2026-02-07	3.00	ACTIVE		t	2026-02-18 20:26:57.965396	2026-03-01 10:28:25.911579	1857	\N	f
227	141	2026-02-09	3.00	ACTIVE	Para Sathe Weight 33.800 gm	t	2026-02-18 20:28:56.016777	2026-03-01 10:28:25.911579	1858	\N	f
228	173	2026-02-10	3.00	ACTIVE		t	2026-02-18 20:30:03.56212	2026-03-01 10:28:25.911579	1859	\N	f
229	174	2026-02-11	3.00	ACTIVE		t	2026-02-18 20:30:59.344582	2026-03-01 10:28:25.911579	1860	\N	f
23	54	2023-01-06	3.00	ACTIVE	total weight full Bangdi: 92 Gram 	t	2026-02-04 00:04:14.670012	2026-03-01 11:52:02.529763	817	\N	t
\.


--
-- Data for Name: customer_deposit_items; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.customer_deposit_items (id, deposit_entry_id, item_id, item_date, weight_received, weight_unit_id, fine_weight, item_status, item_description, is_active, created_date, updated_date) FROM stdin;
3	2	1	2020-01-18	2.650	1	1.855	ACTIVE	1 Jod Butti	t	2026-02-01 17:07:36.817291	\N
1	1	1	2020-12-24	4.200	1	3.780	ACTIVE	1 Nang Asadi	t	2026-02-01 14:36:05.39046	2026-02-03 21:20:17.534746
21	18	1	2021-06-16	16.400	1	12.300	ACTIVE	1 Jod Butti, Kan sher Sathe	t	2026-02-03 22:10:38.214613	\N
22	19	2	2021-07-22	81.000	2	61.000	ACTIVE	1 Jod Chudi	t	2026-02-03 22:13:41.857354	\N
31	26	2	2021-11-11	86.000	2	64.000	ACTIVE	1 Nung Lucky & 1 Nung Chudi	t	2026-02-04 20:50:04.678597	\N
41	36	2	2022-09-14	43.000	2	32.000	ACTIVE	1 Nung Chain Disko Chavi	t	2026-02-04 21:14:14.074786	\N
63	23	2	2023-01-06	90.000	2	54.000	ACTIVE	1 Lakki 	t	2026-02-08 13:11:18.813382	2026-02-08 17:41:28.926291
52	47	2	2024-04-26	46.000	2	32.000	ACTIVE	1 Nung Mangalsutra Hiranu & 1 Nung Vinti	t	2026-02-05 13:45:14.740238	2026-02-08 18:00:50.425678
53	48	1	2024-05-04	14.000	1	9.800	ACTIVE	1 Nung Bangadi	t	2026-02-05 13:47:39.775322	2026-02-08 18:02:30.819097
29	24	2	2021-08-10	24.000	2	14.000	ACTIVE	1 Nung Pin	t	2026-02-04 20:40:59.062986	2026-02-08 18:45:13.272091
54	49	2	2024-05-13	299.000	2	269.000	ACTIVE	Gola Jod 1	t	2026-02-05 13:52:48.055153	2026-02-08 18:03:50.59198
55	50	2	2024-05-17	58.000	2	35.000	ACTIVE	1 Jod Kadli Chudi Jod 1	t	2026-02-05 13:56:06.215085	2026-02-08 18:04:48.991145
56	51	2	2024-05-27	123.000	2	74.000	ACTIVE	Mulo Mag 1 pin Nung 1 Jod	t	2026-02-05 13:58:37.323582	2026-02-08 18:05:56.875898
30	25	2	2021-10-22	92.000	2	64.000	ACTIVE	1 NUNG CHANDI NI LUCKY	t	2026-02-04 20:47:12.912341	2026-02-08 18:45:47.494164
58	53	2	2024-06-17	84.000	2	55.000	ACTIVE	1 Jod Payal	t	2026-02-05 14:02:27.111177	2026-02-08 18:11:20.591024
59	54	1	2024-06-17	3.000	1	2.100	ACTIVE	1 Nung Mangalsutra	t	2026-02-05 14:05:46.728472	2026-02-08 18:14:44.675339
66	55	1	2024-06-20	10.000	1	8.500	ACTIVE	1 Nang Tupiyu	t	2026-02-08 18:16:54.665747	\N
60	20	2	2021-07-24	305.000	2	213.000	ACTIVE	1 Jod Bhuj ni Payal	t	2026-02-07 14:18:01.7996	2026-02-08 18:27:18.744533
25	22	2	2023-02-18	194.000	2	136.000	ACTIVE	1 Jod Payal Patto	t	2026-02-03 22:20:31.302824	2026-02-08 18:42:54.116887
32	27	1	2022-01-12	2.460	1	1.722	ACTIVE	1 Nung Vinti	t	2026-02-04 20:52:51.435267	2026-02-08 18:47:46.463529
33	28	2	2022-01-24	246.000	2	148.000	ACTIVE	1 Jod Zanzari	t	2026-02-04 20:55:07.327558	2026-02-08 18:48:31.360759
34	29	1	2022-04-04	0.510	1	0.306	ACTIVE	1 Nung Om	t	2026-02-04 20:58:37.590448	2026-02-08 18:49:17.695818
35	30	2	2022-04-25	310.000	2	186.000	ACTIVE	1 Nung Kandoro	t	2026-02-04 21:00:50.519457	2026-02-08 18:50:28.909787
36	31	2	2022-06-07	447.000	2	268.000	ACTIVE	1 Jod Langar	t	2026-02-04 21:02:43.966989	2026-02-08 18:51:06.802295
65	21	2	2021-07-28	246.000	2	172.000	RETURNED	 1 nung Katariyu	t	2026-02-08 13:16:03.604232	2026-02-08 21:30:30.144679
57	52	1	2024-06-06	3.720	1	2.604	RETURNED	Butti Jod1	t	2026-02-05 14:00:41.969322	2026-02-08 21:34:16.145419
74	63	2	2024-03-22	154.000	2	116.000	ACTIVE	Bhuj Ni Payal 1 Jod	t	2026-02-10 20:51:36.823842	\N
75	64	2	2023-12-22	197.000	2	148.000	ACTIVE	Athado Jod 1	t	2026-02-10 21:03:04.020293	2026-02-10 21:45:49.775004
76	65	1	2024-01-19	4.000	1	3.000	ACTIVE	1 Nung Aasadi	t	2026-02-10 21:56:12.353083	\N
77	66	1	2024-02-17	1.750	1	1.313	ACTIVE	1 Jod Butti	t	2026-02-10 21:57:28.70484	\N
83	72	2	2023-08-07	35.000	2	26.000	ACTIVE	Mangalsutra  Nung 1 Kati Sonani Nung 1	t	2026-02-11 21:00:27.061917	\N
84	73	2	2023-09-04	59.000	2	44.000	ACTIVE	1 Nung Zudo	t	2026-02-11 21:02:23.108175	\N
86	75	2	2023-11-28	489.000	2	367.000	ACTIVE	Golava Jod 1	t	2026-02-11 21:21:30.616272	\N
42	37	1	2022-09-24	2.300	1	1.610	ACTIVE	1 nung Ful	t	2026-02-04 21:16:36.237523	2026-03-01 11:44:46.606144
7	6	2	2020-10-28	60.000	2	36.000	ACTIVE	1 Jod Payal	t	2026-02-03 21:04:04.148368	2026-03-01 10:41:06.876337
5	4	1	2020-09-10	0.950	1	0.665	ACTIVE	1 Nung Om	t	2026-02-03 20:57:17.06682	2026-03-01 10:35:54.61574
9	8	1	2020-10-24	0.910	1	0.637	ACTIVE	1 Jod Fool	t	2026-02-03 21:12:09.300888	2026-03-01 11:09:52.334068
6	5	2	2020-09-30	46.000	2	28.000	ACTIVE	Jain Lucky	t	2026-02-03 21:00:04.391964	2026-03-01 11:07:32.588871
12	9	2	2020-10-13	31.000	2	22.000	ACTIVE	1 Nung Lucky	t	2026-02-03 21:18:43.440539	2026-03-01 11:10:29.869458
13	10	2	2021-02-02	98.000	2	69.000	ACTIVE	2 Nung Lucky	t	2026-02-03 21:25:36.199899	2026-03-01 11:11:10.090627
14	11	1	2021-02-27	0.460	1	0.276	ACTIVE	1 Nung Om	t	2026-02-03 21:29:05.181516	2026-03-01 11:11:47.644712
15	12	2	2021-02-27	308.000	2	216.000	ACTIVE	1 Nung Kandoro	t	2026-02-03 21:32:13.294967	2026-03-01 11:12:38.567071
16	13	2	2021-03-18	41.000	2	27.000	ACTIVE	1 Nung Zudo,Mangalsutra (Silver)	t	2026-02-03 21:34:25.970568	2026-03-01 11:13:23.551295
17	14	2	2021-04-12	101.000	2	61.000	ACTIVE	1 Nung Zudo	t	2026-02-03 21:36:35.148215	2026-03-01 11:14:46.313633
18	15	1	2021-04-16	3.500	1	3.150	ACTIVE	Vaghmudhiya Nu Kadu	t	2026-02-03 21:48:18.351984	2026-03-01 11:17:06.344178
19	16	2	2021-04-24	375.000	2	225.000	ACTIVE	1 Jod Langar	t	2026-02-03 21:56:06.77965	2026-03-01 11:18:01.20404
20	17	1	2021-06-08	2.100	1	1.470	ACTIVE	1 Nung Vinti	t	2026-02-03 22:01:12.369566	2026-03-01 11:19:08.516572
37	32	2	2022-07-04	106.000	2	85.000	ACTIVE	1 Nung Kadu Jay Sadhi Maa Nu	t	2026-02-04 21:05:01.84594	2026-03-01 11:39:14.377857
38	33	1	2022-07-05	2.300	1	1.610	ACTIVE	1 Jod Butti	t	2026-02-04 21:07:29.303267	2026-03-01 11:39:48.21044
39	34	2	2022-08-30	156.000	2	86.000	ACTIVE	1 Jod Jotpuri Payal	t	2026-02-04 21:09:42.958453	2026-03-01 11:40:31.701716
61	35	2	2022-09-07	396.000	2	356.000	ACTIVE	Chapaka Vala Kadla Jod 1	t	2026-02-08 12:59:42.606593	2026-03-01 11:43:11.977573
43	38	1	2022-10-07	1.160	1	0.812	ACTIVE	1 Jod kukadva	t	2026-02-04 21:19:10.626923	2026-03-01 11:45:20.820544
44	39	2	2022-11-08	344.000	2	224.000	ACTIVE	1 Nung Kandoro Milan Chain Valo	t	2026-02-04 21:20:44.788966	2026-03-01 11:45:59.452187
45	40	2	2022-11-14	251.000	2	226.000	ACTIVE	1 Nung Kadlu Golavalu	t	2026-02-04 21:22:42.269164	2026-03-01 11:46:34.669072
46	41	2	2022-12-02	61.000	2	43.000	ACTIVE	Chandi ni Lucky 1 Nung	t	2026-02-04 21:24:47.982321	2026-03-01 11:47:15.817135
47	42	1	2022-12-03	1.440	1	0.864	ACTIVE	1 Jod Kadiyo	t	2026-02-04 21:26:55.128854	2026-03-01 11:48:25.674189
64	23	1	2023-01-06	2.000	1	1.800	ACTIVE	1 Jod Bangdi	t	2026-02-08 13:11:18.813382	2026-03-01 11:52:02.529763
49	44	2	2023-01-18	149.000	2	89.000	ACTIVE	1 Jod Zanzri	t	2026-02-04 21:42:58.983161	2026-03-01 11:53:01.098178
50	45	2	2023-02-03	240.000	2	144.000	ACTIVE	Pola Kadla Jod 1	t	2026-02-04 21:44:34.142218	2026-03-01 11:53:52.100466
51	46	1	2023-02-13	2.340	1	1.638	ACTIVE	1 Jod Butti	t	2026-02-04 21:46:29.345673	2026-03-01 11:54:24.615797
67	56	2	2023-02-22	231.000	2	173.000	RETURNED	Zanzari Jod 1	t	2026-02-09 22:42:49.158064	2026-03-01 11:56:38.738804
68	57	1	2023-03-09	3.000	1	2.700	ACTIVE	1 Nang Kadu	t	2026-02-09 22:51:04.96761	2026-03-01 11:58:14.860465
69	58	2	2023-03-23	54.000	2	30.000	ACTIVE	1 Nung Judo	t	2026-02-09 22:58:19.573654	2026-03-01 11:58:58.441969
70	59	2	2023-04-11	496.000	2	322.000	ACTIVE	1 Jod Sankada	t	2026-02-09 23:00:45.469382	2026-03-01 11:59:36.212276
71	60	1	2023-05-23	2.080	1	1.456	ACTIVE	1 Nung Jens Vinti	t	2026-02-09 23:03:51.448184	2026-03-01 12:00:09.599534
72	61	2	2023-05-28	464.000	2	325.000	ACTIVE	1 Jod Kadla Sada	t	2026-02-09 23:05:26.395832	2026-03-01 12:00:47.930578
73	62	2	2023-05-31	515.000	2	283.000	ACTIVE	Chandi Vigat: 1 Jod vedh, 1 Jod Payal, hansali Parchuran 	t	2026-02-09 23:08:11.435174	2026-03-01 12:01:21.668614
78	67	2	2023-06-03	98.000	2	69.000	ACTIVE	Lakki 1 Nung	t	2026-02-10 21:59:11.138549	2026-03-01 12:01:56.756759
79	68	2	2023-07-06	250.000	2	225.000	ACTIVE	Kobiyo Jod 1	t	2026-02-10 22:00:35.703167	2026-03-01 12:02:28.175188
80	69	1	2023-07-10	4.560	1	3.192	ACTIVE	1 Nung Vinti	t	2026-02-10 22:02:33.705744	2026-03-01 12:03:01.416964
81	70	2	2023-07-13	95.000	2	67.000	ACTIVE	1 Jod Payal	t	2026-02-10 22:05:19.103269	2026-03-01 12:03:31.195704
82	71	1	2023-07-20	1.130	1	0.791	ACTIVE	Om 1 Nung , Kadoyo Jod 1	t	2026-02-10 22:06:32.955666	2026-03-01 12:04:12.122
85	74	1	2023-11-22	14.850	1	11.137	PLEDGED_TO_MERCHANT	1 Nung Kanthi & Pendal	t	2026-02-11 21:16:03.908982	2026-03-15 19:28:50.852797
87	76	1	2023-11-28	20.500	1	15.375	ACTIVE	Mangalsutra Moti Sathe	t	2026-02-11 21:24:43.625773	\N
88	77	1	2024-02-26	2.250	1	1.688	ACTIVE	Butti Jod 1	t	2026-02-11 21:28:04.179787	\N
89	78	2	2024-03-14	207.000	2	155.000	ACTIVE	Patto Jod 1	t	2026-02-11 21:29:20.179974	\N
90	79	2	2024-04-20	226.000	2	169.000	ACTIVE	Fancy Patto Jod1	t	2026-02-11 21:30:47.270767	\N
91	80	1	2024-10-21	2.190	1	1.643	ACTIVE	1 Jod Butti	t	2026-02-11 21:42:48.722376	\N
92	81	1	2024-11-07	0.720	1	0.540	ACTIVE	1 Nung Om	t	2026-02-11 21:43:56.062672	\N
93	82	2	2024-11-14	52.000	2	39.000	ACTIVE	Lucky Chandi ni	t	2026-02-11 21:45:08.754657	\N
94	83	2	2024-11-16	490.000	2	367.000	ACTIVE	1 Jod Golava	t	2026-02-11 21:46:19.960898	\N
95	84	2	2024-11-23	199.000	2	149.000	ACTIVE	1 Nung Vaghmudhiya Nu Kadu	t	2026-02-11 21:47:26.741414	\N
96	85	2	2024-11-23	174.000	2	130.000	ACTIVE	1 Jod Zanzari	t	2026-02-11 21:48:22.947828	\N
97	86	1	2024-11-28	2.290	1	1.718	ACTIVE	Kadiyo Jod 1	t	2026-02-11 21:50:25.629301	\N
98	87	1	2024-12-02	3.420	1	2.565	ACTIVE	Fancy Butti Jod 1 Double Dekar Ni 	t	2026-02-11 21:52:10.795627	\N
99	88	1	2024-12-05	1.140	1	0.855	ACTIVE	Ful Jod 1	t	2026-02-11 21:53:03.016464	\N
100	89	2	2024-12-12	43.000	2	32.000	ACTIVE	1 Jod Vedh Saveta	t	2026-02-11 21:57:39.656908	\N
101	90	2	2024-12-20	50.000	2	37.000	ACTIVE	Malgalsutra Nung 1	t	2026-02-11 21:58:49.604985	\N
102	91	1	2024-12-25	0.530	1	0.398	ACTIVE	Om Nung 1	t	2026-02-11 22:00:14.026323	\N
103	92	1	2024-12-26	0.410	1	0.307	ACTIVE	Diska Jod 1	t	2026-02-11 22:04:15.288049	\N
104	92	2	2024-12-26	150.000	2	113.000	ACTIVE	Payal Jod 1	t	2026-02-11 22:04:15.288049	\N
105	93	2	2024-08-19	150.000	2	113.000	ACTIVE	Fancy Payal Jod 1	t	2026-02-11 22:05:22.925925	\N
106	94	2	2024-12-26	169.000	2	127.000	ACTIVE	Kandoro & 4 Vinti Chandi Ni	t	2026-02-11 22:06:41.70886	\N
107	95	1	2025-01-06	2.320	1	1.740	ACTIVE	1 Nung Dori	t	2026-02-11 22:08:07.040165	\N
108	96	1	2024-07-06	0.780	1	0.585	ACTIVE	1 Nung Om	t	2026-02-11 22:14:50.244512	\N
109	97	2	2024-07-08	52.000	2	39.000	ACTIVE	Mangalsutra Nung 1	t	2026-02-11 22:16:58.320507	\N
110	98	1	2024-07-12	1.570	1	1.177	ACTIVE	1 Jod Butti	t	2026-02-11 22:18:03.353435	\N
111	99	2	2024-08-03	27.000	2	20.000	ACTIVE	Chudi Jod 1	t	2026-02-11 22:19:17.553746	\N
112	100	1	2024-08-09	4.000	1	3.000	ACTIVE	Hansali Nung 1	t	2026-02-11 22:21:20.636454	\N
113	101	2	2024-09-05	338.000	2	254.000	ACTIVE	Langar Jod 1	t	2026-02-11 22:22:42.058446	\N
114	102	2	2024-09-16	199.000	2	149.000	ACTIVE	Kambali Jod 1	t	2026-02-11 22:24:07.619729	\N
115	103	1	2024-09-21	2.590	1	1.942	ACTIVE	Butti Jod 1	t	2026-02-11 22:25:12.775904	\N
116	104	2	2024-10-08	77.000	2	58.000	ACTIVE	Luvky Nung 1	t	2026-02-11 22:26:44.35576	\N
117	105	1	2024-10-18	2.930	1	2.197	ACTIVE	Butti Jod 1	t	2026-02-11 22:28:13.281443	\N
118	106	1	2024-10-19	2.750	1	2.063	ACTIVE	Ful Sona Nu Nung 1	t	2026-02-11 22:29:19.773055	\N
119	107	1	2023-11-03	14.880	1	11.160	ACTIVE	Lokit 1	t	2026-02-11 22:32:21.768893	2026-02-11 22:34:14.991667
120	108	1	2025-02-03	5.330	1	3.998	ACTIVE	Vinti Nung Vali 1	t	2026-02-12 20:32:30.532845	\N
121	109	1	2025-02-22	1.920	1	1.440	ACTIVE	Butti Jod 1	t	2026-02-12 20:34:20.588306	\N
122	110	2	2025-02-22	49.000	2	37.000	ACTIVE	1 Nung Om Sonano & Mathli Jod 1	t	2026-02-12 20:35:46.584357	\N
123	111	1	2025-02-28	0.610	1	0.458	ACTIVE	1 Nung Om Dori Sathe	t	2026-02-12 20:37:14.396118	\N
124	112	2	2025-03-10	193.000	2	145.000	ACTIVE	1 Jod Kobiyo	t	2026-02-12 20:38:54.778872	\N
125	113	2	2025-03-12	243.000	2	182.000	ACTIVE	1 Jod Zanzari	t	2026-02-12 20:41:27.660786	\N
126	114	1	2025-03-22	3.250	1	2.438	ACTIVE	Butti Jod 1	t	2026-02-12 20:43:57.562498	\N
127	115	2	2025-03-26	199.000	2	149.000	ACTIVE	1 Jod Kobiyo	t	2026-02-12 20:45:03.225059	\N
128	116	1	2025-03-26	12.440	1	9.330	ACTIVE	2 Jod Butti & 2 Jod Vinti & 1 Nung Om	t	2026-02-12 20:46:38.397365	\N
129	117	2	2025-03-26	49.000	2	37.000	ACTIVE	Lakki Nung1	t	2026-02-12 20:48:17.249956	\N
130	118	2	2025-03-27	614.000	2	460.000	ACTIVE	2 Jod Kadla	t	2026-02-12 20:49:56.139652	\N
131	119	1	2025-03-28	3.300	1	2.475	ACTIVE	1 Jod Butti	t	2026-02-12 20:51:52.727589	\N
132	119	2	2025-03-28	138.000	2	104.000	ACTIVE	1 Hansali	t	2026-02-12 20:51:52.727589	\N
133	120	2	2025-04-16	146.000	2	109.000	ACTIVE	2 Jod Payal	t	2026-02-12 20:53:10.711751	\N
134	121	2	2025-04-24	369.000	2	277.000	ACTIVE	Kandoro 1 Nung	t	2026-02-12 20:58:22.120491	\N
135	122	1	2025-05-01	66.500	1	49.875	ACTIVE	1 Nung Kadu Mina Sathe	t	2026-02-12 21:02:34.678927	\N
136	123	2	2025-05-02	87.000	2	65.000	ACTIVE	1 Jod Payal	t	2026-02-12 21:04:31.513346	\N
137	124	2	2025-05-02	164.000	2	123.000	ACTIVE	1 Nung lucky	t	2026-02-12 21:06:09.518865	\N
138	125	1	2025-05-06	1.570	1	1.177	ACTIVE	1 Nung Vinti	t	2026-02-12 21:07:36.930843	\N
139	126	1	2025-05-06	9.560	1	7.170	ACTIVE	Lokit 1 Nung	t	2026-02-12 21:08:39.854878	\N
140	127	1	2025-05-12	1.150	1	0.863	ACTIVE	Butti Jod 1	t	2026-02-12 21:09:52.037651	\N
141	128	1	2025-05-14	0.710	1	0.532	ACTIVE	1 Jod Kadiyo	t	2026-02-12 21:10:53.619603	\N
142	129	2	2025-05-17	20.000	2	15.000	ACTIVE	Lucky Jod 1	t	2026-02-12 21:11:58.265949	\N
143	130	2	2025-05-23	354.000	2	265.000	ACTIVE	Kandoro Nung 1	t	2026-02-12 21:12:56.047659	\N
144	131	2	2025-06-04	358.000	2	268.000	ACTIVE	1 Jod Zanzari	t	2026-02-12 21:15:14.705492	\N
145	132	1	2025-06-12	3.370	1	2.527	ACTIVE	Keri Butti Jod 1	t	2026-02-12 21:19:28.813314	\N
146	133	1	2025-06-17	3.280	1	2.460	ACTIVE	1 Nung Vinti Dora Sathe	t	2026-02-12 21:21:48.519899	\N
147	134	2	2025-06-27	294.000	2	220.000	ACTIVE	1 Nung Kadlu Vagdod Ghat Nu	t	2026-02-12 21:23:42.871476	\N
148	135	1	2025-06-12	4.000	1	3.800	ACTIVE	1 Nung Aasadi	t	2026-02-12 21:26:18.52702	\N
149	136	2	2025-07-12	87.000	2	65.000	ACTIVE	1 Nung Zudo	t	2026-02-12 21:30:08.93781	\N
150	137	2	2025-07-16	139.000	2	104.000	ACTIVE	1 Jod Kobiyo	t	2026-02-12 21:30:55.898927	\N
151	138	1	2025-07-22	0.580	1	0.435	ACTIVE	1 Jod Kadiyo	t	2026-02-12 21:33:03.992922	\N
152	138	2	2025-07-22	90.000	2	68.000	ACTIVE	Bhuj Ni Payal 1 Jod	t	2026-02-12 21:33:03.992922	\N
153	139	1	2025-07-24	6.180	1	4.635	ACTIVE	Marki Jod 1	t	2026-02-12 21:34:15.43469	\N
154	140	1	2025-08-05	1.600	1	1.200	ACTIVE	Keri Butti 1 Jod	t	2026-02-12 21:36:07.763173	\N
155	141	1	2025-08-06	2.400	1	1.800	ACTIVE	Keri Butti Jod 1	t	2026-02-12 21:37:07.393133	\N
156	142	1	2025-08-07	0.380	1	0.285	ACTIVE	Dori Nung 1	t	2026-02-12 21:40:11.941863	\N
157	143	2	2025-08-08	44.000	2	33.000	ACTIVE	1 Jod Chhum Chhum Payal & Bachcha Lucky	t	2026-02-12 21:45:17.636215	\N
158	144	1	2025-08-18	2.370	1	1.778	ACTIVE	Fancy Butti Jod 1	t	2026-02-12 21:47:08.933552	\N
159	145	1	2025-08-19	7.240	1	5.430	ACTIVE	2 Jod Butti 	t	2026-02-12 21:50:37.878587	\N
160	146	2	2025-08-19	141.000	2	106.000	ACTIVE	Kandoro Nung 1	t	2026-02-12 21:53:28.021143	\N
161	147	2	2025-07-12	87.000	2	65.000	ACTIVE	Zudo Nung 1	t	2026-02-16 20:41:04.904967	\N
162	148	2	2025-07-16	139.000	2	104.000	ACTIVE	1 Jod Kobiyo	t	2026-02-16 20:42:20.089291	\N
163	149	1	2025-07-22	0.580	1	0.435	ACTIVE	1 Jod Kadiyo	t	2026-02-16 20:44:55.545534	\N
164	149	2	2025-07-22	90.000	2	68.000	ACTIVE	1 Jod Bhujni Payal	t	2026-02-16 20:44:55.545534	\N
170	155	1	2025-08-18	2.370	1	1.778	ACTIVE	Fancy Butti Jod 1	t	2026-02-16 20:55:30.67504	\N
171	156	1	2025-08-19	5.070	1	4.056	ACTIVE	2 Jod Butti	t	2026-02-16 20:58:29.39282	\N
165	150	1	2025-07-24	6.180	1	4.635	ACTIVE	Marki Jod 1	t	2026-02-16 20:46:35.677851	\N
166	151	1	2025-08-05	1.600	1	1.200	ACTIVE	Keri Butti Jod 1	t	2026-02-16 20:49:50.053168	\N
167	152	1	2025-08-06	2.400	1	1.800	ACTIVE	Keri Butti Jod 1	t	2026-02-16 20:50:57.879972	\N
168	153	1	2026-02-16	0.500	1	0.375	ACTIVE	Dori Nung 1	t	2026-02-16 20:51:59.445544	\N
169	154	2	2025-08-08	44.000	2	33.000	ACTIVE	Chhum Chhum Payal	t	2026-02-16 20:54:35.35084	\N
172	157	2	2025-08-19	141.000	2	106.000	ACTIVE	Kandoro Nung 1	t	2026-02-16 20:59:18.616398	\N
173	158	2	2025-08-20	182.000	2	137.000	ACTIVE	Bhujni Payal Jod 1	t	2026-02-16 21:00:13.356605	\N
174	159	1	2025-08-22	2.230	1	1.673	ACTIVE	Butti Jod 1	t	2026-02-16 21:01:04.264929	\N
176	161	2	2025-09-03	71.000	2	50.000	ACTIVE	1 Jod Payal	t	2026-02-16 21:05:12.080002	\N
177	162	2	2025-09-04	154.000	2	116.000	ACTIVE	Bhujni Payal	t	2026-02-16 21:06:34.324595	\N
178	163	2	2025-09-04	490.000	2	367.000	ACTIVE	Golva Jod 1	t	2026-02-16 21:07:42.13826	\N
179	164	2	2025-09-09	197.000	2	148.000	ACTIVE	Bhujni Payal & 1 Nung Zudo	t	2026-02-16 21:09:14.079051	\N
180	165	2	2025-09-11	57.000	2	43.000	ACTIVE	Mangalsutra Hira Nu Nung 1	t	2026-02-16 21:10:29.616566	\N
181	166	1	2025-09-27	1.610	1	1.208	ACTIVE	Kadiyo Jod 1	t	2026-02-16 21:14:24.857269	\N
182	167	1	2025-10-04	3.630	1	2.723	ACTIVE	Keri Butti Jod 1	t	2026-02-16 21:19:37.334448	\N
183	168	2	2025-10-06	37.000	2	28.000	ACTIVE	Mangalsutra Nung 1	t	2026-02-16 21:21:26.112682	\N
184	169	2	2025-10-10	113.000	2	85.000	ACTIVE	Bangadi Jod 1	t	2026-02-16 21:24:10.374332	\N
185	170	2	2025-10-31	213.000	2	160.000	ACTIVE	1 Jod Payal Patto	t	2026-02-16 21:26:25.632876	\N
186	171	2	2025-10-01	128.000	2	96.000	ACTIVE	Kandoro Nung 1	t	2026-02-16 21:27:39.887837	\N
187	172	1	2025-11-03	6.400	1	5.760	ACTIVE	Gold Chain Pendal Sathe	t	2026-02-16 21:31:27.068849	\N
188	173	1	2025-11-10	4.240	1	3.180	ACTIVE	1 Jod Butti	t	2026-02-16 21:33:24.788651	\N
189	173	2	2025-11-10	434.000	2	325.000	ACTIVE	1 Nung Lucky Parchuran BHuj Ni Payal	t	2026-02-16 21:33:24.788651	\N
190	174	2	2025-11-10	63.000	2	47.000	ACTIVE	Bhujni Payal Jod 1	t	2026-02-16 21:35:16.741118	\N
191	175	2	2025-11-19	65.000	2	49.000	ACTIVE	1 Jod Payal 	t	2026-02-16 21:35:56.230578	\N
192	176	1	2025-11-20	1.280	1	1.254	ACTIVE	1 Jod Butti	t	2026-02-16 21:38:24.581012	\N
193	177	2	2025-11-22	198.000	2	149.000	ACTIVE	1 Jod Kobiyo	t	2026-02-16 21:39:56.499058	\N
194	178	2	2025-11-25	115.000	2	86.000	ACTIVE	Kismat Payal Jod 1	t	2026-02-16 21:40:54.501848	\N
195	179	1	2025-11-29	3.000	1	2.250	ACTIVE	Mangalsutra Dora Sathe	t	2026-02-16 21:43:07.492671	\N
196	180	1	2025-12-05	5.560	1	4.170	ACTIVE	Butti Jod 1	t	2026-02-16 21:44:30.063874	\N
197	181	2	2025-12-06	250.000	2	188.000	ACTIVE	Parchuran Kadla,Kayda,Lucky,Vinti3 	t	2026-02-17 20:29:13.771343	\N
198	182	2	2025-12-07	224.000	2	168.000	ACTIVE	Kobiyo Jod 1	t	2026-02-17 20:30:12.323877	\N
199	183	2	2025-12-08	136.000	2	102.000	ACTIVE	Bhujni Payal	t	2026-02-17 20:31:23.440034	\N
200	184	1	2025-12-08	2.000	1	1.500	ACTIVE	Kadu Nung 1	t	2026-02-17 20:32:24.460181	\N
201	185	2	2025-12-09	215.000	2	161.000	ACTIVE	Athado Ghughri VAlo Jod1	t	2026-02-17 20:33:37.549466	\N
202	186	2	2025-12-09	92.000	2	69.000	ACTIVE	Bhujni Payal	t	2026-02-17 20:34:52.20209	\N
203	187	1	2025-12-12	4.000	1	3.000	ACTIVE	Aasadi Nung 1	t	2026-02-17 20:37:14.871469	\N
204	188	2	2025-12-16	273.000	2	205.000	ACTIVE	Athado Jod 1	t	2026-02-17 20:38:35.230156	\N
205	189	2	2025-12-18	500.000	2	440.000	ACTIVE	1 Jod Kadla 	t	2026-02-17 20:41:19.519955	\N
206	190	1	2025-12-22	1.080	1	0.810	ACTIVE	Om Nung 1	t	2026-02-17 20:42:19.952718	\N
207	191	2	2025-12-24	240.000	2	180.000	ACTIVE	1 Jod Double Kadi	t	2026-02-17 20:44:20.372862	\N
208	192	1	2025-12-24	4.000	1	3.000	ACTIVE	1 Nung Vinti	t	2026-02-17 20:45:35.808134	\N
209	193	2	2025-12-25	20.000	2	15.000	ACTIVE	Chain Nung 1	t	2026-02-17 20:46:18.535047	\N
210	194	2	2025-12-30	280.000	2	210.000	ACTIVE	Golva Jod 1	t	2026-02-17 20:47:28.199322	\N
211	195	2	2025-12-30	148.000	2	111.000	ACTIVE	Kobiyo Jod 1	t	2026-02-17 20:48:22.023815	\N
212	196	2	2026-01-03	105.000	2	79.000	ACTIVE	Payal Jotpuri Jod 1	t	2026-02-17 20:49:40.339287	\N
213	197	1	2026-01-03	31.150	1	29.281	ACTIVE	Set Nung 1	t	2026-02-17 20:50:56.511723	\N
214	198	1	2026-01-05	2.350	1	1.762	ACTIVE	Keri Butti Jod 1	t	2026-02-17 20:51:46.970889	\N
215	199	2	2026-01-05	100.000	2	75.000	ACTIVE	Kismat Payal Jod 1	t	2026-02-17 20:53:11.952111	\N
216	200	2	2026-01-05	163.000	2	122.000	ACTIVE	Payal Jod 1	t	2026-02-17 20:54:02.128926	\N
217	201	2	2026-01-05	55.000	2	41.000	ACTIVE	Mangalsutra Nung 1	t	2026-02-17 20:55:41.85883	\N
218	202	1	2026-01-06	0.570	1	0.427	ACTIVE	Kadiyo Jod 1	t	2026-02-17 20:57:23.621566	\N
219	203	1	2026-01-07	2.480	1	1.860	ACTIVE	Keri Butti Jod 1	t	2026-02-17 20:58:43.573694	\N
220	204	2	2026-01-07	128.000	2	96.000	ACTIVE	1 Jod Marka Vali Payal SMS	t	2026-02-17 21:00:29.226743	\N
221	205	1	2026-01-09	2.280	1	1.710	ACTIVE	Butti Jod 1	t	2026-02-17 21:01:37.868478	\N
222	206	1	2026-01-12	4.000	1	3.480	ACTIVE	1 Nung Aasadi	t	2026-02-17 21:03:51.507453	\N
223	207	2	2026-01-16	243.000	2	182.000	ACTIVE	Zanzari Jod 1	t	2026-02-17 21:05:22.465596	\N
224	208	1	2026-01-17	0.750	1	0.563	ACTIVE	1 Nung Top Butti	t	2026-02-17 21:06:53.227636	\N
226	210	2	2026-01-19	493.000	2	370.000	ACTIVE	1 Jod Kadla	t	2026-02-17 21:13:26.17183	\N
227	211	2	2026-01-24	99.000	2	98.000	ACTIVE	Chudi Jod 1	t	2026-02-17 21:14:40.546046	\N
228	212	1	2026-01-24	2.180	1	1.657	ACTIVE	Gents Vinti 1 Nung & Butti Jod 1	t	2026-02-17 21:16:42.241168	\N
229	213	1	2025-12-25	0.360	1	0.270	ACTIVE	1 Nung Om	t	2026-02-17 21:18:25.17409	\N
230	214	1	2026-01-24	2.200	1	1.650	ACTIVE	1 Jod Butti	t	2026-02-17 22:44:00.70068	\N
231	215	1	2026-01-24	0.600	1	0.450	ACTIVE	Kadiyo Jod 1	t	2026-02-18 20:12:34.3597	\N
232	216	2	2026-01-28	68.000	2	51.000	ACTIVE	Payal Jod 1	t	2026-02-18 20:13:39.200105	\N
233	217	1	2026-01-30	3.000	1	2.250	ACTIVE	1 Nung Gold Kadu Tamba Sathe	t	2026-02-18 20:14:48.628281	\N
234	218	2	2026-01-31	194.000	2	146.000	ACTIVE	Payal Char Line	t	2026-02-18 20:15:41.361955	\N
235	219	2	2026-01-31	203.000	2	152.000	ACTIVE	1 Jod Kobiyo	t	2026-02-18 20:16:32.879738	\N
236	220	2	2026-02-02	322.000	2	242.000	ACTIVE	1 Jod Bhuj Ni Payal	t	2026-02-18 20:17:24.968382	\N
237	221	2	2026-02-02	497.000	2	447.000	ACTIVE	Golva Jod 1	t	2026-02-18 20:20:26.084507	\N
238	222	1	2026-02-02	1.150	1	0.863	ACTIVE	Butti Nung 1	t	2026-02-18 20:21:14.325941	\N
239	223	2	2026-02-02	170.000	2	128.000	ACTIVE	Jela Jod 1	t	2026-02-18 20:21:58.329936	\N
240	224	1	2026-02-03	3.020	1	2.265	ACTIVE	Kansher Jod 1	t	2026-02-18 20:23:25.525391	\N
241	225	2	2026-02-07	47.000	2	35.000	ACTIVE	Lucky Nung 1 & Payal Jod 1	t	2026-02-18 20:24:16.355705	\N
242	226	2	2026-02-07	387.000	2	310.000	ACTIVE	1 Jod Langar 	t	2026-02-18 20:26:57.965396	2026-02-18 20:27:50.039141
243	227	1	2026-02-09	15.000	1	11.250	ACTIVE	Mangalsutra Para Sathe	t	2026-02-18 20:28:56.016777	\N
225	209	1	2026-01-17	11.000	1	9.900	PLEDGED_TO_MERCHANT	Chain Nung 1 Pendal Sathe	t	2026-02-17 21:12:03.975618	2026-03-15 19:12:11.472687
244	228	1	2026-02-10	0.410	1	0.307	ACTIVE	Kati Nung 1	t	2026-02-18 20:30:03.56212	\N
245	229	2	2026-02-11	127.000	2	95.000	ACTIVE	1 NUng Bhujni Payal	t	2026-02-18 20:30:59.344582	\N
4	3	2	2020-07-25	499.000	2	349.000	ACTIVE	Sakda Jod 1	t	2026-02-03 20:52:05.024615	2026-03-01 10:34:32.282269
8	7	2	2020-11-06	256.000	2	154.000	ACTIVE	1 Jod Athado	t	2026-02-03 21:09:41.460348	2026-03-01 11:08:57.999173
48	43	2	2022-12-09	250.000	2	225.000	ACTIVE	Kadla Golva Nung1	t	2026-02-04 21:28:37.727801	2026-03-01 11:49:51.290984
175	160	1	2025-08-30	17.490	1	13.117	PLEDGED_TO_MERCHANT	Chain Nung 1	t	2026-02-16 21:03:05.699457	2026-03-15 19:03:49.160885
\.


--
-- Data for Name: customer_deposit_transaction; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.customer_deposit_transaction (id, deposit_entry_id, transaction_type, amount, transaction_date, description, is_active, created_date) FROM stdin;
3	3	INITIAL_MONEY	10500.00	2020-07-25	Initial Loan	t	2026-02-03 20:52:05.024615
4	4	INITIAL_MONEY	2200.00	2020-09-10	Initial Loan	t	2026-02-03 20:57:17.06682
5	5	INITIAL_MONEY	1000.00	2020-09-30	Initial Loan	t	2026-02-03 21:00:04.391964
6	6	INITIAL_MONEY	1300.00	2020-10-28	Initial Loan	t	2026-02-03 21:04:04.148368
7	7	INITIAL_MONEY	8000.00	2020-11-06	Initial Loan	t	2026-02-03 21:09:41.460348
8	8	INITIAL_MONEY	2000.00	2020-10-24	Initial Loan	t	2026-02-03 21:12:09.300888
9	9	INITIAL_MONEY	1000.00	2020-10-13	Initial Loan	t	2026-02-03 21:15:54.812681
75	63	INITIAL_MONEY	5000.00	2024-03-22	Initial Loan	t	2026-02-10 20:51:36.823842
10	10	INITIAL_MONEY	3000.00	2021-02-02	Initial Loan	t	2026-02-03 21:25:36.199899
11	11	INITIAL_MONEY	1000.00	2021-02-27	Initial Loan	t	2026-02-03 21:29:05.181516
12	12	INITIAL_MONEY	9000.00	2021-02-27	Initial Loan	t	2026-02-03 21:32:13.294967
13	13	INITIAL_MONEY	2000.00	2021-03-18	Initial Loan	t	2026-02-03 21:34:25.970568
14	14	INITIAL_MONEY	2000.00	2021-04-12	Initial Loan	t	2026-02-03 21:36:35.148215
15	15	INITIAL_MONEY	22000.00	2021-04-16	Initial Loan	t	2026-02-03 21:48:18.351984
16	16	INITIAL_MONEY	6500.00	2021-04-24	Initial Loan	t	2026-02-03 21:56:06.77965
17	17	INITIAL_MONEY	5000.00	2021-06-08	Initial Loan	t	2026-02-03 22:01:12.369566
18	18	INITIAL_MONEY	20000.00	2021-06-16	Initial Loan	t	2026-02-03 22:10:38.214613
19	19	INITIAL_MONEY	3000.00	2021-07-22	Initial Loan	t	2026-02-03 22:13:41.857354
21	21	INITIAL_MONEY	8000.00	2021-07-28	Initial Loan	t	2026-02-03 22:17:36.269683
24	24	INITIAL_MONEY	500.00	2021-08-10	Initial Loan	t	2026-02-04 00:08:03.435881
25	25	INITIAL_MONEY	3000.00	2021-10-22	Initial Loan	t	2026-02-04 20:47:12.912341
26	26	INITIAL_MONEY	3000.00	2021-11-11	Initial Loan	t	2026-02-04 20:50:04.678597
28	28	INITIAL_MONEY	5000.00	2022-01-24	Initial Loan	t	2026-02-04 20:55:07.327558
29	29	INITIAL_MONEY	1000.00	2022-04-04	Initial Loan	t	2026-02-04 20:58:37.590448
30	30	INITIAL_MONEY	12000.00	2022-04-25	Initial Loan	t	2026-02-04 21:00:50.519457
31	31	INITIAL_MONEY	10000.00	2022-06-07	Initial Loan	t	2026-02-04 21:02:43.966989
32	32	INITIAL_MONEY	3000.00	2022-07-04	Initial Loan	t	2026-02-04 21:05:01.84594
33	33	INITIAL_MONEY	7000.00	2022-07-05	Initial Loan	t	2026-02-04 21:07:29.303267
34	34	INITIAL_MONEY	3000.00	2022-08-30	Initial Loan	t	2026-02-04 21:09:42.958453
35	35	INITIAL_MONEY	20000.00	2022-09-07	Initial Loan	t	2026-02-04 21:11:57.49946
36	36	INITIAL_MONEY	1000.00	2022-09-14	Initial Loan	t	2026-02-04 21:14:14.074786
37	37	INITIAL_MONEY	4000.00	2022-09-24	Initial Loan	t	2026-02-04 21:16:36.237523
38	38	INITIAL_MONEY	2500.00	2022-10-07	Initial Loan	t	2026-02-04 21:19:10.626923
39	39	INITIAL_MONEY	7500.00	2022-11-08	Initial Loan	t	2026-02-04 21:20:44.788966
40	40	INITIAL_MONEY	12000.00	2022-11-14	Initial Loan	t	2026-02-04 21:22:42.269164
41	41	INITIAL_MONEY	2000.00	2022-12-02	Initial Loan	t	2026-02-04 21:24:47.982321
42	42	INITIAL_MONEY	3500.00	2022-12-03	Initial Loan	t	2026-02-04 21:26:55.128854
44	44	INITIAL_MONEY	4000.00	2023-01-18	Initial Loan	t	2026-02-04 21:42:58.983161
45	45	INITIAL_MONEY	5000.00	2023-02-03	Initial Loan	t	2026-02-04 21:44:34.142218
46	46	INITIAL_MONEY	6000.00	2023-02-13	Initial Loan	t	2026-02-04 21:46:29.345673
47	47	INITIAL_MONEY	1500.00	2024-04-26	Initial Loan	t	2026-02-05 13:45:14.740238
48	48	INITIAL_MONEY	5000.00	2024-05-04	Initial Loan	t	2026-02-05 13:47:39.775322
49	49	INITIAL_MONEY	13000.00	2024-05-13	Initial Loan	t	2026-02-05 13:52:48.055153
50	50	INITIAL_MONEY	2000.00	2024-05-17	Initial Loan	t	2026-02-05 13:56:06.215085
51	51	INITIAL_MONEY	5000.00	2024-05-27	Initial Loan	t	2026-02-05 13:58:37.323582
52	52	INITIAL_MONEY	10500.00	2024-06-06	Initial Loan	t	2026-02-05 14:00:41.969322
53	53	INITIAL_MONEY	3000.00	2024-06-17	Initial Loan	t	2026-02-05 14:02:27.111177
54	54	INITIAL_MONEY	5000.00	2024-06-17	Initial Loan	t	2026-02-05 14:05:46.728472
20	20	INITIAL_MONEY	6000.00	2021-07-24	Initial Loan	t	2026-02-03 22:15:17.281776
76	64	INITIAL_MONEY	5000.00	2023-12-22	Initial Loan	t	2026-02-10 21:03:04.020293
23	23	INITIAL_MONEY	9000.00	2023-01-06	Initial Loan	t	2026-02-04 00:04:14.670012
59	55	INITIAL_MONEY	20000.00	2024-06-20	Initial Loan	t	2026-02-08 18:16:54.665747
77	65	INITIAL_MONEY	13400.00	2024-01-19	Initial Loan	t	2026-02-10 21:56:12.353083
22	22	INITIAL_MONEY	5000.00	2023-02-18	Initial Loan	t	2026-02-03 22:20:31.302824
27	27	INITIAL_MONEY	6000.00	2022-01-12	Initial Loan	t	2026-02-04 20:52:51.435267
78	66	INITIAL_MONEY	5000.00	2024-02-17	Initial Loan	t	2026-02-10 21:57:28.70484
79	67	INITIAL_MONEY	3000.00	2023-06-03	Initial Loan	t	2026-02-10 21:59:11.138549
64	21	PRINCIPAL_PAYMENT	7800.00	2026-02-07	Settlement (Adjusted: ₹21000)	t	2026-02-08 21:30:30.027996
65	21	INTEREST_PAYMENT	13200.00	2026-02-07	Settlement (Adjusted: ₹21000)	t	2026-02-08 21:30:30.027996
2	2	INITIAL_MONEY	5000.00	2020-01-18	Initial Loan	t	2026-02-01 17:06:39.834298
1	1	INITIAL_MONEY	11500.00	2020-12-24	Initial Loan	t	2026-02-01 14:36:05.39046
66	52	PRINCIPAL_PAYMENT	10185.00	2026-02-07	Settlement (Adjusted: ₹16800)	t	2026-02-08 21:34:16.113904
67	52	INTEREST_PAYMENT	6615.00	2026-02-07	Settlement (Adjusted: ₹16800)	t	2026-02-08 21:34:16.113904
68	56	INITIAL_MONEY	4500.00	2023-02-22	Initial Loan	t	2026-02-09 22:42:49.158064
69	57	INITIAL_MONEY	10000.00	2023-03-09	Initial Loan	t	2026-02-09 22:51:04.96761
70	58	INITIAL_MONEY	2000.00	2023-03-23	Initial Loan	t	2026-02-09 22:58:19.573654
71	59	INITIAL_MONEY	20000.00	2023-04-11	Initial Loan	t	2026-02-09 23:00:45.469382
72	60	INITIAL_MONEY	6000.00	2023-05-23	Initial Loan	t	2026-02-09 23:03:51.448184
73	61	INITIAL_MONEY	16000.00	2023-05-28	Initial Loan	t	2026-02-09 23:05:26.395832
74	62	INITIAL_MONEY	20000.00	2023-05-31	Initial Loan	t	2026-02-09 23:08:11.435174
80	68	INITIAL_MONEY	10000.00	2023-07-06	Initial Loan	t	2026-02-10 22:00:35.703167
81	69	INITIAL_MONEY	16000.00	2023-07-10	Initial Loan	t	2026-02-10 22:02:33.705744
82	70	INITIAL_MONEY	4000.00	2023-07-13	Initial Loan	t	2026-02-10 22:05:19.103269
83	71	INITIAL_MONEY	3500.00	2023-07-20	Initial Loan	t	2026-02-10 22:06:32.955666
84	72	INITIAL_MONEY	1000.00	2023-08-07	Initial Loan	t	2026-02-11 21:00:27.061917
85	73	INITIAL_MONEY	4000.00	2023-09-04	Initial Loan	t	2026-02-11 21:02:23.108175
86	74	INITIAL_MONEY	40000.00	2023-11-22	Initial Loan	t	2026-02-11 21:16:03.908982
87	75	INITIAL_MONEY	20000.00	2023-11-28	Initial Loan	t	2026-02-11 21:21:30.616272
88	76	INITIAL_MONEY	15000.00	2023-11-28	Initial Loan	t	2026-02-11 21:24:43.625773
89	77	INITIAL_MONEY	7000.00	2024-02-26	Initial Loan	t	2026-02-11 21:28:04.179787
90	78	INITIAL_MONEY	7000.00	2024-03-14	Initial Loan	t	2026-02-11 21:29:20.179974
91	79	INITIAL_MONEY	6000.00	2024-04-20	Initial Loan	t	2026-02-11 21:30:47.270767
92	80	INITIAL_MONEY	9000.00	2024-10-21	Initial Loan	t	2026-02-11 21:42:48.722376
93	81	INITIAL_MONEY	3000.00	2024-11-07	Initial Loan	t	2026-02-11 21:43:56.062672
94	82	INITIAL_MONEY	2000.00	2024-11-14	Initial Loan	t	2026-02-11 21:45:08.754657
95	83	INITIAL_MONEY	22500.00	2024-11-16	Initial Loan	t	2026-02-11 21:46:19.960898
96	84	INITIAL_MONEY	6000.00	2024-11-23	Initial Loan	t	2026-02-11 21:47:26.741414
97	85	INITIAL_MONEY	4000.00	2024-11-23	Initial Loan	t	2026-02-11 21:48:22.947828
98	86	INITIAL_MONEY	12000.00	2024-11-28	Initial Loan	t	2026-02-11 21:50:25.629301
99	87	INITIAL_MONEY	15000.00	2024-12-02	Initial Loan	t	2026-02-11 21:52:10.795627
100	88	INITIAL_MONEY	3000.00	2024-12-05	Initial Loan	t	2026-02-11 21:53:03.016464
101	89	INITIAL_MONEY	1000.00	2024-12-12	Initial Loan	t	2026-02-11 21:57:39.656908
102	90	INITIAL_MONEY	2000.00	2024-12-20	Initial Loan	t	2026-02-11 21:58:49.604985
103	91	INITIAL_MONEY	1500.00	2024-12-25	Initial Loan	t	2026-02-11 22:00:14.026323
104	92	INITIAL_MONEY	3000.00	2024-12-26	Initial Loan	t	2026-02-11 22:04:15.288049
105	93	INITIAL_MONEY	2500.00	2024-08-19	Initial Loan	t	2026-02-11 22:05:22.925925
107	95	INITIAL_MONEY	1000.00	2025-01-06	Initial Loan	t	2026-02-11 22:08:07.040165
106	94	INITIAL_MONEY	3000.00	2024-12-26	Initial Loan	t	2026-02-11 22:06:41.70886
108	96	INITIAL_MONEY	2500.00	2024-07-06	Initial Loan	t	2026-02-11 22:14:50.244512
109	97	INITIAL_MONEY	1500.00	2024-07-08	Initial Loan	t	2026-02-11 22:16:58.320507
110	98	INITIAL_MONEY	5000.00	2024-07-12	Initial Loan	t	2026-02-11 22:18:03.353435
111	99	INITIAL_MONEY	1700.00	2024-08-03	Initial Loan	t	2026-02-11 22:19:17.553746
112	100	INITIAL_MONEY	9000.00	2024-08-09	Initial Loan	t	2026-02-11 22:21:20.636454
113	101	INITIAL_MONEY	14000.00	2024-09-05	Initial Loan	t	2026-02-11 22:22:42.058446
114	102	INITIAL_MONEY	12000.00	2024-09-16	Initial Loan	t	2026-02-11 22:24:07.619729
115	103	INITIAL_MONEY	5000.00	2024-09-21	Initial Loan	t	2026-02-11 22:25:12.775904
116	104	INITIAL_MONEY	3000.00	2024-10-08	Initial Loan	t	2026-02-11 22:26:44.35576
117	105	INITIAL_MONEY	10000.00	2024-10-18	Initial Loan	t	2026-02-11 22:28:13.281443
118	106	INITIAL_MONEY	10000.00	2024-10-19	Initial Loan	t	2026-02-11 22:29:19.773055
119	107	INITIAL_MONEY	66560.00	2023-11-03	Initial Loan	t	2026-02-11 22:32:21.768893
120	108	INITIAL_MONEY	15000.00	2025-02-03	Initial Loan	t	2026-02-12 20:32:30.532845
121	109	INITIAL_MONEY	7000.00	2025-02-22	Initial Loan	t	2026-02-12 20:34:20.588306
122	110	INITIAL_MONEY	1500.00	2025-02-22	Initial Loan	t	2026-02-12 20:35:46.584357
123	111	INITIAL_MONEY	1500.00	2025-02-28	Initial Loan	t	2026-02-12 20:37:14.396118
124	112	INITIAL_MONEY	7000.00	2025-03-10	Initial Loan	t	2026-02-12 20:38:54.778872
125	113	INITIAL_MONEY	4000.00	2025-03-12	Initial Loan	t	2026-02-12 20:41:27.660786
126	114	INITIAL_MONEY	10000.00	2025-03-22	Initial Loan	t	2026-02-12 20:43:57.562498
127	115	INITIAL_MONEY	12000.00	2025-03-26	Initial Loan	t	2026-02-12 20:45:03.225059
128	116	INITIAL_MONEY	50000.00	2025-03-26	Initial Loan	t	2026-02-12 20:46:38.397365
129	117	INITIAL_MONEY	2500.00	2025-03-26	Initial Loan	t	2026-02-12 20:48:17.249956
130	118	INITIAL_MONEY	22000.00	2025-03-27	Initial Loan	t	2026-02-12 20:49:56.139652
131	119	INITIAL_MONEY	20000.00	2025-03-28	Initial Loan	t	2026-02-12 20:51:52.727589
132	120	INITIAL_MONEY	5000.00	2025-04-16	Initial Loan	t	2026-02-12 20:53:10.711751
133	121	INITIAL_MONEY	15000.00	2025-04-24	Initial Loan	t	2026-02-12 20:58:22.120491
134	122	INITIAL_MONEY	15000.00	2025-05-01	Initial Loan	t	2026-02-12 21:02:34.678927
135	123	INITIAL_MONEY	2500.00	2025-05-02	Initial Loan	t	2026-02-12 21:04:31.513346
136	124	INITIAL_MONEY	7000.00	2025-05-02	Initial Loan	t	2026-02-12 21:06:09.518865
137	125	INITIAL_MONEY	6000.00	2025-05-06	Initial Loan	t	2026-02-12 21:07:36.930843
138	126	INITIAL_MONEY	46500.00	2025-05-06	Initial Loan	t	2026-02-12 21:08:39.854878
139	127	INITIAL_MONEY	4500.00	2025-05-12	Initial Loan	t	2026-02-12 21:09:52.037651
140	128	INITIAL_MONEY	2600.00	2025-05-14	Initial Loan	t	2026-02-12 21:10:53.619603
141	129	INITIAL_MONEY	600.00	2025-05-17	Initial Loan	t	2026-02-12 21:11:58.265949
142	130	INITIAL_MONEY	15000.00	2025-05-23	Initial Loan	t	2026-02-12 21:12:56.047659
143	131	INITIAL_MONEY	15000.00	2025-06-04	Initial Loan	t	2026-02-12 21:15:14.705492
144	132	INITIAL_MONEY	15000.00	2025-06-12	Initial Loan	t	2026-02-12 21:19:28.813314
145	133	INITIAL_MONEY	4000.00	2025-06-17	Initial Loan	t	2026-02-12 21:21:48.519899
146	134	INITIAL_MONEY	15000.00	2025-06-27	Initial Loan	t	2026-02-12 21:23:42.871476
147	135	INITIAL_MONEY	30000.00	2025-06-12	Initial Loan	t	2026-02-12 21:26:18.52702
148	136	INITIAL_MONEY	3000.00	2025-07-12	Initial Loan	t	2026-02-12 21:30:08.93781
149	137	INITIAL_MONEY	8000.00	2025-07-16	Initial Loan	t	2026-02-12 21:30:55.898927
150	138	INITIAL_MONEY	8000.00	2025-07-22	Initial Loan	t	2026-02-12 21:33:03.992922
151	139	INITIAL_MONEY	5000.00	2025-07-24	Initial Loan	t	2026-02-12 21:34:15.43469
152	140	INITIAL_MONEY	5000.00	2025-08-05	Initial Loan	t	2026-02-12 21:36:07.763173
153	141	INITIAL_MONEY	11000.00	2025-08-06	Initial Loan	t	2026-02-12 21:37:07.393133
154	142	INITIAL_MONEY	2000.00	2025-08-07	Initial Loan	t	2026-02-12 21:40:11.941863
155	143	INITIAL_MONEY	2500.00	2025-08-08	Initial Loan	t	2026-02-12 21:45:17.636215
156	144	INITIAL_MONEY	10000.00	2025-08-18	Initial Loan	t	2026-02-12 21:47:08.933552
157	145	INITIAL_MONEY	29150.00	2025-08-19	Initial Loan	t	2026-02-12 21:50:37.878587
158	146	INITIAL_MONEY	5000.00	2025-08-19	Initial Loan	t	2026-02-12 21:53:28.021143
159	147	INITIAL_MONEY	3000.00	2025-07-12	Initial Loan	t	2026-02-16 20:41:04.904967
160	148	INITIAL_MONEY	8000.00	2025-07-16	Initial Loan	t	2026-02-16 20:42:20.089291
161	149	INITIAL_MONEY	8000.00	2025-07-22	Initial Loan	t	2026-02-16 20:44:55.545534
162	150	INITIAL_MONEY	5000.00	2025-07-24	Initial Loan	t	2026-02-16 20:46:35.677851
163	151	INITIAL_MONEY	5000.00	2025-08-05	Initial Loan	t	2026-02-16 20:49:50.053168
164	152	INITIAL_MONEY	11000.00	2025-08-06	Initial Loan	t	2026-02-16 20:50:57.879972
165	153	INITIAL_MONEY	2000.00	2026-02-16	Initial Loan	t	2026-02-16 20:51:59.445544
166	154	INITIAL_MONEY	2500.00	2025-08-08	Initial Loan	t	2026-02-16 20:54:35.35084
167	155	INITIAL_MONEY	10000.00	2025-08-18	Initial Loan	t	2026-02-16 20:55:30.67504
168	156	INITIAL_MONEY	29150.00	2025-08-19	Initial Loan	t	2026-02-16 20:58:29.39282
169	157	INITIAL_MONEY	5000.00	2025-08-19	Initial Loan	t	2026-02-16 20:59:18.616398
170	158	INITIAL_MONEY	4000.00	2025-08-20	Initial Loan	t	2026-02-16 21:00:13.356605
171	159	INITIAL_MONEY	11500.00	2025-08-22	Initial Loan	t	2026-02-16 21:01:04.264929
172	160	INITIAL_MONEY	90000.00	2025-08-30	Initial Loan	t	2026-02-16 21:03:05.699457
173	161	INITIAL_MONEY	2000.00	2025-09-03	Initial Loan	t	2026-02-16 21:05:12.080002
174	162	INITIAL_MONEY	7000.00	2025-09-04	Initial Loan	t	2026-02-16 21:06:34.324595
175	163	INITIAL_MONEY	25000.00	2025-09-04	Initial Loan	t	2026-02-16 21:07:42.13826
176	164	INITIAL_MONEY	10000.00	2025-09-09	Initial Loan	t	2026-02-16 21:09:14.079051
177	165	INITIAL_MONEY	2000.00	2025-09-11	Initial Loan	t	2026-02-16 21:10:29.616566
178	166	INITIAL_MONEY	8000.00	2025-09-27	Initial Loan	t	2026-02-16 21:14:24.857269
179	167	INITIAL_MONEY	10000.00	2025-10-04	Initial Loan	t	2026-02-16 21:19:37.334448
180	168	INITIAL_MONEY	1000.00	2025-10-06	Initial Loan	t	2026-02-16 21:21:26.112682
181	169	INITIAL_MONEY	5000.00	2025-10-10	Initial Loan	t	2026-02-16 21:24:10.374332
182	170	INITIAL_MONEY	7500.00	2025-10-31	Initial Loan	t	2026-02-16 21:26:25.632876
183	171	INITIAL_MONEY	6000.00	2025-10-01	Initial Loan	t	2026-02-16 21:27:39.887837
184	172	INITIAL_MONEY	40000.00	2025-11-03	Initial Loan	t	2026-02-16 21:31:27.068849
185	173	INITIAL_MONEY	40000.00	2025-11-10	Initial Loan	t	2026-02-16 21:33:24.788651
186	174	INITIAL_MONEY	3000.00	2025-11-10	Initial Loan	t	2026-02-16 21:35:16.741118
187	175	INITIAL_MONEY	2500.00	2025-11-19	Initial Loan	t	2026-02-16 21:35:56.230578
188	176	INITIAL_MONEY	9000.00	2025-11-20	Initial Loan	t	2026-02-16 21:38:24.581012
189	177	INITIAL_MONEY	6000.00	2025-11-22	Initial Loan	t	2026-02-16 21:39:56.499058
190	178	INITIAL_MONEY	5000.00	2025-11-25	Initial Loan	t	2026-02-16 21:40:54.501848
191	179	INITIAL_MONEY	15000.00	2025-11-29	Initial Loan	t	2026-02-16 21:43:07.492671
192	180	INITIAL_MONEY	30000.00	2025-12-05	Initial Loan	t	2026-02-16 21:44:30.063874
193	181	INITIAL_MONEY	12500.00	2025-12-06	Initial Loan	t	2026-02-17 20:29:13.771343
194	182	INITIAL_MONEY	15000.00	2025-12-07	Initial Loan	t	2026-02-17 20:30:12.323877
195	183	INITIAL_MONEY	9000.00	2025-12-08	Initial Loan	t	2026-02-17 20:31:23.440034
196	184	INITIAL_MONEY	10000.00	2025-12-08	Initial Loan	t	2026-02-17 20:32:24.460181
197	185	INITIAL_MONEY	11000.00	2025-12-09	Initial Loan	t	2026-02-17 20:33:37.549466
198	186	INITIAL_MONEY	5000.00	2025-12-09	Initial Loan	t	2026-02-17 20:34:52.20209
199	187	INITIAL_MONEY	12000.00	2025-12-12	Initial Loan	t	2026-02-17 20:37:14.871469
200	188	INITIAL_MONEY	6000.00	2025-12-16	Initial Loan	t	2026-02-17 20:38:35.230156
201	189	INITIAL_MONEY	50000.00	2025-12-18	Initial Loan	t	2026-02-17 20:41:19.519955
203	191	INITIAL_MONEY	16000.00	2025-12-24	Initial Loan	t	2026-02-17 20:44:20.372862
202	190	INITIAL_MONEY	1600.00	2025-12-22	Initial Loan	t	2026-02-17 20:42:19.952718
204	192	INITIAL_MONEY	11000.00	2025-12-24	Initial Loan	t	2026-02-17 20:45:35.808134
205	193	INITIAL_MONEY	1200.00	2025-12-25	Initial Loan	t	2026-02-17 20:46:18.535047
206	194	INITIAL_MONEY	10000.00	2025-12-30	Initial Loan	t	2026-02-17 20:47:28.199322
207	195	INITIAL_MONEY	10000.00	2025-12-30	Initial Loan	t	2026-02-17 20:48:22.023815
208	196	INITIAL_MONEY	4000.00	2026-01-03	Initial Loan	t	2026-02-17 20:49:40.339287
209	197	INITIAL_MONEY	210000.00	2026-01-03	Initial Loan	t	2026-02-17 20:50:56.511723
210	198	INITIAL_MONEY	1500.00	2026-01-05	Initial Loan	t	2026-02-17 20:51:46.970889
211	199	INITIAL_MONEY	3000.00	2026-01-05	Initial Loan	t	2026-02-17 20:53:11.952111
212	200	INITIAL_MONEY	9000.00	2026-01-05	Initial Loan	t	2026-02-17 20:54:02.128926
213	201	INITIAL_MONEY	3500.00	2026-01-05	Initial Loan	t	2026-02-17 20:55:41.85883
214	202	INITIAL_MONEY	3000.00	2026-01-06	Initial Loan	t	2026-02-17 20:57:23.621566
215	203	INITIAL_MONEY	10000.00	2026-01-07	Initial Loan	t	2026-02-17 20:58:43.573694
216	204	INITIAL_MONEY	10000.00	2026-01-07	Initial Loan	t	2026-02-17 21:00:29.226743
217	205	INITIAL_MONEY	6000.00	2026-01-09	Initial Loan	t	2026-02-17 21:01:37.868478
218	206	INITIAL_MONEY	25000.00	2026-01-12	Initial Loan	t	2026-02-17 21:03:51.507453
219	207	INITIAL_MONEY	10000.00	2026-01-16	Initial Loan	t	2026-02-17 21:05:22.465596
220	208	INITIAL_MONEY	4000.00	2026-01-17	Initial Loan	t	2026-02-17 21:06:53.227636
221	209	INITIAL_MONEY	90000.00	2026-01-17	Initial Loan	t	2026-02-17 21:12:03.975618
222	210	INITIAL_MONEY	30000.00	2026-01-19	Initial Loan	t	2026-02-17 21:13:26.17183
223	211	INITIAL_MONEY	11000.00	2026-01-24	Initial Loan	t	2026-02-17 21:14:40.546046
224	212	INITIAL_MONEY	15000.00	2026-01-24	Initial Loan	t	2026-02-17 21:16:42.241168
225	213	INITIAL_MONEY	1500.00	2025-12-25	Initial Loan	t	2026-02-17 21:18:25.17409
226	214	INITIAL_MONEY	13000.00	2026-01-24	Initial Loan	t	2026-02-17 22:44:00.70068
227	215	INITIAL_MONEY	3000.00	2026-01-24	Initial Loan	t	2026-02-18 20:12:34.3597
228	216	INITIAL_MONEY	4000.00	2026-01-28	Initial Loan	t	2026-02-18 20:13:39.200105
229	217	INITIAL_MONEY	20000.00	2026-01-30	Initial Loan	t	2026-02-18 20:14:48.628281
230	218	INITIAL_MONEY	9000.00	2026-01-31	Initial Loan	t	2026-02-18 20:15:41.361955
231	219	INITIAL_MONEY	15000.00	2026-01-31	Initial Loan	t	2026-02-18 20:16:32.879738
232	220	INITIAL_MONEY	15000.00	2026-02-02	Initial Loan	t	2026-02-18 20:17:24.968382
233	221	INITIAL_MONEY	50000.00	2026-02-02	Initial Loan	t	2026-02-18 20:20:26.084507
234	222	INITIAL_MONEY	6500.00	2026-02-02	Initial Loan	t	2026-02-18 20:21:14.325941
235	223	INITIAL_MONEY	13000.00	2026-02-02	Initial Loan	t	2026-02-18 20:21:58.329936
236	224	INITIAL_MONEY	11000.00	2026-02-03	Initial Loan	t	2026-02-18 20:23:25.525391
237	225	INITIAL_MONEY	3000.00	2026-02-07	Initial Loan	t	2026-02-18 20:24:16.355705
238	226	INITIAL_MONEY	35000.00	2026-02-07	Initial Loan	t	2026-02-18 20:26:57.965396
239	227	INITIAL_MONEY	100000.00	2026-02-09	Initial Loan	t	2026-02-18 20:28:56.016777
240	228	INITIAL_MONEY	2000.00	2026-02-10	Initial Loan	t	2026-02-18 20:30:03.56212
241	229	INITIAL_MONEY	5000.00	2026-02-11	Initial Loan	t	2026-02-18 20:30:59.344582
43	43	INITIAL_MONEY	10000.00	2022-12-09	Initial Loan	t	2026-02-04 21:28:37.727801
242	56	PRINCIPAL_PAYMENT	4365.00	2026-02-23	Settlement (Adjusted: ₹9360)	t	2026-03-01 11:56:38.652858
243	56	INTEREST_PAYMENT	4995.00	2026-02-23	Settlement (Adjusted: ₹9360)	t	2026-03-01 11:56:38.652858
248	18	PRINCIPAL_PAYMENT	11400.00	2026-01-29		t	2026-03-15 14:59:39.303276
249	18	INTEREST_PAYMENT	33600.00	2026-01-29		t	2026-03-15 14:59:39.303276
250	74	EXTRA_WITHDRAWAL	10000.00	2026-03-14		t	2026-03-15 19:25:55.242803
\.


--
-- Data for Name: customer_master; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.customer_master (id, customer_name, mobile_number, email, address, village, district, state, pincode, referral_customer_id, kyc_verified, is_active, created_date, updated_date) FROM stdin;
10	Madhuben Sureshbhai Patni	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-03 20:58:17.414063	2026-02-03 20:58:17.406731
12	Gitaben Bharatbhai Bhil	\N	\N	Patan	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-03 21:04:46.665473	2026-02-03 21:04:46.661995
13	Amratji Bachuji Thakor	\N	\N	\N	Vachhalva	Patan	Gujarat	\N	\N	t	t	2026-02-03 21:10:40.55063	2026-02-03 21:10:40.54708
14	Bhanuben Shaikh	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-03 21:13:34.650954	2026-02-03 21:13:34.646933
15	Vishnubhai Ramabhai Raval	9664595752	\N	\N	Umadi	Patan	Gujarat	\N	\N	t	t	2026-02-03 21:25:24.017073	2026-02-03 21:25:24.014271
17	Agaji Pratapji Thakor	\N	\N	Baju Ma	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-03 21:31:56.436954	2026-02-03 21:31:56.431669
18	Gitaben Rajeshbhai Bhil	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-03 21:34:20.491021	2026-02-03 21:34:20.488721
19	Shilpaben Amratji Thakor	\N	\N	\N	Pipala Gam	Patan	Gujarat	\N	\N	t	t	2026-02-03 21:36:19.859992	2026-02-03 21:36:19.857332
20	Lilaben Kantilal Bhil	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-03 21:38:44.073614	2026-02-03 21:38:44.071135
21	Daxaben Solanki	8128200501	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-03 21:52:08.683267	2026-02-03 21:52:08.676906
22	Rutvikbhai Amratlal Solanki	9724946710	\N	\N	Ajimala	Patan	Gujarat	\N	\N	t	t	2026-02-03 21:58:44.919486	2026-02-03 21:58:44.91725
23	Jayeshbhai Setabhai Thakor	6352758490	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-03 22:03:48.325966	2026-02-03 22:03:48.316869
24	Siddhraj Ratanji Thakor	\N	\N	\N	Der	Patan	Gujarat	\N	\N	t	t	2026-02-03 22:12:29.633966	2026-02-03 22:12:29.627941
25	Lalsang Nagji Thakor	\N	\N	\N	Vagdod	Patan	Gujarat	\N	\N	t	t	2026-02-03 22:14:31.597929	2026-02-03 22:14:31.594037
26	Saratanbhai Desai	\N	\N	\N	Sursan	Patan	Gujarat	\N	\N	t	t	2026-02-03 22:16:36.40407	2026-02-03 22:16:36.40162
29	Ratanben Chelabhai Marwadi	\N	\N	\N	\N	\N	Gujarat	\N	\N	t	t	2026-02-04 00:05:15.063237	2026-02-04 00:05:15.061556
30	Rameshbhai Manilal Raval	9428564252	\N	\N	Paladi	Patan	Gujarat	\N	\N	t	t	2026-02-04 20:45:43.146678	2026-02-04 20:45:43.139902
31	Vijuji Ratanji Thakor	7434066813	\N	\N	der	\N	Gujarat	\N	\N	t	t	2026-02-04 20:49:32.649378	2026-02-04 20:49:32.647324
32	Vishalbhai Modi	\N	\N	Baju ma	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-04 20:51:28.003698	2026-02-04 20:51:28.001882
33	Vadanji Jayantiji Thakor	\N	\N	\N	Diyodar	\N	Gujarat	\N	\N	t	t	2026-02-04 20:53:51.449491	2026-02-04 20:53:51.445885
34	Shilpaben Bharatbhai Bhil	\N	\N	Salivado	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-04 20:58:32.4455	2026-02-04 20:58:32.443556
36	Vijuben Somaji Thakor	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-04 21:01:31.796739	2026-02-04 21:01:31.793918
37	Jagadishbhai Punabhai Bhangi	\N	\N	\N	vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-04 21:03:51.217678	2026-02-04 21:03:51.215485
38	Hiraben Champuji Thakor	\N	\N	\N	Kamboi	\N	Gujarat	\N	\N	t	t	2026-02-04 21:06:10.980269	2026-02-04 21:06:10.978997
39	Sonalben Bhagyaji Mir	\N	\N	\N	Hansapur	\N	Gujarat	\N	\N	t	t	2026-02-04 21:08:27.438298	2026-02-04 21:08:27.43432
43	Rupaben Patni	\N	\N	\N	Bakrapura	\N	Gujarat	\N	\N	t	t	2026-02-04 21:17:53.906089	2026-02-04 21:17:53.905011
46	Bhagabhai Karasanbhai Bhil	9723411659	\N	Khokharvado	\N	Patan	Gujarat	\N	\N	t	t	2026-02-04 21:23:50.473281	2026-02-04 21:23:50.471222
52	Jasodaben Maheshbhai Patni	\N	\N	\N	\N	\N	Gujarat	\N	\N	t	t	2026-02-04 21:43:35.340269	2026-02-04 21:43:35.339131
53	hansaben Agaji Thakor	\N	\N	Baju Ma	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-04 21:45:03.169125	2026-02-04 21:45:03.162397
54	Anandbhai Khodabhai Raval	\N	\N	\N	Ajimana	Patan	Gujarat	\N	\N	t	t	2026-02-04 21:47:56.78116	2026-02-04 21:47:56.780215
55	Tinabhai Vanabhai Senma	\N	\N	\N	\N	\N	Gujarat	\N	\N	t	t	2026-02-05 13:43:52.201938	2026-02-05 13:43:52.124795
56	Savitaben Maganlal Thakor	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-05 13:46:00.992452	2026-02-05 13:46:00.986437
57	Kanuji Baguji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-05 13:49:12.935465	2026-02-05 13:49:12.932531
58	Parvinbhai Babulal Bhangi	\N	\N	\N	Vagdod	\N	Gujarat	\N	\N	t	t	2026-02-05 13:54:50.798713	2026-02-05 13:54:50.78877
59	Malabhai Mir 	\N	\N	\N	Ranuj	\N	Gujarat	\N	\N	t	t	2026-02-05 13:57:17.553797	2026-02-05 13:57:17.551674
60	Chetansinh Gulabsinh Darbar	\N	\N	\N	\N	\N	Gujarat	\N	\N	t	t	2026-02-05 13:59:37.382729	2026-02-05 13:59:37.379832
61	Kuldipji Thakor	9265372231	\N	\N	mehmadpur	\N	Gujarat	\N	\N	t	t	2026-02-05 14:01:49.77413	2026-02-05 14:01:49.771493
62	Ganeshbhai Ishwarbhai Solanki	\N	\N	\N	\N	\N	Gujarat	\N	\N	t	t	2026-02-05 14:03:20.907255	2026-02-05 14:03:20.902674
63	Mukeshji Jogaji Thakor	\N	\N	\N	Der	\N	Gujarat	\N	\N	t	t	2026-02-05 14:06:33.151153	2026-02-05 14:06:33.148054
64	Arjunji HemaJi Thakor	\N	\N	\N	Jamthi	Patan	Gujarat	\N	\N	t	t	2026-02-08 18:42:05.981442	2026-02-08 18:42:05.970707
11	Zayadaben Jusufbhai Shaikh	\N	\N	Pinjarkot, Patan	Patan	\N	Gujarat	\N	\N	t	t	2026-02-03 21:02:07.728951	2026-03-01 11:08:11.121774
66	Raghubha Rajuji Thakor	\N	\N	\N	Kubernagar	Patan	Gujarat	\N	\N	t	t	2026-02-09 22:40:14.990843	2026-02-09 22:40:14.981998
67	Anumji Hemaji Thakor	\N	\N	\N	Gamthi	\N	Gujarat	\N	\N	t	t	2026-02-09 22:48:11.809343	2026-02-09 22:48:11.806271
68	Sanjaybhai Thegabhai Parmar	\N	\N	\N	Dharpur	\N	Gujarat	\N	\N	t	t	2026-02-09 22:50:09.45825	2026-02-09 22:50:09.454682
69	Vishnuji Jagatsinh Thakor	\N	\N	\N	Kimbuva	\N	Gujarat	\N	\N	t	t	2026-02-09 23:01:44.640606	2026-02-09 23:01:44.637689
70	Jitendrakumar Chhanabhai Bhil	\N	\N	\N	\N	\N	Gujarat	\N	\N	t	t	2026-02-09 23:06:19.413322	2026-02-09 23:06:19.411957
72	Mukeshbhai Natvarlal Parmar	9712873150	\N	\N	Hajipur	\N	Gujarat	\N	\N	t	t	2026-02-10 20:54:59.265165	2026-02-10 20:54:59.263136
73	Lakshmanji Jenaji Thakor	\N	\N	\N	Kamboi	\N	Gujarat	\N	\N	t	t	2026-02-10 21:47:05.377427	2026-02-10 21:47:05.371363
74	Galabji deraji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-10 21:56:56.533179	2026-02-10 21:56:56.524427
75	Jagdishbhai Kantilal Parmar	\N	\N	\N	Sankhari	\N	Gujarat	\N	\N	t	t	2026-02-10 21:58:31.087808	2026-02-10 21:58:31.081601
76	Bhavaji Rayaji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-10 21:59:57.905249	2026-02-10 21:59:57.903916
77	Mehulji Natuji Thakor	\N	\N	\N	\N	Patan	Gujarat	\N	\N	t	t	2026-02-10 22:01:58.083119	2026-02-10 22:01:58.081551
78	Vikramji Kalaji Thakor	\N	\N	\N	Runi	\N	Gujarat	\N	\N	t	t	2026-02-10 22:04:42.816733	2026-02-10 22:04:42.812126
79	Jayeshbhai Vaghela	6353632918	\N	\N	\N	\N	Gujarat	\N	\N	t	t	2026-02-10 22:50:14.298647	2026-02-10 22:50:14.248146
80	Kaluji Kalaji Thakor	\N	\N	\N	Vamaiya	\N	Gujarat	\N	\N	t	t	2026-02-11 21:01:52.277362	2026-02-11 21:01:52.271527
81	Anilbhai Ghudaji Rabari	\N	\N	\N	Melusan	\N	Gujarat	\N	\N	t	t	2026-02-11 21:15:11.8371	2026-02-11 21:15:11.810006
84	Mehulbhai Gopalbhai Solanki	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-11 21:24:12.191225	2026-02-11 21:24:12.181562
85	Jayedaben Yusufbhai shaikh	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-11 21:30:00.725067	2026-02-11 21:30:00.723339
86	Sureshji Ghemarji Thakor	\N	\N	\N	Kamboi	\N	Gujarat	\N	\N	t	t	2026-02-11 21:42:21.845197	2026-02-11 21:42:21.839639
87	Vikramji Mafaji Thakor	\N	\N	\N	Kansa	\N	Gujarat	\N	\N	t	t	2026-02-11 21:43:24.410248	2026-02-11 21:43:24.40718
88	Rajubhai Nareshbhai Solanki	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-11 21:44:43.811935	2026-02-11 21:44:43.810355
89	Sobhanaben Rupaji Thakor	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-11 21:45:44.401489	2026-02-11 21:45:44.396971
91	Bhavanaben Mangalsinh Darji	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-11 21:48:00.313654	2026-02-11 21:48:00.311657
92	Virasangji Hariji Thakor	\N	\N	\N	Kamboi	\N	Gujarat	\N	\N	t	t	2026-02-11 21:48:55.619087	2026-02-11 21:48:55.617045
93	Sureshji Nagji Thakor	\N	\N	\N	Vagdod	\N	Gujarat	\N	\N	t	t	2026-02-11 21:51:03.915121	2026-02-11 21:51:03.91156
94	Ishubhai Malabhai Mir	\N	\N	\N	Hansapur	\N	Gujarat	\N	\N	t	t	2026-02-11 21:56:31.930862	2026-02-11 21:56:31.926822
71	Kishorbhai Bhavabhai Solanki	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-10 20:49:28.097822	2026-02-11 22:01:12.628205
95	Najamaben Shaikh	\N	\N	\N	Pinjarkot	Patan	Gujarat	\N	\N	t	t	2026-02-11 22:02:46.955058	2026-02-11 22:02:46.952755
90	Ashokbhai Babubhai Patni	9327801885	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-11 21:47:01.04982	2026-02-12 21:43:58.941171
83	Kamiben Rajuji Thakor	9998965062	\N	\N	Hansapur	\N	Gujarat	\N	\N	t	t	2026-02-11 21:20:47.599135	2026-02-12 21:46:08.934392
2	Mangalbhai Tejabhai 	\N	\N	Sujanipur	Sujanipur	Patan	Gujarat	\N	\N	t	t	2026-02-01 13:51:20.153702	2026-03-01 10:32:00.976989
1	Vishnu Bachuji Thakor	9773922988	\N	Vachhalva	Vachhalva	Patan	Gujarat	\N	\N	t	t	2026-02-01 13:49:26.926753	2026-03-01 18:11:36.516626
35	Pravinji Kantiji Thakor	\N	\N	\N	Koita	Deesa	Gujarat	\N	\N	t	t	2026-02-04 20:59:36.671245	2026-03-01 11:35:38.382192
47	Jigneshbhai Patel	\N	\N	\N	Nehoda	Patan	Gujarat	\N	\N	t	t	2026-02-04 21:25:32.380598	2026-03-01 11:47:59.461618
51	Himmatbhai Parabatji Thakor	\N	\N	\N	vadhi	\N	Gujarat	\N	\N	t	t	2026-02-04 21:42:10.793813	2026-03-01 11:52:36.029619
96	Nareshbhai Chandulaal Patni	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-11 22:07:54.686886	2026-02-11 22:07:54.684725
97	 Joyataji Amlaji Thakor	\N	\N	\N	Jamthi	\N	Gujarat	\N	\N	t	t	2026-02-11 22:14:00.687361	2026-02-11 22:14:00.685128
98	Sureshbhai Ratabhai Bhil	\N	\N	\N	Aghar	\N	Gujarat	\N	\N	t	t	2026-02-11 22:16:21.745972	2026-02-11 22:16:21.744211
100	Lakshmiben Govindji Thakor	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-11 22:18:42.316611	2026-02-11 22:18:42.315105
101	Babaji Bhavanji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-11 22:20:28.184189	2026-02-11 22:20:28.182631
102	Maheshji Tejaji Thakor	\N	\N	\N	Anavada	\N	Gujarat	\N	\N	t	t	2026-02-11 22:23:17.964435	2026-02-11 22:23:17.962027
103	Ganeshbhai Ishwarbhai Bhangi	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-11 22:24:39.406408	2026-02-11 22:24:39.404659
104	Babiben Hamirji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-11 22:26:03.840403	2026-02-11 22:26:03.837888
105	Ruksanabanu Javedbhai Shaikh	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-11 22:27:27.571525	2026-02-11 22:27:27.568712
106	Puriben Kishanbhai Solanki	\N	\N	\N	Vagdod	\N	Gujarat	\N	\N	t	t	2026-02-12 20:31:21.324378	2026-02-12 20:31:21.296742
107	Sonalben Amratji Thakor	\N	\N	Mahavir Society	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-12 20:33:56.840733	2026-02-12 20:33:56.837189
108	Minaben Dineshbhai Solanki	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-12 20:36:40.322664	2026-02-12 20:36:40.317326
109	Pravinji Prahaladji Thakor	8780094815	\N	\N	Hajipur	\N	Gujarat	\N	\N	t	t	2026-02-12 20:38:19.907085	2026-02-12 20:40:06.567104
110	Keshaji Shankarji Thakor	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-12 20:40:59.642161	2026-02-12 20:40:59.640817
111	Lalitbhai Uttambhai Solanki	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-12 20:43:36.278031	2026-02-12 20:43:36.276089
112	Ashokbhai Kishanbhai Barot	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-12 20:45:54.232262	2026-02-12 20:45:54.230786
113	Dharsingh Shunilbhai Banjariya	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-12 20:49:30.514115	2026-02-12 20:49:30.512107
114	Govindbhai Gokulbhai Raval	\N	\N	\N	Kotavar	\N	Gujarat	\N	\N	t	t	2026-02-12 20:50:42.053292	2026-02-12 20:50:42.051513
115	Karanji Somaji Thakor	9662849614	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-12 20:52:48.793608	2026-02-12 20:54:30.32848
116	Viraji Thakor	8849013064	\N	\N	Dasavada	\N	Gujarat	\N	\N	t	t	2026-02-12 20:55:35.007352	2026-02-12 20:55:35.006236
117	Hargovanbhai Shunilbhai Valmiki	9909709887	\N	\N	Aghar	\N	Gujarat	\N	\N	t	t	2026-02-12 21:01:26.769083	2026-02-12 21:03:17.774508
118	Banuben Shaikh	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-12 21:03:59.547312	2026-02-12 21:03:59.546457
119	Nareshbhai Chanduji Thakor	\N	\N	Same	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-12 21:05:40.494147	2026-02-12 21:05:40.491136
120	Sapanaben Mehubhai Jansari	\N	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-12 21:09:36.229982	2026-02-12 21:09:36.228798
121	Kiranben Ratanji Thakor	\N	\N	\N	Dair	\N	Gujarat	\N	\N	t	t	2026-02-12 21:12:29.773652	2026-02-12 21:12:29.770731
123	Ranjanben Amarsinh Darbar	\N	\N	\N	Bakrapura	Patan	Gujarat	\N	\N	t	t	2026-02-12 21:20:47.583476	2026-02-12 21:20:47.57995
122	Sanjaybhai Kanubhai Patni	9624666964	\N	\N	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-12 21:14:41.897808	2026-02-12 21:22:27.265945
124	Sanjaybhai Agaji Thakor	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-12 21:29:47.786459	2026-02-12 21:29:47.784468
125	Ashaben Bharatbhai Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-12 21:31:46.255161	2026-02-12 21:31:46.254045
126	Rahulbhai Sureshbhai Bhangi	\N	\N	\N	Ajimala	\N	Gujarat	\N	\N	t	t	2026-02-12 21:35:37.368133	2026-02-12 21:35:37.366634
127	Jatinbhai Rajubhai Makvana	\N	\N	\N	Sujnipur	Patan	Gujarat	\N	\N	t	t	2026-02-12 21:36:48.761519	2026-02-12 21:36:48.754293
128	Maheshbhai Pratapbhai Bhil	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-12 21:46:43.320484	2026-02-12 21:46:43.319495
129	Sanjaybhai Gunvantlaal Trivedi	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-12 21:48:24.387857	2026-02-12 21:54:01.117073
133	Sureshbhai Maganbhai Parmar	9909627965	\N	\N	Balva	\N	Gujarat	\N	\N	t	t	2026-02-16 21:02:01.88159	2026-02-16 21:03:41.837642
134	Alkaben Mehulji Thakor	\N	\N	\N	Chanasma	\N	Gujarat	\N	\N	t	t	2026-02-16 21:04:25.01048	2026-02-16 21:04:25.008282
135	Abdulkhan Ahmadbhai Sipai	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-16 21:06:12.334056	2026-02-16 21:06:12.332554
136	Alpaben Kiranbhai Thakor	\N	\N	\N	Gabu	\N	Gujarat	\N	\N	t	t	2026-02-16 21:07:04.21948	2026-02-16 21:07:04.216188
137	Jamnaben Thakor	\N	\N	\N	Kansa	\N	Gujarat	\N	\N	t	t	2026-02-16 21:09:50.284155	2026-02-16 21:09:50.282988
138	Kokilaben Rameshbhai Patni	\N	\N	\N	Ramnagar	\N	Gujarat	\N	\N	t	t	2026-02-16 21:11:44.188904	2026-02-16 21:11:44.18135
99	Bhikhiben Dharmabhai Solanki	7041205637	\N	\N	Vagdod	\N	Gujarat	\N	\N	t	t	2026-02-11 22:17:36.071486	2026-02-16 21:23:02.531229
139	Firojbhai Malabhai Mir	\N	\N	\N	Ranuj	\N	Gujarat	\N	\N	t	t	2026-02-16 21:23:38.503821	2026-02-16 21:23:38.498566
140	Ranjanben Bhagaji Thakor	\N	\N	\N	Hansapur	\N	Gujarat	\N	\N	t	t	2026-02-16 21:25:52.876399	2026-02-16 21:25:52.87122
141	Nishaben Sachinbhai Goswami	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-16 21:27:15.894622	2026-02-16 21:27:15.888843
142	Saratanbhai Hemaji Thakor	\N	\N	\N	noyta	\N	Gujarat	\N	\N	t	t	2026-02-16 21:34:41.927928	2026-02-16 21:34:41.92381
143	Vishnu Babaji Thakor	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-16 21:39:26.823826	2026-02-16 21:39:26.819544
144	Vishalbhai Vipulbhai Ood	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-16 21:44:03.298939	2026-02-16 21:44:03.295717
145	Maheshbhai Amratbhai Lavar	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-17 20:28:15.033805	2026-02-17 20:28:14.995818
146	Somaji Kadvaji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-17 20:29:50.238011	2026-02-17 20:29:50.235083
147	Vikramsinh Abhesinh Darbar	\N	\N	\N	Balva	\N	Gujarat	\N	\N	t	t	2026-02-17 20:30:55.756329	2026-02-17 20:30:55.750959
148	Dhirubhai Sureshbhai Solanki	\N	\N	\N	Balva	\N	Gujarat	\N	\N	t	t	2026-02-17 20:31:54.991144	2026-02-17 20:31:54.985121
149	Mehulji Amratji Lavar	9054824819	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-17 20:33:04.244925	2026-02-17 20:33:59.481674
150	Ramaji Bachuji Thakor	\N	\N	\N	Kamboi	\N	Gujarat	\N	\N	t	t	2026-02-17 20:34:33.192004	2026-02-17 20:34:33.182236
151	Velusinh Pradhanji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-17 20:36:24.359921	2026-02-17 20:36:24.357208
152	Dayiben Vijaybhai Thakor	7203857156	\N	\N	Bakrapura	Patan	Gujarat	\N	\N	t	t	2026-02-17 20:39:37.337698	2026-02-17 20:42:58.252887
153	Patel Mafatlal Haribha	\N	\N	\N	Kamlivada	Patan	Gujarat	\N	\N	t	t	2026-02-17 20:45:08.081546	2026-02-17 20:45:08.078934
154	Maniben Kansiya	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-17 20:47:05.595057	2026-02-17 20:47:05.59259
155	Mukeshji Vinaji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-17 20:47:59.953207	2026-02-17 20:47:59.951619
156	Nathaji Ganeshji Thakor	\N	\N	\N	Vamaiya	\N	Gujarat	\N	\N	t	t	2026-02-17 20:49:10.382438	2026-02-17 20:49:10.378663
157	Ansarbhai Ilyasbhai Shaikh	\N	\N	Gymkhana	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-17 20:52:44.99247	2026-02-17 20:52:44.990208
158	Sunilbhai Raval	\N	\N	\N	Runi	\N	Gujarat	\N	\N	t	t	2026-02-17 20:56:40.524218	2026-02-17 20:56:40.521905
159	Mulchandbhai Nathalal Senma	\N	\N	\N	Rajpar	\N	Gujarat	\N	\N	t	t	2026-02-17 20:58:05.792165	2026-02-17 20:58:05.790017
160	Kamuben Rameshbhai Senma	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-17 21:01:15.052803	2026-02-17 21:01:15.047035
161	Meruji gandaji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-17 21:02:49.478439	2026-02-17 21:02:49.476151
162	Viralji Punaji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-17 21:05:03.352519	2026-02-17 21:05:03.350661
163	Dalpatbhai Punabhai Bhangi	9601389810	\N	\N	Kalana	\N	Gujarat	\N	\N	t	t	2026-02-17 21:06:25.341419	2026-02-17 21:07:16.876799
164	Sanjaybhai Veersinh Thakor	6354762530	\N	\N	Vagdod	\N	Gujarat	\N	\N	t	t	2026-02-17 21:13:02.782098	2026-02-17 21:13:02.774432
165	Shankarji Laluji Thakor	\N	\N	\N	Charup	\N	Gujarat	\N	\N	t	t	2026-02-17 21:15:16.014876	2026-02-17 21:15:16.013019
166	Vejsinh Fatesinh Darbar	\N	\N	\N	Balva	\N	Gujarat	\N	\N	t	t	2026-02-17 21:17:51.700821	2026-02-17 21:17:51.694254
167	Sonalben Solanki	7203883720	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-17 22:45:29.066387	2026-02-17 22:45:29.063398
168	Mukeshbhai Kanubhai Marwadi	\N	\N	Suryanagar	Patan	\N	Gujarat	\N	\N	t	t	2026-02-17 22:50:01.871741	2026-02-17 22:50:01.866078
169	Dasharathji Sohamji Thakor	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-17 22:52:43.331939	2026-02-17 22:52:43.326095
172	Gopalbhai Viththalbhai Solanki	\N	\N	\N	Patan	\N	Gujarat	\N	\N	t	t	2026-02-17 22:55:56.564124	2026-02-17 22:55:56.557204
173	Baliben Kagasiya	\N	\N	Baju Ma	Patan	\N	Gujarat	\N	\N	t	t	2026-02-17 22:56:39.041727	2026-02-17 22:56:39.040012
174	Shanduben Thakor	\N	\N	\N	KuberNagar	\N	Gujarat	\N	\N	t	t	2026-02-17 22:57:17.748658	2026-02-17 22:57:17.747688
171	Mehmudbhai Sherubhai Mir	\N	\N	\N	Hansapur	\N	Gujarat	\N	\N	t	t	2026-02-17 22:54:37.310256	2026-02-18 20:22:38.979361
170	Vaktaji Ghenaji Thakor	\N	\N	\N	Vachhalva	\N	Gujarat	\N	\N	t	t	2026-02-17 22:53:42.378521	2026-02-18 20:19:32.043875
8	Vijaybhai Radhuji Thakor	\N	\N	Patan (Same)	Patan	Patan	Gujarat	\N	\N	t	t	2026-02-03 20:47:41.017051	2026-03-01 10:33:46.40412
42	Navalsingh Abhaysingh Thakor	8511736568	\N	\N	Balva	\N	Gujarat	\N	\N	t	t	2026-02-04 21:16:32.374476	2026-03-01 11:44:14.956574
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
38	1	120000.00	2026-02-01	t	2026-02-01 17:03:05.289426
39	2	190000.00	2026-02-01	t	2026-02-01 17:03:15.831148
40	1	120000.00	2026-02-08	t	2026-02-08 18:20:31.415073
41	2	190000.00	2026-02-08	t	2026-02-08 18:20:32.885926
42	1	152000.00	2026-02-17	t	2026-02-17 21:10:19.362327
\.


--
-- Data for Name: merchant_item_entry; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.merchant_item_entry (id, merchant_id, customer_deposit_item_id, entry_date, interest_rate, entry_status, notes, is_active, created_date, updated_date, principal_amount) FROM stdin;
1	1	175	2026-03-12	1.00	ACTIVE		t	2026-03-15 19:03:49.160885	2026-03-15 19:11:00.248589	100000.0000
2	1	225	2026-03-13	1.00	ACTIVE		t	2026-03-15 19:12:11.472687	\N	100000.0000
3	1	85	2026-03-13	1.00	ACTIVE		t	2026-03-15 19:28:50.852797	\N	48000.0000
\.


--
-- Data for Name: merchant_item_transaction; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.merchant_item_transaction (id, merchant_item_entry_id, transaction_type, amount, transaction_date, description, is_active, created_date) FROM stdin;
1	1	PLEDGE	100000.00	2026-03-12		t	2026-03-15 19:03:49.160885
2	2	PLEDGE	100000.00	2026-03-13		t	2026-03-15 19:12:11.472687
3	3	PLEDGE	48000.00	2026-03-13		t	2026-03-15 19:28:50.852797
\.


--
-- Data for Name: merchant_master; Type: TABLE DATA; Schema: mms; Owner: postgres
--

COPY mms.merchant_master (id, merchant_name, merchant_type, mobile_number, address, village, district, state, pincode, default_interest_rate, is_active, created_date, updated_date) FROM stdin;
1	Dishva Modi	LENDER	7984940788	16/B, Sarathi Duplex, Pareva Circle, Patan	\N	\N	\N	\N	1.00	t	2026-03-15 15:32:09.144855	2026-03-15 15:32:09.139967
2	Chetanaben Modi	LENDER	\N	\N	\N	\N	\N	\N	1.00	t	2026-03-15 15:32:40.954925	2026-03-15 15:32:40.953958
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

SELECT pg_catalog.setval('mms.customer_deposit_entry_id_seq', 229, true);


--
-- Name: customer_deposit_items_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.customer_deposit_items_id_seq', 245, true);


--
-- Name: customer_deposit_transaction_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.customer_deposit_transaction_id_seq', 250, true);


--
-- Name: customer_master_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.customer_master_id_seq', 174, true);


--
-- Name: item_master_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.item_master_id_seq', 2, true);


--
-- Name: item_price_history_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.item_price_history_id_seq', 42, true);


--
-- Name: merchant_item_entry_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.merchant_item_entry_id_seq', 3, true);


--
-- Name: merchant_item_transaction_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.merchant_item_transaction_id_seq', 3, true);


--
-- Name: merchant_master_id_seq; Type: SEQUENCE SET; Schema: mms; Owner: postgres
--

SELECT pg_catalog.setval('mms.merchant_master_id_seq', 2, true);


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

