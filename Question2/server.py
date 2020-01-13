import flask
from flask import abort, Response
app = flask.Flask(__name__)
app.config["DEBUG"] = True
@app.route("/check.txt")
def index():
    return Response(
        "Its Working",
        status=200,
    ) 
@app.route("/404")
def error404():
    return Response(
        "Not Found",
        status=404,
    ) 
@app.route("/403")
def error403():
    return Response(
        "Forbidden",
        status=403,
    )
@app.route("/500")
def error500():
    return Response(
        "Application error",
        status=500,
    )  
@app.route('/502')
def error502():
    code = 502
    msg = 'Bad Gateway'
    return msg, code
app.run(host="0.0.0.0",port=8000)