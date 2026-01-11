/**
 * Utility constants for the application.
 */
package com.mms.backend.util;

public final class Constants {

    private Constants() {
        // Utility class
    }

    public static final String TX_INITIAL_MONEY = "INITIAL_MONEY";
    public static final String TX_PRINCIPAL_PAYMENT = "PRINCIPAL_PAYMENT";
    public static final String TX_INTEREST_PAYMENT = "INTEREST_PAYMENT";
    public static final String TX_EXTRA_WITHDRAWAL = "EXTRA_WITHDRAWAL";
    public static final String TX_PRINCIPAL_LOAN = "PRINCIPAL_LOAN";
    public static final String TX_INTEREST_RECEIVED = "INTEREST_RECEIVED";

    public static final String STATUS_ACTIVE = "ACTIVE";
    public static final String STATUS_CLOSED = "CLOSED";
    public static final String STATUS_RETURNED = "RETURNED";
    public static final String STATUS_RISK = "RISK";
    public static final String STATUS_SAFE = "SAFE";

    public static final String KEY_ITEM_ID = "itemId";
    public static final String LITERAL_MONTHS = " months";

    // System Config Keys
    public static final String CONFIG_PAGINATION_DEFAULT_SIZE = "system.pagination.default.size";
    public static final String CONFIG_RISK_THRESHOLD = "system.risk.threshold.percentage";
    public static final String CONFIG_CALENDAR_ROUND_UP = "system.calendar.months.round_up";
    public static final String CONFIG_ENCRYPTION_SECRET_KEY = "system.encryption.secret-key";

    // Common Strings
    public static final String STR_ID = "id";
    public static final String STR_ASC = "asc";
    public static final String STR_DESC = "desc";
    public static final String STR_SECURE = "SECURE";

    // Report Types
    public static final String REPORT_TYPE_DEPOSITS = "deposits";
    public static final String REPORT_TYPE_CUSTOMERS = "customers";
    public static final String REPORT_TYPE_MERCHANTS = "merchants";

    // File Names
    public static final String FILE_NAME_DEPOSITS_REPORT = "Deposits_Report.xlsx";
    public static final String FILE_NAME_CUSTOMERS_REPORT = "Customers_Report.xlsx";
    public static final String FILE_NAME_MERCHANTS_REPORT = "Merchants_Report.xlsx";

    // Report Sheet Names
    public static final String REPORT_SHEET_DEPOSITS = "Deposits";
    public static final String REPORT_SHEET_CUSTOMERS = "Customers";
    public static final String REPORT_SHEET_MERCHANT_TRANSFERS = "Merchant Transfers";

    // Date Formats
    public static final String DATE_FORMAT_FILE_NAME = "yyyy-MM-dd_HH-mm-ss";
    public static final String DATE_FORMAT_CHART_LABEL = "dd MMM";

    // Chart Periods
    public static final String PERIOD_WEEK = "WEEK";
    public static final String PERIOD_MONTH = "MONTH";
    public static final String PERIOD_YEAR = "YEAR";
    public static final String PERIOD_DAY = "DAY";
}
