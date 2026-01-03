export const CONFIG_KEYS = {
    BUSINESS_NAME: 'business.name',
    BUSINESS_SHORT_NAME: 'business.short_name',
    BUSINESS_ADDRESS: 'business.address',
    BUSINESS_MOBILE: 'business.mobile',
    BUSINESS_EMAIL: 'business.email',
    BUSINESS_GSTIN: 'business.gstin',

    DEFAULT_UNIT_ID: 'default.unit.master.id',
    DEFAULT_INTEREST_RATE: 'default.customer.interest.rate',
    DEFAULT_FINE_PERCENTAGE: 'default.fine.percentage',
    DEFAULT_STATE: 'default.customer.state',
    DEFAULT_GIVING_PERCENTAGE: 'default.giving.percentage',

    SYSTEM_CURRENCY_SYMBOL: 'system.currency.symbol',
    SYSTEM_RISK_THRESHOLD: 'system.risk.threshold.percentage',
    SYSTEM_PAGINATION_SIZE: 'system.pagination.default.size',
    SYSTEM_CALENDAR_ROUND_UP: 'system.calendar.months.round_up'
};

export const APP_CONSTANTS = {
    DEFAULT_STATE: 'Gujarat',
    DATE_FORMAT: 'yyyy-MM-dd',
    CURRENCY_CODE: 'INR'
};

export const RECOMMENDED_CONFIGS = [
    { key: CONFIG_KEYS.BUSINESS_NAME, val: 'Jay Laxmi Jewellers Dhiran System', desc: 'The official name of the business' },
    { key: CONFIG_KEYS.BUSINESS_SHORT_NAME, val: 'Jay Laxmi', desc: 'Shorter name for sidebar logo' },
    { key: CONFIG_KEYS.BUSINESS_ADDRESS, val: 'Patan, Gujarat', desc: 'Physical address for receipts' },
    { key: CONFIG_KEYS.BUSINESS_MOBILE, val: '+91 99245 80455', desc: 'Primary contact number' },
    { key: CONFIG_KEYS.BUSINESS_EMAIL, val: 'jaylaxmi@gamil.com', desc: 'Business email address' },
    { key: CONFIG_KEYS.BUSINESS_GSTIN, val: '--------------', desc: 'GST Registration Number' },
    { key: CONFIG_KEYS.DEFAULT_UNIT_ID, val: '1', desc: 'Default unit ID (1 for GRAM)' },
    { key: CONFIG_KEYS.DEFAULT_INTEREST_RATE, val: '3.0', desc: 'Default monthly interest rate for new deposits' },
    { key: CONFIG_KEYS.DEFAULT_FINE_PERCENTAGE, val: '75.0', desc: 'Average default purity percentage for items' },
    { key: CONFIG_KEYS.SYSTEM_CURRENCY_SYMBOL, val: '₹', desc: 'Local currency symbol used for display' },
    { key: CONFIG_KEYS.SYSTEM_RISK_THRESHOLD, val: '100', desc: 'Risk status if Loan > X% of Asset Value' },
    { key: CONFIG_KEYS.SYSTEM_PAGINATION_SIZE, val: '10', desc: 'Default rows per page in tables' },
    { key: CONFIG_KEYS.SYSTEM_CALENDAR_ROUND_UP, val: 'true', desc: 'Whether to count partial month as full month' },
    { key: CONFIG_KEYS.DEFAULT_STATE, val: 'Gujarat', desc: 'Default state for new customer creation' },
    { key: CONFIG_KEYS.DEFAULT_GIVING_PERCENTAGE, val: '60.0', desc: 'Default loan-to-value percentage for items' }
];
