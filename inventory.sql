-- Inventory Hub ERP System - SQLite Database Schema
-- Database: inventory_hub.db

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Drop tables if they exist (for clean setup)
IF OBJECT_ID('Order_Items', 'U') IS NOT NULL DROP TABLE Order_Items;
IF OBJECT_ID('Shipment', 'U') IS NOT NULL DROP TABLE Shipment;
IF OBJECT_ID('Inventory', 'U') IS NOT NULL DROP TABLE Inventory;
IF OBJECT_ID('Manufacturing_Job', 'U') IS NOT NULL DROP TABLE Manufacturing_Job;
IF OBJECT_ID('Sales_Order', 'U') IS NOT NULL DROP TABLE Sales_Order;
IF OBJECT_ID('Customer', 'U') IS NOT NULL DROP TABLE Customer;
IF OBJECT_ID('Employee', 'U') IS NOT NULL DROP TABLE Employee;
IF OBJECT_ID('SME_Company', 'U') IS NOT NULL DROP TABLE SME_Company;
IF OBJECT_ID('Product', 'U') IS NOT NULL DROP TABLE Product;
IF OBJECT_ID('Category', 'U') IS NOT NULL DROP TABLE Category;
IF OBJECT_ID('Units', 'U') IS NOT NULL DROP TABLE Units;
IF OBJECT_ID('Location', 'U') IS NOT NULL DROP TABLE Location;
IF OBJECT_ID('Person', 'U') IS NOT NULL DROP TABLE Person;

-- Create Person table
CREATE TABLE Person (
    person_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    password_hash NVARCHAR(MAX) NOT NULL,
    user_type NVARCHAR(20) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT valid_user_type CHECK (user_type IN ('Employee', 'Customer', 'SME_Company'))
);

-- Create Customer table
CREATE TABLE Customer (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    person_id INT NOT NULL,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    phone_number NVARCHAR(20),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE
);

-- Create Employee table
CREATE TABLE Employee (
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    person_id INT NOT NULL,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    position NVARCHAR(50) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE
);

-- Create SME_Company table
CREATE TABLE SME_Company (
    company_id INT IDENTITY(1,1) PRIMARY KEY,
    person_id INT NOT NULL,
    company_name NVARCHAR(100) NOT NULL,
    industry NVARCHAR(50),
    contact_person NVARCHAR(100),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE
);

-- Create Location table
CREATE TABLE Location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    address_line1 NVARCHAR(100) NOT NULL,
    address_line2 NVARCHAR(100),
    city NVARCHAR(50) NOT NULL,
    postal_code NVARCHAR(20),
    country NVARCHAR(50) NOT NULL,
    location_type NVARCHAR(20) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT valid_location_type CHECK (location_type IN ('warehouse', 'customer', 'supplier', 'office'))
);

-- Create Category lookup table 
CREATE TABLE Category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(50) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT GETDATE()
);

-- Create Units lookup table  
CREATE TABLE Units (
    unit_id INT IDENTITY(1,1) PRIMARY KEY,
    unit_name NVARCHAR(20) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT GETDATE()
);

-- Create Product table
CREATE TABLE Product (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    sku NVARCHAR(20) NOT NULL UNIQUE,
    product_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    category_id INT,
    unit_id INT,
    unit_price DECIMAL(18,2) NOT NULL,
    cost_price DECIMAL(18,2) NOT NULL,
    selling_price DECIMAL(18,2),
    created_at DATETIME DEFAULT GETDATE(),
    last_updated DATETIME DEFAULT GETDATE(),
    CONSTRAINT chk_unit_price CHECK (unit_price > 0),
    CONSTRAINT chk_cost_price CHECK (cost_price > 0),
    CONSTRAINT chk_selling_price CHECK (selling_price > 0),
    FOREIGN KEY (category_id) REFERENCES Category(category_id),
    FOREIGN KEY (unit_id) REFERENCES Units(unit_id)
);

-- Create Sales_Order table
CREATE TABLE Sales_Order (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    order_number NVARCHAR(20) NOT NULL UNIQUE,
    customer_id INT,
    company_id INT,
    order_date DATETIME DEFAULT GETDATE(),
    order_status NVARCHAR(20) NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(18,2) NOT NULL,
    shipping_address_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0),
    CONSTRAINT valid_order_status CHECK (order_status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE SET NULL,
    FOREIGN KEY (company_id) REFERENCES SME_Company(company_id) ON DELETE SET NULL,
    FOREIGN KEY (shipping_address_id) REFERENCES Location(location_id)
);

-- Create Order_Items table
CREATE TABLE Order_Items (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_unit_price CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES Sales_Order(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Create Inventory table
CREATE TABLE Inventory (
    inventory_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    location_id INT NOT NULL,
    quantity_on_hand INT NOT NULL DEFAULT 0,
    reorder_level INT DEFAULT 0,
    shelf_location NVARCHAR(20),
    status NVARCHAR(20) NOT NULL DEFAULT 'In Stock',
    created_at DATETIME DEFAULT GETDATE(),
    last_updated DATETIME DEFAULT GETDATE(),
    CONSTRAINT chk_quantity_on_hand CHECK (quantity_on_hand >= 0),
    CONSTRAINT valid_inventory_status CHECK (status IN ('In Stock', 'Low Stock', 'Out of Stock', 'Reserved')),
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- Create Shipment table
CREATE TABLE Shipment (
    shipment_id INT IDENTITY(1,1) PRIMARY KEY,
    shipment_number NVARCHAR(20) NOT NULL UNIQUE,
    order_id INT NOT NULL,
    shipment_date DATETIME,
    estimated_delivery DATETIME,
    shipment_status NVARCHAR(20) NOT NULL DEFAULT 'pending',
    tracking_number NVARCHAR(50),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT valid_shipment_status CHECK (shipment_status IN ('pending', 'in_transit', 'delivered', 'cancelled')),
    FOREIGN KEY (order_id) REFERENCES Sales_Order(order_id)
);

-- Create Manufacturing_Job table
CREATE TABLE Manufacturing_Job (
    job_id INT IDENTITY(1,1) PRIMARY KEY,
    job_number NVARCHAR(20) NOT NULL UNIQUE,
    product_id INT NOT NULL,
    planned_quantity INT NOT NULL,
    completed_quantity INT DEFAULT 0,
    start_date DATETIME,
    due_date DATETIME NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'scheduled',
    progress_percentage INT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT chk_planned_quantity CHECK (planned_quantity > 0),
    CONSTRAINT valid_job_status CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    CONSTRAINT valid_progress CHECK (progress_percentage BETWEEN 0 AND 100),
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
('JOB-001', 1, 100, '2024-02-01', 'in_progress', 25),
('JOB-002', 3, 50, '2024-02-15', 'scheduled', 0),
('JOB-003', 2, 200, '2024-02-10', 'completed', 100);
