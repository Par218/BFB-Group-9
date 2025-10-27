Inventory Hub ERP System
A comprehensive web-based ERP system for inventory management, built with HTML, Bootstrap, JavaScript, and SQLite.

Features
Dashboard: Overview of key metrics, sales vs production analytics, and quick actions

Inventory Management: Track and manage stock levels, categories, and inventory value

Sales & Marketing: Monitor campaigns, leads, and sales performance

Manufacturing: Manage production schedules, job progress, and capacity utilization

Logistics: Track shipments, deliveries, and warehouse operations

Customer Management: Maintain customer database and create invoices

Reporting: Generate various business reports with date filtering

Database Setup
Using SQLite Command Line
Open command prompt/terminal in the project directory

Run the SQL commands:

bash
sqlite3 inventory_hub.db < inventory.sql
Database Schema
Entity Relationship Diagram (ERD)

Database Tables and Views
Tables
User: Central table recording all users (employees, customers, SME companies) with authentication and security details

Customer: Child table of User, recording individual customer specific details and contact information

Employee: Child table of User, recording employee specific information including position and employment details

SME_Company: Child table of User, recording client/partner companies and their business information

Location: Table recording all physical locations including warehouses, customer addresses, and supplier locations

Product: Table recording all products offered through the system with pricing, categories, and measurement units

Sales_Order: Table recording all sales orders with customer/company information, order status, and total amounts

Order_Items: Junction table linking sales orders to products with quantities and pricing

Inventory: Table tracking current inventory levels across different locations

Shipment: Table tracking and recording shipments for sales orders with status and tracking information

Manufacturing_Job: Table managing production schedules, quantities, progress, and due dates

Views
Logistics_Dashboard: Summary of logistics related data used to organize and coordinate logistics operations including shipments, orders, and customer information

Manufacturing_Dashboard: Summary of manufacturing information including job schedules, quantities, due dates, and progress percentages for production planning

SalesMarketing_Dashboard: Comprehensive view of sales data and performance metrics used for analysis, reporting, and business planning

Sample Data
The database includes realistic sample data for testing:

4 Users: Admin, individual customers, and SME company

2 Customers: John Doe and Jane Doe with contact information

1 Employee: System Administrator

1 SME Company: ABC Industries in manufacturing sector

3 Locations: Warehouses in Johannesburg, Cape Town, and Durban

3 Products: Cream Donuts, Chocolate Chip Cookies, Whole Wheat Bread across different categories

2 Sales Orders: Sample transactions with realistic amounts

2 Shipments: Active shipments with tracking numbers

2 Manufacturing Jobs: Scheduled and in-progress production jobs

File Structure
text
├── index.html              # Main dashboard with analytics and quick actions
├── Login.html              # User authentication page
├── Register.html           # User registration page
├── Inventory.html          # Inventory management and tracking
├── Logistics.html          # Shipment and warehouse management
├── Manufacturing.html      # Production scheduling and job management
├── SalesAndMarketing.html  # Campaigns and sales performance tracking
├── barChart.js            # Chart.js implementation for analytics
├── inventory.sql          # Complete database schema and sample data
└── readme.md              # Project documentation
Quick Actions Features
Create Invoice: Generate customer invoices with item search and automatic calculations

Add Stock: Add new products to inventory with category and pricing

Add Customer: Register new customers with contact information

Generate Report: Create business reports with date range filtering

Technologies Used
HTML5: Structure and forms across all modules

Bootstrap 5.3.8: UI framework and responsive design

Chart.js: Interactive charts and analytics visualization

SQLite: Database for data persistence and relationships

JavaScript: Client-side functionality and chart rendering

Usage
Initialize the database using the SQLite command line method above

Open index.html in your web browser

Navigate through the different modules using the sidebar navigation

Use quick actions for common tasks like creating invoices or adding stock

Browser Compatibility
The application works with all modern browsers that support HTML5, CSS3, and ES6 JavaScript, including:

Chrome 90+

Firefox 88+

Safari 14+

Edge 90+

Note
This is a frontend application with a defined database schema. For production deployment, you would need to implement backend functionality for database connectivity, form processing, and user authentication.

Project Structure Overview
The ERP system follows a modular approach with dedicated pages for each business function while maintaining a consistent navigation structure and user interface across all modules. The database design supports complex business relationships between customers, orders, inventory, and manufacturing operations.





