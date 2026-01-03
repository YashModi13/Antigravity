import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { MmsService, Merchant, DepositItem, MerchantItem } from '../mms.service';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ToastService } from 'src/app/theme/shared/components/toast/toast.service';

@Component({
    selector: 'app-mms-merchant',
    imports: [CommonModule, SharedModule, FormsModule],
    templateUrl: './merchant.component.html',
    styleUrls: ['./merchant.component.scss']
})
export class MmsMerchantComponent implements OnInit {
    merchants: Merchant[] = [];
    availableItems: DepositItem[] = [];
    filteredAvailableItems: DepositItem[] = [];

    activePledges: MerchantItem[] = [];
    filteredActivePledges: MerchantItem[] = [];

    depositFilterId: number | null = null;

    // Filters
    itemFilters = {
        customerName: '',
        itemName: '',
        weight: '',
        fineWeight: '',
        assetValue: '',
        status: ''
    };

    pledgeFilters = {
        merchantName: '',
        customerName: '',
        itemName: '',
        weight: '',
        interestRate: '',
        assetValue: '',
        totalOwed: ''
    };

    // Sorting
    availableSortColumn = 'customerName';
    availableSortDir: 'asc' | 'desc' = 'asc';

    pledgeSortColumn = 'profitLoss';
    pledgeSortDir: 'asc' | 'desc' = 'asc';

    uniqueItemNames: string[] = [];

    // Form
    selectedItems: { [key: number]: boolean } = {};
    targetMerchantId: number | null = null;
    interestRate: number = 0;
    principalAmount: number = 0;
    entryDate: string = new Date().toISOString().split('T')[0];
    notes: string = '';

    get merchantPortfolio() {
        const portfolioMap = new Map<number, any>();

        this.activePledges.forEach(p => {
            if (!portfolioMap.has(p.merchantId)) {
                portfolioMap.set(p.merchantId, {
                    merchantName: p.merchantName,
                    itemCount: 0,
                    totalWeight: 0,
                    totalFineWeight: 0,
                    totalPrincipal: 0,
                    totalOwed: 0,
                    totalAssetValue: 0,
                    totalNetMargin: 0
                });
            }
            const data = portfolioMap.get(p.merchantId);
            data.itemCount++;
            data.totalWeight += (p.weight || 0);
            data.totalFineWeight += (p.fineWeight || 0);
            data.totalPrincipal += (p.principalAmount || 0);
            data.totalOwed += (p.totalOwed || 0);
            data.totalAssetValue += (p.currentAssetValue || 0);
            data.totalNetMargin += (p.netMonthlyMargin || 0);
        });

        return Array.from(portfolioMap.values()).sort((a, b) => b.totalOwed - a.totalOwed);
    }

    get overallPortfolioSummary() {
        return this.merchantPortfolio.reduce((acc, curr) => {
            acc.totalItems += curr.itemCount;
            acc.totalPrincipal += curr.totalPrincipal;
            acc.totalOwed += curr.totalOwed;
            acc.totalAssetValue += curr.totalAssetValue;
            acc.totalNetMargin += curr.totalNetMargin;
            return acc;
        }, { totalItems: 0, totalPrincipal: 0, totalOwed: 0, totalAssetValue: 0, totalNetMargin: 0 });
    }

    get selectedAssetValueTotal(): number {
        return this.availableItems
            .filter(item => this.selectedItems[item.id])
            .reduce((sum, item) => sum + (item.currentAssetValue || 0), 0);
    }

    get hasSelectedItems(): boolean {
        return Object.values(this.selectedItems).some(isSelected => isSelected);
    }

    get canDeleteSelectedMerchant(): boolean {
        if (!this.targetMerchantId) return false;
        // Check if current merchant has any active pledges
        // We use loose comparison (==) because targetMerchantId might be string from select
        const hasActive = this.activePledges.some(p => p.merchantId == this.targetMerchantId);
        return !hasActive;
    }

    // Merchant Modal
    showMerchantModal = false;
    isEditingMerchant = false;
    merchantForm: any = {
        id: null,
        merchantName: '',
        merchantType: 'JEWELLER',
        mobileNumber: '',
        address: '',
        defaultInterestRate: 1.5,
        isActive: true
    };

    // Redemption Modal
    showRedeemModal = false;
    selectedPledgeForRedeem: any = null;
    redeemForm: any = {
        principalPaid: 0,
        interestPaid: 0,
        totalPaid: 0,
        notes: ''
    };

    // Transaction Modal
    showTransactionModal = false;
    selectedPledgeForTransaction: any = null;
    transactionForm: any = {
        amount: 0,
        notes: '',
        payFullInterest: false
    };

    // Edit Entry Modal
    showEditEntryModal = false;
    editEntryForm: any = {
        entryId: null,
        merchantId: null,
        entryDate: '',
        interestRate: 0,
        principalAmount: 0,
        notes: ''
    };

    // Details Modal
    showDetailsModal = false;
    selectedEntryDetails: any = null;
    ledger: any[] = [];
    ledgerSummary: any = {};

    constructor(
        private mmsService: MmsService,
        private route: ActivatedRoute,
        private router: Router,
        private toastService: ToastService
    ) { }

    ngOnInit() {
        this.route.queryParams.subscribe(params => {
            if (params['depositId']) {
                this.depositFilterId = +params['depositId'];
            }
            this.loadData();
        });
    }

    loadData() {
        this.mmsService.getAllMerchants().subscribe(data => this.merchants = data);
        this.mmsService.getAvailableItems().subscribe(data => {
            let items = data;
            if (this.depositFilterId) {
                items = items.filter((i: any) => i.depositEntryId === this.depositFilterId);
            }
            this.availableItems = items;
            this.uniqueItemNames = [...new Set(items.map((i: any) => i.itemName))];
            this.applyItemFilters();
        });
        this.mmsService.getActiveMerchantItems().subscribe(data => {
            this.activePledges = data;
            this.applyPledgeFilters();
        });
    }

    applyItemFilters() {
        let result = this.availableItems.filter(i => {
            const matchName = this.itemFilters.customerName ? i.customerName.toLowerCase().includes(this.itemFilters.customerName.toLowerCase()) : true;
            const matchItem = this.itemFilters.itemName ? i.itemName === this.itemFilters.itemName : true;
            const matchWeight = this.itemFilters.weight ? (i.weight || 0) >= parseFloat(this.itemFilters.weight) : true;
            const matchFine = this.itemFilters.fineWeight ? (i.fineWeight || 0) >= parseFloat(this.itemFilters.fineWeight) : true;
            const matchAsset = this.itemFilters.assetValue ? (i.currentAssetValue || 0) >= parseFloat(this.itemFilters.assetValue) : true;
            const matchStatus = this.itemFilters.status ? i.itemStatus.includes(this.itemFilters.status) : true;
            return matchName && matchItem && matchWeight && matchFine && matchAsset && matchStatus;
        });

        // Sort: Selection first, then chosen column
        result.sort((a, b) => {
            const isASelected = this.selectedItems[a.id] ? 1 : 0;
            const isBSelected = this.selectedItems[b.id] ? 1 : 0;

            if (isASelected !== isBSelected) {
                return isBSelected - isASelected;
            }

            const valA = (a as any)[this.availableSortColumn];
            const valB = (b as any)[this.availableSortColumn];
            let comp = 0;
            if (valA > valB) comp = 1; else if (valA < valB) comp = -1;
            return this.availableSortDir === 'asc' ? comp : -comp;
        });

        this.filteredAvailableItems = result;

        // Reset principal amount if no items are selected
        if (!this.hasSelectedItems) {
            this.principalAmount = 0;
        }
    }

    applyPledgeFilters() {
        let result = this.activePledges.filter(p => {
            const matchMerchant = this.pledgeFilters.merchantName ? p.merchantName.toLowerCase().includes(this.pledgeFilters.merchantName.toLowerCase()) : true;
            const matchCustomer = this.pledgeFilters.customerName ? p.customerName.toLowerCase().includes(this.pledgeFilters.customerName.toLowerCase()) : true;
            const matchItem = this.pledgeFilters.itemName ? p.itemName.toLowerCase().includes(this.pledgeFilters.itemName.toLowerCase()) : true;
            const matchWeight = this.pledgeFilters.weight ? (p.weight || 0) >= parseFloat(this.pledgeFilters.weight) : true;
            const matchRate = this.pledgeFilters.interestRate ? (p.interestRate || 0) >= parseFloat(this.pledgeFilters.interestRate) : true;
            const matchAsset = this.pledgeFilters.assetValue ? (p.currentAssetValue || 0) >= parseFloat(this.pledgeFilters.assetValue) : true;
            const matchOwed = this.pledgeFilters.totalOwed ? (p.totalOwed || 0) >= parseFloat(this.pledgeFilters.totalOwed) : true;
            return matchMerchant && matchCustomer && matchItem && matchWeight && matchRate && matchAsset && matchOwed;
        });

        // Sort
        result.sort((a, b) => {
            let valA: any = '';
            let valB: any = '';

            if (this.pledgeSortColumn === 'profitLoss') {
                valA = (a.currentAssetValue || 0) - (a.totalOwed || 0);
                valB = (b.currentAssetValue || 0) - (b.totalOwed || 0);
            } else {
                valA = (a as any)[this.pledgeSortColumn];
                valB = (b as any)[this.pledgeSortColumn];
            }

            let comp = 0;
            if (valA > valB) comp = 1; else if (valA < valB) comp = -1;
            return this.pledgeSortDir === 'asc' ? comp : -comp;
        });

        this.filteredActivePledges = result;
    }

    toggleAvailableSort(col: string) {
        if (this.availableSortColumn === col) {
            this.availableSortDir = this.availableSortDir === 'asc' ? 'desc' : 'asc';
        } else {
            this.availableSortColumn = col;
            this.availableSortDir = 'asc';
        }
        this.applyItemFilters();
    }

    togglePledgeSort(col: string) {
        if (this.pledgeSortColumn === col) {
            this.pledgeSortDir = this.pledgeSortDir === 'asc' ? 'desc' : 'asc';
        } else {
            this.pledgeSortColumn = col;
            this.pledgeSortDir = 'asc';
        }
        this.applyPledgeFilters();
    }

    onMerchantChange() {
        const merchant = this.merchants.find(m => m.id == this.targetMerchantId);
        if (merchant) {
            this.interestRate = merchant.defaultInterestRate ?? 1.5;
        } else {
            this.interestRate = 0;
        }
    }

    openMerchantModal(editM: any = null) {
        if (editM) {
            this.isEditingMerchant = true;
            this.merchantForm = { ...editM };
        } else {
            this.isEditingMerchant = false;
            this.merchantForm = {
                id: null,
                merchantName: '',
                merchantType: 'JEWELLER',
                mobileNumber: '',
                address: '',
                defaultInterestRate: 1.5,
                isActive: true
            };
        }
        this.showMerchantModal = true;
    }

    editSelectedMerchant() {
        if (!this.targetMerchantId) return;
        const m = this.merchants.find(m => m.id == this.targetMerchantId);
        if (m) this.openMerchantModal(m);
    }

    showDeleteConfirmModal = false;

    deleteSelectedMerchant() {
        if (!this.targetMerchantId) return;
        this.showDeleteConfirmModal = true;
    }

    confirmDeleteMerchant() {
        if (!this.targetMerchantId) return;

        this.mmsService.deleteMerchant(this.targetMerchantId).subscribe({
            next: () => {
                this.toastService.success('Merchant deleted successfully');
                this.targetMerchantId = null;
                this.interestRate = 0;
                this.showDeleteConfirmModal = false;
                this.loadData();
            },
            error: () => {
                this.toastService.error('Error deleting merchant');
                this.showDeleteConfirmModal = false;
            }
        });
    }

    saveMerchant() {
        if (this.isEditingMerchant) {
            this.mmsService.updateMerchant(this.merchantForm.id, this.merchantForm).subscribe({
                next: () => {
                    this.toastService.success('Merchant updated successfully');
                    this.showMerchantModal = false;
                    this.loadData();
                },
                error: () => this.toastService.error('Error updating merchant')
            });
        } else {
            this.mmsService.createMerchant(this.merchantForm).subscribe({
                next: (res) => {
                    this.toastService.success('Merchant added successfully');
                    this.showMerchantModal = false;
                    this.loadData();
                    this.targetMerchantId = res.id;
                    this.onMerchantChange();
                },
                error: (err) => {
                    console.error(err);
                    this.toastService.error('Error adding merchant. Check if mobile number is unique.');
                }
            });
        }
    }

    clearFilter() {
        this.depositFilterId = null;
        this.itemFilters = { customerName: '', itemName: '', weight: '', fineWeight: '', assetValue: '', status: '' };
        this.pledgeFilters = { merchantName: '', customerName: '', itemName: '', weight: '', interestRate: '', assetValue: '', totalOwed: '' };
        this.router.navigate([], { queryParams: { depositId: null }, queryParamsHandling: 'merge' });
        this.loadData();
    }

    submitTransfer() {
        if (!this.targetMerchantId) {
            this.toastService.error('Please select a merchant');
            return;
        }

        const itemIds = Object.keys(this.selectedItems)
            .filter(id => this.selectedItems[parseInt(id)])
            .map(id => parseInt(id));

        if (itemIds.length === 0) {
            this.toastService.error('Please select at least one item');
            return;
        }

        if (this.principalAmount > this.selectedAssetValueTotal) {
            this.toastService.error('Principal Amount cannot exceed Total Asset Value');
            return;
        }

        const totalAssetValue = this.selectedAssetValueTotal;

        let completed = 0;
        const totalItems = itemIds.length;

        for (const itemId of itemIds) {
            // Find the item to get its asset value
            const item = this.availableItems.find(i => i.id === itemId);
            let itemPrincipal = 0;

            // Proportional Distribution Logic
            if (item && totalAssetValue > 0) {
                const ratio = (item.currentAssetValue || 0) / totalAssetValue;
                itemPrincipal = this.principalAmount * ratio;
            } else if (totalItems > 0) {
                // Fallback: Even split if asset values are missing
                itemPrincipal = this.principalAmount / totalItems;
            }

            const payload = {
                depositItemId: itemId,
                merchantId: this.targetMerchantId,
                interestRate: this.interestRate,
                principalAmount: itemPrincipal,
                entryDate: this.entryDate,
                notes: this.notes
            };

            this.mmsService.transferToMerchant(payload).subscribe({
                next: () => {
                    completed++;
                    if (completed === itemIds.length) {
                        this.toastService.success('Transfer Successful!');
                        this.selectedItems = {};
                        this.loadData();
                    }
                },
                error: (err) => {
                    console.error(err);
                    this.toastService.error('Error transferring item ' + itemId);
                }
            });
        }
    }

    openRedeemModal(pledge: any) {
        this.selectedPledgeForRedeem = pledge;

        // Calculate exact required amounts with proper rounding (Same to Same fix)
        this.redeemForm = {
            principalPaid: parseFloat((pledge.principalAmount || 0).toFixed(2)),
            interestPaid: parseFloat((Math.max(0, (pledge.accruedInterest || 0) - (pledge.totalInterestPaid || 0))).toFixed(2)),
            totalPaid: 0,
            notes: 'Full Redemption of pledged item'
        };

        this.calculateRedeemTotal();
        this.showRedeemModal = true;
    }

    // Transaction Logic
    pendingInterestForTx = 0;

    openTransactionModal(pledge: any) {
        this.selectedPledgeForTransaction = pledge;
        // Calc pending interest
        this.pendingInterestForTx = Math.max(0, (pledge.accruedInterest || 0) - (pledge.totalInterestPaid || 0));

        this.transactionForm = {
            amount: 0,
            notes: '',
            payFullInterest: false
        };
        this.showTransactionModal = true;
    }

    toggleFullInterest() {
        if (this.transactionForm.payFullInterest) {
            this.transactionForm.amount = Number(this.pendingInterestForTx.toFixed(2));
        } else {
            // User unchecked, keep the amount or clear? 
            // Usually clearing or letting them edit is fine. 
            // If they unchecked, they likely want to type custom amount.
            // I'll leave it as is, but now it's editable.
        }
    }

    submitTransaction() {
        if (!this.selectedPledgeForTransaction) return;

        const pledge = this.selectedPledgeForTransaction;
        const amount = Number(this.transactionForm.amount) || 0;

        if (amount <= 0 && !this.transactionForm.notes) { // Allow 0 if just notes? No, payment usually requires amount.
            this.toastService.error('Please enter a valid amount');
            return;
        }

        if (amount > this.pendingInterestForTx) {
            this.toastService.error('Amount cannot exceed pending interest');
            return;
        }

        // Logic: ALWAYS Interest Only (as per user request)
        // Even if amount > pendingInterest, we record it as Interest Payment (excess).
        // Principal is ONLY reduced via "Get Back" / Redeem option.

        const interestPaid = amount;
        const principalPaid = 0;

        const data = {
            principalPaid: principalPaid,
            interestPaid: interestPaid,
            notes: this.transactionForm.notes
        };

        this.mmsService.addMerchantTransaction(this.selectedPledgeForTransaction.entryId, data).subscribe({
            next: () => {
                this.toastService.success('Interest Payment recorded successfully');
                this.showTransactionModal = false;
                this.loadData();
            },
            error: () => this.toastService.error('Error recording transaction')
        });
    }

    openDetailsModal(pledge: any) {
        this.selectedEntryDetails = null;
        this.showDetailsModal = true;
        this.mmsService.getMerchantEntryDetails(pledge.entryId).subscribe(data => {
            this.selectedEntryDetails = data;
            this.generateLedger(data);
        });
    }

    generateLedger(data: any) {
        this.ledger = [];
        const entryDate = new Date(data.summary.entryDate);
        const rate = data.summary.interestRate;
        const transactions = data.transactions || [];
        // Determine duration: either explicit or until today
        const today = new Date();
        const months = data.summary.monthsDuration || 1;

        // 1. Create Event Stream
        let events: any[] = [];

        // A. Opening
        events.push({
            date: entryDate,
            type: 'OPENING',
            desc: 'Opening Balance',
            pEffect: data.summary.principalAmount, // Use raw starting amount? The summary principal might be *current*.
            // Wait, summary principal is current principal. We need original or derive it.
            // Actually, we can assume 'principalAmount' + 'totalPrincipalPaid' = Original Principal?
            // Yes, let's derive Original Principal.
            // original = summary.principalAmount + totalPrincipalPaid
            pEffectRaw: (data.summary.principalAmount || 0) + (data.summary.totalPrincipalPaid || 0),
            iEffect: 0
        });

        // B. Transactions
        transactions.forEach((t: any) => {
            let pEff = 0;
            let iEff = 0;
            if (t.transactionType === 'PRINCIPAL_PAYMENT') pEff = -t.amount;
            if (t.transactionType === 'INTEREST_PAYMENT') iEff = -t.amount;

            events.push({
                date: new Date(t.transactionDate),
                type: t.transactionType.replace('_', ' '), // Show 'INTEREST PAYMENT' or 'PRINCIPAL PAYMENT'
                desc: t.description || 'Payment Received',
                pEffectRaw: pEff,
                iEffectRaw: iEff,
                txType: t.transactionType
            });
        });

        // C. Monthly Interest Accruals
        for (let i = 1; i <= months; i++) {
            // Logic Change: Show date as Start of Month (Entry Date + (i-1) months)
            const accrualDate = new Date(entryDate);
            accrualDate.setMonth(accrualDate.getMonth() + i - 1);

            // We include it even if it's today (it's the start date of the current cycle)

            events.push({
                date: accrualDate,
                type: 'INTEREST',
                desc: `Interest (Month ${i})`,
                pEffectRaw: 0,
                iEffectRaw: 0, // Will calc during replay
                isAccrual: true
            });
        }

        // 2. Sort Events
        events.sort((a, b) => {
            const dateDiff = a.date.getTime() - b.date.getTime();
            if (dateDiff !== 0) return dateDiff;

            // If same date, enforce logical order:
            // 1. OPENING (Set baseline)
            // 2. INTEREST (Charge for the period starting now)
            // 3. PAYMENT (Pay off what exists)
            const getPriority = (type: string) => {
                if (type === 'OPENING') return 0;
                if (type === 'INTEREST') return 1;
                return 2;
            };
            return getPriority(a.type) - getPriority(b.type);
        });

        // 3. Replay
        let runningPrincipal = 0;
        let runningInterest = 0;
        let totalPaid = 0;

        this.ledger = events.map(e => {
            // Apply Effects
            if (e.type === 'OPENING') {
                runningPrincipal = e.pEffectRaw;
            } else if (e.type === 'INTEREST') {
                // Calc on current principal
                // Logic: Principal * Rate / 100
                const interest = (runningPrincipal * rate) / 100;
                e.iEffectRaw = interest;
                runningInterest += interest;
            } else if (e.type.includes('PAYMENT')) {
                runningPrincipal += e.pEffectRaw;
                runningInterest += e.iEffectRaw; // e.iEffectRaw is negative for payment
                totalPaid += Math.abs(e.pEffectRaw + e.iEffectRaw);
            }

            return {
                date: e.date,
                type: e.type,
                desc: e.desc,
                principalChange: e.pEffectRaw,
                interestChange: e.iEffectRaw,
                balPrincipal: runningPrincipal,
                balInterest: runningInterest,
                totalOwed: runningPrincipal + runningInterest
            };
        });

        // 4. Summary
        this.ledgerSummary = {
            balPrincipal: runningPrincipal,
            balInterest: runningInterest,
            totalPaid: totalPaid,
            totalOwed: runningPrincipal + runningInterest
        };

        // Keep in chronological order (Oldest First)
        // this.ledger.reverse();
    }

    calculateRedeemTotal() {
        this.redeemForm.totalPaid = (Number(this.redeemForm.principalPaid) || 0) + (Number(this.redeemForm.interestPaid) || 0);
    }

    confirmRedeem() {
        if (!this.selectedPledgeForRedeem) return;

        const entryId = this.selectedPledgeForRedeem.entryId;
        this.mmsService.returnFromMerchant(entryId, this.redeemForm).subscribe({
            next: () => {
                this.toastService.success('Item received back from merchant and account settled');
                this.showRedeemModal = false;
                this.loadData();
            },
            error: (err) => {
                console.error(err);
                this.toastService.error('Error redeeming item. Please try again.');
            }
        });
    }

    redeemItem(entryId: number) {
        const pledge = this.activePledges.find(p => p.entryId === entryId);
        if (pledge) {
            this.openRedeemModal(pledge);
        }
    }

    // Edit Entry Logic
    openEditEntryModal(pledge: any) {
        let dateVal = pledge.entryDate;
        // Handle Java LocalDate Array [yyyy, MM, dd] if it comes as array
        if (Array.isArray(dateVal)) {
            const y = dateVal[0];
            const m = dateVal[1].toString().padStart(2, '0');
            const d = dateVal[2].toString().padStart(2, '0');
            dateVal = `${y}-${m}-${d}`;
        }

        this.editEntryForm = {
            entryId: pledge.entryId,
            merchantId: pledge.merchantId,
            entryDate: dateVal,
            interestRate: pledge.interestRate,
            principalAmount: pledge.principalAmount,
            notes: pledge.notes || ''
        };
        this.showEditEntryModal = true;
    }

    saveEntryEdit() {
        const payload = {
            merchantId: this.editEntryForm.merchantId,
            entryDate: this.editEntryForm.entryDate,
            interestRate: this.editEntryForm.interestRate,
            principalAmount: this.editEntryForm.principalAmount,
            notes: this.editEntryForm.notes
        };

        this.mmsService.updateMerchantEntry(this.editEntryForm.entryId, payload).subscribe({
            next: () => {
                this.toastService.success('Entry updated successfully');
                this.showEditEntryModal = false;
                this.loadData();
            },
            error: (err) => {
                console.error(err);
                this.toastService.error(err.error || 'Error updating entry');
            }
        });
    }
}
