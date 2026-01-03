import { Component, OnInit, ViewChild, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { MmsService, DepositSummary, ItemMaster } from '../mms.service';
import { FormsModule } from '@angular/forms';
import { NgApexchartsModule, ApexOptions, ChartComponent } from 'ng-apexcharts';
import { ToastService } from 'src/app/theme/shared/components/toast/toast.service';
import { map } from 'rxjs';
import { CONFIG_KEYS } from '../shared/constant';

@Component({
    selector: 'app-mms-dashboard',
    standalone: true,
    imports: [CommonModule, SharedModule, FormsModule, NgApexchartsModule],
    templateUrl: './dashboard.component.html',
    styleUrls: ['./dashboard.component.scss']
})
export class MmsDashboardComponent implements OnInit {
    deposits: DepositSummary[] = [];
    items: ItemMaster[] = [];
    businessName$ = this.mmsService.configs$.pipe(
        map(configs => {
            const config = configs.find(c => c.propertyKey === CONFIG_KEYS.BUSINESS_NAME);
            if (!config) throw new Error("Missing config: " + CONFIG_KEYS.BUSINESS_NAME);
            return config.propertyValue;
        })
    );
    currencySymbol$ = this.mmsService.configs$.pipe(
        map(configs => {
            const config = configs.find(c => c.propertyKey === CONFIG_KEYS.SYSTEM_CURRENCY_SYMBOL);
            if (!config) throw new Error("Missing config: " + CONFIG_KEYS.SYSTEM_CURRENCY_SYMBOL);
            return config.propertyValue;
        })
    );
    priceUpdates: { [key: number]: number } = {};
    stats: any = {};

    selectedPeriod: string = 'WEEK';
    chartOptions: Partial<ApexOptions> = {
        series: [],
        chart: {
            type: 'line',
            height: 350,
            fontFamily: 'inherit',
            toolbar: {
                show: false
            }
        },
        colors: ['#1de9b6', '#f44236'],
        dataLabels: {
            enabled: false
        },
        stroke: {
            curve: 'smooth',
            width: 3
        },
        xaxis: {
            type: 'category',
            categories: []
        },
        yaxis: {
            title: {
                text: 'Amount (₹)'
            }
        },
        markers: {
            size: 4
        },
        fill: {
            opacity: 1
        },
        tooltip: {
            y: {
                formatter: (val) => {
                    const symbol = this.mmsService.getConfigValue(CONFIG_KEYS.SYSTEM_CURRENCY_SYMBOL) || '₹';
                    return symbol + ' ' + val;
                }
            }
        },
        legend: {
            show: true,
            position: 'top'
        }
    };

    @ViewChild("chart") chart: ChartComponent;

    constructor(
        private mmsService: MmsService,
        private toastService: ToastService,
        private cdr: ChangeDetectorRef
    ) { }

    ngOnInit() {
        this.loadData();
        this.loadItems();
        this.loadChart();
        this.loadStats();
    }

    loadData() {
        this.mmsService.getDashboardData().subscribe((data) => {
            this.deposits = data;
        });
    }

    loadItems() {
        this.mmsService.getAllItems().subscribe((data) => {
            this.items = data;
        });
    }

    loadStats() {
        this.mmsService.getDashboardStats().subscribe((data) => {
            this.stats = data;
        });
    }

    priceDisplay: { [key: number]: string } = {};

    onPriceInput(itemId: number, event: any) {
        let valueStr = event.target.value.replace(/,/g, '');
        const value = Number(valueStr);
        if (!isNaN(value) && valueStr !== '' && value > 0) {
            this.priceUpdates[itemId] = value;
            this.priceDisplay[itemId] = value.toLocaleString('en-IN');
        } else {
            this.priceUpdates[itemId] = null;
            this.priceDisplay[itemId] = '';
        }
    }

    updatePrice(itemId: number) {
        const price = this.priceUpdates[itemId];
        const item = this.items.find(i => i.id === itemId);
        if (price && item) {
            this.mmsService.updatePrice(itemId, price).subscribe({
                next: () => {
                    this.toastService.success(`${item.itemName} Price updated to ₹${price.toLocaleString('en-IN')} successfully!`);
                    this.loadData();
                    this.loadStats();
                    this.loadChart();
                    this.priceUpdates[itemId] = null;
                    this.priceDisplay[itemId] = '';
                },
                error: () => {
                    this.toastService.error(`Failed to update ${item.itemName} price.`);
                }
            });
        }
    }

    setPeriod(period: string) {
        this.selectedPeriod = period;
        this.loadChart();
    }

    loadChart() {
        this.mmsService.getChartData(this.selectedPeriod).subscribe((data) => {
            this.updateChart(data);
        });
    }

    // Flag to control chart visibility and force re-render
    isChartLoaded: boolean = false;

    updateChart(data: any[]) {
        const categories = data.map((d) => d.label);
        const purchaseData = data.map((d) => Number(d.purchaseAmount) || 0);
        const sellData = data.map((d) => Number(d.sellAmount) || 0);

        this.chartOptions = {
            ...this.chartOptions,
            series: [
                {
                    name: 'Active (New Loans)',
                    data: purchaseData
                },
                {
                    name: 'Closed (Settlements)',
                    data: sellData
                }
            ],
            xaxis: {
                categories: categories
            },
            colors: ['#1de9b6', '#f44236']
        };

        // Force Re-render by toggling *ngIf
        this.isChartLoaded = false;
        this.cdr.detectChanges(); // Ensure DOM removal

        setTimeout(() => {
            this.isChartLoaded = true;
            this.cdr.detectChanges(); // Ensure DOM addition
        }, 100);
    }

    addDemoData() {
        this.mmsService.seedData(10).subscribe({
            next: () => {
                this.toastService.success('10 Demo Entries Added successfully!');
                this.loadData();
                this.loadChart();
                this.loadStats();
            },
            error: () => {
                this.toastService.error('Failed to add demo data.');
            }
        });
    }
}
