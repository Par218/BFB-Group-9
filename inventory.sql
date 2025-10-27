-- Inventory Hub ERP System - SQLite Database Schema
-- Database: inventory_hub.db

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Shipment;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Manufacturing_Job;
DROP TABLE IF EXISTS Sales_Order;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS SME_Company;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Units;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Person;

-- Create Person table
CREATE TABLE Person (
    person_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    user_type TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_user_type CHECK (user_type IN ('employee', 'customer', 'sme_company'))
);

-- Create Customer table
CREATE TABLE Customer (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    person_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone_number TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE
);

-- Create Employee table
CREATE TABLE Employee (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    person_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    position TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE
);

-- Create SME_Company table
CREATE TABLE SME_Company (
    company_id INTEGER PRIMARY KEY AUTOINCREMENT,
    person_id INTEGER NOT NULL,
    company_name TEXT NOT NULL,
    industry TEXT,
    contact_person TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE
);

-- Create Location table
CREATE TABLE Location (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    address_line1 TEXT NOT NULL,
    city TEXT NOT NULL,
    postal_code TEXT,
    country TEXT NOT NULL,
    location_type TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_location_type CHECK (location_type IN ('warehouse', 'customer', 'supplier', 'office'))
);

-- Create Category lookup table 
CREATE TABLE Category (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name TEXT NOT NULL UNIQUE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Create Units lookup table  
CREATE TABLE Units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL UNIQUE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Create Product table
CREATE TABLE Product (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku TEXT NOT NULL UNIQUE,
    product_name TEXT NOT NULL,
    description TEXT,
    category_id INTEGER,
    unit_id INTEGER,
    unit_price REAL NOT NULL CHECK(unit_price > 0),
    cost_price REAL NOT NULL CHECK(cost_price > 0),
    selling_price REAL CHECK(selling_price > 0),
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Category(category_id),
    FOREIGN KEY (unit_id) REFERENCES Units(unit_id)
);

-- Create Sales_Order table
CREATE TABLE Sales_Order (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_number TEXT NOT NULL UNIQUE,
    customer_id INTEGER,
    company_id INTEGER,
    order_date TEXT DEFAULT CURRENT_TIMESTAMP,
    order_status TEXT NOT NULL DEFAULT 'pending',
    total_amount REAL NOT NULL CHECK(total_amount >= 0),
    shipping_address_id INTEGER NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_order_status CHECK (order_status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE SET NULL,
    FOREIGN KEY (company_id) REFERENCES SME_Company(company_id) ON DELETE SET NULL,
    FOREIGN KEY (shipping_address_id) REFERENCES Location(location_id)
);

-- Create Order_Items table
CREATE TABLE Order_Items (
    order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    unit_price REAL NOT NULL CHECK(unit_price >= 0),
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Sales_Order(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Create Inventory table
CREATE TABLE Inventory (
    inventory_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    quantity_on_hand INTEGER NOT NULL DEFAULT 0 CHECK(quantity_on_hand >= 0),
    shelf_location TEXT,
    status TEXT NOT NULL DEFAULT 'In Stock',
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_inventory_status CHECK (status IN ('In Stock', 'Low Stock', 'Out of Stock', 'Reserved')),
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- Create Shipment table
CREATE TABLE Shipment (
    shipment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shipment_number TEXT NOT NULL UNIQUE,
    order_id INTEGER NOT NULL,
    shipment_date TEXT,
    shipment_status TEXT NOT NULL DEFAULT 'pending',
    tracking_number TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_shipment_status CHECK (shipment_status IN ('pending', 'in_transit', 'delivered', 'cancelled')),
    FOREIGN KEY (order_id) REFERENCES Sales_Order(order_id)
);

-- Create Manufacturing_Job table
CREATE TABLE Manufacturing_Job (
    job_id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_number TEXT NOT NULL UNIQUE,
    product_id INTEGER NOT NULL,
    planned_quantity INTEGER NOT NULL CHECK(planned_quantity > 0),
    start_date TEXT,
    due_date TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled',
    progress_percentage INTEGER NOT NULL DEFAULT 0 CHECK(progress_percentage BETWEEN 0 AND 100),
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_job_status CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);


-- Insert Categories
INSERT INTO Category (category_name) VALUES 
('Donuts'), ('Cookies'), ('Cakes'), ('Bread'),
('Beverages'), ('Pastries'), ('Sandwiches');

-- Insert Units
INSERT INTO Units (unit_name) VALUES 
('R/unit'), ('R/kg'), ('R/ton'),
('R/liter'), ('R/box'), ('R/pack');

-- Insert Person records
INSERT INTO Person (username, email, password_hash, user_type) VALUES
('admin', 'admin@inventoryhub.com', 'hashed_password_1', 'employee'),
('johndoe', 'john.doe@email.com', 'hashed_password_2', 'customer'),
('janedoe', 'jane.doe@email.com', 'hashed_password_3', 'customer'),
('abccorp', 'contact@abccorp.com', 'hashed_password_4', 'sme_company'),
('electriccorp', 'info@electriccorp.com', 'hashed_password_5', 'sme_company');

-- Insert Employees
INSERT INTO Employee (person_id, first_name, last_name, position) VALUES
(1, 'Admin', 'User', 'System Administrator');

-- Insert Customers 
INSERT INTO Customer (person_id, first_name, last_name, phone_number) VALUES
(2, 'John', 'Doe', '+27111234567'),
(3, 'Jane', 'Doe', '+27119876543');

-- Insert SME Companies 
INSERT INTO SME_Company (person_id, company_name, industry, contact_person) VALUES
(4, 'ABC Industries', 'Manufacturing', 'Bob Smith'),
(5, 'Electric Corp', 'Electronics', 'Sarah Johnson');

-- Insert Locations
INSERT INTO Location (address_line1, city, postal_code, country, location_type) VALUES
('123 Warehouse St', 'Johannesburg', '2000', 'South Africa', 'warehouse'),
('456 Customer Ave', 'Cape Town', '8000', 'South Africa', 'customer'),
('789 Industrial Rd', 'Durban', '4000', 'South Africa', 'warehouse'),
('101 Office Park', 'Pretoria', '0001', 'South Africa', 'office');

-- Insert Products
INSERT INTO Product (sku, product_name, description, category_id, unit_id, unit_price, cost_price, selling_price) VALUES
('SKU-001', 'Cream Donut', 'Fresh cream filled donut', 
 (SELECT category_id FROM Category WHERE category_name = 'Donuts'),
 (SELECT unit_id FROM Units WHERE unit_name = 'R/unit'),
 15.00, 8.00, 18.00),

('SKU-002', 'Chocolate Chip Cookie', 'Classic chocolate chip cookie', 
 (SELECT category_id FROM Category WHERE category_name = 'Cookies'),
 (SELECT unit_id FROM Units WHERE unit_name = 'R/unit'),
 10.00, 5.00, 12.00),

('SKU-003', 'Vanilla Cake', 'Moist vanilla sponge cake', 
 (SELECT category_id FROM Category WHERE category_name = 'Cakes'),
 (SELECT unit_id FROM Units WHERE unit_name = 'R/unit'),
 25.00, 12.00, 30.00),

('SKU-004', 'Whole Wheat Bread', 'Healthy whole wheat bread', 
 (SELECT category_id FROM Category WHERE category_name = 'Bread'),
 (SELECT unit_id FROM Units WHERE unit_name = 'R/unit'),
 20.00, 10.00, 24.00);

-- Insert Inventory 
INSERT INTO Inventory (product_id, location_id, quantity_on_hand, reorder_level, shelf_location, status) VALUES
(1, 1, 25, 10, 'A1', 'In Stock'),
(2, 1, 8, 15, 'B2', 'Low Stock'),
(3, 1, 0, 5, 'C3', 'Out of Stock'),
(4, 1, 15, 8, 'D4', 'In Stock'),
(1, 3, 30, 10, 'E1', 'In Stock'),
(2, 3, 5, 15, 'F2', 'Low Stock');

-- Insert Sales Orders 
INSERT INTO Sales_Order (order_number, customer_id, company_id, order_status, total_amount, shipping_address_id) VALUES
('ORD-001', 1, NULL, 'delivered', 50.00, 2),  
('ORD-002', NULL, 1, 'pending', 200.00, 2),    
('ORD-003', 2, NULL, 'cancelled', 50.00, 2);   

-- Insert Order Items
INSERT INTO Order_Items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 2, 15.00),
(1, 2, 2, 10.00),
(2, 2, 20, 10.00),
(3, 1, 2, 15.00),
(3, 2, 2, 10.00);

-- Insert Shipments
INSERT INTO Shipment (shipment_number, order_id, shipment_status, tracking_number) VALUES
('SHIP-001', 1, 'delivered', 'TRK123456'),
('SHIP-002', 2, 'pending', 'TRK789012');

-- Insert Manufacturing Jobs
INSERT INTO Manufacturing_Job (job_number, product_id, planned_quantity, due_date, status, progress_percentage) VALUES
('JOB-001', 1, 100, '2024-02-01 00:00:00', 'in_progress', 25),
('JOB-002', 3, 50, '2024-02-15 00:00:00', 'scheduled', 0),
('JOB-003', 2, 200, '2024-02-10 00:00:00', 'completed', 100);

