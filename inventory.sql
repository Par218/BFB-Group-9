-- Inventory Hub ERP System - SQLite Database Schema
-- Database: inventory_hub.db

PRAGMA foreign_keys = ON;

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

CREATE TABLE Person (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    user_type TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_user_type CHECK (user_type IN ('employee', 'customer', 'sme_company'))
);

CREATE TABLE Customer (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone_number TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Person(user_id) ON DELETE CASCADE
);

CREATE TABLE Employee (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    position TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Person(user_id) ON DELETE CASCADE
);

CREATE TABLE SME_Company (
    company_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    company_name TEXT NOT NULL,
    industry TEXT,
    contact_person TEXT,
    FOREIGN KEY (user_id) REFERENCES Person(user_id) ON DELETE CASCADE
);

CREATE TABLE Location (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    address_line1 TEXT NOT NULL,
    city TEXT NOT NULL,
    postal_code TEXT,
    country TEXT NOT NULL,
    location_type TEXT NOT NULL,
    CONSTRAINT valid_location_type CHECK (location_type IN ('warehouse', 'customer', 'supplier', 'office'))
);

CREATE TABLE Category (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE Units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL UNIQUE
);

CREATE TABLE Product (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku TEXT NOT NULL UNIQUE,
    product_name TEXT NOT NULL,
    category_id INTEGER,
    unit_id INTEGER,
    unit_price REAL NOT NULL CHECK(unit_price > 0),
    cost_price REAL NOT NULL CHECK(cost_price > 0),
    selling_price REAL CHECK(selling_price > 0),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE RESTRICT,
    FOREIGN KEY (unit_id) REFERENCES Units(unit_id) ON DELETE RESTRICT
);

CREATE TABLE Sales_Order (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_number TEXT NOT NULL UNIQUE,
    customer_id INTEGER,
    company_id INTEGER,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    order_status TEXT NOT NULL DEFAULT 'pending' CHECK(order_status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    total_amount REAL NOT NULL CHECK(total_amount >= 0),
    shipping_address_id INTEGER NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE SET NULL,
    FOREIGN KEY (company_id) REFERENCES SME_Company(company_id) ON DELETE SET NULL,
    FOREIGN KEY (shipping_address_id) REFERENCES Location(location_id)
);

CREATE TABLE Order_Items (
    order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    unit_price REAL NOT NULL CHECK(unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES Sales_Order(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE RESTRICT
);

CREATE TABLE Inventory (
    inventory_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    quantity_on_hand INTEGER NOT NULL DEFAULT 0 CHECK(quantity_on_hand >= 0),
    shelf_location TEXT,
    status TEXT NOT NULL DEFAULT 'In Stock',
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE Shipment (
    shipment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shipment_number TEXT NOT NULL UNIQUE,
    order_id INTEGER NOT NULL,
    shipment_date DATETIME,
    shipment_status TEXT NOT NULL DEFAULT 'pending' CHECK(shipment_status IN ('pending', 'in_transit', 'delivered', 'cancelled')),
    tracking_number TEXT,
    FOREIGN KEY (order_id) REFERENCES Sales_Order(order_id)
);

CREATE TABLE Manufacturing_Job (
    job_id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_number TEXT NOT NULL UNIQUE,
    product_id INTEGER NOT NULL,
    planned_quantity INTEGER NOT NULL CHECK(planned_quantity > 0),
    start_date DATETIME,
    due_date DATETIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled' CHECK(status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    progress_percentage INTEGER NOT NULL DEFAULT 0 CHECK(progress_percentage BETWEEN 0 AND 100),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

INSERT INTO Category (category_name) VALUES 
('Donuts'), ('Cookies'), ('Cakes'), ('Bread');

INSERT INTO Units (unit_name) VALUES 
('R/unit'), ('R/kg'), ('R/ton');

INSERT INTO Person (username, email, password_hash, user_type) VALUES
('admin', 'admin@inventoryhub.com', 'hashed_password_1', 'employee'),
('johndoe', 'john.doe@email.com', 'hashed_password_2', 'customer'),
('janedoe', 'jane.doe@email.com', 'hashed_password_3', 'customer'),
('abccorp', 'contact@abccorp.com', 'hashed_password_4', 'sme_company'),
('electriccorp', 'info@electriccorp.com', 'hashed_password_5', 'sme_company');

INSERT INTO Employee (user_id, first_name, last_name, position) VALUES
((SELECT user_id FROM Person WHERE username='admin'), 'Admin', 'User', 'System Administrator');

INSERT INTO Customer (user_id, first_name, last_name, phone_number) VALUES
((SELECT user_id FROM Person WHERE username='johndoe'), 'John', 'Doe', '+27111234567'),
((SELECT user_id FROM Person WHERE username='janedoe'), 'Jane', 'Doe', '+27119876543');

INSERT INTO SME_Company (user_id, company_name, industry, contact_person) VALUES
((SELECT user_id FROM Person WHERE username='abccorp'), 'ABC Industries', 'Manufacturing', 'Bob Smith'),
((SELECT user_id FROM Person WHERE username='electriccorp'), 'Electric Corp', 'Electronics', 'Sarah Johnson');

INSERT INTO Location (address_line1, city, postal_code, country, location_type) VALUES
('123 Warehouse St', 'Johannesburg', '2000', 'South Africa', 'warehouse'),
('456 Customer Ave', 'Cape Town', '8000', 'South Africa', 'customer'),
('789 Industrial Rd', 'Durban', '4000', 'South Africa', 'warehouse');

INSERT INTO Product (sku, product_name, category_id, unit_id, unit_price, cost_price, selling_price) VALUES
('SKU-001', 'Cream Donut', (SELECT category_id FROM Category WHERE category_name='Donuts'), (SELECT unit_id FROM Units WHERE unit_name='R/unit'), 15.00, 8.00, 18.00),
('SKU-002', 'Chocolate Chip', (SELECT category_id FROM Category WHERE category_name='Cookies'), (SELECT unit_id FROM Units WHERE unit_name='R/unit'), 10.00, 5.00, 12.00),
('SKU-003', 'Vanilla Cake', (SELECT category_id FROM Category WHERE category_name='Cakes'), (SELECT unit_id FROM Units WHERE unit_name='R/unit'), 25.00, 12.00, 30.00),
('SKU-004', 'Whole Wheat Bread', (SELECT category_id FROM Category WHERE category_name='Bread'), (SELECT unit_id FROM Units WHERE unit_name='R/unit'), 20.00, 10.00, 24.00);

INSERT INTO Inventory (product_id, location_id, quantity_on_hand, shelf_location, status) VALUES
((SELECT product_id FROM Product WHERE sku='SKU-001'), 1, 25, 'A1', 'In Stock'),
((SELECT product_id FROM Product WHERE sku='SKU-002'), 1, 8, 'B2', 'Low Stock'),
((SELECT product_id FROM Product WHERE sku='SKU-003'), 1, 0, 'C3', 'Out of Stock'),
((SELECT product_id FROM Product WHERE sku='SKU-004'), 1, 15, 'D4', 'In Stock'),
((SELECT product_id FROM Product WHERE sku='SKU-001'), 3, 30, 'E1', 'In Stock'),
((SELECT product_id FROM Product WHERE sku='SKU-002'), 3, 5, 'F2', 'Low Stock');

-- Get correct customer/company IDs for orders
INSERT INTO Sales_Order (order_number, customer_id, company_id, order_status, total_amount, shipping_address_id) VALUES
('ORD-001', (SELECT customer_id FROM Customer WHERE user_id=(SELECT user_id FROM Person WHERE username='johndoe')), NULL, 'delivered', 50.00, 2),  
('ORD-002', NULL, (SELECT company_id FROM SME_Company WHERE user_id=(SELECT user_id FROM Person WHERE username='abccorp')), 'pending', 200.00, 2),    
('ORD-003', (SELECT customer_id FROM Customer WHERE user_id=(SELECT user_id FROM Person WHERE username='janedoe')), NULL, 'cancelled', 50.00, 2);   

-- Get correct order/product IDs for order items
INSERT INTO Order_Items (order_id, product_id, quantity, unit_price) VALUES
((SELECT order_id FROM Sales_Order WHERE order_number='ORD-001'), (SELECT product_id FROM Product WHERE sku='SKU-001'), 2, 15.00),
((SELECT order_id FROM Sales_Order WHERE order_number='ORD-001'), (SELECT product_id FROM Product WHERE sku='SKU-002'), 2, 10.00),
((SELECT order_id FROM Sales_Order WHERE order_number='ORD-002'), (SELECT product_id FROM Product WHERE sku='SKU-002'), 20, 10.00),
((SELECT order_id FROM Sales_Order WHERE order_number='ORD-003'), (SELECT product_id FROM Product WHERE sku='SKU-001'), 2, 15.00),
((SELECT order_id FROM Sales_Order WHERE order_number='ORD-003'), (SELECT product_id FROM Product WHERE sku='SKU-002'), 2, 10.00);

INSERT INTO Shipment (shipment_number, order_id, shipment_status, tracking_number) VALUES
('SHIP-001', (SELECT order_id FROM Sales_Order WHERE order_number='ORD-001'), 'delivered', 'TRK123456'),
('SHIP-002', (SELECT order_id FROM Sales_Order WHERE order_number='ORD-002'), 'pending', 'TRK789012');

INSERT INTO Manufacturing_Job (job_number, product_id, planned_quantity, due_date, status, progress_percentage) VALUES
('JOB-001', (SELECT product_id FROM Product WHERE sku='SKU-001'), 100, '2024-02-01', 'in_progress', 25),
('JOB-002', (SELECT product_id FROM Product WHERE sku='SKU-003'), 50, '2024-02-15', 'scheduled', 0),
('JOB-003', (SELECT product_id FROM Product WHERE sku='SKU-002'), 200, '2024-02-10', 'completed', 100);
