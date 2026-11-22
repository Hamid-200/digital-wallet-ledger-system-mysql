-- ============================================================================
-- stored_procedure.sql
-- ACID-Compliant P2P Transfer Procedure with Row Locking & Error Handling
-- ============================================================================

USE digital_wallet_ledger_db;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_transfer_funds$$

CREATE PROCEDURE sp_transfer_funds (
    IN p_sender_acc VARCHAR(50),
    IN p_receiver_acc VARCHAR(50),
    IN p_amount DECIMAL(14, 4),
    IN p_fee DECIMAL(14, 4)
)
proc_body: BEGIN
    DECLARE v_sender_balance DECIMAL(14, 4);
    DECLARE v_sender_status ENUM('ACTIVE', 'FROZEN', 'SUSPENDED');
    DECLARE v_receiver_status ENUM('ACTIVE', 'FROZEN', 'SUSPENDED');
    DECLARE v_sender_exists INT DEFAULT 0;
    DECLARE v_receiver_exists INT DEFAULT 0;
    DECLARE v_txn_id VARCHAR(64);
    DECLARE v_total_deduction DECIMAL(14, 4);

    DECLARE v_err_code CHAR(5) DEFAULT '00000';
    DECLARE v_err_msg TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_err_code = RETURNED_SQLSTATE,
            v_err_msg = MESSAGE_TEXT;
        ROLLBACK;
        SELECT 'FAILED' AS status, CONCAT('MySQL Error [', v_err_code, ']: ', v_err_msg) AS message, NULL AS transaction_id;
    END;

    -- Input validation
    IF p_amount <= 0 THEN
        SELECT 'FAILED' AS status, 'Transfer amount must be greater than zero.' AS message, NULL AS transaction_id;
        LEAVE proc_body;
    END IF;

    IF p_fee < 0 THEN
        SELECT 'FAILED' AS status, 'Fee cannot be negative.' AS message, NULL AS transaction_id;
        LEAVE proc_body;
    END IF;

    IF p_sender_acc = p_receiver_acc THEN
        SELECT 'FAILED' AS status, 'Sender and Receiver Account cannot be the same' AS message, NULL AS transaction_id;
        LEAVE proc_body;
    END IF;

    SET v_total_deduction = p_amount + p_fee;

    START TRANSACTION;

        SELECT
            COUNT(*),
            COALESCE(acc.current_balance, 0.0000),
            u.status
        INTO
            v_sender_exists,
            v_sender_balance,
            v_sender_status
        FROM Accounts acc
        JOIN Users u ON acc.user_id = u.user_id
        WHERE acc.account_id = p_sender_acc
        GROUP BY acc.current_balance, u.status
        FOR UPDATE;

        SELECT
            COUNT(*),
            u.status
        INTO
            v_receiver_exists,
            v_receiver_status
        FROM Accounts acc
        JOIN Users u ON acc.user_id = u.user_id
        WHERE acc.account_id = p_receiver_acc
        GROUP BY acc.current_balance, u.status
        FOR UPDATE;

        -- Business rule guards
        IF v_sender_exists = 0 THEN
            ROLLBACK;
            SELECT 'FAILED' AS status, 'Sender account does not exist' AS message, NULL AS transaction_id;
            LEAVE proc_body;
        END IF;

        IF v_receiver_exists = 0 THEN
            ROLLBACK;
            SELECT 'FAILED' AS status, 'Receiver account does not exist' AS message, NULL AS transaction_id;
            LEAVE proc_body;
        END IF;

        IF v_sender_status != 'ACTIVE' THEN
            ROLLBACK;
            SELECT 'FAILED' AS status, CONCAT('Sender account is ', v_sender_status, '.') AS message, NULL AS transaction_id;
            LEAVE proc_body;
        END IF;

        IF v_receiver_status != 'ACTIVE' THEN
            ROLLBACK;
            SELECT 'FAILED' AS status, CONCAT('Receiver account is ', v_receiver_status, '.') AS message, NULL AS transaction_id;
            LEAVE proc_body;
        END IF;

        IF v_sender_balance < v_total_deduction THEN
            ROLLBACK;
            SELECT 'FAILED' AS status, 'Insufficient Funds to make the transfer' AS message, NULL AS transaction_id;
            LEAVE proc_body;
        END IF;

        -- Execute atomic mutations
        SET v_txn_id = CONCAT('TXN_', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '_', FLOOR(1000 + RAND() * 9000));

        UPDATE Accounts
        SET current_balance = current_balance - v_total_deduction
        WHERE account_id = p_sender_acc;

        UPDATE Accounts
        SET current_balance = current_balance + p_amount
        WHERE account_id = p_receiver_acc;

        IF p_fee > 0 THEN
            UPDATE Accounts
            SET current_balance = current_balance + p_fee
            WHERE account_id = 'ACC_SYS_REVENUE';
        END IF;

        INSERT INTO Transactions (transaction_id, description, status)
        VALUES (
            v_txn_id,
            CONCAT('P2P Transfer: ', p_sender_acc, ' -> ', p_receiver_acc, ' ($', p_amount, ') Fee: $', p_fee),
            'SUCCESS'
        );

        INSERT INTO Ledger_Entries (transaction_id, account_id, entry_type, amount)
        VALUES
            (v_txn_id, p_sender_acc, 'DEBIT', v_total_deduction),
            (v_txn_id, p_receiver_acc, 'CREDIT', p_amount);

        IF p_fee > 0 THEN
            INSERT INTO Ledger_Entries (transaction_id, account_id, entry_type, amount)
            VALUES
                (v_txn_id, 'ACC_SYS_REVENUE', 'CREDIT', p_fee);
        END IF;

    COMMIT;

    SELECT
        'SUCCESS' AS status,
        CONCAT('Transferred $', p_amount, ' from ', p_sender_acc, ' to ', p_receiver_acc) AS message,
        v_txn_id AS transaction_id;

END $$

DELIMITER ;
