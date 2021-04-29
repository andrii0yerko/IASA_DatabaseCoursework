import os

from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import UserMixin, login_user, current_user, logout_user
from flask import render_template, redirect, url_for, request, flash

from application import app, login


class Admin(UserMixin):
    id = 'admin'
    
    def __init__(self):
        super().__init__()
        self.password_hash = generate_password_hash(os.environ['ADMIN_PASSWORD'])
        self.username = os.environ['ADMIN_USERNAME']
        
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def check_username(self, username):
        return self.username==username
    
    def check_login(self, username, password):
        return self.check_username(username) and self.check_password(password)

admin = Admin()    

@login.user_loader
def load_user(user):
    if user == 'admin':
        return admin
    return None


@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('admin_panel'))
    if request.method == 'POST':
        form = request.form
        print(form)
        print(form['password'])
        print(admin.check_password(form['password']))
        if not admin.check_login(form['username'], form['password']):
            flash('Invalid username or password')
            return redirect(url_for('login'))
        login_user(admin)
        return redirect(url_for('admin_panel'))
    return render_template('login.html', title='Sign In')


@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('index'))


@app.route('/admin')
def admin_panel():
    return render_template('base.html', title='Admin panel')