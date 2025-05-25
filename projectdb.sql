-- 1. Gammu SMS inbox table (used by Gammu)
CREATE TABLE inbox (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    SenderNumber VARCHAR(20),
    TextDecoded TEXT,
    ReceivingDateTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    Processed ENUM('false','true') DEFAULT 'false'
);

-- 2. Packages
CREATE TABLE packages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    amount DECIMAL(10,2),
    duration_minutes INT
);

-- 3. Users (can be linked by phone number or MAC address)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone VARCHAR(20) UNIQUE,
    mac_address VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Payments (parsed SMSes)
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    transaction_id VARCHAR(100) UNIQUE,
    amount DECIMAL(10,2),
    received_at DATETIME,
    package_id INT,
    valid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (package_id) REFERENCES packages(id)
);

-- 5. Access Sessions (optional, for tracking usage)
CREATE TABLE sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    start_time DATETIME,
    end_time DATETIME,
    active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
