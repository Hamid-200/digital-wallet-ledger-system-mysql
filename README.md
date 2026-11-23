# Digital Wallet & Double-Entry Financial Ledger (MySQL)

A production-style relational database system modeling a peer-to-peer (P2P) digital wallet and financial ledger. Built to enforce **ACID compliance**, **double-entry bookkeeping**, concurrency control, and automated forensic auditing directly at the database layer.

## Architecture & Core Principles

* **5-Table Relational Schema:** `Users`, `Accounts`, `Transactions`, `Ledger_Entries`, and `Audit_Logs` using `DECIMAL(14,4)` financial precision.
* **Wallet as Cache, Ledger as Truth:** `Accounts.current_balance` acts as a fast-lookup balance snapshot, while `Ledger_Entries` stores the immutable, zero-sum transaction history ($\sum \text{Debits} - \sum \text{Credits} = 0$).
* **Concurrency & ACID Guarantees:** Uses `START TRANSACTION`, `COMMIT`, `ROLLBACK`, and `FOR UPDATE` row-level locking to prevent race conditions and double-spending.
* **Automated Audit Trail:** An `AFTER UPDATE` trigger (`trg_audit_account_balance`) captures every balance mutation on `Accounts`, even if the transfer stored procedure is bypassed.

## Key Features

1. **Atomic Transfer Engine (`sp_transfer_funds`)**
   * Validates positive amounts, non-negative fees, distinct accounts, active user statuses, and sufficient funds.
   * Atomically updates sender, receiver, and platform revenue (`ACC_SYS_REVENUE`) balances while writing balanced double-entry ledger lines.
   * Implements `DECLARE EXIT HANDLER FOR SQLEXCEPTION` with diagnostics for automatic rollbacks on runtime errors.

2. **Financial Auditing & Fraud Detection (`05_analytics_audits.sql`)**
   * **Zero-Sum Invariant Audit:** Conditional aggregation (`SUM(CASE...)`) with `HAVING` to flag any unbalanced transaction.
   * **Running Balance Reconstruction:** `SUM() OVER (PARTITION BY account_id ORDER BY created_at, entry_id)` to replay account history and detect cache drift.
   * **Rapid Velocity Fraud Detection:** CTE with `LAG()` and `TIMESTAMPDIFF(SECOND, ...)` to flag accounts executing consecutive outgoing transfers within 120 seconds.

## Execution Order

Run the scripts sequentially in MySQL Workbench or the MySQL CLI:

1. `schema.sql`
2. `seed_data.sql`
3. `stored_procedure.sql`
4. `audit_trigger.sql`
5. `analytics_audits.sql`

### Sample Transfer Call
```sql
CALL sp_transfer_funds('ACC_SARAH', 'ACC_DAVID', 100.0000, 2.5000);
