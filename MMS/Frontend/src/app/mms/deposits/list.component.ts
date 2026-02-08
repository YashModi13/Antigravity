import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { MmsService, DepositSummary } from '../mms.service';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ToastService } from 'src/app/theme/shared/components/toast/toast.service';
import { forkJoin, of } from 'rxjs';
import { catchError, switchMap, map } from 'rxjs/operators';


@Component({
    selector: 'app-mms-deposits-list',
    imports: [CommonModule, SharedModule, FormsModule],
    templateUrl: './list.component.html',
    styleUrls: ['./list.component.scss']
})
export class MmsDepositsListComponent implements OnInit {
    deposits: DepositSummary[] = [];
    filteredDeposits: DepositSummary[] = [];
    selectedDeposit: any = null; // For modal details
    ledger: any[] = []; // For passbook view
    ledgerSummary: any = { principal: 0, interest: 0, total: 0 };

    // Payment Modal
    showPaymentModal = false;
    selectedDepositForPayment: any = null;
    paymentForm = {
        principalPaid: 0,
        interestPaid: 0,
        notes: '',
        addPrincipal: false,
        extraPrincipal: 0,
        transactionDate: new Date().toISOString().split('T')[0]
    };
    payFullInterest = false;

    protected readonly Math = Math;

    // Pagination & Sorting
    pageSize = 10;
    currentPage = 1;
    pageSizeOptions = [10, 50, 100, 200, 500];

    sortColumn = 'monthsWait';
    sortDirection: 'asc' | 'desc' = 'asc';

    // Filter Model
    filters = {
        id: '',
        tokenNo: '',
        customerName: '',
        depositDate: '',
        months: '',
        loanAmount: '',
        interest: '',
        unpaidInterest: '',
        assetValue: '',
        pl: '',
        status: '',
        isVerified: ''
    };

    // Settlement & Redemption State
    showSettlementModal = false;
    showRedeemModal = false;
    settlementData: any = null;
    selectedPledgeForRedeem: any = null;
    settlementAmount: number = 0;
    isFullPayment = true;
    redeemForm: any = {
        principalPaid: 0,
        interestPaid: 0,
        totalPaid: 0,
        notes: ''
    };

    get hasActivePledges(): boolean {
        return this.settlementData?.activeMerchantEntries?.some((e: any) => e.status === 'ACTIVE') || false;
    }

    constructor(
        private readonly mmsService: MmsService,
        private readonly router: Router,
        private readonly toastService: ToastService
    ) { }

    ngOnInit() {
        this.loadData();
    }

    loadData() {
        this.mmsService.getActiveDepositSummaryPaginated(
            this.currentPage - 1,
            this.pageSize,
            this.sortColumn,
            this.sortDirection,
            this.filters
        ).subscribe(response => {
            this.filteredDeposits = response.content;
            this.totalItems = response.totalElements;
        });
    }

    applyFilter() {
        // For server-side pagination, 'filtering' usually requires passing params to backend.
        // For this step, we just reload data (which respects sort/page).
        this.loadData();
    }

    totalItems = 0;
    get totalPages(): number {
        return Math.ceil(this.totalItems / this.pageSize);
    }

    get pages(): number[] {
        const pages = [];
        for (let i = 1; i <= this.totalPages; i++) pages.push(i);
        return pages;
    }

    toggleSort(column: string) {
        if (this.sortColumn === column) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortColumn = column;
            this.sortDirection = 'asc';
        }
        this.currentPage = 1;
        this.loadData();
    }

    changePage(page: number) {
        if (page >= 1 && page <= this.totalPages) {
            this.currentPage = page;
            this.loadData();
        }
    }

    onPageSizeChange() {
        this.currentPage = 1;
        this.loadData();
    }

    resetFilter() {
        this.filters = {
            id: '',
            tokenNo: '',
            customerName: '',
            depositDate: '',
            months: '',
            loanAmount: '',
            interest: '',
            unpaidInterest: '',
            assetValue: '',
            pl: '',
            status: '',
            isVerified: ''
        };
        this.sortColumn = 'depositId';
        this.sortDirection = 'asc';
        this.currentPage = 1;
        this.applyFilter();
    }


    viewDetails(deposit: DepositSummary) {
        this.mmsService.getDeposit(deposit.depositId).subscribe({
            next: (data) => {
                // Prepare data for shared component
                this.generateLedger(data);

                const start = new Date(data.depositDate);
                const end = data.status === 'CLOSED' && data.updatedDate ? new Date(data.updatedDate) : new Date();
                const diffTime = Math.abs(end.getTime() - start.getTime());
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                const months = Math.floor(diffDays / 30);
                const days = diffDays % 30;

                this.selectedDeposit = {
                    ...data,
                    accruedInterest: this.ledgerSummary.totalInterestAccrued,
                    paidInterest: this.ledgerSummary.totalInterestPaid,
                    durationDisplay: `${months} months ${days} days`
                };
            },
            error: () => {
                this.toastService.error('Failed to fetch deposit details');
            }
        });
    }

    editDeposit(id: number) {
        this.router.navigate(['/mms/entry'], { queryParams: { id: id } });
    }

    saleDeposit(id: number) {
        // Navigate to merchant transfer with this deposit ID to filter items
        this.router.navigate(['/mms/merchant'], { queryParams: { depositId: id } });
    }



    openPaymentModal(deposit: DepositSummary) {
        this.selectedDepositForPayment = deposit;
        this.paymentForm = {
            principalPaid: 0,
            interestPaid: 0,
            notes: '',
            addPrincipal: false,
            extraPrincipal: 0,
            transactionDate: new Date().toISOString().split('T')[0]
        };
        this.payFullInterest = false;
        this.showPaymentModal = true;
    }

    toggleFullInterest() {
        if (this.payFullInterest && this.selectedDepositForPayment) {
            this.paymentForm.interestPaid = this.selectedDepositForPayment.unpaidInterest;
        } else {
            this.paymentForm.interestPaid = 0;
        }
    }

    submitPayment() {
        if (!this.selectedDepositForPayment) return;

        const p = Number(this.paymentForm.principalPaid) || 0;
        const i = Number(this.paymentForm.interestPaid) || 0;

        if (p <= 0 && i <= 0) {
            this.toastService.error('Enter at least some Principal or Interest amount');
            return;
        }

        const payload = {
            principalPaid: p,
            interestPaid: i,
            totalPaid: p + i,
            notes: this.paymentForm.notes,
            extraPrincipal: this.paymentForm.addPrincipal ? (Number(this.paymentForm.extraPrincipal) || 0) : 0,
            transactionDate: this.paymentForm.transactionDate
        };

        this.mmsService.addDepositTransaction(this.selectedDepositForPayment.depositId, payload).subscribe({
            next: () => {
                this.toastService.success('Payment Recorded Successfully');
                this.showPaymentModal = false;
                this.loadData();
            },
            error: (err) => {
                this.toastService.error('Failed to record payment');
                console.error(err);
            }
        });
    }

    // Settlement Modal UI state logic already handled at top


    // Merchant Liability Modal
    showMerchantLiabilityModal = false;
    merchantLiabilityData: any[] = [];
    blockedDepositId: number | null = null;

    closeDeposit(summaryDeposit: any) {
        const depositId = summaryDeposit.depositId;

        forkJoin({
            activeEntries: this.mmsService.getActiveMerchantEntries(depositId),
            fullDetails: this.mmsService.getDeposit(depositId)
        }).pipe(
            switchMap(({ activeEntries, fullDetails }) => {
                const itemValueRequests = (fullDetails.items || []).map((item: any) => {
                    if (!item.itemId || !item.fineWeight) return of(0);
                    return this.mmsService.calculateAssetValue(item.itemId, item.fineWeight).pipe(
                        catchError(() => of(0))
                    );
                });

                return forkJoin(itemValueRequests).pipe(
                    map(values => ({ activeEntries, fullDetails, values }))
                );
            })
        ).subscribe({
            next: ({ activeEntries, fullDetails, values }) => {
                if (fullDetails.items) {
                    fullDetails.items.forEach((item: any, index: number) => {
                        item.estValue = values[index];
                    });
                }

                this.settlementData = {
                    ...fullDetails,
                    finalPrincipal: fullDetails.totalLoanAmount,
                    finalInterest: fullDetails.unpaidInterest,
                    totalPayable: ((fullDetails.totalLoanAmount || 0) + (fullDetails.unpaidInterest || 0)),
                    activeMerchantEntries: activeEntries || []
                };

                this.generateLedger(fullDetails);
                this.isFullPayment = true;
                this.updateSettlementAmount();
                this.showSettlementModal = true;
            },
            error: (err) => {
                this.toastService.error('Failed to prepare settlement data');
                console.error(err);
            }
        });
    }

    openRedeemModal(pledge: any) {
        this.selectedPledgeForRedeem = pledge;
        // Default calculate: remaining principal and pending interest (Rounded to 2 decimals)
        this.redeemForm = {
            principalPaid: Number.parseFloat((pledge.principalAmount || 0).toFixed(2)),
            interestPaid: Number.parseFloat((Math.max(0, (pledge.accruedInterest || 0) - (pledge.totalInterestPaid || 0))).toFixed(2)),
            totalPaid: 0,
            notes: 'Redeemed during final settlement'
        };
        this.calculateRedeemTotal();
        this.showRedeemModal = true;
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
                // Refresh settlement data to reflect the return
                this.closeDeposit({ depositId: this.settlementData.depositId });
            },
            error: (err) => {
                console.error(err);
                this.toastService.error('Error redeeming item. Please try again.');
            }
        });
    }

    // Settlement Modal state logic handled at top


    updateSettlementAmount() {
        if (this.isFullPayment && this.ledgerSummary) {
            // Round to 2 decimal places to match UI display (Same to Same)
            this.settlementAmount = Number.parseFloat(this.ledgerSummary.total.toFixed(2));
        }
    }

    get settlementValidationError(): string | null {
        if (this.isFullPayment) return null; // Full payment is always valid logic-wise

        const amt = this.settlementAmount;
        const min = this.ledgerSummary?.principal || 0;
        const max = this.ledgerSummary?.total || 0;

        // Allow small floating point margin (0.01)
        if (amt < (min - 0.01)) return `Amount cannot be less than Principal (₹ ${min.toFixed(2)})`;
        if (amt > (max + 0.01)) return `Amount cannot exceed Total Payable (₹ ${max.toFixed(2)})`;

        return null;
    }

    confirmSettlement(confirmed: boolean) {
        if (!this.settlementData) return;

        if (this.settlementValidationError) {
            this.toastService.error(this.settlementValidationError);
            return;
        }

        if (!confirmed) {
            this.toastService.error('Please confirm that the payment has been received.');
            return;
        }

        // Calculate Split based on input amount
        const totalInterest = this.ledgerSummary.interest || 0;
        const totalPrincipal = this.ledgerSummary.principal || 0;
        let pPaid = 0;
        let iPaid = 0;

        if (this.isFullPayment) {
            // Exact Match
            pPaid = totalPrincipal;
            iPaid = totalInterest;
        } else if (this.settlementAmount >= totalInterest) {
            // Custom Amount Logic: Pay Interest First? Or Proportional?
            // Usually, Interest is paid first.
            iPaid = totalInterest;
            pPaid = this.settlementAmount - totalInterest;
        } else {
            iPaid = this.settlementAmount;
        }

        // 1. Record the Payment Transaction
        const paymentData = {
            principalPaid: pPaid,
            interestPaid: iPaid,
            notes: this.isFullPayment ? 'Final Settlement (Full)' : `Settlement (Adjusted: ₹${this.settlementAmount})`
        };

        // Call addDepositTransaction
        this.mmsService.addDepositTransaction(this.settlementData.depositId, paymentData).subscribe({
            next: () => {
                // 2. Close the Deposit
                this.closeDepositRequest();
            },
            error: (err) => {
                this.toastService.error('Failed to record payment transaction');
                console.error(err);
            }
        });
    }

    closeDepositRequest() {
        this.mmsService.closeDeposit(this.settlementData.depositId).subscribe({
            next: () => {
                this.toastService.success('Deposit Settled & Closed Successfully');
                this.showSettlementModal = false;
                this.settlementData = null;
                this.loadData();
            },
            error: (err) => {
                this.toastService.error('Failed to close deposit');
                console.error(err);
            }
        });
    }

    generateLedger(deposit: any) {
        if (!deposit) return;

        const events: any[] = [];

        // A. Add explicit transactions
        if (deposit.transactions) {
            deposit.transactions.forEach((tx: any) => {
                const event = this.mapTransactionToEvent(tx);
                if (event) events.push(event);
            });
        }

        // B. Generate Monthly Interest Accruals
        this.addInterestAccrualEvents(deposit, events);

        // C. Sort Events Chronologically
        this.sortLedgerEvents(events);

        // D. Replay and Calculate
        this.processLedgerEvents(events, deposit.interestRate || 2);
    }

    private mapTransactionToEvent(tx: any): any {
        const typeMap: { [key: string]: { type: string, dr?: number, cr?: number, isInterest?: boolean, desc: string } } = {
            'INITIAL_MONEY': { type: 'OPENING', cr: tx.amount, desc: 'Opening Balance' },
            'EXTRA_WITHDRAWAL': { type: 'EXTRA_WITHDRAWAL', cr: tx.amount, desc: 'Additional Loan' },
            'PRINCIPAL_PAYMENT': { type: 'PRINCIPAL_PAYMENT', dr: tx.amount, desc: 'Principal Repayment' },
            'INTEREST_PAYMENT': { type: 'INTEREST PAYMENT', dr: tx.amount, isInterest: true, desc: 'Interest Repayment' }
        };

        const config = typeMap[tx.type];
        if (!config) return null;

        const isInterest = config.isInterest || false;
        const description = tx.description ? `${config.desc} (${tx.description})` : config.desc;

        return {
            date: new Date(tx.date),
            type: config.type,
            principalCr: isInterest ? 0 : (config.cr || 0),
            principalDr: isInterest ? 0 : (config.dr || 0),
            interestCr: 0,
            interestDr: isInterest ? (config.dr || 0) : 0,
            rawDate: tx.date,
            desc: description
        };
    }

    private addInterestAccrualEvents(deposit: any, events: any[]) {
        const depositDate = new Date(deposit.depositDate);
        const today = new Date();
        let monthCount = 1;

        while (true) {
            const intDate = new Date(depositDate);
            intDate.setMonth(depositDate.getMonth() + (monthCount - 1));

            if (intDate > today && monthCount > 1) break;

            events.push({
                date: intDate,
                type: 'INTEREST',
                principalCr: 0,
                principalDr: 0,
                interestCr: 0,
                interestDr: 0,
                rawDate: intDate.toISOString().split('T')[0],
                desc: `Interest (Month ${monthCount})`
            });

            monthCount++;
            if (monthCount > 1200) break;
        }
    }

    private sortLedgerEvents(events: any[]) {
        events.sort((a, b) => {
            if (a.date.getTime() !== b.date.getTime()) {
                return a.date.getTime() - b.date.getTime();
            }
            const priority = (type: string) => {
                if (type === 'OPENING') return 0;
                if (type === 'INTEREST') return 1;
                return 2;
            };
            return priority(a.type) - priority(b.type);
        });
    }

    private processLedgerEvents(events: any[], interestRate: number) {
        let currentPrincipal = 0;
        let runningBalance = 0;
        let totalInterestAccrued = 0;
        let totalInterestPaid = 0;

        events.forEach(ev => {
            if (ev.type === 'OPENING' || ev.type === 'EXTRA_WITHDRAWAL') {
                currentPrincipal += ev.principalCr;
            } else if (ev.type === 'PRINCIPAL_PAYMENT') {
                currentPrincipal -= ev.principalDr;
            }

            if (ev.type === 'INTEREST') {
                const intAmount = (currentPrincipal * interestRate) / 100;
                ev.interestCr = intAmount;
                totalInterestAccrued += intAmount;
            }

            runningBalance += ev.principalCr - ev.principalDr + ev.interestCr - ev.interestDr;
            totalInterestPaid += ev.interestDr;

            ev.balance = runningBalance;
            ev.currentPrincipal = currentPrincipal;
        });

        this.ledger = events.map(ev => ({
            date: ev.date,
            description: ev.desc,
            notes: null,
            principal: (ev.principalCr || 0) - (ev.principalDr || 0),
            interest: (ev.interestCr || 0) - (ev.interestDr || 0),
            balance: ev.balance
        }));

        this.ledgerSummary = {
            principal: currentPrincipal,
            interest: runningBalance - currentPrincipal,
            total: runningBalance,
            totalInterestPaid: totalInterestPaid,
            totalInterestAccrued: totalInterestAccrued
        };
    }

    get settlementMargin() {
        if (!this.settlementData) return { totalCustInt: 0, totalMerchInt: 0, netProfit: 0 };

        // 1. Total interest charged to the customer for this entire loan
        const totalCustInt = this.ledgerSummary?.totalInterestAccrued || 0;

        // 2. Total interest owed to all merchants for items from this loan
        const totalMerchInt = (this.settlementData.activeMerchantEntries || []).reduce(
            (sum: number, item: any) => sum + (item.accruedInterest || 0), 0
        );

        return {
            totalCustInt,
            totalMerchInt,
            netProfit: totalCustInt - totalMerchInt
        };
    }
}
