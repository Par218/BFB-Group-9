-- Supply Chain Management System - SQLite Database Schema
-- Aligned with HTML department structure
PRAGMA foreign_keys = ON;

-- Drop tables if they exist
DROP TABLE IF EXISTS stock_movements;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS campaigns;
DROP TABLE IF EXISTS sales_leads;
DROP TABLE IF EXISTS manufacturing_jobs;

-- Create users table
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('logistics', 'sales_marketing', 'manufacturing', 'inventory', 'admin')),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create suppliers table
CREATE TABLE suppliers (
    supplier_id INTEGER PRIMARY KEY AUTOINCREMENT,
    supplier_name TEXT NOT NULL UNIQUE,
    contact_email TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create products table (for Inventory page)
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku TEXT UNIQUE NOT NULL,
    product_name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    cost_price REAL NOT NULL CHECK (cost_price >= 0),
    selling_price REAL NOT NULL CHECK (selling_price >= 0),
    supplier_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Create inventory table (for Inventory page)
CREATE TABLE inventory (
    inventory_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    location TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    min_stock_level INTEGER DEFAULT 10,
    max_stock_level INTEGER DEFAULT 100,
    status TEXT DEFAULT 'In Stock' CHECK (status IN ('In Stock', 'Low Stock', 'Out of Stock')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Create campaigns table (for Sales & Marketing page)
CREATE TABLE campaigns (
    campaign_id INTEGER PRIMARY KEY AUTOINCREMENT,
    campaign_name TEXT NOT NULL,
    campaign_type TEXT NOT NULL CHECK (campaign_type IN ('Digital', 'Print', 'Event', 'Social Media')),
    status TEXT NOT NULL CHECK (status IN ('Active', 'Paused', 'Completed')),
    budget REAL NOT NULL,
    reach INTEGER DEFAULT 0,
    conversions INTEGER DEFAULT 0,
    roi REAL DEFAULT 0,
    start_date DATE,
    end_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create sales_leads table (for Sales & Marketing page)
CREATE TABLE sales_leads (
    lead_id INTEGER PRIMARY KEY AUTOINCREMENT,
    lead_name TEXT NOT NULL,
    company TEXT,
    email TEXT,
    phone TEXT,
    status TEXT NOT NULL CHECK (status IN ('New', 'Contacted', 'Qualified', 'Proposal', 'Closed')),
    value REAL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create manufacturing_jobs table (for Manufacturing page)
CREATE TABLE manufacturing_jobs (
    job_id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_number TEXT UNIQUE NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'On Hold')),
    start_date DATE,
    end_date DATE,
    capacity_utilization INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Create orders table
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_number TEXT UNIQUE NOT NULL,
    user_id INTEGER NOT NULL,
    total_amount REAL NOT NULL DEFAULT 0,
    status TEXT NOT NULL CHECK (status IN ('Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled')),
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Create shipments table (for Logistics page)
CREATE TABLE shipments (
    shipment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    shipment_number TEXT UNIQUE NOT NULL,
    order_id INTEGER NOT NULL,
    carrier TEXT,
    tracking_number TEXT,
    status TEXT NOT NULL CHECK (status IN ('Dispatched', 'In Transit', 'Delivered', 'Delayed')),
    origin TEXT,
    destination TEXT,
    estimated_delivery DATE,
    actual_delivery DATE,
    driver_name TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Create stock_movements table
CREATE TABLE stock_movements (
    movement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    movement_type TEXT NOT NULL CHECK (movement_type IN ('IN', 'OUT')),
    quantity INTEGER NOT NULL,
    reason TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample data that matches your HTML structure

-- Users for different departments
INSERT INTO users (username, email, password_hash, role, first_name, last_name, phone) VALUES
('logistics_manager', 'logistics@erp.com', 'hashed_pass', 'logistics', 'John', 'Doe', '+1-555-0101'),
('sales_rep', 'sales@erp.com', 'hashed_pass', 'sales_marketing', 'Sarah', 'Smith', '+1-555-0102'),
('manufacturing_head', 'manufacturing@erp.com', 'hashed_pass', 'manufacturing', 'Mike', 'Johnson', '+1-555-0103'),
('inventory_manager', 'inventory@erp.com', 'hashed_pass', 'inventory', 'Emily', 'Davis', '+1-555-0104');

-- Suppliers
INSERT INTO suppliers (supplier_name, contact_email, phone, address) VALUES
('Tech Components Inc', 'orders@techcomponents.com', '+1-555-0201', '123 Industrial Park, Tech City'),
('Raw Materials Co', 'supply@rawmaterials.com', '+1-555-0202', '456 Mining Ave, Resource Town');

-- Products (for Inventory page table)
INSERT INTO products (sku, product_name, description, category, cost_price, selling_price, supplier_id) VALUES
('MB-001', 'Motherboard X1', 'High-performance motherboard', 'Electronics', 450.00, 750.00, 1),
('CPU-001', 'Processor i9-13900', 'Latest generation processor', 'Electronics', 650.00, 950.00, 1),
('RAM-001', 'DDR5 32GB RAM', 'High-speed memory module', 'Electronics', 180.00, 280.00, 1),
('STEEL-001', 'Stainless Steel Sheet', 'Premium stainless steel', 'Raw Materials', 85.00, 120.00, 2);

-- Inventory (matches your Inventory.html table structure)
INSERT INTO inventory (product_id, location, quantity, min_stock_level, max_stock_level, status) VALUES
(1, 'Warehouse A, Section B', 45, 10, 100, 'In Stock'),
(2, 'Warehouse A, Section B', 28, 5, 50, 'In Stock'),
(3, 'Warehouse A, Section C', 3, 25, 200, 'Low Stock'),
(4, 'Warehouse B, Yard Storage', 500, 100, 1000, 'In Stock');

-- Campaigns (for Sales & Marketing page)
INSERT INTO campaigns (campaign_name, campaign_type, status, budget, reach, conversions, roi) VALUES
('Q1 Digital Campaign', 'Digital', 'Active', 5000.00, 15000, 450, 15.5),
('Product Launch Event', 'Event', 'Active', 8000.00, 2000, 120, 8.2),
('Social Media Push', 'Social Media', 'Paused', 3000.00, 50000, 800, 25.1);

-- Sales Leads (for Sales Pipeline in Sales & Marketing page)
INSERT INTO sales_leads (lead_name, company, email, status, value) VALUES
('ABC Corp', 'ABC Corporation', 'purchase@abccorp.com', 'Proposal', 25000.00),
('XYZ Ltd', 'XYZ Limited', 'procurement@xyz.com', 'Qualified', 15000.00),
('Tech Solutions', 'Tech Solutions Inc', 'sales@techsolutions.com', 'Contacted', 18000.00);

-- Manufacturing Jobs (for Manufacturing page)
INSERT INTO manufacturing_jobs (job_number, product_id, quantity, status, capacity_utilization) VALUES
('JOB-2024-001', 1, 100, 'In Progress', 75),
('JOB-2024-002', 2, 50, 'Scheduled', 0),
('JOB-2024-003', 3, 200, 'Completed', 100);

-- Orders
INSERT INTO orders (order_number, user_id, total_amount, status) VALUES
('ORD-001', 2, 12500.00, 'Delivered'),
('ORD-002', 2, 8500.00, 'Shipped'),
('ORD-003', 2, 3200.00, 'Pending');

-- Shipments (for Logistics page)
INSERT INTO shipments (shipment_number, order_id, carrier, tracking_number, status, origin, destination, estimated_delivery, driver_name) VALUES
('SHP-001', 1, 'FedEx', '789012345678', 'Delivered', 'Johannesburg, GP', 'Cape Town, WC', '2024-01-15', 'John Driver'),
('SHP-002', 2, 'UPS', '890123456789', 'In Transit', 'Johannesburg, GP', 'Durban, KZN', '2024-01-18', 'Mike Smith'),
('SHP-003', 3, 'DHL', '901234567890', 'Dispatched', 'Johannesburg, GP', 'Pretoria, GP', '2024-01-20', 'Sarah Johnson');