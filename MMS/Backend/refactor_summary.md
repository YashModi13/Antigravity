# Implementation Plan - Backend Refactoring & Lint Fixes

## 1. Objectives
- Resolve all SonarQube and IDE lint warnings.
- Refactor "Brain Methods" to reduce cognitive complexity.
- Standardize constants and injection patterns.
- Ensure type safety and remove wildcards.
- **New**: Centralize ALL static values/string literals to `Constants` class.

## 2. Changes Implemented

### A. Constants Extraction
- Created `com.mms.backend.util.Constants` to centralized frequent string literals:
    - Transaction Types: `INITIAL_MONEY`, `PRINCIPAL_PAYMENT`, etc.
    - Statuses: `ACTIVE`, `CLOSED`, `RISK`, etc.
    - Keys: `itemId`, ` months`.
    - **System Configs**: `system.pagination.default.size`, `system.risk.threshold.percentage`, etc.
    - **Report Types/Files**: `deposits`, `Customers_Report.xlsx`, Sheet Names.
    - **Chart Periods**: `WEEK`, `MONTH`, `YEAR`.
    - **Date Formats**: `dd MMM`, `yyyy-MM-dd_HH-mm-ss`.
- **Lint Fix**: Added private constructor to `Constants` to prevent instantiation.

### B. Service Refactoring
1.  **DashboardChartService**:
    - Replaced literals (`CLOSED`, `WEEK`, etc.) with `Constants.*`.
    - Extracted `calculateStartDate` helper method to reduce cognitive complexity.

2.  **ReportService**:
    - Replaced Sheet Names (`Deposits`, etc.) with `Constants.REPORT_SHEET_*`.

3.  **CustomerController**:
    - Replaced config keys (`system.pagination.default.size`) and defaults (`id`, `asc`) with `Constants.*`.

4.  **SystemController**:
    - Replaced report types, file names, date formats, and `SECURE` string with `Constants.*`.

5.  **DepositQueryService** & **DepositService**:
    - Previously refactored to use `Constants.*`.

### C. General Resolutions
- **Null Safety**: Added `Objects.requireNonNull` and `@NonNull` annotations.
- **Injection**: Replaced field injection with constructor injection.
- **Security Advice**: Fixed serialization and type safety in `EncryptionResponseAdvice`.

## 3. Verification
- `mvn compile` executes successfully (Exit Code 0).
- All identified static values and string literals have been moved to `Constants.java`.
