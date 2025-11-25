



# Inventory Hub ERP System

A comprehensive web-based ERP system for inventory management, built with HTML, Bootstrap, JavaScript, and SQLite. 

A system by:

Phathutshedzo Mudau u19032936

Ndumiso Zondi u22631268

Jayden Williams u22830368 

Caleb Pillay u23528232

## Features

* **Dynamic Dashboard**: Real-time overview of revenue, products sold, active orders, and completed jobs with percentage growth indicators.
* **User Authentication**: Secure Login and Registration system for Vendors (Business Owners).
* **Inventory Management**: Track stock levels, value, and categories. Includes visual alerts for low-stock and out-of-stock items.
* **Sales & Invoicing**: Create invoices dynamically, managing customer associations and automatically deducting stock upon creation.
* **Manufacturing**: Monitor production schedules, track job progress percentages, and view start/due dates.
* **Logistics**: Track shipment statuses (Pending, In Transit, Delivered) and view recent shipment history.
* **Reporting**: Generate Sales and Inventory reports (placeholder functionality).

## Database Setup

### Using SQLite Command Line

1. Open command prompt/terminal in the project directory
2. Run the SQL commands:
   ```bash
   sqlite3 inventory.db < inventory.sql
   
## Database Schema

### Entity Relationship Diagram (ERD)

<img width="1908" height="1248" alt="Project_ERD" src="https://github.com/user-attachments/assets/2b0cca06-f70f-48d2-bb5e-4f107d35453a" />
note : this is the original ERD and the scope of the final database structure has been scaled back. The final tables used in the program are shown below.



## Tables

1.  **`vendors`**: Stores business owner credentials (email, password, business name).
2.  **`customers`**: Stores client contact information (name, email, phone, address).
3.  **`product_categories`**: Categorizes items (e.g., Electronics, Tools, Food).
4.  **`products`**: Inventory items including SKU, prices (cost/sell), stock levels, and alert thresholds.
5.  **`sales_orders`**: Header table for sales transactions (status: draft, pending, confirmed, shipped, delivered).
6.  **`invoices`**: Financial records linking orders to customers.
7.  **`invoice_items`**: Line items for invoices (links Products to Invoices).
8.  **`manufacturing_jobs`**: Production jobs with start/due dates and progress percentages.
9.  **`stock_updates`**: Audit trail for inventory adjustments (restock, sale, damage).


## Views

1.  **Logistics Dashboard (`Logistics.html`)**
    * **Data Presented**: Summary of Pending Processing, Active Shipments, and Delivered Shipments. Includes a detailed table of recent shipments with status indicators and destination details.

2.  **Manufacturing Dashboard (`Manufacturing.html`)**
    * **Data Presented**: KPI cards for Active, Completed, and Scheduled jobs. Features a detailed job list including Job Number, Product, Start/Due Dates, and a visual progress bar for current status.

3.  **Sales & Marketing Dashboard (`SalesAndMarketing.html`)**
    * **Data Presented**: Metrics for Total Reach, Conversions, Sales Pipeline Value, and Total Revenue. Includes a breakdown of recent orders and average order value calculations.

4.  **Inventory Dashboard (`Inventory.html`)**
    * **Data Presented**: Total item counts, low stock alerts, and total inventory monetary value. The main view provides a searchable table of all products with category and stock status (In Stock/Low Stock/Out of Stock).

5.  **Main Executive Dashboard (`index.html`)**
    * **Data Presented**: Aggregates key metrics from all other modules (Revenue, Sales, Jobs, Orders) and provides quick access buttons for common tasks like invoicing and reporting.

---

## Sample Data

The database includes realistic sample data for testing:

1.  **`vendors`**: Stores business owner credentials (email, password, business name).
2.  **`customers`**: Stores client contact information (name, email, phone, address).
3.  **`product_categories`**: Categorizes items (e.g., Electronics, Tools, Food).
4.  **`products`**: Inventory items including SKU, prices (cost/sell), stock levels, and alert thresholds.
5.  **`sales_orders`**: Header table for sales transactions (status: draft, pending, confirmed, shipped, delivered).
6.  **`invoices`**: Financial records linking orders to customers.
7.  **`invoice_items`**: Line items for invoices (links Products to Invoices).
8.  **`manufacturing_jobs`**: Production jobs with start/due dates and progress percentages.
9.  **`stock_updates`**: Audit trail for inventory adjustments (restock, sale, damage).

---

## File Structure

   
      ├── app.py                  # Main application controller
      ├── inventory.db            # SQLite database file  
      ├── inventory.sql           # Database schema and seed data
      ├── README.md               # Project documentation
      └── static/                 # Static assets folder
         └── Pictures/            # Images and Icons    
      └── templates/              # HTML Templates folder
       ├── base.html           # Master layout template
       ├── index.html          # Dashboard
       ├── Inventory.html      # Inventory view
       ├── Logistics.html      # Logistics view
       ├── Manufacturing.html  # Manufacturing view
       ├── Login.html          # Login view
       ├── Register.html       # Registration view
       └── SalesAndMarketing.html   # Marketing view
       
## Usage

1. Initialize the database using the SQLite command line method above
2. Open `index.html` in your web browser
3. Navigate through the different modules using the sidebar navigation
4. Use quick actions for common tasks like creating invoices or adding stock

## Technologies Used

* **Backend**: Python, Flask (Microframework)
* **Frontend**: HTML5, Jinja2 Templating, Bootstrap 5.3.8
* **Database**: SQLite
* **Visualization**: Chart.js (Dynamic data rendering)

## Browser Compatibility

The application works with all modern browsers that support HTML5, CSS3, and ES6 JavaScript, including:

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

Note: This is a static HTML application. For production use, you would need to add backend functionality for database connectivity and form processing.

## References

<a href="https://www.flaticon.com/free-icons/inventory-management" title="inventory-management icons">Inventory-management icons created by Freepik - Flaticon</a>

