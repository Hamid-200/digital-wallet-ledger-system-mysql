-- ============================================================================
-- audit_trigger.sql
-- Automated Forensic Audit Trail Trigger on Accounts Balance Changes
-- ============================================================================

USE digital_wallet_ledger_db;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_audit_account_balance$$

CREATE TRIGGER trg_audit_account_balance
AFTER UPDATE ON Accounts
FOR EACH ROW
BEGIN
    IF OLD.current_balance != NEW.current_balance THEN
        INSERT INTO Audit_Logs (
            account_id,
            transaction_id,
            old_balance,
            new_balance,
            change_reason
        ) VALUES (
            NEW.account_id,
            NULL,
            OLD.current_balance,
            NEW.current_balance,
            CONCAT('Balance changed by ', NEW.current_balance - OLD.current_balance)
        );
    END IF;
END $$

DELIMITER ;
