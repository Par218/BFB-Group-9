-- Inventory Hub ERP System 

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Drop tables in correct order
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Shipment;
DROP TABLE IF EXISTS Sales_Order;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Manufacturing_Job;
DROP TABLE IF EXISTS Marketing_Campaign;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS SME_Company;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS User;

-- Create tables
CREATE TABLE User (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type VARCHAR(20) NOT NULL CHECK(user_type IN ('employee', 'customer', 'sme_company')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Customer (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

CREATE TABLE Employee (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

CREATE TABLE SME_Company (
    company_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    industry VARCHAR(50),
    contact_person VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

CREATE TABLE Location (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    address_line1 VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20),
    country VARCHAR(50) NOT NULL,
    location_type VARCHAR(20) NOT NULL CHECK(location_type IN ('warehouse', 'customer', 'supplier', 'office'))
);

CREATE TABLE Product (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    unit_of_measurement VARCHAR(20) NOT NULL
);

CREATE TABLE Sales_Order (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER,
    company_id INTEGER,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(20) DEFAULT 'pending' CHECK(order_status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    total_amount DECIMAL(10,2) NOT NULL,
    shipping_address_id INTEGER NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (company_id) REFERENCES SME_Company(company_id),
    FOREIGN KEY (shipping_address_id) REFERENCES Location(location_id)
);

CREATE TABLE Order_Items (
    order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Sales_Order(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Inventory (
    inventory_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    quantity_on_hand INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE Shipment (
    shipment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shipment_number VARCHAR(50) UNIQUE NOT NULL,
    order_id INTEGER NOT NULL,
    shipment_date DATETIME,
    shipment_status VARCHAR(20) DEFAULT 'pending' CHECK(shipment_status IN ('pending', 'in_transit', 'delivered', 'cancelled')),
    tracking_number VARCHAR(100),
    FOREIGN KEY (order_id) REFERENCES Sales_Order(order_id)
);

CREATE TABLE Manufacturing_Job (
    job_id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_number VARCHAR(50) UNIQUE NOT NULL,
    product_id INTEGER NOT NULL,
    planned_quantity INTEGER NOT NULL,
    start_date DATETIME,
    due_date DATETIME NOT NULL,
    status VARCHAR(20) DEFAULT 'scheduled' CHECK(status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    progress_percentage INTEGER DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Insert sample data
INSERT INTO User (username, email, password_hash, user_type) VALUES
('admin', 'admin@inventoryhub.com', 'hashed_password_1', 'employee'),
('johndoe', 'john.doe@email.com', 'hashed_password_2', 'customer'),
('abccorp', 'contact@abccorp.com', 'hashed_password_3', 'sme_company'),
('janedoe', 'jane.doe@email.com', 'hashed_password_4', 'customer');

INSERT INTO Employee (user_id, first_name, last_name, position) VALUES
(1, 'Admin', 'User', 'System Administrator');

INSERT INTO Customer (user_id, first_name, last_name, phone_number) VALUES
(2, 'John', 'Doe', '+1234567890'),
(4, 'Jane', 'Doe', '+0987654321');

INSERT INTO SME_Company (user_id, company_name, industry, contact_person) VALUES
(3, 'ABC Industries', 'Manufacturing', 'Bob Smith');

INSERT INTO Location (address_line1, city, postal_code, country, location_type) VALUES
('123 Main St', 'Johannesburg', '2000', 'South Africa', 'warehouse'),
('456 Oak Ave', 'Cape Town', '8000', 'South Africa', 'customer'),
('789 Factory Rd', 'Durban', '4000', 'South Africa', 'warehouse');

INSERT INTO Product (sku, product_name, category, unit_price, cost_price, unit_of_measurement) VALUES
('SKU-001', 'Cream Donut', 'Donuts', 15.00, 8.00, 'unit'),
('SKU-002', 'Chocolate Chip Cookie', 'Cookies', 10.00, 5.00, 'unit'),
('SKU-003', 'Whole Wheat Bread', 'Bread', 25.00, 12.00, 'loaf');

INSERT INTO Inventory (product_id, location_id, quantity_on_hand) VALUES
(1, 1, 50),
(2, 1, 75),
(3, 3, 30);

INSERT INTO Sales_Order (order_number, customer_id, total_amount, shipping_address_id) VALUES
('ORD-001', 1, 150.00, 2),
('ORD-002', 2, 200.00, 2);

INSERT INTO Order_Items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 10, 15.00),
(2, 2, 20, 10.00);

INSERT INTO Shipment (shipment_number, order_id, tracking_number) VALUES
('SHIP-001', 1, 'TRK123456'),
('SHIP-002', 2, 'TRK789012');

INSERT INTO Manufacturing_Job (job_number, product_id, planned_quantity, due_date, status, progress_percentage) VALUES
('JOB-001', 1, 100, '2024-02-01', 'in_progress', 25),
('JOB-002', 3, 50, '2024-02-15', 'scheduled', 0);

-- Create essential views for dashboards
CREATE VIEW Logistics_Dashboard AS
SELECT 
    s.shipment_id,
    s.shipment_number,
    so.order_number,
    s.shipment_status,
    s.shipment_date,
    s.tracking_number,
    c.first_name || ' ' || c.last_name as customer_name
FROM Shipment s
JOIN Sales_Order so ON s.order_id = so.order_id
LEFT JOIN Customer c ON so.customer_id = c.customer_id;

CREATE VIEW Manufacturing_Dashboard AS
SELECT 
    mj.job_id,
    mj.job_number,
    p.product_name,
    mj.planned_quantity,
    mj.start_date,
    mj.due_date,
    mj.status,
    mj.progress_percentage
FROM Manufacturing_Job mj
JOIN Product p ON mj.product_id = p.product_id;

CREATE VIEW SalesMarketing_Dashboard AS
SELECT 
    so.order_id,
    so.order_number,
    so.order_date,
    so.total_amount,
    so.order_status,
    COALESCE(c.first_name || ' ' || c.last_name, sme.company_name) as customer_name
FROM Sales_Order so
LEFT JOIN Customer c ON so.customer_id = c.customer_id
LEFT JOIN SME_Company sme ON so.company_id = sme.company_id;

-- Verification query
SELECT 'Database setup completed successfully' as status;
