import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, BehaviorSubject, tap } from 'rxjs';
import { REST_URLS } from './shared/resturl';

export interface DepositSummary {
    depositId: number;
    customerName: string;
    depositDate: string;
    totalLoanAmount: number;
    totalInterestAccrued: number;
    totalInterestPaid: number;
    unpaidInterest: number;
    currentAssetValue: number;
    status: 'SAFE' | 'RISK';
    profitLoss: number;
    depositedMonths: number;
    depositedTimeDisplay: string;
    monthlyInterest: number;
}

export interface ConfigProperty {
    id?: number;
    propertyKey: string;
    propertyValue: string;
    description?: string;
    isActive?: boolean;
}

export interface UnitMaster {
    id: number;
    unitName: string;
    unitInGram: number;
}

export interface ItemMaster {
    id: number;
    itemName: string;
    unit: UnitMaster;
    unitQuantity: number;
}

export interface Merchant {
    id: number;
    merchantName: string;
    merchantType: string;
    defaultInterestRate: number;
}

export interface DepositItem {
    id: number;
    depositEntryId: number;
    customerName: string;
    itemName: string;
    weight: number;
    fineWeight: number;
    itemStatus: string;
    currentAssetValue: number;
}

export interface MerchantItem {
    entryId: number;
    merchantId: number;
    merchantName: string;
    depositItemId: number;
    customerName: string;
    itemName: string;
    weight: number;
    fineWeight: number;
    entryDate: string;
    interestRate: number;
    principalAmount: number;
    accruedInterest: number;
    totalOwed: number;
    status: string;
    currentAssetValue: number;
    notes: string;
    totalPrincipalPaid: number;
    totalInterestPaid: number;
    monthlyInterestAmount: number;
    monthsDuration: number;
    customerInterestRate: number;
    customerMonthlyInterest: number;
    netMonthlyMargin: number;
    transactions?: any[];
}

export interface DashboardStats {
    totalActiveDeposits: number;
    totalClosedDeposits: number;
    totalLoanAmount: number;
    totalInterestAccrued: number;
    todayPurchase: number;
    todaySell: number;
}

@Injectable({
    providedIn: 'root'
})
export class MmsService {
    private pricesSubject = new BehaviorSubject<any[]>([]);
    public prices$ = this.pricesSubject.asObservable();

    private configsSubject = new BehaviorSubject<ConfigProperty[]>([]);
    public configs$ = this.configsSubject.asObservable();

    constructor(private http: HttpClient) {
        this.refreshLatestPrices();
        this.refreshConfigs();
    }

    refreshConfigs() {
        this.getAllConfigs().subscribe({
            next: (data) => this.configsSubject.next(data),
            error: (err) => console.error('MmsService: Error fetching configs:', err)
        });
    }

    getConfigValue(key: string): string {
        const config = this.configsSubject.value.find(c => c.propertyKey === key);
        if (!config) {
            throw new Error(`Critical System Error: Missing configuration for '${key}'. Please update System Settings.`);
        }
        return config.propertyValue;
    }

    getDashboardData(): Observable<DepositSummary[]> {
        return this.http.post<DepositSummary[]>(REST_URLS.DASHBOARD, {});
    }

    getActiveDepositSummary(): Observable<DepositSummary[]> {
        return this.getDashboardData();
    }

    getActiveDepositSummaryPaginated(page: number, size: number, sort: string, dir: string, filters?: any): Observable<any> {
        let payload: any = {
            page,
            size,
            sort,
            dir,
            ...filters
        };
        return this.http.post<any>(REST_URLS.DASHBOARD_PAGINATED, payload);
    }

    getDashboardStats(): Observable<DashboardStats> {
        return this.http.post<DashboardStats>(REST_URLS.DASHBOARD_STATS, {});
    }

    getAllItems(): Observable<ItemMaster[]> {
        return this.http.post<ItemMaster[]>(REST_URLS.ITEMS_LIST, {});
    }

    getAllUnits(): Observable<UnitMaster[]> {
        return this.http.post<UnitMaster[]>(REST_URLS.UNITS_LIST, {});
    }

    getAllConfigs(): Observable<ConfigProperty[]> {
        return this.http.post<ConfigProperty[]>(REST_URLS.CONFIGS_LIST, {});
    }

    saveConfig(config: ConfigProperty): Observable<ConfigProperty> {
        if (config.id) {
            return this.http.post<ConfigProperty>(REST_URLS.CONFIGS_UPDATE, config);
        }
        return this.http.post<ConfigProperty>(REST_URLS.CONFIGS_SAVE, config);
    }

    deleteConfig(id: number): Observable<void> {
        return this.http.post<void>(REST_URLS.CONFIGS_DELETE, { id });
    }

    refreshLatestPrices() {
        this.http.post<any[]>(REST_URLS.PRICES_LATEST, {}).subscribe({
            next: (data) => {
                this.pricesSubject.next(data);
            },
            error: (err) => {
                console.error('MmsService: Error fetching prices:', err);
            }
        });
    }

    getLatestPrices(): Observable<any[]> {
        return this.http.post<any[]>(REST_URLS.PRICES_LATEST, {}).pipe(
            tap(data => this.pricesSubject.next(data))
        );
    }

    updatePrice(itemId: number, price: number): Observable<any[]> {
        return this.http.post<any[]>(REST_URLS.PRICES_UPDATE, { itemId, price }).pipe(
            tap(data => {
                if (data && Array.isArray(data)) {
                    this.pricesSubject.next(data);
                } else {
                    this.refreshLatestPrices();
                }
            })
        );
    }

    createDeposit(data: any): Observable<any> {
        return this.http.post(REST_URLS.DEPOSITS_CREATE, data, { responseType: 'text' });
    }

    // deleteCustomer(id: number): Observable<void> {
    //     return this.http.post<void>(REST_URLS.CUSTOMERS_DELETE, { id });
    // }

    searchCustomers(query: string): Observable<any[]> {
        return this.http.post<any[]>(REST_URLS.CUSTOMERS_SEARCH, { q: query });
    }

    getCustomers(page: number = 0, size: number = 10, sortBy: string = 'id', sortDir: string = 'asc'): Observable<any> {
        const payload = { page, size, sortBy, sortDir };
        return this.http.post<any>(REST_URLS.CUSTOMERS_LIST, payload);
    }

    getCustomerItems(customerId: number): Observable<any[]> {
        return this.http.post<any[]>(REST_URLS.CUSTOMERS_ITEMS, { id: customerId });
    }

    getCustomerPortfolio(customerId: number): Observable<any> {
        return this.http.post<any>(REST_URLS.CUSTOMERS_PORTFOLIO, { id: customerId });
    }

    calculateAssetValue(itemId: number, fineWeight: number): Observable<number> {
        return this.http.post<number>(REST_URLS.ITEMS_CALCULATE_VALUE, { itemId, fineWeight });
    }

    createCustomer(data: any): Observable<any> {
        return this.http.post<any>(REST_URLS.CUSTOMERS_CREATE, data);
    }

    updateCustomer(id: number, data: any): Observable<any> {
        const payload = { ...data, id: id };
        return this.http.post<any>(REST_URLS.CUSTOMERS_UPDATE, payload);
    }

    getDeposit(id: number): Observable<any> {
        return this.http.post<any>(REST_URLS.DEPOSITS_DETAILS, { id });
    }

    updateDeposit(id: number, data: any): Observable<any> {
        const payload = { ...data, id: id };
        return this.http.post(REST_URLS.DEPOSITS_UPDATE, payload, { responseType: 'text' });
    }

    addDepositTransaction(id: number, data: any): Observable<any> {
        const payload = { ...data, depositId: id };
        return this.http.post(REST_URLS.DEPOSITS_ADD_TRANSACTION, payload, { responseType: 'text' });
    }

    checkTokenAvailability(tokenNo: number): Observable<boolean> {
        return this.http.post<boolean>(REST_URLS.DEPOSITS_CHECK_TOKEN, { tokenNo });
    }

    generateToken(): Observable<number> {
        return this.http.post<number>(REST_URLS.DEPOSITS_GENERATE_TOKEN, {});
    }

    checkActiveMerchantItems(id: number): Observable<boolean> {
        return this.http.post<boolean>(REST_URLS.DEPOSITS_CHECK_ACTIVE_ITEMS, { id });
    }

    getActiveMerchantEntries(id: number): Observable<any[]> {
        return this.http.post<any[]>(REST_URLS.DEPOSITS_ACTIVE_MERCHANT_ENTRIES, { id });
    }

    closeDeposit(id: number): Observable<any> {
        return this.http.post(REST_URLS.DEPOSITS_CLOSE, { id }, { responseType: 'text' });
    }

    getAllMerchants(): Observable<Merchant[]> {
        return this.http.post<Merchant[]>(REST_URLS.MERCHANTS_LIST, {});
    }

    createMerchant(data: any): Observable<Merchant> {
        return this.http.post<Merchant>(REST_URLS.MERCHANTS_CREATE, data);
    }

    updateMerchant(id: number, data: any): Observable<Merchant> {
        const payload = { ...data, id: id };
        return this.http.post<Merchant>(REST_URLS.MERCHANTS_UPDATE, payload);
    }

    deleteMerchant(id: number): Observable<any> {
        return this.http.post(REST_URLS.MERCHANTS_DELETE, { id }, { responseType: 'text' });
    }

    getAvailableItems(): Observable<DepositItem[]> {
        return this.http.post<DepositItem[]>(REST_URLS.ITEMS_AVAILABLE, {});
    }

    transferToMerchant(data: any): Observable<any> {
        return this.http.post(REST_URLS.MERCHANT_ENTRIES_TRANSFER, data, { responseType: 'text' });
    }

    updateMerchantEntry(id: number, data: any): Observable<any> {
        const payload = { ...data, id: id };
        return this.http.post(REST_URLS.MERCHANT_ENTRIES_UPDATE, payload, { responseType: 'text' });
    }

    getActiveMerchantItems(): Observable<MerchantItem[]> {
        return this.http.post<MerchantItem[]>(REST_URLS.MERCHANT_ENTRIES_ACTIVE, {});
    }

    returnFromMerchant(entryId: number, data: any): Observable<any> {
        const payload = { ...data, id: entryId };
        return this.http.post(REST_URLS.MERCHANT_ENTRIES_RETURN, payload, { responseType: 'text' });
    }

    addMerchantTransaction(entryId: number, data: any): Observable<any> {
        const payload = { ...data, id: entryId };
        return this.http.post(REST_URLS.MERCHANT_ENTRIES_TRANSACTION, payload, { responseType: 'text' });
    }

    getMerchantEntryDetails(entryId: number): Observable<any> {
        return this.http.post<any>(REST_URLS.MERCHANT_ENTRIES_DETAILS, { id: entryId });
    }

    getChartData(period: string): Observable<any[]> {
        return this.http.post<any[]>(REST_URLS.DASHBOARD_CHART, { period });
    }

    seedData(count: number): Observable<any> {
        return this.http.post(REST_URLS.TEST_SEED, { count }, { responseType: 'text' }).pipe(
            tap(() => this.refreshLatestPrices())
        );
    }

    downloadReport(type: string): Observable<Blob> {
        return this.http.post(REST_URLS.REPORTS_GENERATE, { type }, { responseType: 'blob' });
    }

    backupDatabase(): Observable<Blob> {
        return this.http.post(REST_URLS.DATABASE_BACKUP, {}, { responseType: 'blob' });
    }

    restoreDatabase(file: File, params: any): Observable<any> {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('host', params.host);
        formData.append('port', params.port);
        formData.append('user', params.user);
        formData.append('pass', params.pass);
        formData.append('db', params.db);
        formData.append('schema', params.schema);
        formData.append('psqlPath', params.psqlPath);
        return this.http.post(REST_URLS.DATABASE_RESTORE, formData, { responseType: 'text' });
    }

}
