import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { MmsService, DepositSummary, ItemMaster } from '../mms.service';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ToastService } from 'src/app/theme/shared/components/toast/toast.service';
import { forkJoin, of } from 'rxjs';
import { catchError, map } from 'rxjs/operators';


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
        notes: ''
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
        customerName: '',
        depositDate: '',
        months: '',
        loanAmount: '',
        interest: '',
        unpaidInterest: '',
        assetValue: '',
        pl: '',
        status: ''
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
        private mmsService: MmsService,
        private router: Router,
        private toastService: ToastService
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
            customerName: '',
            depositDate: '',
            months: '',
            loanAmount: '',
            interest: '',
            unpaidInterest: '',
            assetValue: '',
            pl: '',
            status: ''
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
            notes: ''
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
            notes: this.paymentForm.notes
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
        // 1. Fetch detailed active merchant entries
        this.mmsService.getActiveMerchantEntries(summaryDeposit.depositId).subscribe({
            next: (activeEntries) => {
                // 2. Fetch Full Deposit Details
                this.mmsService.getDeposit(summaryDeposit.depositId).subscribe({
                    next: (fullDetails) => {
                        // 2a. Fetch Precise Asset Value for Each Item (Backend Calculation)
                        const itemValueRequests = (fullDetails.items || []).map((item: any) => {
                            if (!item.itemId || !item.fineWeight) return of(0);
                            return this.mmsService.calculateAssetValue(item.itemId, item.fineWeight).pipe(
                                catchError(() => of(0)) // If calc fails, return 0
                            );
                        });

                        forkJoin(itemValueRequests).subscribe((values: any[]) => {
                            // Assign values to items
                            if (fullDetails.items) {
                                fullDetails.items.forEach((item: any, index: number) => {
                                    item.estValue = values[index];
                                });
                            }

                            // 3. Prepare Settlement Data
                            this.settlementData = {
                                ...fullDetails,
                                finalPrincipal: fullDetails.totalLoanAmount,
                                finalInterest: fullDetails.unpaidInterest,
                                totalPayable: ((fullDetails.totalLoanAmount || 0) + (fullDetails.unpaidInterest || 0)),
                                activeMerchantEntries: activeEntries || []
                            };

                            // 4. Generate Ledger
                            this.generateLedger(fullDetails);

                            // 5. Open Modal
                            this.isFullPayment = true;
                            // Use helper to set amount with correct rounding
                            this.updateSettlementAmount();
                            this.showSettlementModal = true;
                        });
                    },
                    error: (err) => {
                        this.toastService.error('Failed to fetch deposit details');
                        console.error(err);
                    }
                });
            },
            error: (err) => {
                this.toastService.error('Failed to validate deposit status');
                console.error(err);
            }
        });
    }

    openRedeemModal(pledge: any) {
        this.selectedPledgeForRedeem = pledge;
        // Default calculate: remaining principal and pending interest (Rounded to 2 decimals)
        this.redeemForm = {
            principalPaid: parseFloat((pledge.principalAmount || 0).toFixed(2)),
            interestPaid: parseFloat((Math.max(0, (pledge.accruedInterest || 0) - (pledge.totalInterestPaid || 0))).toFixed(2)),
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
            this.settlementAmount = parseFloat(this.ledgerSummary.total.toFixed(2));
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
        let pPaid = 0;
        let iPaid = 0;

        const totalInterest = this.ledgerSummary.interest || 0;
        const totalPrincipal = this.ledgerSummary.principal || 0;

        if (this.isFullPayment) {
            // Exact Match
            pPaid = totalPrincipal;
            iPaid = totalInterest;
        } else {
            // Custom Amount Logic: Pay Interest First? Or Proportional?
            // Usually, Interest is paid first.
            if (this.settlementAmount >= totalInterest) {
                iPaid = totalInterest;
                pPaid = this.settlementAmount - totalInterest;
            } else {
                iPaid = this.settlementAmount;
                pPaid = 0;
            }
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

        const ledger: any[] = [];
        let runningBalance = 0; // Total Owed

        // 1. Initial Deposit / Opening Balance
        // We find the 'INITIAL_MONEY' transaction or just use deposit date
        // Ideally we iterate correctly.

        // Let's create a timeline of events.
        const events: any[] = [];

        // A. Add explicit transactions
        if (deposit.transactions) {
            deposit.transactions.forEach((tx: any) => {
                let type = tx.type;
                let dr = 0;
                let cr = 0;
                let isInterest = false;

                if (type === 'INITIAL_MONEY') {
                    type = 'OPENING';
                    cr = tx.amount; // Principal Added (Loan Taken) -> We owe this
                    if (!tx.description) tx.description = 'Opening Balance';
                } else if (type === 'EXTRA_WITHDRAWAL') {
                    cr = tx.amount; // More Loan
                } else if (type === 'PRINCIPAL_PAYMENT') {
                    dr = tx.amount; // Loan Repaid
                } else if (type === 'INTEREST_PAYMENT') {
                    type = 'INTEREST PAYMENT';
                    dr = tx.amount; // Paid towards interest
                    isInterest = true;
                } else if (type === 'INTEREST_RECEIVED') {
                    // This is if we manually posted interest.
                    // usually we calculate it dynamically.
                    // let's skip dynamic calculation if we have these? 
                    // No, let's stick to dynamic for consistency with "Merchant" view.
                }

                if (type !== 'INTEREST_RECEIVED') { // Skip internal posted interest for now to avoid duplication with auto-generated

                    // Format Description: Friendly Type + (Comment)
                    let friendlyDesc = tx.description || '';
                    if (type === 'OPENING') friendlyDesc = 'Opening Balance';
                    else if (type === 'PRINCIPAL_PAYMENT') friendlyDesc = `Principal Repayment${tx.description ? ' (' + tx.description + ')' : ''}`;
                    else if (type === 'INTEREST PAYMENT') friendlyDesc = `Interest Repayment${tx.description ? ' (' + tx.description + ')' : ''}`;
                    else if (type === 'EXTRA_WITHDRAWAL') friendlyDesc = `Additional Loan${tx.description ? ' (' + tx.description + ')' : ''}`;

                    events.push({
                        date: new Date(tx.date),
                        type: type,
                        principalCr: !isInterest ? cr : 0,
                        principalDr: !isInterest ? dr : 0,
                        interestCr: 0, // Will accrue dynamically
                        interestDr: isInterest ? dr : 0,
                        rawDate: tx.date,
                        desc: friendlyDesc
                    });
                }
            });
        }

        // B. Generate Monthly Interest Accruals
        // Start from deposit date, go up to today.
        const depositDate = new Date(deposit.depositDate);
        const today = new Date();
        const interestRate = deposit.interestRate || 2;
        let currentDate = new Date(depositDate);

        // We assume strictly 1st month starts immediately? Or at end?
        // Merchant view logic: "Start of Month" billing.
        // i.e., Date 1: Interest for Month 1 starts.

        // Loop months
        let monthCount = 1;
        // We go until today.
        while (currentDate <= today || monthCount === 1) { // Ensure at least 1 month
            // Calculate principal at this point? It's hard to know exact balance at historical date without replaying.
            // Simplified: We assume interest is calculated on *Current* principal for simplicity or 
            // we need to perform a chronological replay.

            // Let's do chronological replay sort first.
            // But we need the events to "insert" interest.

            // Strategy: Add "Interest Event" at strictly +1 month intervals?
            // Or just simple logic: 
            // Date = DepositDate + (Month-1) months.

            let intDate = new Date(depositDate);
            intDate.setMonth(depositDate.getMonth() + (monthCount - 1));

            // If this generated date is in future beyond "now", stop? 
            // well, "active/started" month counts.
            if (intDate > today && monthCount > 1) break;

            events.push({
                date: intDate,
                type: 'INTEREST',
                principalCr: 0,
                principalDr: 0,
                interestCr: 0, // Placeholder, calculated during replay
                interestDr: 0,
                rawDate: intDate.toISOString().split('T')[0],
                desc: `Interest (Month ${monthCount})`
            });

            currentDate.setMonth(currentDate.getMonth() + 1);
            monthCount++;
            if (monthCount > 1200) break; // Safety break
        }

        // C. Sort Events Chronologically
        // Priority on same day: Opening -> Interest -> Payment
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

        // D. Replay to calculate balances
        let currentPrincipal = 0;
        let totalInterestAccrued = 0;
        let totalPaid = 0;

        events.forEach(ev => {
            // 1. Update Principal
            if (ev.type === 'OPENING' || ev.type === 'EXTRA_WITHDRAWAL') {
                currentPrincipal += ev.principalCr;
            }
            if (ev.type === 'PRINCIPAL_PAYMENT') {
                currentPrincipal -= ev.principalDr;
            }

            // 2. Calculate Interest if Type is INTEREST
            if (ev.type === 'INTEREST') {
                const intAmount = (currentPrincipal * interestRate) / 100;
                ev.interestCr = intAmount; // Accrued
                totalInterestAccrued += intAmount;
            }

            // 3. Payments
            if (ev.type === 'INTEREST PAYMENT') {
                // specific logic
            }

            // 4. Update Running Balance (Principal + Interest - Paid)
            // Actually, Passbook usually shows "Balance" of Loan+Interest?
            // Let's keep it simple: Balance = Principal + All Interest - All Paid

            // But wait, "Interest Payment" reduces the liability.
            if (ev.type === 'INTEREST PAYMENT') {
                // It reduces balance
            }

            // runningInterest?
            // Let's track "Total Liability"
            // Balance = Principal + AccruedInterest - PaidInterest - PaidPrincipal

            // Re-calc for this line
            // We need to know "Principal" and "Interest" components?
            // The table usually shows a single "Total Balance" column.

            const netPrincipal = currentPrincipal; // already adjusted for principal payments
            // We need cumulative interest and cumulative payments till this point? 
            // easier:
            // Balance changes by: +PrincipalCr -PrincipalDr +InterestCr -InterestDr

            runningBalance += ev.principalCr;
            runningBalance -= ev.principalDr;
            runningBalance += ev.interestCr;
            runningBalance -= ev.interestDr;

            ev.balance = runningBalance;
            ev.currentPrincipal = currentPrincipal;
        });

        // Map events to the view model expected by HTML
        this.ledger = events.map(ev => ({
            date: ev.date,
            description: ev.desc, // Map desc -> description
            notes: null, // or ev.notes if available
            // Net Principal Change for display column
            principal: (ev.principalCr || 0) - (ev.principalDr || 0),
            // Net Interest Change for display column
            interest: (ev.interestCr || 0) - (ev.interestDr || 0),
            balance: ev.balance
        }));

        // Calculate Final Summary
        // Principal Bal = currentPrincipal (after loop)
        // Interest Bal = (Sum of Interest Cr) - (Sum of Interest Dr)

        let interestBal = 0;
        let totalInterestPaid = 0;
        let grossInterest = 0;

        events.forEach(ev => {
            interestBal += (ev.interestCr || 0);
            interestBal -= (ev.interestDr || 0);
            totalInterestPaid += (ev.interestDr || 0);
            grossInterest += (ev.interestCr || 0);
        });

        this.ledgerSummary = {
            principal: currentPrincipal,
            interest: interestBal, // Net Outstanding
            total: runningBalance,
            totalInterestPaid: totalInterestPaid,
            totalInterestAccrued: grossInterest
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
