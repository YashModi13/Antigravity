import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { MmsService, ItemMaster } from '../mms.service';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ToastService } from 'src/app/theme/shared/components/toast/toast.service';
import { Subscription } from 'rxjs';
import { CONFIG_KEYS, APP_CONSTANTS } from '../shared/constant';


@Component({
    selector: 'app-mms-entry',
    standalone: true,
    imports: [CommonModule, SharedModule, FormsModule],
    templateUrl: './entry.component.html',
    styleUrls: ['./entry.component.scss']
})
export class MmsEntryComponent implements OnInit, OnDestroy {
    private pricesSubscription: Subscription | undefined;
    latestPrices: any[] = [];
    // New Customer Form
    customer = {
        name: '',
        mobile: ''
    };

    // Customer Search State
    searchTerm = '';
    searchResults: any[] = [];
    showResults = false;
    selectedCustomerName = '';
    selectedCustomer: any = null;

    // Create New Customer State
    showNewCustomerModal = false;
    newCustomer = {
        customerName: '',
        mobileNumber: '',
        email: '',
        address: '',
        village: '',
        district: '',
        state: APP_CONSTANTS.DEFAULT_STATE, // Use Constant
        pincode: '',
        referralName: '',
        referralCustomer: null as any, // To store relation
        kycVerified: false
    };

    // Referral Search State
    referralSearchTerm = '';
    referralSearchResults: any[] = [];
    showReferralResults = false;


    isEditMode = false;
    editId: number | null = null;
    isLoading = false;

    // System Config Defaults
    defaultUnitId = 1;
    defaultInterestRate = 3.0;
    defaultFinePercentage = 75.0;
    currencySymbol = '₹';
    defaultState = APP_CONSTANTS.DEFAULT_STATE;
    defaultGivingPercentage = 60.0;

    // Deposit Form

    items: ItemMaster[] = [];
    units: any[] = [];
    loanAmountDisplay = '';

    onLoanAmountInput(event: any) {
        let valueStr = event.target.value.replace(/,/g, '');
        const value = Number(valueStr);
        if (!isNaN(value) && valueStr !== '' && value > 0) {
            this.deposit.initialLoanAmount = value;
            this.loanAmountDisplay = value.toLocaleString('en-IN');
        } else {
            this.deposit.initialLoanAmount = null;
            this.loanAmountDisplay = '';
        }
        // Force sync the display value back to the input element
        event.target.value = this.loanAmountDisplay;
    }

    onInterestRateChange() {
        if (this.deposit.interestRate != null && this.deposit.interestRate <= 0) {
            this.deposit.interestRate = 3.0; // Reset to default if zero or negative
        }
    }

    onGivingPercentageChange() {
        if (this.deposit.givingPercentage != null && this.deposit.givingPercentage < 1) {
            this.deposit.givingPercentage = 1; // Minimum 1%
        }
        if (this.deposit.givingPercentage > 100) {
            this.deposit.givingPercentage = 100;
        }
    }

    deposit = {
        customerId: null as number | null,
        depositDate: new Date().toISOString().split('T')[0],
        interestRate: 3.0,
        givingPercentage: 60,
        notes: '',
        initialLoanAmount: null as number | null,
        itemLines: [] as any[]
    };

    constructor(
        private mmsService: MmsService,
        private route: ActivatedRoute,
        private router: Router,
        private toastService: ToastService
    ) { }

    ngOnInit() {
        this.mmsService.getAllItems().subscribe({
            next: data => this.items = data,
            error: err => this.toastService.error('Failed to load items')
        });

        this.mmsService.getAllUnits().subscribe({
            next: data => this.units = data,
            error: err => this.toastService.error('Failed to load units')
        });

        this.mmsService.getAllConfigs().subscribe({
            next: configs => {
                const getReq = (key: string) => {
                    const c = configs.find(x => x.propertyKey === key);
                    if (!c) throw new Error("Missing required config: " + key);
                    return c.propertyValue;
                };

                try {
                    this.defaultUnitId = Number(getReq(CONFIG_KEYS.DEFAULT_UNIT_ID));

                    this.defaultInterestRate = Number(getReq(CONFIG_KEYS.DEFAULT_INTEREST_RATE));
                    if (!this.isEditMode) this.deposit.interestRate = this.defaultInterestRate;

                    this.defaultFinePercentage = Number(getReq(CONFIG_KEYS.DEFAULT_FINE_PERCENTAGE));
                    this.currencySymbol = getReq(CONFIG_KEYS.SYSTEM_CURRENCY_SYMBOL);
                    this.defaultState = getReq(CONFIG_KEYS.DEFAULT_STATE);
                    this.defaultGivingPercentage = Number(getReq(CONFIG_KEYS.DEFAULT_GIVING_PERCENTAGE));
                    if (!this.isEditMode) this.deposit.givingPercentage = this.defaultGivingPercentage;
                    if (!this.showNewCustomerModal) {
                        this.newCustomer.state = this.defaultState;
                    }
                } catch (e) {
                    this.toastService.error(e.message);
                    console.error(e);
                }
            }
        });

        this.pricesSubscription = this.mmsService.prices$.subscribe(prices => {
            this.latestPrices = prices;
        });

        this.route.queryParams.subscribe(params => {
            if (params['id']) {
                this.isEditMode = true;
                this.editId = +params['id'];
                this.loadDeposit(this.editId);
            } else {
                this.isEditMode = false;
                this.editId = null;
                this.deposit.itemLines = [];
                this.addItemLine();
            }
        });

        this.mmsService.refreshLatestPrices();
    }



    ngOnDestroy() {
        if (this.pricesSubscription) {
            this.pricesSubscription.unsubscribe();
        }
    }

    updateAssetValue(line: any) {
        if (line.weight != null && line.fineWeight != null) {
            if (line.fineWeight > line.weight) {
                line.error = 'Fine Weight cannot exceed Weight';
                line.assetValue = null;
                return;
            } else {
                line.error = null;
            }
        }

        if (!line.itemId || !line.fineWeight) {
            line.assetValue = null;
            return;
        }

        // Get the conversion factor for the item's own defined unit
        const item = this.items.find(i => i.id == line.itemId);
        const unitFactor = (item && item.unit) ? item.unit.unitInGram : 1;
        const fineWeightInGrams = line.fineWeight * unitFactor;

        this.mmsService.calculateAssetValue(line.itemId, fineWeightInGrams).subscribe({
            next: (value) => {
                line.assetValue = value;
            },
            error: (err) => {
                console.error('Error calculating asset value', err);
                line.assetValue = null;
            }
        });
    }

    onItemChange(line: any) {
        this.updateAssetValue(line);
    }

    onUnitChange(line: any) {
        // Unit selection is now tied to the item
        this.updateAssetValue(line);
    }

    onFinePercentageChange(line: any) {
        if (line.finePercentage > 100) line.finePercentage = 100;
        if (line.finePercentage < 0) line.finePercentage = 0;

        if (line.weight != null && line.finePercentage != null) {
            line.fineWeight = Number(((line.weight * line.finePercentage) / 100).toFixed(3));
            this.updateAssetValue(line);
        } else {
            line.fineWeight = null;
            line.assetValue = null;
        }
    }

    onFineWeightChange(line: any) {
        if (line.fineWeight != null && line.fineWeight < 0) line.fineWeight = 0;

        if (line.weight != null && line.fineWeight != null && line.weight > 0) {
            line.finePercentage = Number(((line.fineWeight / line.weight) * 100).toFixed(3));
            if (line.finePercentage > 100) {
                line.finePercentage = 100;
                line.fineWeight = line.weight;
            }
            this.updateAssetValue(line);
        } else if (line.fineWeight == null) {
            line.assetValue = null;
        }
    }

    onWeightChange(line: any) {
        if (line.weight != null && line.weight < 0) line.weight = 0;

        // When total weight changes, we usually keep the purity (percentage) same and update fine weight
        if (line.weight != null && line.finePercentage != null) {
            line.fineWeight = Number(((line.weight * line.finePercentage) / 100).toFixed(3));
            this.updateAssetValue(line);
        } else {
            line.fineWeight = null;
            line.assetValue = null;
        }
    }

    formatDecimal(line: any, field: string) {
        if (line[field] != null && line[field] !== '') {
            // Force 0.XXX leading zero and 3 decimal places
            line[field] = Number(line[field]).toFixed(3);
        }
    }

    loadDeposit(id: number) {
        this.isLoading = true;
        this.mmsService.getDeposit(id).subscribe({
            next: data => {
                this.isLoading = false;
                if (!data) {
                    this.toastService.error('Deposit not found');
                    return;
                }
                this.deposit.customerId = data.customerId;
                this.deposit.depositDate = data.depositDate;
                this.deposit.interestRate = data.interestRate;
                this.deposit.notes = data.notes;
                this.deposit.initialLoanAmount = data.initialLoanAmount || null;
                this.loanAmountDisplay = this.deposit.initialLoanAmount ? this.deposit.initialLoanAmount.toLocaleString('en-IN') : '';

                // Set Customer Name for Display
                if (data.customerName) {
                    this.selectedCustomerName = data.customerName;
                    this.searchTerm = data.customerName;
                }

                this.deposit.itemLines = data.items.map((i: any) => ({
                    itemId: i.itemId,
                    weight: i.weight,
                    unitId: this.defaultUnitId,
                    fineWeight: i.fineWeight,
                    finePercentage: i.weight > 0 ? Number(((i.fineWeight / i.weight) * 100).toFixed(3)) : 0,
                    description: i.description,
                    assetValue: null
                }));

                // Calculate asset values for all loaded items
                this.deposit.itemLines.forEach(line => this.updateAssetValue(line));
            },
            error: err => {
                this.isLoading = false;
                this.toastService.error('Failed to load deposit details');
                console.error('Error loading deposit:', err);
            }
        });
    }

    searchCustomers() {
        if (this.searchTerm.length < 2) {
            this.showResults = false;
            return;
        }

        this.mmsService.searchCustomers(this.searchTerm).subscribe(results => {
            this.searchResults = results;
            this.showResults = true;
        });
    }

    selectCustomer(customer: any) {
        this.deposit.customerId = customer.id;
        this.selectedCustomerName = customer.customerName;
        this.selectedCustomer = customer;
        this.searchTerm = customer.customerName;
        this.showResults = false;
    }

    openNewCustomerModal() {
        this.showResults = false;
        this.newCustomer = {
            customerName: this.searchTerm,
            mobileNumber: '',
            email: '',
            address: '',
            village: '',
            district: '',
            state: this.defaultState,
            pincode: '',
            referralName: '',
            referralCustomer: null,
            kycVerified: false
        };
        this.referralSearchTerm = '';
        this.showNewCustomerModal = true;
    }

    searchReferrals() {
        if (this.referralSearchTerm.length < 2) {
            this.showReferralResults = false;
            // If they clear it, clear the linkage
            if (this.referralSearchTerm.length === 0) {
                this.newCustomer.referralCustomer = null;
                this.newCustomer.referralName = '';
            }
            return;
        }

        this.mmsService.searchCustomers(this.referralSearchTerm).subscribe(results => {
            this.referralSearchResults = results;
            this.showReferralResults = true;
        });
    }

    selectReferral(customer: any) {
        this.newCustomer.referralCustomer = { id: customer.id };
        this.newCustomer.referralName = customer.customerName; // Optional: keep name too
        this.referralSearchTerm = customer.customerName;
        this.showReferralResults = false;
    }

    saveNewCustomer() {
        if (!this.newCustomer.customerName) {
            this.toastService.error('Customer Name is required');
            return;
        }

        this.mmsService.createCustomer(this.newCustomer).subscribe({
            next: (customer: any) => {
                this.toastService.success('Customer created successfully');
                this.selectCustomer(customer);
                this.showNewCustomerModal = false;
            },
            error: (err) => {
                this.toastService.error('Error creating customer');
                console.error(err);
            }
        });
    }

    addItemLine() {

        this.deposit.itemLines.push({
            itemId: null,
            weight: null,
            unitId: this.defaultUnitId,
            fineWeight: null,
            finePercentage: this.defaultFinePercentage,
            assetValue: null,
            description: ''
        });
    }

    // Unified helper for calculations and display
    getUnitName(itemId: any): string {
        if (!itemId) {
            const defUnit = this.units.find(u => u.id == this.defaultUnitId);
            return defUnit ? defUnit.unitName : '';
        }
        const item = this.items.find(i => i.id == itemId);
        return (item && item.unit) ? item.unit.unitName : '';
    }

    // Totals Calculation (Grouped by Item Type)
    get itemSummaryGrouped() {
        const summary: { [key: string]: { name: string, weight: number, fineWeight: number, unit: string } } = {};

        this.deposit.itemLines.forEach(line => {
            if (!line.itemId) return;
            const item = this.items.find(i => i.id == line.itemId);
            if (!item) return;

            const name = item.itemName;
            const unit = (item.unit) ? item.unit.unitName : '';

            if (!summary[name]) {
                summary[name] = { name, weight: 0, fineWeight: 0, unit };
            }
            summary[name].weight += (Number(line.weight) || 0);
            summary[name].fineWeight += (Number(line.fineWeight) || 0);
        });

        return Object.values(summary);
    }

    get totalAssetValue(): number {
        return this.deposit.itemLines.reduce((acc, line) => acc + (Number(line.assetValue) || 0), 0);
    }

    get eligibleLoanAmount(): number {
        return Math.floor((this.totalAssetValue * (this.deposit.givingPercentage || 0)) / 100);
    }

    get isLoanAmountInvalid(): boolean {
        const amount = Number(this.deposit.initialLoanAmount);
        if (this.deposit.initialLoanAmount === null) return false;
        if (amount <= 0) return true;
        if (amount > this.eligibleLoanAmount) return true;
        return false;
    }

    get loanAmountErrorMsg(): string {
        const amount = Number(this.deposit.initialLoanAmount);
        if (this.deposit.initialLoanAmount === null) return '';
        if (amount <= 0) return 'Loan amount must be greater than 0';
        if (amount > this.eligibleLoanAmount) return `Amount exceeds safe limit (${this.currencySymbol} ${this.eligibleLoanAmount.toLocaleString('en-IN')})`;
        return '';
    }

    submitDeposit() {
        // 1. Validate Customer
        if (!this.deposit.customerId) {
            this.toastService.error('Please select a Customer');
            return;
        }

        // 2. Validate Interest Rate
        if (this.deposit.interestRate == null || this.deposit.interestRate <= 0) {
            this.toastService.error('Please enter a valid Interest Rate');
            return;
        }

        // 3. Validate Items Existence
        if (this.deposit.itemLines.length === 0) {
            this.toastService.error('Please add at least one item');
            return;
        }

        // 4. Validate Each Item Line
        for (const line of this.deposit.itemLines) {
            if (!line.itemId) {
                this.toastService.error('Please select an Item type for all rows');
                return;
            }
            if (!line.weight || line.weight <= 0) {
                this.toastService.error('Weight must be greater than 0 for all items');
                return;
            }
            if (!line.description || line.description.trim() === '') {
                this.toastService.error('Please enter a Description for all items');
                return;
            }
            if (line.fineWeight > line.weight) {
                this.toastService.error(`Fine Weight cannot be greater than Weight for item`);
                return;
            }
        }

        // 5. Validate Loan Amount Rules
        if (this.isLoanAmountInvalid || this.deposit.initialLoanAmount == null) {
            this.toastService.error(this.loanAmountErrorMsg || 'Please enter a valid Loan Amount');
            return;
        }

        if (this.isEditMode) {
            const payload = {
                depositDate: this.deposit.depositDate,
                interestRate: this.deposit.interestRate,
                notes: this.deposit.notes,
                initialLoanAmount: this.deposit.initialLoanAmount,
                items: this.deposit.itemLines.map(line => {
                    const item = this.items.find(i => i.id == line.itemId);
                    const factor = (item && item.unit) ? item.unit.unitInGram : 1;
                    return {
                        itemId: line.itemId,
                        weight: line.weight * factor,
                        unitId: (item && item.unit) ? item.unit.id : this.defaultUnitId,
                        fineWeight: line.fineWeight * factor,
                        description: line.description
                    };
                })
            };

            this.mmsService.updateDeposit(this.editId!, payload).subscribe({
                next: () => {
                    this.toastService.success('Deposit Updated Successfully!');
                    this.router.navigate(['/mms/deposits']);
                },
                error: err => {
                    this.toastService.error('Error updating deposit');
                    console.error('Update Error:', err);
                }
            });
        } else {
            const payload = {
                customerId: this.deposit.customerId,
                depositDate: this.deposit.depositDate,
                interestRate: this.deposit.interestRate,
                notes: this.deposit.notes,
                initialLoanAmount: this.deposit.initialLoanAmount,
                items: this.deposit.itemLines.map(line => {
                    const item = this.items.find(i => i.id == line.itemId);
                    const factor = (item && item.unit) ? item.unit.unitInGram : 1;
                    return {
                        itemId: line.itemId,
                        weight: line.weight * factor,
                        unitId: (item && item.unit) ? item.unit.id : this.defaultUnitId,
                        fineWeight: line.fineWeight * factor,
                        description: line.description
                    };
                })
            };

            this.mmsService.createDeposit(payload).subscribe({
                next: () => {
                    this.toastService.success('Deposit Created Successfully!');
                    this.deposit.itemLines = [];
                    this.addItemLine();
                },
                error: (err) => {
                    this.toastService.error('Error creating deposit');
                    console.error('Create Error:', err);
                }
            });
        }
    }

}
