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

    customersList: any[] = [];
    filteredCustomers: any[] = []; // List for the table display

    // Pagination & Sorting
    page = 0;
    size = 10; // Default, can be overwritten by config if needed
    totalPages = 0;
    totalElements = 0;
    sortBy = 'id';
    sortDir = 'asc';

    // Filters
    villages: string[] = [];
    districts: string[] = [];
    selectedVillage: string = '';
    selectedDistrict: string = '';

    ngOnInit() {
        this.loadCustomers();
    }

    loadCustomers() {
        this.isLoading = true;
        this.mmsService.getCustomers(this.page, this.size, this.sortBy, this.sortDir).subscribe({
            next: (data) => {
                this.customersList = data.content;
                this.filteredCustomers = data.content;
                this.totalPages = data.totalPages;
                this.totalElements = data.totalElements;

                // For now, extract filters from the current page (limitation of basic pagination)
                // In a full implementation, we'd need a separate endpoint for distinct values.
                this.extractFilters();
                this.isLoading = false;
            },
            error: (err) => {
                console.error('Failed to load customers', err);
                this.isLoading = false;
            }
        });
    }

    onPageChange(page: number) {
        this.page = page;
        this.loadCustomers();
    }

    onSort(column: string) {
        if (this.sortBy === column) {
            this.sortDir = this.sortDir === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortBy = column;
            this.sortDir = 'asc';
        }
        this.loadCustomers();
    }

    // Edit Customer State
    showEditModal = false;
    editingCustomer: any = {
        id: null,
        customerName: '',
        mobileNumber: '',
        email: '',
        address: '',
        village: '',
        district: '',
        state: '',
        pincode: '',
        referralCustomer: null,
        referralName: '',
        kycVerified: false
    };
    editReferralSearchTerm = '';
    editReferralSearchResults: any[] = [];
    showEditReferralResults = false;

    editCustomer(customer: any) {
        // Clone the customer data to avoid mutating the table directly before save
        this.editingCustomer = { ...customer };
        // Ensure nested object is handled safely
        this.editingCustomer.referralCustomer = customer.referralCustomer ? { ...customer.referralCustomer } : null;
        this.editReferralSearchTerm = customer.referralName || '';
        this.showEditModal = true;
    }

    closeEditModal() {
        this.showEditModal = false;
        this.editReferralSearchResults = [];
    }

    // Referral Search for Edit Modal
    searchEditReferrals() {
        if (this.editReferralSearchTerm.length < 2) {
            this.showEditReferralResults = false;
            if (this.editReferralSearchTerm.length === 0) {
                this.editingCustomer.referralCustomer = null;
            }
            return;
        }

        this.mmsService.searchCustomers(this.editReferralSearchTerm).subscribe(results => {
            // Filter out self if present
            this.editReferralSearchResults = results.filter(c => c.id !== this.editingCustomer.id);
            this.showEditReferralResults = true;
        });
    }

    selectEditReferral(customer: any) {
        this.editingCustomer.referralCustomer = { id: customer.id }; // Minimal object for backend
        this.editReferralSearchTerm = customer.customerName;
        this.showEditReferralResults = false;
    }

    saveEditedCustomer() {
        if (!this.editingCustomer.customerName || !this.editingCustomer.mobileNumber) {
            this.toastService.error('Name and Mobile Number are required');
            return;
        }

        // Prepare payload (ensure referral is set correctly)
        const payload = { ...this.editingCustomer };
        // If referral term matches current referral name, good. If cleared, set null.
        if (!this.editReferralSearchTerm) {
            payload.referralCustomer = null;
        }

        this.isLoading = true;
        this.mmsService.updateCustomer(this.editingCustomer.id, payload).subscribe({
            next: (updated) => {
                this.toastService.success('Customer updated successfully');
                this.showEditModal = false;
                this.isLoading = false;
                this.loadCustomers(); // Refresh list to show updates
            },
            error: (err) => {
                this.toastService.error('Failed to update customer');
                console.error(err);
                this.isLoading = false;
            }
        });
    }

    extractFilters() {
        const vSet = new Set<string>();
        const dSet = new Set<string>();
        this.customersList.forEach(c => {
            if (c.village) vSet.add(c.village);
            if (c.district) dSet.add(c.district);
        });
        this.villages = Array.from(vSet).sort();
        this.districts = Array.from(dSet).sort();
    }

    applyFilters() {
        // With server-side pagination, client-side filtering is limited to the current page.
        // Ideally, we pass filters to the backend.
        // For this step, I'll filter the current page view.
        this.filteredCustomers = this.customersList.filter(c => {
            const matchesSearch = !this.searchTerm ||
                c.customerName.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
                c.mobileNumber.includes(this.searchTerm) ||
                (c.village && c.village.toLowerCase().includes(this.searchTerm.toLowerCase()));

            const matchesVillage = !this.selectedVillage || c.village === this.selectedVillage;
            const matchesDistrict = !this.selectedDistrict || c.district === this.selectedDistrict;

            return matchesSearch && matchesVillage && matchesDistrict;
        });
    }

    searchCustomers() {
        // 1. Trigger local filtering (on current page)
        this.applyFilters();

        // 2. Search Dropdown logic (Backend Search)
        if (!this.searchTerm) {
            this.showResults = false;
            return;
        }
        this.mmsService.searchCustomers(this.searchTerm).subscribe(results => {
            this.searchResults = results;
            this.showResults = true;
        });
    }

    clearFilters() {
        this.searchTerm = '';
        this.selectedVillage = '';
        this.selectedDistrict = '';
        this.loadCustomers(); // Reload original page data
        this.showResults = false;
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
