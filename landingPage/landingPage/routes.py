from flask import Flask, render_template, request, flash
from forms import ContactForm
from flask.ext.mail import Message, Mail

mail = Mail()

app = Flask(__name__)
 
app.secret_key = 'r0B30E4bD/1ZD72p:4&4y9O[7G9E<]'


app.config["MAIL_SERVER"] = "smtp.gmail.com"
app.config["MAIL_PORT"] = 465
app.config["MAIL_USE_SSL"] = True
app.config["MAIL_USERNAME"] = 'nathan.lam@nova.com'
app.config["MAIL_PASSWORD"] = 'A952cc3'
 
mail.init_app(app)

@app.route('/', methods=['GET', 'POST'])
def home():
    form = ContactForm()
 
    if request.method == 'POST':
        if form.validate() == False:
            flash('Please enter your email')
            return render_template('home.html', form=form);
        else:
            msg = Message("New User", sender='nathan.lam@nova.com', recipients=['ray.liu@nova.com'])
            msg.body = (form.email.data)
            mail.send(msg)
            return render_template('home.html', success=True);

    elif request.method == 'GET':
        return render_template('home.html', form=form)

if __name__ == '__main__':
  app.run(debug=True)
