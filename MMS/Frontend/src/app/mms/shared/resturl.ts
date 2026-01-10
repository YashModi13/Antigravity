export const BASE_DOMAIN = ''; // Leave empty for relative or update as needed e.g. 'http://localhost:8081'
export const BASE_API_URL = BASE_DOMAIN + '/api';

export const REST_URLS = {
    DASHBOARD: `${BASE_API_URL}/dashboard`,
    DASHBOARD_PAGINATED: `${BASE_API_URL}/dashboard/paginated-v2`,
    DASHBOARD_STATS: `${BASE_API_URL}/dashboard/stats`,
    DASHBOARD_CHART: `${BASE_API_URL}/dashboard/chart`,

    ITEMS_LIST: `${BASE_API_URL}/items/list`,
    ITEMS_AVAILABLE: `${BASE_API_URL}/items/available`,
    ITEMS_CALCULATE_VALUE: `${BASE_API_URL}/items/calculate-value`,

    UNITS_LIST: `${BASE_API_URL}/units/list`,

    CONFIGS_LIST: `${BASE_API_URL}/configs/list`,
    CONFIGS_DETAILS: `${BASE_API_URL}/configs/details`,
    CONFIGS_SAVE: `${BASE_API_URL}/configs/save`,
    CONFIGS_UPDATE: `${BASE_API_URL}/configs/update`,
    CONFIGS_DELETE: `${BASE_API_URL}/configs/delete`,

    PRICES_UPDATE: `${BASE_API_URL}/prices`,
    PRICES_LATEST: `${BASE_API_URL}/prices/latest`,

    DEPOSITS_CREATE: `${BASE_API_URL}/deposits/create`,
    DEPOSITS_DETAILS: `${BASE_API_URL}/deposits/details`,
    DEPOSITS_UPDATE: `${BASE_API_URL}/deposits/update`,
    DEPOSITS_CLOSE: `${BASE_API_URL}/deposits/close`,
    DEPOSITS_CHECK_ACTIVE_ITEMS: `${BASE_API_URL}/deposits/check-active-items`,
    DEPOSITS_ACTIVE_MERCHANT_ENTRIES: `${BASE_API_URL}/deposits/active-merchant-entries`,
    DEPOSITS_ADD_TRANSACTION: `${BASE_API_URL}/deposits/transactions/add`,
    DEPOSITS_CHECK_TOKEN: `${BASE_API_URL}/deposits/check-token`,
    DEPOSITS_GENERATE_TOKEN: `${BASE_API_URL}/deposits/generate-token`,

    CUSTOMERS_LIST: `${BASE_API_URL}/customers/list`,
    CUSTOMERS_CREATE: `${BASE_API_URL}/customers/create`,
    CUSTOMERS_UPDATE: `${BASE_API_URL}/customers/update`,
    CUSTOMERS_SEARCH: `${BASE_API_URL}/customers/search`,
    CUSTOMERS_ITEMS: `${BASE_API_URL}/customers/items`,
    CUSTOMERS_PORTFOLIO: `${BASE_API_URL}/customers/portfolio`,

    MERCHANTS_LIST: `${BASE_API_URL}/merchants/list`,
    MERCHANTS_CREATE: `${BASE_API_URL}/merchants/create`,
    MERCHANTS_UPDATE: `${BASE_API_URL}/merchants/update`,
    MERCHANTS_DELETE: `${BASE_API_URL}/merchants/delete`,

    MERCHANT_ENTRIES_TRANSFER: `${BASE_API_URL}/merchant-entries/transfer`,
    MERCHANT_ENTRIES_UPDATE: `${BASE_API_URL}/merchant-entries/update`,
    MERCHANT_ENTRIES_ACTIVE: `${BASE_API_URL}/merchant-entries/active`,
    MERCHANT_ENTRIES_DETAILS: `${BASE_API_URL}/merchant-entries/details`,
    MERCHANT_ENTRIES_RETURN: `${BASE_API_URL}/merchant-entries/return`,
    MERCHANT_ENTRIES_TRANSACTION: `${BASE_API_URL}/merchant-entries/transaction`,

    REPORTS_GENERATE: `${BASE_API_URL}/reports/generate`,
    DATABASE_BACKUP: `${BASE_API_URL}/database/backup`,
    DATABASE_RESTORE: `${BASE_API_URL}/database/restore`,

    TEST_SEED: `${BASE_API_URL}/test/seed`
};
