from flask import Flask, render_template, request, redirect, url_for, flash, session, jsonify
import sqlite3
import os
from werkzeug.security import generate_password_hash, check_password_hash
import random

app = Flask(__name__)
app.secret_key = 'your_secret_key'


def init_db():
    with app.app_context():
        db = sqlite3.connect('products.db')
        with app.open_resource('schema.sql', mode='r') as f:
            db.cursor().executescript(f.read())
        db.commit()


if not os.path.exists('products.db'):
    init_db()


def get_db():
    db = sqlite3.connect('products.db')
    db.row_factory = sqlite3.Row
    return db


@app.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = get_db()
        user = db.execute('SELECT * FROM users WHERE username = ?',
                          (username, )).fetchone()
        if user and check_password_hash(user['password'], password):
            session['user_id'] = user['id']
            session['is_admin'] = user['is_admin']
            flash('Logged in successfully', 'success')
            return redirect(url_for('dashboard'))
        flash('Invalid credentials', 'error')
    return render_template('login.html')


@app.route('/logout')
def logout():
    session.pop('user_id', None)
    session.pop('is_admin', None)
    return redirect(url_for('login'))


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = generate_password_hash(request.form['password'])
        db = get_db()
        if db.execute('SELECT id FROM users WHERE username = ?',
                      (username, )).fetchone() is not None:
            flash('Username already exists', 'error')
        else:
            db.execute('INSERT INTO users (username, password) VALUES (?, ?)',
                       (username, password))
            db.commit()
            flash('Registration successful. Please log in.', 'success')
            return redirect(url_for('login'))
    return render_template('register.html')


@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    db = get_db()
    user = db.execute('SELECT username FROM users WHERE id = ?',
                      (session['user_id'], )).fetchone()

    if user is None:
        flash('User not found. Please log in again.', 'error')
        return redirect(url_for('logout'))
    is_admin = session.get('is_admin', False)
    username = user['username']
    return render_template('dashboard.html',
                           username=username,
                           is_admin=is_admin)


@app.route('/datasheet')
def datasheet():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    db = get_db()

    # Fetch approved and pending products based on the approval status
    if session['is_admin']:
        approved_products = db.execute(
            'SELECT p.*, u.username FROM products p JOIN users u ON p.user_id = u.id WHERE approve_status = "approved"'
        ).fetchall()
        pending_products = db.execute(
            'SELECT p.*, u.username FROM products p JOIN users u ON p.user_id = u.id WHERE approve_status = "pending"'
        ).fetchall()

        # Calculate Amount Received and Amount Yet to Receive for admin
        amount_received = db.execute('''
            SELECT SUM(approved_price) AS total_received
            FROM products
            WHERE approve_status = "approved" 
              AND payment_status = "paid" 
              AND sold_status = "sold"
              AND return_status = "not returned"
        ''').fetchone()['total_received'] or 0

        amount_yet_to_receive = db.execute('''
            SELECT SUM(approved_price) AS total_pending
            FROM products
            WHERE approve_status = "approved"
              AND payment_status = "unpaid"
              AND sold_status = "sold"            
        ''').fetchone()['total_pending'] or 0

    else:
        approved_products = db.execute(
            'SELECT * FROM products WHERE user_id = ? AND approve_status = "approved"',
            (session['user_id'], )).fetchall()
        pending_products = db.execute(
            'SELECT * FROM products WHERE user_id = ? AND approve_status = "pending"',
            (session['user_id'], )).fetchall()

        # Calculate Amount Received and Amount Yet to Receive for regular user
        amount_received = db.execute(
            '''
            SELECT SUM(approved_price) AS total_received
            FROM products
            WHERE user_id = ?
              AND approve_status = "approved" 
              AND payment_status = "paid" 
              AND return_status = "not returned"
        ''', (session['user_id'], )).fetchone()['total_received'] or 0

        amount_yet_to_receive = db.execute(
            '''
            SELECT SUM(approved_price) AS total_pending
            FROM products
            WHERE user_id = ?
              AND approve_status = "approved"
              AND payment_status = "unpaid"
        ''', (session['user_id'], )).fetchone()['total_pending'] or 0

    user = db.execute('SELECT username FROM users WHERE id = ?',
                      (session['user_id'], )).fetchone()
    username = user['username']
    admin_status = session['is_admin']
    return render_template('datasheet.html',
                           approved_products=approved_products,
                           pending_products=pending_products,
                           username=username,
                           amount_received=amount_received,
                           amount_yet_to_receive=amount_yet_to_receive,
                           admin_status=admin_status)


@app.route('/product/add', methods=['GET', 'POST'])
def add_product():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    if request.method == 'POST':
        product_category = request.form.get('product_category')
        product_quality = request.form.get('product_quality')

        if not product_category or not product_quality:
            flash('Product category and quality are required.', 'error')
            return redirect(url_for('add_product'))

        # Generate a 13-digit numeric code for trackability_key using random
        trackability_key = ''.join(
            [str(random.randint(0, 9)) for _ in range(13)])

        db = get_db()
        user = db.execute('SELECT username FROM users WHERE id = ?',
                          (session['user_id'], )).fetchone()

        if user is None:
            flash('User not found. Please log in again.', 'error')
            return redirect(url_for('logout'))

        username = user['username']

        try:
            db.execute(
                'INSERT INTO products (product_category, product_quality, trackability_key, user_id, username) VALUES (?, ?, ?, ?, ?)',
                (product_category, product_quality, trackability_key,
                 session['user_id'], username))
            db.commit()
            flash('Product added successfully', 'success')
        except sqlite3.IntegrityError as e:
            flash(f'An error occurred: {e}', 'error')

        return redirect(url_for('datasheet'))

    return render_template('product_form.html')


@app.route('/product/edit/<int:id>', methods=['GET', 'POST'])
def edit_product(id):
    if 'user_id' not in session:
        return redirect(url_for('login'))

    db = get_db()
    product = db.execute('SELECT * FROM products WHERE id = ?',
                         (id, )).fetchone()

    if not product:
        flash('Product not found', 'error')
        return redirect(url_for('datasheet'))

    if session['is_admin'] or product['user_id'] == session['user_id']:
        if request.method == 'POST':
            if session['is_admin']:
                approved_price = request.form['approved_price']
                return_status = request.form['return_status']
                sold_status = request.form['sold_status']
                payment_status = request.form['payment_status']
                quality_control = request.form['quality_control']

                # Automatically set approve_status to 'approved' if approved_price is updated
                if approved_price:
                    db.execute(
                        'UPDATE products SET approved_price = ?, return_status = ?, sold_status = ?, payment_status = ?, quality_control = ?, approve_status = "approved" WHERE id = ?',
                        (approved_price, return_status, sold_status, payment_status,
                         quality_control, id))
                else:
                    db.execute(
                        'UPDATE products SET return_status = ?, sold_status = ?, payment_status = ?, quality_control = ? WHERE id = ?',
                        (return_status, sold_status, payment_status, quality_control, id))
                db.commit()
                flash('Product updated successfully (admin)', 'success')
                return redirect(url_for('datasheet'))

            else:
                product_category = request.form['product_category']
                product_quality = request.form['product_quality']
                db.execute(
                    'UPDATE products SET product_category = ?, product_quality = ?, approve_status = "pending" WHERE id = ?',
                    (product_category, product_quality, id))
                db.commit()
                flash('Product updated successfully', 'success')
                return redirect(url_for('datasheet'))

        if session['is_admin']:
            return render_template('admin_product_form.html', product=product)
        else:
            return render_template('product_form.html', product=product)
    else:
        flash('You do not have permission to edit this product.', 'error')
        return redirect(url_for('datasheet'))


@app.route('/product/delete/<int:id>')
def delete_product(id):
    if 'user_id' not in session:
        return redirect(url_for('login'))
    db = get_db()
    db.execute('DELETE FROM products WHERE id = ?', (id, ))
    db.commit()
    flash('Product deleted successfully', 'success')
    return redirect(url_for('datasheet'))


@app.route('/admin/product/edit/<int:id>', methods=['GET', 'POST'])
def admin_edit_product(id):
    if 'user_id' not in session or not session['is_admin']:
        return redirect(url_for('login'))

    db = get_db()
    product = db.execute('SELECT * FROM products WHERE id = ?',
                         (id, )).fetchone()

    if request.method == 'POST':
        approved_price = request.form['approved_price']
        return_status = request.form['return_status']
        sold_status = request.form['sold_status']
        payment_status = request.form['payment_status']
        quality_control = request.form['quality_control']

        # Automatically set approve_status to 'approved' if approved_price is updated
        if approved_price:
            db.execute(
                'UPDATE products SET approved_price = ?, return_status = ?, sold_status = ?, payment_status = ?, quality_control = ?, approve_status = "approved" WHERE id = ?',
                (approved_price, return_status, sold_status, payment_status, quality_control,
                 id))
        else:
            db.execute(
                'UPDATE products SET return_status = ?, sold_status = ?, payment_status = ?, quality_control = ? WHERE id = ?',
                (return_status, sold_status, payment_status, quality_control, id))

        db.commit()
        flash('Product updated successfully', 'success')
        return redirect(url_for('datasheet'))

    return render_template('admin_product_form.html', product=product)


@app.route('/api/products', methods=['GET'])
def api_get_products():
    if 'user_id' not in session:
        return jsonify({'error': 'Unauthorized access'}), 401

    db = get_db()
    if session['is_admin']:
        approved_products = db.execute(
            'SELECT p.*, u.username FROM products p JOIN users u ON p.user_id = u.id WHERE approve_status = "approved"'
        ).fetchall()
        pending_products = db.execute(
            'SELECT p.*, u.username FROM products p JOIN users u ON p.user_id = u.id WHERE approve_status = "pending"'
        ).fetchall()
    else:
        approved_products = db.execute(
            'SELECT * FROM products WHERE user_id = ? AND approve_status = "approved"',
            (session['user_id'], )).fetchall()
        pending_products = db.execute(
            'SELECT * FROM products WHERE user_id = ? AND approve_status = "pending"',
            (session['user_id'], )).fetchall()

    # Format the data to return JSON
    approved_product_list = [dict(product) for product in approved_products]
    pending_product_list = [dict(product) for product in pending_products]

    return jsonify({
        'approved_products': approved_product_list,
        'pending_products': pending_product_list
    }), 200


@app.route('/api/admin/dashboard-data')
def admin_dashboard_data():
    if 'user_id' not in session or not session.get('is_admin', False):
        return jsonify({'error': 'Unauthorized access'}), 401

    db = get_db()

    # Admin specific data aggregation
    total_data = db.execute('''
        SELECT 
            SUM(CASE WHEN sold_status = 'sold' THEN 1 ELSE 0 END) AS total_sold_count,
            SUM(CASE WHEN sold_status = 'unsold' THEN 1 ELSE 0 END) AS total_unsold_count,
            SUM(CASE WHEN approve_status = 'approved' THEN 1 ELSE 0 END) AS total_approved_count,
            SUM(CASE WHEN approve_status = 'pending' THEN 1 ELSE 0 END) AS total_not_approved_count,
            SUM(CASE WHEN return_status = 'returned' THEN 1 ELSE 0 END) AS total_returned_count,
            SUM(CASE WHEN return_status = 'not returned' THEN 1 ELSE 0 END) AS total_not_returned_count,
            SUM(CASE WHEN quality_control = 'passed' THEN 1 ELSE 0 END) AS total_passed_qc_count,
            SUM(CASE WHEN quality_control = 'failed' THEN 1 ELSE 0 END) AS total_failed_qc_count
        FROM products
    ''').fetchone()

    products_by_user_query = '''
    SELECT u.username, COUNT(p.id) as product_count
    FROM products p
    JOIN users u ON p.user_id = u.id
    GROUP BY u.username
    '''
    products_by_user = db.execute(products_by_user_query).fetchall()

    products_by_user_labels = [row['username'] for row in products_by_user]
    products_by_user_values = [
        row['product_count'] for row in products_by_user
    ]

    dates_query = 'SELECT date, COUNT(*) as count FROM products GROUP BY date'
    product_counts = db.execute(dates_query).fetchall()
    dates = [row['date'] for row in product_counts]
    product_counts = [row['count'] for row in product_counts]

    return jsonify({
        'totalSoldCount':
        total_data['total_sold_count'],
        'totalUnsoldCount':
        total_data['total_unsold_count'],
        'totalApprovedCount':
        total_data['total_approved_count'],
        'totalNotApprovedCount':
        total_data['total_not_approved_count'],
        'totalReturnedCount':
        total_data['total_returned_count'],
        'totalNotReturnedCount':
        total_data['total_not_returned_count'],
        'totalPassedQCCount':
        total_data['total_passed_qc_count'],
        'totalFailedQCCount':
        total_data['total_failed_qc_count'],
        'productsByUser':
        products_by_user_labels,
        'productsByUserValues':
        products_by_user_values,
        'dates':
        dates,
        'productCounts':
        product_counts,
        'adminStatus':
        True  # Explicitly indicate that this is admin data
    })


@app.route('/api/user/dashboard-data')
def user_dashboard_data():
    if 'user_id' not in session or session.get('is_admin', False):
        return jsonify({'error': 'Unauthorized access'}), 401

    db = get_db()
    user_id = session['user_id']

    # Regular user specific data aggregation
    user_data = db.execute(
        '''
        SELECT 
            SUM(CASE WHEN sold_status = 'sold' THEN 1 ELSE 0 END) AS sold_count,
            SUM(CASE WHEN sold_status = 'unsold' THEN 1 ELSE 0 END) AS unsold_count,
            SUM(CASE WHEN approve_status = 'approved' THEN 1 ELSE 0 END) AS approved_count,
            SUM(CASE WHEN approve_status = 'pending' THEN 1 ELSE 0 END) AS not_approved_count,
            SUM(CASE WHEN return_status = 'returned' THEN 1 ELSE 0 END) AS returned_count,
            SUM(CASE WHEN return_status = 'not returned' THEN 1 ELSE 0 END) AS not_returned_count,
            SUM(CASE WHEN quality_control = 'passed' THEN 1 ELSE 0 END) AS passed_qc_count,
            SUM(CASE WHEN quality_control = 'failed' THEN 1 ELSE 0 END) AS failed_qc_count
        FROM products
        WHERE user_id = ?
    ''', (user_id, )).fetchone()

    dates_query = 'SELECT date, COUNT(*) as count FROM products WHERE user_id = ? GROUP BY date'
    product_counts = db.execute(dates_query, (user_id, )).fetchall()
    dates = [row['date'] for row in product_counts]
    product_counts = [row['count'] for row in product_counts]

    return jsonify({
        'soldCount': user_data['sold_count'],
        'unsoldCount': user_data['unsold_count'],
        'approvedCount': user_data['approved_count'],
        'notApprovedCount': user_data['not_approved_count'],
        'returnedCount': user_data['returned_count'],
        'notReturnedCount': user_data['not_returned_count'],
        'passedQCCount': user_data['passed_qc_count'],
        'failedQCCount': user_data['failed_qc_count'],
        'dates': dates,
        'productCounts': product_counts
    })
@app.route('/product_tracing', methods=['GET', 'POST'])
def product_tracing():
    product = None
    if request.method == 'POST':
        trackability_key = request.form['trackability_key']
        db = get_db()
        product = db.execute('SELECT username, product_category, approved_price, date FROM products WHERE trackability_key = ?',
                             (trackability_key,)).fetchone()
        if not product:
            flash('Product not found', 'error')

    return render_template('product_tracing.html', product=product)



if __name__ == '__main__':
    app.run(debug=True)
