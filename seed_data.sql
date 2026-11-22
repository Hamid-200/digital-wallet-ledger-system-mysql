-- ============================================================================
-- seed_data.sql
-- Sample Dataset: Users, System/User Accounts, Transactions & Ledger Entries
-- ============================================================================

USE digital_wallet_ledger_db;

INSERT INTO Users (user_id, full_name, email, status, created_at) VALUES
('USR_101', 'Sarah Jenkins',    'sarah.j@example.com',    'ACTIVE',    '2026-08-01 08:00:00'),
('USR_102', 'David Chen',       'david.c@example.com',    'ACTIVE',    '2026-08-01 08:30:00'),
('USR_103', 'Liam Vance',       'liam.v@example.com',     'FROZEN',    '2026-08-02 09:15:00'),
('USR_104', 'Elena Rostova',    'elena.r@example.com',    'ACTIVE',    '2026-08-02 10:00:00'),
('USR_105', 'Marcus Sterling',  'marcus.s@example.com',   'ACTIVE',    '2026-08-03 11:20:00'),
('USR_106', 'Amina Yusuf',      'amina.y@example.com',    'ACTIVE',    '2026-08-03 12:45:00'),
('USR_107', 'Kenji Sato',       'kenji.s@example.com',    'SUSPENDED', '2026-08-04 14:10:00'),
('USR_108', 'Chloe Dubois',     'chloe.d@example.com',    'ACTIVE',    '2026-08-04 15:30:00'),
('USR_109', 'Tariq Al-Mansoor', 'tariq.m@example.com',    'ACTIVE',    '2026-08-05 09:00:00'),
('USR_110', 'Zoe Kravitz',      'zoe.k@example.com',      'ACTIVE',    '2026-08-05 10:15:00');

INSERT INTO Accounts (account_id, user_id, account_type, currency, current_balance, created_at) VALUES
-- System Accounts
('ACC_SYS_REVENUE', NULL,      'SYSTEM_REVENUE', 'USD',     28.5000, '2026-08-01 00:00:00'),
('ACC_SYS_HOLDING', NULL,      'SYSTEM_HOLDING', 'USD', 500000.0000, '2026-08-01 00:00:00'),

-- User Wallets
('ACC_SARAH',  'USR_101', 'USER_WALLET', 'USD',  1420.0000, '2026-08-01 08:05:00'),
('ACC_DAVID',  'USR_102', 'USER_WALLET', 'USD',   518.5000, '2026-08-01 08:35:00'),
('ACC_LIAM',   'USR_103', 'USER_WALLET', 'USD',    50.0000, '2026-08-02 09:20:00'),
('ACC_ELENA',  'USR_104', 'USER_WALLET', 'USD',  3100.0000, '2026-08-02 10:05:00'),
('ACC_MARCUS', 'USR_105', 'USER_WALLET', 'USD',   850.0000, '2026-08-03 11:25:00'),
('ACC_AMINA',  'USR_106', 'USER_WALLET', 'USD',  2250.0000, '2026-08-03 12:50:00'),
('ACC_KENJI',  'USR_107', 'USER_WALLET', 'USD',     0.0000, '2026-08-04 14:15:00'),
('ACC_CHLOE',  'USR_108', 'USER_WALLET', 'USD',   640.0000, '2026-08-04 15:35:00'),
('ACC_TARIQ',  'USR_109', 'USER_WALLET', 'USD',  1890.0000, '2026-08-05 09:05:00'),
('ACC_ZOE',    'USR_110', 'USER_WALLET', 'USD',   110.0000, '2026-08-05 10:20:00');

INSERT INTO Transactions (transaction_id, description, status, created_at) VALUES
('TXN_20260810_01', 'Initial Funding from Bank Reserve to Sarah', 'SUCCESS', '2026-08-10 10:00:00'),
('TXN_20260810_02', 'Initial Funding from Bank Reserve to Elena', 'SUCCESS', '2026-08-10 10:30:00'),
('TXN_20260811_01', 'P2P Transfer Sarah -> David with Fee',      'SUCCESS', '2026-08-11 14:15:00'),
('TXN_20260812_01', 'P2P Transfer Elena -> Marcus with Fee',     'SUCCESS', '2026-08-12 09:00:00'),
('TXN_20260813_01', 'P2P Transfer Marcus -> Amina with Fee',     'SUCCESS', '2026-08-13 16:45:00'),
('TXN_20260814_01', 'P2P Transfer Amina -> Tariq with Fee',      'SUCCESS', '2026-08-14 11:10:00'),
('TXN_20260815_01', 'P2P Transfer Chloe -> Zoe with Fee',        'SUCCESS', '2026-08-15 13:20:00'),
('TXN_20260816_01', 'P2P Transfer Sarah -> Liam with Fee',       'FAILED',  '2026-08-16 15:00:00'),
('TXN_20260817_01', 'Rapid P2P Transfer 1: David -> Chloe',      'SUCCESS', '2026-08-17 18:00:00'),
('TXN_20260817_02', 'Rapid P2P Transfer 2: David -> Tariq',      'SUCCESS', '2026-08-17 18:01:15'),
('TXN_20260817_03', 'Rapid P2P Transfer 3: David -> Elena',      'SUCCESS', '2026-08-17 18:02:10');

INSERT INTO Ledger_Entries (transaction_id, account_id, entry_type, amount, created_at) VALUES
-- TXN 1: Reserve -> Sarah ($1,500.00)
('TXN_20260810_01', 'ACC_SYS_HOLDING', 'DEBIT',  1500.0000, '2026-08-10 10:00:00'),
('TXN_20260810_01', 'ACC_SARAH',       'CREDIT', 1500.0000, '2026-08-10 10:00:00'),

-- TXN 2: Reserve -> Elena ($3,500.00)
('TXN_20260810_02', 'ACC_SYS_HOLDING', 'DEBIT',  3500.0000, '2026-08-10 10:30:00'),
('TXN_20260810_02', 'ACC_ELENA',       'CREDIT', 3500.0000, '2026-08-10 10:30:00'),

-- TXN 3: Sarah -> David ($200.00 + $2.00 fee)
('TXN_20260811_01', 'ACC_SARAH',       'DEBIT',   202.0000, '2026-08-11 14:15:00'),
('TXN_20260811_01', 'ACC_DAVID',       'CREDIT',  200.0000, '2026-08-11 14:15:00'),
('TXN_20260811_01', 'ACC_SYS_REVENUE', 'CREDIT',    2.0000, '2026-08-11 14:15:00'),

-- TXN 4: Elena -> Marcus ($400.00 + $3.00 fee)
('TXN_20260812_01', 'ACC_ELENA',       'DEBIT',   403.0000, '2026-08-12 09:00:00'),
('TXN_20260812_01', 'ACC_MARCUS',      'CREDIT',  400.0000, '2026-08-12 09:00:00'),
('TXN_20260812_01', 'ACC_SYS_REVENUE', 'CREDIT',    3.0000, '2026-08-12 09:00:00'),

-- TXN 5: Marcus -> Amina ($250.00 + $2.50 fee)
('TXN_20260813_01', 'ACC_MARCUS',      'DEBIT',   252.5000, '2026-08-13 16:45:00'),
('TXN_20260813_01', 'ACC_AMINA',       'CREDIT',  250.0000, '2026-08-13 16:45:00'),
('TXN_20260813_01', 'ACC_SYS_REVENUE', 'CREDIT',    2.5000, '2026-08-13 16:45:00'),

-- TXN 6: Amina -> Tariq ($100.00 + $1.00 fee)
('TXN_20260814_01', 'ACC_AMINA',       'DEBIT',   101.0000, '2026-08-14 11:10:00'),
('TXN_20260814_01', 'ACC_TARIQ',       'CREDIT',  100.0000, '2026-08-14 11:10:00'),
('TXN_20260814_01', 'ACC_SYS_REVENUE', 'CREDIT',    1.0000, '2026-08-14 11:10:00'),

-- TXN 7: Chloe -> Zoe ($80.00 + $1.00 fee)
('TXN_20260815_01', 'ACC_CHLOE',       'DEBIT',    81.0000, '2026-08-15 13:20:00'),
('TXN_20260815_01', 'ACC_ZOE',         'CREDIT',   80.0000, '2026-08-15 13:20:00'),
('TXN_20260815_01', 'ACC_SYS_REVENUE', 'CREDIT',    1.0000, '2026-08-15 13:20:00'),

-- Rapid Velocity Sequence (David sending 3 fast transfers under 3 minutes)
-- TXN 9: David -> Chloe ($50.00 + $1.00 fee)
('TXN_20260817_01', 'ACC_DAVID',       'DEBIT',    51.0000, '2026-08-17 18:00:00'),
('TXN_20260817_01', 'ACC_CHLOE',       'CREDIT',   50.0000, '2026-08-17 18:00:00'),
('TXN_20260817_01', 'ACC_SYS_REVENUE', 'CREDIT',    1.0000, '2026-08-17 18:00:00'),

-- TXN 10: David -> Tariq ($60.00 + $1.00 fee)
('TXN_20260817_02', 'ACC_DAVID',       'DEBIT',    61.0000, '2026-08-17 18:01:15'),
('TXN_20260817_02', 'ACC_TARIQ',       'CREDIT',   60.0000, '2026-08-17 18:01:15'),
('TXN_20260817_02', 'ACC_SYS_REVENUE', 'CREDIT',    1.0000, '2026-08-17 18:01:15'),

-- TXN 11: David -> Elena ($70.00 + $1.00 fee)
('TXN_20260817_03', 'ACC_DAVID',       'DEBIT',    71.0000, '2026-08-17 18:02:10'),
('TXN_20260817_03', 'ACC_ELENA',       'CREDIT',   70.0000, '2026-08-17 18:02:10'),
('TXN_20260817_03', 'ACC_SYS_REVENUE', 'CREDIT',    1.0000, '2026-08-17 18:02:10');
