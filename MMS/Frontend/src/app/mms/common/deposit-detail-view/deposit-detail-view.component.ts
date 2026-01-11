import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { MmsService } from '../../mms.service';
import { ToastService } from 'src/app/theme/shared/components/toast/toast.service';

@Component({
    selector: 'app-deposit-detail-view',
    standalone: true,
    imports: [CommonModule, FormsModule, SharedModule, RouterModule],
    templateUrl: './deposit-detail-view.component.html',
    styleUrls: []
})
export class DepositDetailViewComponent {
    @Input() deposit: any;
    @Input() customerName: string = ''; // For settlement modal display
    @Output() refresh = new EventEmitter<void>();

    // --- PAYMENT MODAL STATE ---
    showPaymentModal = false;
    paymentForm = {
        principalPaid: 0,
        interestPaid: 0,
        notes: ''
    };
    payFullInterest = false;

    // --- SETTLEMENT MODAL STATE ---
    showSettlementModal = false;
    settlementData: any = null;
    settlementAmount: number = 0;
    isFullPayment = true;

    // --- HISTORY MODAL STATE ---
    showHistoryModal = false;
    historyData: any = null;
    isLoadingHistory = false;

    constructor(
        private readonly mmsService: MmsService,
        private readonly toastService: ToastService
    ) { }

    // --- PAYMENT ACTIONS ---

    openPaymentModal() {
        this.paymentForm = {
            principalPaid: 0,
            interestPaid: 0,
            notes: ''
        };
        this.payFullInterest = false;
        this.showPaymentModal = true;
    }

    calculateInterest() {
        if (this.payFullInterest && this.deposit) {
            const pending = (this.deposit.accruedInterest || 0) - (this.deposit.paidInterest || 0);
            this.paymentForm.interestPaid = Math.max(0, pending);
        }
    }

    submitPayment() {
        if (!this.deposit) return;

        // Validation
        if (this.paymentForm.principalPaid <= 0 && this.paymentForm.interestPaid <= 0) {
            this.toastService.error('Please enter an amount to pay.');
            return;
        }

        const txData = {
            principalPaid: this.paymentForm.principalPaid,
            interestPaid: this.paymentForm.interestPaid,
            notes: this.paymentForm.notes || 'Payment via Portfolio'
        };

        this.mmsService.addDepositTransaction(this.deposit.depositId, txData).subscribe({
            next: () => {
                this.toastService.success('Payment Recorded Successfully');
                this.showPaymentModal = false;
                this.refresh.emit(); // Notify parent to reload
            },
            error: (err) => {
                this.toastService.error('Failed to record payment');
                console.error(err);
            }
        });
    }

    // --- SETTLEMENT ACTIONS ---

    openSettlementModal() {
        // Pre-calculate settlement totals
        const pendingInterest = (this.deposit.accruedInterest || 0) - (this.deposit.paidInterest || 0);
        const outstandingPrincipal = this.deposit.loanAmount || 0;
        const totalDue = outstandingPrincipal + pendingInterest;

        this.settlementData = {
            depositId: this.deposit.depositId,
            customerName: this.customerName || 'Customer',
            loanAmount: outstandingPrincipal,
            pendingInterest: pendingInterest,
            totalDue: totalDue,
            items: this.deposit.items
        };

        this.settlementAmount = totalDue;
        this.isFullPayment = true;
        this.showSettlementModal = true;
    }

    confirmSettlement(confirmed: boolean) {
        if (!this.settlementData || !confirmed) return;

        let pPaid = 0;
        let iPaid = 0;

        if (this.isFullPayment) {
            pPaid = this.settlementData.loanAmount;
            iPaid = this.settlementData.pendingInterest;
        } else {
            // Custom Amount Logic: Pay Interest First
            const totalInt = this.settlementData.pendingInterest;
            if (this.settlementAmount >= totalInt) {
                iPaid = totalInt;
                pPaid = this.settlementAmount - totalInt;
            } else {
                iPaid = this.settlementAmount;
                // pPaid is already 0
            }
        }

        const paymentData = {
            principalPaid: pPaid,
            interestPaid: iPaid,
            notes: this.isFullPayment ? 'Final Settlement (Full)' : `Settlement (Adjusted: ₹${this.settlementAmount})`
        };

        this.mmsService.addDepositTransaction(this.settlementData.depositId, paymentData).subscribe({
            next: () => {
                // Then Close
                this.mmsService.closeDeposit(this.settlementData.depositId).subscribe({
                    next: () => {
                        this.toastService.success('Deposit Settled & Closed Successfully');
                        this.showSettlementModal = false;
                        this.refresh.emit(); // Notify parent
                    },
                    error: (e) => this.toastService.error('Failed to close deposit')
                });
            },
            error: (err) => this.toastService.error('Failed to record settlement payment')
        });
    }

    // --- HISTORY ACTIONS ---

    openHistoryModal() {
        console.log('Opening History Modal for Deposit:', this.deposit?.depositId);
        if (!this.deposit) {
            console.error('Deposit object is missing!');
            return;
        }
        this.isLoadingHistory = true;
        this.showHistoryModal = true;

        this.mmsService.getDeposit(this.deposit.depositId).subscribe({
            next: (data) => {
                this.historyData = data;
                this.isLoadingHistory = false;
            },
            error: (err) => {
                console.error(err);
                this.toastService.error('Failed to load history');
                this.isLoadingHistory = false;
                this.showHistoryModal = false;
            }
        });
    }
}
