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
        return this.http.get<DepositSummary[]>(REST_URLS.DASHBOARD);
    }

    getActiveDepositSummary(): Observable<DepositSummary[]> {
        return this.getDashboardData();
    }

    getActiveDepositSummaryPaginated(page: number, size: number, sort: string, dir: string, filters?: any): Observable<any> {
        let params = new HttpParams()
            .set('page', page)
            .set('size', size)
            .set('sort', sort)
            .set('dir', dir);

        if (filters) {
            Object.keys(filters).forEach(key => {
                if (filters[key] !== null && filters[key] !== '') {
                    params = params.set(key, filters[key]);
                }
            });
        }

        return this.http.get<any>(REST_URLS.DASHBOARD_PAGINATED, { params });
    }

    getDashboardStats(): Observable<DashboardStats> {
        return this.http.get<DashboardStats>(REST_URLS.DASHBOARD_STATS);
    }

    getAllItems(): Observable<ItemMaster[]> {
        return this.http.get<ItemMaster[]>(REST_URLS.ITEMS);
    }

    getAllUnits(): Observable<UnitMaster[]> {
        return this.http.get<UnitMaster[]>(REST_URLS.UNITS);
    }

    getAllConfigs(): Observable<ConfigProperty[]> {
        return this.http.get<ConfigProperty[]>(REST_URLS.CONFIGS);
    }

    saveConfig(config: ConfigProperty): Observable<ConfigProperty> {
        if (config.id) {
            return this.http.put<ConfigProperty>(`${REST_URLS.CONFIGS}/${config.id}`, config);
        }
        return this.http.post<ConfigProperty>(REST_URLS.CONFIGS, config);
    }

    deleteConfig(id: number): Observable<void> {
        return this.http.delete<void>(`${REST_URLS.CONFIGS}/${id}`);
    }

    refreshLatestPrices() {
        const timestamp = new Date().getTime();
        this.http.get<any[]>(`${REST_URLS.PRICES_LATEST}?t=${timestamp}`).subscribe({
            next: (data) => {
                this.pricesSubject.next(data);
            },
            error: (err) => {
                console.error('MmsService: Error fetching prices:', err);
            }
        });
    }

    getLatestPrices(): Observable<any[]> {
        const timestamp = new Date().getTime();
        return this.http.get<any[]>(`${REST_URLS.PRICES_LATEST}?t=${timestamp}`).pipe(
            tap(data => this.pricesSubject.next(data))
        );
    }

    updatePrice(itemId: number, price: number): Observable<any[]> {
        return this.http.post<any[]>(REST_URLS.PRICES, { itemId, price }).pipe(
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
        return this.http.post(REST_URLS.DEPOSITS, data, { responseType: 'text' });
    }

    deleteCustomer(id: number): Observable<void> {
        return this.http.delete<void>(`${REST_URLS.CUSTOMERS}/${id}`);
    }

    searchCustomers(query: string): Observable<any[]> {
        return this.http.get<any[]>(`${REST_URLS.CUSTOMERS_SEARCH}?q=${query}`);
    }

    getCustomerItems(customerId: number): Observable<any[]> {
        return this.http.get<any[]>(`${REST_URLS.CUSTOMERS}/${customerId}/items`);
    }

    getCustomerPortfolio(customerId: number): Observable<any> {
        return this.http.get<any>(`${REST_URLS.CUSTOMERS}/${customerId}/portfolio`);
    }

    calculateAssetValue(itemId: number, fineWeight: number): Observable<number> {
        return this.http.get<number>(`${REST_URLS.ITEMS_CALCULATE_VALUE}?itemId=${itemId}&fineWeight=${fineWeight}`);
    }

    createCustomer(data: any): Observable<any> {
        return this.http.post<any>(REST_URLS.CUSTOMERS, data);
    }

    getDeposit(id: number): Observable<any> {
        return this.http.get<any>(`${REST_URLS.DEPOSITS}/${id}`);
    }

    updateDeposit(id: number, data: any): Observable<any> {
        return this.http.put(`${REST_URLS.DEPOSITS}/${id}`, data, { responseType: 'text' });
    }

    addDepositTransaction(id: number, data: any): Observable<any> {
        return this.http.post(`${REST_URLS.DEPOSITS}/${id}/transactions`, data, { responseType: 'text' });
    }

    checkTokenAvailability(tokenNo: number): Observable<boolean> {
        return this.http.get<boolean>(`${REST_URLS.DEPOSITS}/check-token?tokenNo=${tokenNo}`);
    }

    generateToken(): Observable<number> {
        return this.http.get<number>(`${REST_URLS.DEPOSITS}/generate-token`);
    }

    checkActiveMerchantItems(id: number): Observable<boolean> {
        return this.http.get<boolean>(`${REST_URLS.DEPOSITS}/${id}/has-active-merchant-items`);
    }

    getActiveMerchantEntries(id: number): Observable<any[]> {
        return this.http.get<any[]>(`${REST_URLS.DEPOSITS}/${id}/active-merchant-entries`);
    }

    closeDeposit(id: number): Observable<any> {
        return this.http.delete(`${REST_URLS.DEPOSITS}/${id}`, { responseType: 'text' });
    }

    getAllMerchants(): Observable<Merchant[]> {
        return this.http.get<Merchant[]>(REST_URLS.MERCHANTS);
    }

    createMerchant(data: any): Observable<Merchant> {
        return this.http.post<Merchant>(REST_URLS.MERCHANTS, data);
    }

    updateMerchant(id: number, data: any): Observable<Merchant> {
        return this.http.put<Merchant>(`${REST_URLS.MERCHANTS}/${id}`, data);
    }

    deleteMerchant(id: number): Observable<any> {
        return this.http.delete(`${REST_URLS.MERCHANTS}/${id}`, { responseType: 'text' });
    }

    getAvailableItems(): Observable<DepositItem[]> {
        return this.http.get<DepositItem[]>(REST_URLS.ITEMS_AVAILABLE);
    }

    transferToMerchant(data: any): Observable<any> {
        return this.http.post(REST_URLS.MERCHANT_ENTRIES, data, { responseType: 'text' });
    }

    updateMerchantEntry(id: number, data: any): Observable<any> {
        return this.http.put(`${REST_URLS.MERCHANT_ENTRIES}/${id}`, data, { responseType: 'text' });
    }

    getActiveMerchantItems(): Observable<MerchantItem[]> {
        return this.http.get<MerchantItem[]>(`${REST_URLS.MERCHANT_ENTRIES}/active`);
    }

    returnFromMerchant(entryId: number, data: any): Observable<any> {
        return this.http.post(`${REST_URLS.MERCHANT_ENTRIES}/${entryId}/return`, data, { responseType: 'text' });
    }

    addMerchantTransaction(entryId: number, data: any): Observable<any> {
        return this.http.post(`${REST_URLS.MERCHANT_ENTRIES}/${entryId}/transaction`, data, { responseType: 'text' });
    }

    getMerchantEntryDetails(entryId: number): Observable<any> {
        return this.http.get<any>(`${REST_URLS.MERCHANT_ENTRIES}/${entryId}/details`);
    }

    getChartData(period: string): Observable<any[]> {
        return this.http.get<any[]>(`${REST_URLS.DASHBOARD_CHART}?period=${period}`);
    }

    seedData(count: number): Observable<any> {
        return this.http.post(`${REST_URLS.TEST_SEED}?count=${count}`, {}, { responseType: 'text' }).pipe(
            tap(() => this.refreshLatestPrices())
        );
    }
}

