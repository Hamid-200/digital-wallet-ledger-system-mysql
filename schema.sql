-- ============================================================================
-- schema.sql
-- Database & 5-Table Relational Schema for Digital Wallet & Financial Ledger
-- ============================================================================

CREATE DATABASE IF NOT EXISTS digital_wallet_ledger_db;
USE digital_wallet_ledger_db;

CREATE TABLE IF NOT EXISTS Users (
    user_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    status ENUM('ACTIVE', 'FROZEN', 'SUSPENDED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS Accounts (
    account_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    account_type ENUM('USER_WALLET', 'SYSTEM_REVENUE', 'SYSTEM_HOLDING') NOT NULL,
    currency CHAR(3) DEFAULT 'USD',
    current_balance DECIMAL(14, 4) DEFAULT 0.0000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_current_balance CHECK (account_type != 'USER_WALLET' OR current_balance >= 0),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id VARCHAR(64) PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Ledger_Entries (
    entry_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(64),
    account_id VARCHAR(50),
    entry_type ENUM('DEBIT', 'CREDIT') NOT NULL,
    amount DECIMAL(14, 4) NOT NULL CHECK (amount > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES Transactions(transaction_id),
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

CREATE TABLE IF NOT EXISTS Audit_Logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id VARCHAR(50),
    transaction_id VARCHAR(64),
    old_balance DECIMAL(14, 4) NOT NULL,
    new_balance DECIMAL(14, 4) NOT NULL,
    change_reason VARCHAR(255) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES Transactions(transaction_id),
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);
