export const BASE_DOMAIN = ''; // Leave empty for relative or update as needed e.g. 'http://localhost:8081'
export const BASE_API_URL = BASE_DOMAIN + '/api';

export const REST_URLS = {
    DASHBOARD: `${BASE_API_URL}/dashboard`,
    DASHBOARD_PAGINATED: `${BASE_API_URL}/dashboard/paginated`,
    DASHBOARD_STATS: `${BASE_API_URL}/dashboard/stats`,
    DASHBOARD_CHART: `${BASE_API_URL}/dashboard/chart`,

    ITEMS: `${BASE_API_URL}/items`,
    ITEMS_AVAILABLE: `${BASE_API_URL}/items/available`,
    ITEMS_CALCULATE_VALUE: `${BASE_API_URL}/items/calculate-value`,

    UNITS: `${BASE_API_URL}/units`,

    CONFIGS: `${BASE_API_URL}/configs`,

    PRICES: `${BASE_API_URL}/prices`,
    PRICES_LATEST: `${BASE_API_URL}/prices/latest`,

    DEPOSITS: `${BASE_API_URL}/deposits`,

    CUSTOMERS: `${BASE_API_URL}/customers`,
    CUSTOMERS_SEARCH: `${BASE_API_URL}/customers/search`,

    MERCHANTS: `${BASE_API_URL}/merchants`,
    MERCHANT_ENTRIES: `${BASE_API_URL}/merchant-entries`,

    TEST_SEED: `${BASE_API_URL}/test/seed`
};
