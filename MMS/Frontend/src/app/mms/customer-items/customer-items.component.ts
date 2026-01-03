import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { MmsService } from '../mms.service';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { ToastService } from 'src/app/theme/shared/components/toast/toast.service';
import { DepositDetailViewComponent } from '../common/deposit-detail-view/deposit-detail-view.component';

@Component({
    selector: 'app-customer-items',
    standalone: true,
    imports: [CommonModule, SharedModule, FormsModule, RouterModule, DepositDetailViewComponent],
    templateUrl: './customer-items.component.html',
    styles: [`
    .deposit-card {
        border-left: 4px solid #ccc;
        transition: transform 0.2s;
    }
    .deposit-card.ACTIVE {
        border-left-color: #28a745; 
        background-color: #f9fff9;
    }
    .deposit-card.RETURNED {
        border-left-color: #6c757d; 
    }
    .deposit-card.RISK {
        border-left-color: #dc3545; 
        background-color: #fff5f5;
    }
    .deposit-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    }
  `]
})
export class CustomerItemsComponent implements OnInit {
    searchTerm = '';
    searchResults: any[] = [];
    showResults = false;

    portfolio: any = null; // CustomerPortfolioDTO
    isLoading = false;
    activeTab: 'ACTIVE' | 'HISTORY' = 'ACTIVE';

    // Stats
    totalLoan = 0;
    totalAssetValue = 0;

    protected readonly Math = Math;

    constructor(
        private mmsService: MmsService,
        private router: Router,
        private toastService: ToastService
    ) { }

    ngOnInit() { }

    searchCustomers() {
        if (!this.searchTerm) {
            this.showResults = false;
            return;
        }
        this.mmsService.searchCustomers(this.searchTerm).subscribe(results => {
            this.searchResults = results;
            this.showResults = true;
        });
    }

    selectCustomer(customer: any) {
        this.searchTerm = customer.customerName;
        this.showResults = false;
        this.loadPortfolio(customer.id);
    }

    loadPortfolio(customerId: number) {
        this.isLoading = true;
        this.portfolio = null;
        this.mmsService.getCustomerPortfolio(customerId).subscribe({
            next: (data) => {
                this.portfolio = data;
                this.calculateTotals();
                this.isLoading = false;
            },
            error: (err) => {
                console.error(err);
                this.isLoading = false;
            }
        });
    }

    calculateTotals() {
        this.totalLoan = 0;
        this.totalAssetValue = 0;
        if (this.portfolio && this.portfolio.deposits) {
            this.portfolio.deposits.forEach((d: any) => {
                if (d.status === 'ACTIVE') {
                    this.totalLoan += d.loanAmount || 0;
                    if (d.items) {
                        d.items.forEach((i: any) => this.totalAssetValue += i.currentAssetValue || 0);
                    }
                }
            });
        }
    }
}
