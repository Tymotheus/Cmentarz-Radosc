#Forms classes defined for all the forms in the app
#They are used to post data into the db and receive information from it
import datetime
from flask_wtf import FlaskForm
from flask_wtf.file import FileField, FileAllowed
from flask_login import current_user
from wtforms import StringField, PasswordField, SubmitField, BooleanField, \
TextAreaField, DateField, IntegerField
from wtforms.validators import DataRequired, Length, Email, EqualTo, ValidationError
from Radosc.models import User


# wprowadzanie danych nowego nieboszczyka przez klienta
class NieboszczykForm(FlaskForm):
    username = StringField('Imię i Nazwisko',
                validators=[DataRequired(), Length(min=4)])
    data_urodzenia = DateField('Data urodzenia', validators=[DataRequired()])
    data_zgonu = DateField('Data zgonu', validators=[DataRequired()])
    submit = SubmitField('Zarejestruj Nieboszczyka')


#dodawanie nowych krypt
class KryptaForm(FlaskForm):
    nazwa_krypty = StringField('Nazwa krypty', validators=[DataRequired()])
    pojemnosc = IntegerField('Pojemność', validators=[DataRequired()])
    submit = SubmitField('Dodaj kryptę')
    #data


#dodawanie nowych kostnic
class KostnicaForm(FlaskForm):
    nazwa_kostnicy = StringField('Nazwa kostnicy', validators=[DataRequired()])
    submit = SubmitField('Dodaj kostnicę')


#dodawanie nowych krematoriów
class KrematoriumForm(FlaskForm):
    nazwa_krematorium = StringField('Nazwa krematorium', validators=[DataRequired()])
    submit = SubmitField('Dodaj krematorium')


#przypisanie trumien do krypt
class PrzypiszTrumneKrypcieForm(FlaskForm):
    id_trumny = IntegerField('ID trumny', validators=[DataRequired()])
    id_krypty = IntegerField('ID krypty', validators=[DataRequired()])
    submit = SubmitField('Przypisz trumnę')


#przypisanie trumien do nagrobków
class PrzypiszTrumneNagrobkowiForm(FlaskForm):
    id_trumny = IntegerField('ID trumny', validators=[DataRequired()])
    id_nagrobka = IntegerField('ID nagrobka', validators=[DataRequired()])
    submit = SubmitField('Przypisz trumnę')


#przypisanie urn do krypt
class PrzypiszUrneKrypcieForm(FlaskForm):
    id_urny = IntegerField('ID urny', validators=[DataRequired()])
    id_krypty = IntegerField('ID krypty', validators=[DataRequired()])
    submit = SubmitField('Przypisz urnę')


#przypisanie trumny do nieboszczyka
class PrzypiszTrumneNieboszczykowiForm(FlaskForm):
    id_nieboszczyka = IntegerField('ID nieboszczyka', validators=[DataRequired()] )
    id_trumny = IntegerField('ID trumny', validators=[DataRequired()])
    submit = SubmitField('Przypisz trumnę')


#przypisanie urny do nieboszczyka
class PrzypiszUrneNieboszczykowiForm(FlaskForm):
    id_nieboszczyka = IntegerField('ID nieboszczyka', validators=[DataRequired()] )
    id_urny = IntegerField('ID urny', validators=[DataRequired()])
    submit = SubmitField('Przypisz urnę')


#wyszukiwanie nieboszczyków
class WyszukajNieboszczykaForm(FlaskForm):
    imie = StringField('Imię i nazwisko nieboszczyka', validators=[DataRequired()])
    submit = SubmitField('Wyszukaj nieboszczyka')
    trumna = BooleanField('Trumna')
    urna = BooleanField('Urna')


#dodaj trumniarza
class DodajTrumniarzaForm(FlaskForm):
    imie_trumniarza = StringField('Imię i nazwisko trumniarza')
    submit = SubmitField('Dodaj Trumniarza')


#dodaj urniarza
class DodajUrniarzaForm(FlaskForm):
    imie_urniarza = StringField('Imię i nazwisko urniarza')
    submit = SubmitField('Dodaj Urniarza')


#dodaj sprzątacza
class DodajSprzataczaForm(FlaskForm):
    imie_sprzatacza = StringField('Imię i nazwisko sprzątacza')
    submit = SubmitField('Dodaj Sprzątacza')


#nowa trumna
class DodajTrumneForm(FlaskForm):
    material = StringField('Materiał')
    id_kostnicy = IntegerField('ID Kostnicy')
    submit = SubmitField('Dodaj Trumnę')


#nowa urna
class DodajUrneForm(FlaskForm):
    material = StringField('Materiał')
    id_krematorium = IntegerField('ID krematorium')
    submit = SubmitField('Dodaj Urnę')


#nowy nagrobek
class DodajNagrobekForm(FlaskForm):
    material = StringField('Materiał')
    submit = SubmitField('Dodaj Nagrobek')


#regitering new users
class RegistrationForm(FlaskForm):
    username = StringField('Nazwa użytkownika',
                validators=[DataRequired(), Length(min=2, max=20)])
    email = StringField('Email',
                validators=[DataRequired(), Email()])
    password = PasswordField('Hasło', validators=[DataRequired()])
    confirm_password = PasswordField('Potwierdź hasło',
                validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Zarejestruj się')

    #checking if already exists
    def validate_username(self, username):
        user = User.query.filter_by(username=username.data).first()
        if user:
            raise ValidationError('That username is taken. Please choose a different one.')

    def validate_email(self, email):
        user = User.query.filter_by(email=email.data).first()
        if user:
            raise ValidationError('That email is taken. Please choose a different one.')

#logging into the app
class LoginForm(FlaskForm):
    email = StringField('Email',
                validators=[DataRequired(), Email()])
    password = PasswordField('Hasło', validators=[DataRequired()])
    remember = BooleanField('Pamiętaj mnie')
    submit = SubmitField('Zaloguj')

#updating information in an account
class UpdateAccountForm(FlaskForm):
    username = StringField('Username',
                validators=[DataRequired(), Length(min=2, max=20)])
    email = StringField('Email',
                validators=[DataRequired(), Email()])
    picture = FileField('Update profile picture', validators=[FileAllowed(['jpg', 'png'])])
    submit = SubmitField('Update')

    #checking if already exists
    def validate_username(self, username):
        if username.data != current_user.username:
            user = User.query.filter_by(username=username.data).first()
            if user:
                raise ValidationError('That username is taken. Please choose a different one.')

    def validate_email(self, email):
        if email.data != current_user.email:
            user = User.query.filter_by(email=email.data).first()
            if user:
                raise ValidationError('That email is taken. Please choose a different one.')
