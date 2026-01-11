# User Request: Add Date-Wise Details Button

## 1. Objective
Add a button to show date-wise transaction details for deposit entries in both **Active** and **Closed** (History) sections of the Customer Portfolio.

## 2. Changes Implemented

### A. Frontend - `DepositDetailViewComponent`
1.  **Updated Logic (TS)**:
    - Added state identifiers: `showHistoryModal`, `historyData`, `isLoadingHistory`.
    - Added `openHistoryModal()` method which calls `mmsService.getDeposit(id)` to fetch full details including transactions.

2.  **Updated UI (HTML)**:
    - **Shared Action Area**: Refactored the button container to be visible for all statuses (removed `*ngIf`).
    - **Visibility Logic**: Moved `*ngIf="deposit?.status === 'ACTIVE'"` to individual "Pay" and "Settle" buttons.
    - **New Button**: Added a **History** button (visible for both Active and Closed) that triggers `openHistoryModal()`.
    - **History Modal**: Added a Bootstrap modal containing a responsive table to display:
        - Date (`mediumDate` format)
        - Transaction Type (Badge)
        - Amount (Color-coded: Green for Credit, Red for Debit)
        - Notes/Description

### B. Frontend - `CustomerItemsComponent`
1.  **Closed Section Update**:
    - Inserted the `<app-deposit-detail-view>` component into the footer of the **Closed** deposit card.
    - This ensures the "History" button appears in the "History & Closed" tab as requested.

## 3. Verification
- The "History" button is now available for all deposits.
- Clicking it fetches and displays the transaction log in a modal.
- The button exists in both "Active Pledges" and "History & Closed" tabs.
