from flask import render_template, flash

from application import app, conn


@app.errorhandler(404)
def not_found(e):
  return render_template("base.html", title="404 Not Found")


@app.errorhandler(401)
def unauthorized(e):
  flash("This action requires administrator rights")
  return render_template("base.html", title="401 Unauthorized")


@app.errorhandler(500)
def internal_error(e):
    conn.rollback()
    return render_template("500.html")