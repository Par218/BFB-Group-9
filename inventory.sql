-- Inventory Management System - SQLite Database Schema
-- Database: inventory.db

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS stock_updates;
DROP TABLE IF EXISTS invoice_items;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS sales_orders;
DROP TABLE IF EXISTS manufacturing_jobs;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS vendors;
DROP TABLE IF EXISTS product_categories;

-- Create product_categories table
CREATE TABLE product_categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name TEXT NOT NULL UNIQUE,
    category_description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create vendors table (for vendor registration and management)
CREATE TABLE vendors (
    vendor_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    business_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    address TEXT,
    password TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create customers table
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku TEXT UNIQUE NOT NULL,
    product_name TEXT NOT NULL,
    category_id INTEGER,
    quantity INTEGER NOT NULL DEFAULT 0,
    price REAL NOT NULL CHECK (price >= 0),
    cost_price REAL,
    description TEXT,
    supplier TEXT,
    min_stock_level INTEGER DEFAULT 0,
    max_stock_level INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
);

-- Create invoices table
CREATE TABLE invoices (
    invoice_id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_number TEXT UNIQUE NOT NULL,
    customer_id INTEGER,
    total_amount REAL DEFAULT 0,
    status TEXT DEFAULT 'draft',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Create invoice_items table
CREATE TABLE invoice_items (
    item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price REAL,
    total_price REAL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Create manufacturing_jobs table
CREATE TABLE manufacturing_jobs (
    job_id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_number TEXT UNIQUE NOT NULL,
    product_id INTEGER,
    quantity INTEGER NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    start_date DATETIME,
    due_date DATETIME,
    progress_percentage INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Create sales_orders table
CREATE TABLE sales_orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_number TEXT UNIQUE NOT NULL,
    customer_id INTEGER,
    total_amount REAL DEFAULT 0,
    status TEXT NOT NULL CHECK (status IN ('draft', 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE stock_updates (
    update_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    vendor_id INTEGER NOT NULL,
    update_type TEXT NOT NULL CHECK (update_type IN ('add', 'remove', 'set')),
    quantity_change INTEGER NOT NULL,
    old_quantity INTEGER NOT NULL,
    new_quantity INTEGER NOT NULL,
    reason TEXT NOT NULL CHECK (reason IN ('restock', 'sale', 'damage', 'return', 'adjustment', 'other')),
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id)
);

-- Insert sample categories
INSERT INTO product_categories (category_name, category_description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books and publications'),
('Food & Beverages', 'Food and drink products'),
('Tools & Hardware', 'Tools and hardware supplies'),
('Furniture', 'Furniture and home items'),
('Beauty & Health', 'Beauty and health products'),
('Sports & Outdoors', 'Sports equipment and outdoor gear'),
('Other', 'Miscellaneous items');

-- Insert sample vendor
INSERT INTO vendors (first_name, last_name, business_name, email, phone, address, password) VALUES
('John', 'Doe', 'TechStore Solutions', 'john.doe@techstore.com', '+1-555-0123', '123 Business Ave, Commerce City, CC 12345', 'password123');

-- Insert sample customers
INSERT INTO customers (name, email, phone, address) VALUES
('ABC Corporation', 'contact@abccorp.com', '+1-555-0101', '123 Business Street, New York, NY 10001'),
('Jane Smith', 'jane.smith@email.com', '+1-555-0102', '456 Oak Avenue, Los Angeles, CA 90210'),
('Bob Johnson', 'bob.johnson@email.com', '+1-555-0103', '789 Pine Road, Chicago, IL 60601');

-- Insert sample products with corresponding categories
INSERT INTO products (sku, product_name, category_id, quantity, price, cost_price, description, supplier, min_stock_level, max_stock_level) VALUES
('ELEC-001', 'Samsung Galaxy S23', 1, 25, 899.99, 650.00, 'Latest Samsung smartphone with advanced camera features', 'Samsung Electronics', 5, 50),
('ELEC-002', 'iPhone 14 Pro', 1, 15, 999.00, 750.00, 'Apple iPhone 14 Pro with ProRAW and ProRes capabilities', 'Apple Inc.', 3, 40),
('ACC-001', 'AirPods Pro', 1, 30, 249.00, 180.00, 'Apple AirPods Pro with active noise cancellation', 'Apple Inc.', 5, 30),
('CLOTH-001', 'Nike Air Max', 2, 50, 120.00, 80.00, 'Nike Air Max running shoes, size 10', 'Nike Inc.', 10, 100),
('BOOK-001', 'JavaScript: The Definitive Guide', 3, 45, 45.99, 30.00, 'Comprehensive guide to JavaScript programming', 'OReilly Media', 10, 200),
('TOOL-001', 'Cordless Drill Set', 5, 18, 89.99, 60.00, 'Professional cordless drill with multiple bits', 'DeWalt Tools', 5, 50),
('FURN-001', 'Office Chair', 6, 12, 199.99, 120.00, 'Ergonomic office chair with lumbar support', 'Office Furniture Co', 3, 25),
('BEAU-001', 'Moisturizing Cream', 7, 30, 24.99, 15.00, 'Daily moisturizing cream for all skin types', 'Beauty Supplies Ltd', 15, 100),
('SPORT-001', 'Yoga Mat', 8, 20, 39.99, 25.00, 'Premium quality non-slip yoga mat', 'Fitness World', 10, 75),
('FOOD-001', 'Organic Coffee Beans', 4, 50, 18.99, 12.00, 'Premium organic coffee beans, 1lb bag', 'Organic Farms', 20, 200);

-- Insert sample invoices
INSERT INTO invoices (invoice_number, customer_id, total_amount, status) VALUES
('INV-202401-001', 1, 15420.50, 'paid'),
('INV-202401-002', 2, 2450.00, 'paid'),
('INV-202401-003', 3, 899.99, 'pending');

-- Insert sample invoice items
INSERT INTO invoice_items (invoice_id, product_id, quantity, unit_price, total_price) VALUES
(1, 1, 10, 899.99, 8999.90),
(1, 2, 5, 999.00, 4995.00),
(1, 3, 8, 249.00, 1992.00),
(2, 4, 15, 120.00, 1800.00),
(2, 5, 10, 45.99, 459.90),
(3, 6, 2, 89.99, 179.98),
(3, 7, 3, 199.99, 599.97);

-- Insert sample manufacturing jobs
INSERT INTO manufacturing_jobs (job_number, product_id, quantity, status, start_date, due_date, progress_percentage) VALUES
('JOB-202401-001', 1, 50, 'completed', '2024-01-01', '2024-01-15', 100),
('JOB-202401-002', 2, 30, 'in_progress', '2024-01-10', '2024-01-25', 65),
('JOB-202401-003', 3, 100, 'scheduled', '2024-01-20', '2024-02-05', 0);

-- Insert sample sales orders
INSERT INTO sales_orders (order_number, customer_id, total_amount, status) VALUES
('ORD-202401-001', 1, 15420.50, 'delivered'),
('ORD-202401-002', 2, 2450.00, 'confirmed'),
('ORD-202401-003', 3, 899.99, 'pending'),
('ORD-202401-004', 1, 3200.00, 'shipped'),
('ORD-202401-005', 2, 1500.00, 'pending');

-- Insert sample stock updates
INSERT INTO stock_updates (product_id, vendor_id, update_type, quantity_change, old_quantity, new_quantity, reason, notes) VALUES
(1, 1, 'add', 10, 15, 25, 'restock', 'Received new shipment from Samsung'),
(3, 1, 'remove', 2, 32, 30, 'sale', 'Sold 2 units to walk-in customer'),
(2, 1, 'remove', 1, 16, 15, 'sale', 'Online order #12345'),
(4, 1, 'add', 20, 30, 50, 'restock', 'Monthly shoe inventory replenishment'),
(5, 1, 'add', 15, 30, 45, 'restock', 'Book store order received'),
(6, 1, 'remove', 2, 20, 18, 'sale', 'Contractor bulk order #67890'),
(7, 1, 'add', 5, 7, 12, 'restock', 'Office furniture restock order');
