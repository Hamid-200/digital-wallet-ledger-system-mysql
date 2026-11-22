-- ============================================================================
-- analytics_audits.sql
-- Financial Auditing, Running Balance Reconstruction & Velocity Fraud Detection
-- ============================================================================

USE digital_wallet_ledger_db;

-- 1. ZERO-SUM INVARIANT AUDIT
-- Verifies every transaction in Ledger_Entries has equal total debits and credits.
-- Returns 0 rows when the ledger is mathematically healthy.
SELECT
    transaction_id,
    SUM(CASE WHEN entry_type = 'CREDIT' THEN amount ELSE 0.0000 END) AS total_credit,
    SUM(CASE WHEN entry_type = 'DEBIT' THEN amount ELSE 0.0000 END) AS total_debit,
    SUM(CASE WHEN entry_type = 'DEBIT' THEN amount ELSE 0.0000 END)
      - SUM(CASE WHEN entry_type = 'CREDIT' THEN amount ELSE 0.0000 END) AS imbalance
FROM Ledger_Entries
GROUP BY transaction_id
HAVING imbalance != 0;


-- 2. CHRONOLOGICAL RUNNING BALANCE RECONSTRUCTION
-- Replays immutable ledger entries per account to verify wallet snapshot accuracy.
SELECT
    *,
    CASE
        WHEN entry_type = 'DEBIT' THEN -amount
        ELSE amount
    END AS signed_amount,
    SUM(
        CASE
            WHEN entry_type = 'DEBIT' THEN -amount
            ELSE amount
        END
    ) OVER (PARTITION BY account_id ORDER BY created_at, entry_id) AS running_balance
FROM Ledger_Entries;


-- 3. RAPID VELOCITY / FRAUD DETECTION
-- Flags accounts executing consecutive outgoing (DEBIT) transfers within 2 minutes (120 sec).
WITH ledger_entries_with_previous_time AS (
    SELECT
        *,
        LAG(created_at) OVER (PARTITION BY account_id ORDER BY created_at) AS previous_txn_time
    FROM Ledger_Entries
    WHERE entry_type = 'DEBIT'
)
SELECT
    account_id,
    transaction_id,
    amount,
    created_at,
    previous_txn_time,
    TIMESTAMPDIFF(SECOND, previous_txn_time, created_at) AS time_difference
FROM ledger_entries_with_previous_time
WHERE TIMESTAMPDIFF(SECOND, previous_txn_time, created_at) <= 120;
