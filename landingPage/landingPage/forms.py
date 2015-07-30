from flask.ext.wtf import Form

from wtforms import TextField, BooleanField, SubmitField
from wtforms import validators, ValidationError

class ContactForm(Form):
  email = TextField("Email",  [validators.Required(), validators.Email()])
  submit = SubmitField("Send")