from flask import render_template, flash

from application import app, db


@app.errorhandler(404)
def not_found(e):
  return render_template("base.html", title="404 Not Found")


@app.errorhandler(401)
def unauthorized(e):
  flash("This action requires administrator rights")
  return render_template("base.html", title="401 Unauthorized")


@app.errorhandler(500)
def internal_error(e):
    db.conn.rollback()
    return render_template("500.html")