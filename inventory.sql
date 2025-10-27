-- Database Creation
CREATE DATABASE erp_system;
USE erp_system;

-- SME Company
CREATE TABLE sme_company (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    industry VARCHAR(50),
    location_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Location (Warehouses/Offices)
CREATE TABLE location (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type ENUM('warehouse', 'office', 'store', 'factory'),
    address VARCHAR(255),
    capacity INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add foreign key after location table is created
ALTER TABLE sme_company ADD FOREIGN KEY (location_id) REFERENCES location(location_id);

-- Roles
CREATE TABLE role (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Modules
CREATE TABLE module (
    module_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    enabled TINYINT DEFAULT 1
);

-- Permissions
CREATE TABLE permissions (
    permission_id INT PRIMARY KEY AUTO_INCREMENT,
    can_view TINYINT DEFAULT 0,
    can_edit TINYINT DEFAULT 0,
    can_delete TINYINT DEFAULT 0,
    module_id INT NOT NULL,
    role_id INT NOT NULL,
    FOREIGN KEY (module_id) REFERENCES module(module_id),
    FOREIGN KEY (role_id) REFERENCES role(role_id)
);

-- Users (Base table for Customer, Employee, Developer)
CREATE TABLE user (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type ENUM('customer', 'employee', 'developer') DEFAULT 'customer',
    role_id INT,
    company_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES role(role_id),
    FOREIGN KEY (company_id) REFERENCES sme_company(company_id)
);

-- Customer (extends User)
CREATE TABLE customer (
    user_id INT PRIMARY KEY,
    phone VARCHAR(50),
    address VARCHAR(255),
    social_handle VARCHAR(100),
    credit_limit DECIMAL(15,2) DEFAULT 0,
    payment_terms INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
);

-- Employee (extends User)
CREATE TABLE employee (
    user_id INT PRIMARY KEY,
    position VARCHAR(100),
    salary DECIMAL(15,2),
    hire_date DATE,
    department ENUM('sales', 'manufacturing', 'logistics', 'inventory', 'admin'),
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
);

-- Developer (extends User)
CREATE TABLE developer (
    user_id INT PRIMARY KEY,
    specialization VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
);

-- Categories
CREATE TABLE category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES category(category_id)
);

-- Units
CREATE TABLE unit (
    unit_id INT PRIMARY KEY AUTO_INCREMENT,
    unit_name VARCHAR(50) NOT NULL,
    unit_symbol VARCHAR(10) NOT NULL,
    unit_type ENUM('weight', 'volume', 'piece', 'length') DEFAULT 'piece'
);

-- Products
CREATE TABLE product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    category VARCHAR(50),
    unit VARCHAR(10),
    cost_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    description TEXT,
    min_stock_level INT DEFAULT 0,
    max_stock_level INT DEFAULT 1000,
    company_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES sme_company(company_id)
);

-- Inventory
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    quantity INT NOT NULL DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    product_id INT NOT NULL,
    location_id INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id),
    UNIQUE KEY unique_product_location (product_id, location_id)
);

-- Sales Order
CREATE TABLE sales_order (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_qty INT NOT NULL,
    due_date DATE,
    status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    final_amount DECIMAL(15,2) NOT NULL,
    product_id INT NOT NULL,
    user_id INT NOT NULL, -- customer user_id
    company_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (company_id) REFERENCES sme_company(company_id)
);

-- Production Plan
CREATE TABLE production_plan (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    planned_qty INT NOT NULL,
    prod_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'planned',
    product_id INT NOT NULL,
    employee_user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (employee_user_id) REFERENCES user(user_id)
);

-- Forecast
CREATE TABLE forecast (
    forecast_id INT PRIMARY KEY AUTO_INCREMENT,
    forecast_qty INT NOT NULL,
    forecast_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    product_id INT NOT NULL,
    user_id INT NOT NULL, -- employee user_id
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- Shipment
CREATE TABLE shipment (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    shipped_qty INT NOT NULL,
    ship_date DATE,
    status VARCHAR(20) DEFAULT 'pending',
    tracking_number VARCHAR(100),
    carrier VARCHAR(100),
    estimated_delivery DATE,
    actual_delivery DATE,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    product_id INT NOT NULL,
    location_id INT NOT NULL,
    order_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id),
    FOREIGN KEY (order_id) REFERENCES sales_order(order_id)
);

-- Social Features: Posts
CREATE TABLE post (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    content LONGTEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    company_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (company_id) REFERENCES sme_company(company_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- Comments
CREATE TABLE comment (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    content LONGTEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- Likes
CREATE TABLE like (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    UNIQUE KEY unique_like (post_id, user_id)
);

-- Engagement Report
CREATE TABLE engagement_report (
    metric_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    comments INT DEFAULT 0,
    views INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES post(post_id) ON DELETE CASCADE
);

-- Update comment table to include metric_id after engagement_report is created
ALTER TABLE comment ADD COLUMN metric_id INT;
ALTER TABLE comment ADD FOREIGN KEY (metric_id) REFERENCES engagement_report(metric_id);

-- Notifications
CREATE TABLE notification (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    event VARCHAR(200) NOT NULL,
    severity VARCHAR(20) DEFAULT 'info',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT NOT NULL,
    is_read TINYINT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- Audit Log
CREATE TABLE audit_log (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT NOT NULL,
    record_id INT,
    old_values JSON,
    new_values JSON,
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- Insert Initial Data
INSERT INTO role (role_name, description) VALUES
('admin', 'System administrator with full access'),
('manager', 'Department manager with elevated permissions'),
('employee', 'Regular employee with basic access'),
('customer', 'External customer user');

INSERT INTO module (name, enabled) VALUES
('dashboard', 1),
('inventory', 1),
('sales', 1),
('manufacturing', 1),
('logistics', 1),
('reports', 1),
('social', 1);

INSERT INTO unit (unit_name, unit_symbol, unit_type) VALUES
('Piece', 'pc', 'piece'),
('Kilogram', 'kg', 'weight'),
('Gram', 'g', 'weight'),
('Liter', 'L', 'volume'),
('Meter', 'm', 'length');

INSERT INTO category (category_name, description) VALUES
('Electronics', 'Electronic devices and components'),
('Furniture', 'Office and home furniture'),
('Raw Materials', 'Materials for manufacturing'),
('Finished Goods', 'Completed products for sale');

-- Create indexes for better performance
CREATE INDEX idx_sales_order_status ON sales_order(status);
CREATE INDEX idx_sales_order_due_date ON sales_order(due_date);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_production_plan_dates ON production_plan(prod_date, end_date);
CREATE INDEX idx_forecast_date ON forecast(forecast_date);
CREATE INDEX idx_shipment_status ON shipment(status);
CREATE INDEX idx_user_type ON user(user_type);

-- Create views for common queries
CREATE VIEW vw_inventory_status AS
SELECT 
    p.product_id,
    p.name as product_name,
    p.category,
    l.name as location_name,
    i.quantity,
    p.cost_price,
    (i.quantity * p.cost_price) as inventory_value,
    CASE 
        WHEN i.quantity <= p.min_stock_level THEN 'Low Stock'
        WHEN i.quantity = 0 THEN 'Out of Stock'
        ELSE 'In Stock'
    END as stock_status
FROM inventory i
JOIN product p ON i.product_id = p.product_id
JOIN location l ON i.location_id = l.location_id;

CREATE VIEW vw_sales_production_overview AS
SELECT 
    DATE_FORMAT(so.order_date, '%Y-%m') as month,
    SUM(so.order_qty) as total_sales_qty,
    SUM(so.final_amount) as total_sales_value,
    COALESCE(SUM(pp.planned_qty), 0) as total_production_qty
FROM sales_order so
LEFT JOIN production_plan pp ON DATE_FORMAT(pp.prod_date, '%Y-%m') = DATE_FORMAT(so.order_date, '%Y-%m')
GROUP BY DATE_FORMAT(so.order_date, '%Y-%m');

CREATE VIEW vw_manufacturing_progress AS
SELECT 
    pp.plan_id,
    p.name as product_name,
    pp.planned_qty,
    pp.prod_date,
    pp.end_date,
    pp.status,
    DATEDIFF(pp.end_date, CURDATE()) as days_remaining,
    e.name as assigned_employee
FROM production_plan pp
JOIN product p ON pp.product_id = p.product_id
JOIN user e ON pp.employee_user_id = e.user_id;

CREATE VIEW vw_user_details AS
SELECT 
    u.user_id,
    u.name,
    u.surname,
    u.email,
    u.user_type,
    r.role_name,
    c.name as company_name,
    CASE 
        WHEN u.user_type = 'customer' THEN cust.phone
        WHEN u.user_type = 'employee' THEN emp.position
        WHEN u.user_type = 'developer' THEN dev.specialization
    END as details
FROM user u
LEFT JOIN role r ON u.role_id = r.role_id
LEFT JOIN sme_company c ON u.company_id = c.company_id
LEFT JOIN customer cust ON u.user_id = cust.user_id
LEFT JOIN employee emp ON u.user_id = emp.user_id
LEFT JOIN developer dev ON u.user_id = dev.user_id;
