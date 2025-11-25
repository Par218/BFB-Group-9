from flask import Flask, render_template, request, redirect, url_for, flash, session,g
import sqlite3
import os
from datetime import datetime, timedelta
import random
from werkzeug.security import generate_password_hash, check_password_hash

project_root = os.path.dirname(os.path.abspath(__file__))#Ndumiso add
DATABASE = os.path.join(project_root, 'inventory.db')

app = Flask(#Ndumiso add
    __name__,
    template_folder=os.path.join(project_root, 'templates'),
    static_folder=os.path.join(project_root, 'static')
)
app.secret_key = 'inventory-hub-secret-key'


@app.context_processor
def utility_processor():
    def format_date(date, format_string='%Y-%m-%d'):
        if isinstance(date, str):
            return date
        return date.strftime(format_string)
    return dict(format_date=format_date, datetime=datetime)

def get_db_connection():
    try:
        conn = sqlite3.connect(DATABASE)
        conn.row_factory = sqlite3.Row
        return conn
    except sqlite3.Error as e:
        print(f"Database connection error: {e}")
        return None

def init_database():
    conn = sqlite3.connect(DATABASE)
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='vendors'")
        if not cursor.fetchone():
            if os.path.exists('inventory.sql'):
                with open('inventory.sql', 'r') as f:
                    conn.executescript(f.read())
                print("Database initialized.")
    except Exception as e:
        print(f"Error initializing database: {e}")
    finally:
        conn.close()

@app.teardown_appcontext
def close_connection(e = None):
    db = g.pop('db', None)
    if db is not None:
        db.close()

def generate_invoice_number():
    return f"INV-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000, 9999)}"

def calculate_percentage_change(current, previous):
    if previous == 0: return 0 if current == 0 else 100
    return round(((current - previous) / previous) * 100, 1)

def get_last_month_data():
    conn = get_db_connection()
    if not conn: return {}
    try:
        today = datetime.now()
        first_day_curr = today.replace(day=1)
        last_day_prev = first_day_curr - timedelta(days=1)
        first_day_prev = last_day_prev.replace(day=1)
        dates = (first_day_prev.strftime('%Y-%m-%d'), last_day_prev.strftime('%Y-%m-%d'))

        revenue = conn.execute('SELECT SUM(total_amount) FROM invoices WHERE created_at BETWEEN ? AND ? AND status != "draft"', dates).fetchone()[0] or 0
        sold = conn.execute('SELECT SUM(quantity) FROM invoice_items ii JOIN invoices i ON ii.invoice_id = i.invoice_id WHERE i.created_at BETWEEN ? AND ? AND i.status != "draft"', dates).fetchone()[0] or 0
        jobs = conn.execute('SELECT COUNT(*) FROM manufacturing_jobs WHERE created_at BETWEEN ? AND ? AND status = "completed"', dates).fetchone()[0] or 0
        orders = conn.execute('SELECT COUNT(*) FROM sales_orders WHERE created_at BETWEEN ? AND ? AND status IN ("pending", "confirmed")', dates).fetchone()[0] or 0
        
        return {'revenue': float(revenue), 'products_sold': sold, 'completed_jobs': jobs, 'active_orders': orders}
    except:
        return {}
    finally:
        conn.close()

def get_dashboard_data():
    data = {
        'total_products': 0, 'inventory_value': 0.0, 'total_revenue': 0.0,
        'products_sold': 0, 'complete_jobs': 0, 'active_jobs': 0,
        'scheduled_jobs': 0, 'active_orders': 0, 'revenue_change': 0,
        'products_sold_change': 0, 'jobs_change': 0, 'orders_change': 0,
        'customers': [], 'products': [], 'categories': [], 'recent_orders': [],
        'low_stock_count': 0, 'out_of_stock_count': 0, 'active_shipments': 0
    }
    conn = get_db_connection()
    if not conn: return data
    try:
        # 1. Fetch General Stats (Simple Counts)
        data['total_products'] = conn.execute('SELECT COUNT(*) FROM products').fetchone()[0] or 0
        data['inventory_value'] = conn.execute('SELECT SUM(quantity * price) FROM products').fetchone()[0] or 0.0
        data['total_revenue'] = conn.execute('SELECT SUM(total_amount) FROM invoices WHERE status != "draft"').fetchone()[0] or 0.0
        data['products_sold'] = conn.execute('SELECT SUM(quantity) FROM invoice_items ii JOIN invoices i ON ii.invoice_id = i.invoice_id WHERE i.status != "draft"').fetchone()[0] or 0
        data['complete_jobs'] = conn.execute('SELECT COUNT(*) FROM manufacturing_jobs WHERE status = "completed"').fetchone()[0] or 0
        data['active_jobs'] = conn.execute('SELECT COUNT(*) FROM manufacturing_jobs WHERE status = "in_progress"').fetchone()[0] or 0
        data['scheduled_jobs'] = conn.execute('SELECT COUNT(*) FROM manufacturing_jobs WHERE status = "scheduled"').fetchone()[0] or 0
        data['active_orders'] = conn.execute('SELECT COUNT(*) FROM sales_orders WHERE status IN ("pending", "confirmed")').fetchone()[0] or 0
        
        # 2. Calculate Changes
        last_month = get_last_month_data()
        data['revenue_change'] = calculate_percentage_change(data['total_revenue'], last_month.get('revenue', 0))
        data['products_sold_change'] = calculate_percentage_change(data['products_sold'], last_month.get('products_sold', 0))
        data['jobs_change'] = calculate_percentage_change(data['complete_jobs'], last_month.get('completed_jobs', 0))
        data['orders_change'] = calculate_percentage_change(data['active_orders'], last_month.get('active_orders', 0))
        
        # 3. Fetch Lists (Customers & Categories)
        data['customers'] = conn.execute('SELECT * FROM customers ORDER BY name').fetchall()
        categories_raw = conn.execute('SELECT * FROM product_categories').fetchall()
        data['categories'] = categories_raw # Used for dropdowns

        # 4. Fetch Products & Merge Categories in Python (Prevents SQL JOIN Crashes)
        products_raw = conn.execute('SELECT * FROM products ORDER BY product_name').fetchall()
        
        # Create a lookup dictionary for categories: {id: 'Category Name'}
        cat_map = {c['category_id']: c['category_name'] for c in categories_raw}
        
        processed_products = []
        low_stock_counter = 0
        out_stock_counter = 0

        for p in products_raw:
            # Convert Row to Dict so we can add new keys
            item = dict(p)
            
            # Add Category Name safely
            item['category_name'] = cat_map.get(p['category_id'], 'Uncategorized')
            
            # Add Alert Level Logic
            # If min_stock_level is 0 or None, force it to 10. Otherwise use the real value.
            min_level = p['min_stock_level'] if (p['min_stock_level'] is not None and p['min_stock_level'] > 0) else 10
            item['alert_level'] = min_level
            
            # Calculate Counters
            if p['quantity'] == 0:
                out_stock_counter += 1
            elif p['quantity'] <= min_level:
                low_stock_counter += 1
                
            processed_products.append(item)
            
        data['products'] = processed_products
        data['low_stock_count'] = low_stock_counter
        data['out_of_stock_count'] = out_stock_counter

        # 5. Recent Orders (Explicit Selection)
        data['recent_orders'] = conn.execute('''
            SELECT order_number, 
                   c.name as client_name, 
                   c.name as name, 
                   total_amount, 
                   status, 
                   so.created_at 
            FROM sales_orders so 
            LEFT JOIN customers c ON so.customer_id = c.customer_id 
            ORDER BY created_at DESC LIMIT 5
        ''').fetchall()

        data['active_shipments'] = conn.execute('SELECT COUNT(*) FROM sales_orders WHERE status = "shipped"').fetchone()[0] or 0
        
    except Exception as e:
        print(f"Data fetch error: {e}")
    finally:
        conn.close()
    return data

# --- Routes ---

@app.route('/')
def index():
    if not session.get('loggedin'): return redirect(url_for('login'))

    else:
        data = get_dashboard_data()
        username = session.get('business_name')
        active1 = 'active'  # Dashboard
        active2 = ''  # Logistics
        active3 = ''  # Sales & Marketing
        active4 = ''  # Inventory
        active5 = ''  # Manufacturing


    return render_template('index.html', email = username, active1=active1, **data)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        conn = get_db_connection()
        curs = conn.cursor()
        try:
            vendor = curs.execute('SELECT * FROM vendors WHERE email = ? AND password = ?', (email, password)).fetchone()
            if vendor:
                session['loggedin'] = True
                session['vendor_id'] = vendor['vendor_id']
                session['email'] = vendor['email']
                session['business_name'] = vendor['business_name']
                flash('Login successful!', 'success')
                return redirect(url_for('index'))
            else:
                flash('Invalid email or password', 'danger')
        except sqlite3.OperationalError as e:
            flash(f'Database error: {e}. Try restarting the application.', 'danger')
        except Exception as e:
            flash(f'An error occurred: {e}', 'danger')
        finally:
            conn.close()
    return render_template('Login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form.get('name')
        surname = request.form.get('surname')
        username = request.form.get('username') 
        email = request.form.get('email')
        password = request.form.get('password')
        password2 = request.form.get('password2')
        if password != password2:
            flash('Passwords do not match', 'danger')
            return redirect(request.url)
        
        conn = get_db_connection()
        curs = conn.cursor()
        try:
            if conn.execute('SELECT 1 FROM vendors WHERE email = ?', (email,)).fetchone():
                flash('Email already registered', 'danger')
                return redirect(request.url)
            elif not len(password) >= 8:
                flash('Password must be at least 8 characters long', 'danger')
                return redirect(request.url)
            else:
                business_name = username if username else f"{name} {surname} Business"
                conn.execute('INSERT INTO vendors (first_name, last_name, business_name, email, password) VALUES (?, ?, ?, ?, ?)', (name, surname, business_name, email, password))
                conn.commit()
                flash('Successful Registration! Please log in.', 'success')
                return redirect(url_for('login'))
        except Exception as e: 
            flash(f'Registration failed: {e}', 'danger')
        finally:
            conn.close()
    return render_template('Register.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))
# --- Data Modification Routes ---

@app.route('/add_customer', methods=['POST'])
def add_customer():
    if not session.get('loggedin'): return redirect(url_for('login'))
    conn = get_db_connection()
    try:
        conn.execute('INSERT INTO customers (name, email, phone, address) VALUES (?, ?, ?, ?)', 
                     (request.form.get('customerName'), request.form.get('customerEmail'), request.form.get('customerPhone'), request.form.get('customerAddress')))
        conn.commit()
    finally:
        conn.close()
    return redirect(url_for('index'))

@app.route('/create_invoice', methods=['POST'])
def create_invoice():
    if not session.get('loggedin'): return redirect(url_for('login'))
    conn = get_db_connection()
    try:
        customer_id = request.form.get('customer_id')
        if not customer_id: return redirect(url_for('index'))
        items = []
        total = 0
        products = conn.execute('SELECT * FROM products').fetchall()
        for p in products:
            qty = int(request.form.get(f'product_{p["product_id"]}', 0))
            if qty > 0:
                if qty > p['quantity']:
                    flash(f'Insufficient stock: {p["product_name"]}', 'error')
                    return redirect(url_for('index'))
                total += qty * p['price']
                items.append((p, qty, qty * p['price']))
        
        if items:
            inv_num = generate_invoice_number()
            cur = conn.execute('INSERT INTO invoices (invoice_number, customer_id, total_amount, status) VALUES (?, ?, ?, ?)', (inv_num, customer_id, total, 'created'))
            inv_id = cur.lastrowid
            for p, qty, line_total in items:
                conn.execute('INSERT INTO invoice_items (invoice_id, product_id, quantity, unit_price, total_price) VALUES (?, ?, ?, ?, ?)', (inv_id, p['product_id'], qty, p['price'], line_total))
                conn.execute('UPDATE products SET quantity = quantity - ? WHERE product_id = ?', (qty, p['product_id']))
            conn.execute('INSERT INTO sales_orders (order_number, customer_id, total_amount, status) VALUES (?, ?, ?, ?)', (f"ORD-{inv_num.split('-')[1]}-{inv_num.split('-')[2]}", customer_id, total, 'confirmed'))
            conn.commit()
            flash(f'Invoice {inv_num} created.', 'success')
    finally:
        conn.close()
    return redirect(url_for('index'))

@app.route('/add_stock', methods=['POST'])
def add_stock():
    if not session.get('loggedin'): return redirect(url_for('login'))
    try:
        sku = f"PROD-{random.randint(1000, 9999)}"
        conn = get_db_connection()
        conn.execute('INSERT INTO products (sku, product_name, category_id, quantity, price, cost_price, description) VALUES (?, ?, ?, ?, ?, ?, ?)',
                     (sku, request.form.get('stockName'), request.form.get('stockCategory'), int(request.form.get('stockQuantity', 0)), 
                      request.form.get('stockSellPrice'), request.form.get('stockCostPrice'), request.form.get('stockDescription', '')))
        conn.commit()
        conn.close()
    except Exception as e:
        flash(f'Error: {e}', 'error')
    return redirect(request.referrer or url_for('index'))

@app.route('/add_category', methods=['POST'])
def add_category():
    if not session.get('loggedin'): return redirect(url_for('login'))
    conn = get_db_connection()
    conn.execute('INSERT INTO product_categories (category_name, category_description) VALUES (?, ?)', 
                 (request.form.get('categoryName'), request.form.get('categoryDescription')))
    conn.commit()
    conn.close()
    return redirect(request.referrer or url_for('index'))

@app.route('/generate_report', methods=['POST'])
def generate_report():
    return redirect(url_for('index'))


