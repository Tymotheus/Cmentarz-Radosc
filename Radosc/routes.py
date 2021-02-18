import os
import secrets
import datetime
from PIL import Image #for resizing uploaded images
from flask import render_template, url_for, flash, redirect, request, abort
from flask import jsonify
from flask_login import login_user, logout_user, current_user, login_required

from Radosc import app, db, bcrypt
from Radosc.forms import *
from Radosc.database import *
from Radosc.models import User, Post


@app.route("/home")
def home():
    posts = Post.query.all()
    return render_template('home.html', posts=reversed(posts))


@app.route("/")
@app.route("/about")
def about():
    return render_template('about.html', title='About')


@app.route('/nieboszczyk/', methods=['GET', 'POST'])
def nieboszczyk():
    nieboszczycy = pobierz_nieboszczykow()
    nieprzypisani_nieboszczycy = pobierz_nieprzypisanych_nieboszczykow()
    print("Nieboszczycy:")
    print(nieboszczycy)
    print("Nieprzypisani nieboszczycy:")
    print(nieprzypisani_nieboszczycy)
    form = NieboszczykForm()
    wyszukaj_form = WyszukajNieboszczykaForm()
    sredni_wiek = round(pobierz_sredni_wiek()[0][0], 2)
    search_result = ()
    #formularz do wprowadzania nieboszczyków
    if form.validate_on_submit():
        # TODO: Make some frontend validation here
        print(wstaw_nieboszczyka(form.username.data, form.data_urodzenia.data, form.data_zgonu.data))
        flash(f'Twoje zgłoszenie zostało odnotowane', 'success')
        return redirect(url_for('nieboszczyk'))
    #formularz do wyszukiwania nieboszczyków
    if wyszukaj_form.validate_on_submit():
        search_result = wyszukaj_nieboszczyka(wyszukaj_form.imie.data)
        if search_result:
            flash(f'Nieboszczyk znaleziony', 'success')
            search_result = search_result[0]
        else:
            flash(f'Nieboszczyk nie został znaleziony', 'warning')
        print(search_result)
    return render_template('nieboszczyk.html', title='Zaaplikuj', form=form, \
        wyszukaj_form=wyszukaj_form, nieboszczycy=nieboszczycy, \
        sredni_wiek=sredni_wiek, search_result=search_result, \
        nieprzypisani_nieboszczycy=nieprzypisani_nieboszczycy)


@app.route('/krypta/', methods=['GET', 'POST'])
def krypta():
    krypty = pobierz_krypty()
    print(krypty)
    print()
    form = KryptaForm()
    #TO DO: this one below probably needs refactoring and polishing
    #UWAGA będę teraz robił skomplikowaną operację!
    #Dla każdej krypty pobieram jej mieszkańców i zapisuję w zmiennej!
    mieszkancy_trumny = [ mieszkancy_krypty_trumny(krypta[1]) for krypta in krypty]
    mieszkancy_urny = [ mieszkancy_krypty_urny(krypta[1]) for krypta in krypty]
    print("Zmienna mieszkancy trumny: " + str(mieszkancy_trumny) )
    print("Zmienna mieszkancy urny: " + str(mieszkancy_urny))
    print()
    krypty = list(zip(krypty,mieszkancy_trumny, mieszkancy_urny))
    print("Zmienna krypty: " + str(krypty))
    if form.validate_on_submit():
        wstaw_krypte(form.nazwa_krypty.data, form.pojemnosc.data)
        flash(f'Krypta została dodana', 'success')
        return redirect(url_for('krypta'))
    return render_template('krypta.html', title="Krypta", form=form, \
            krypty=krypty)


@app.route('/nagrobek/', methods=['GET', 'POST'])
def nagrobek():
    zajete_nagrobki = pobierz_zajete_nagrobki()
    nieprzypisane_nagrobki = pobierz_nieprzypisane_nagrobki()
    form = DodajNagrobekForm()
    print("Zajęte nagrobki: ")
    print(zajete_nagrobki)
    print("Nieprzypisane nagrobki: ")
    print(nieprzypisane_nagrobki)
    if form.validate_on_submit():
        dodaj_nagrobek(form.material.data)
        return redirect(url_for('nagrobek'))
    return render_template('nagrobek.html', title='Nagrobek', \
        form=form,\
        zajete_nagrobki=zajete_nagrobki, nieprzypisane_nagrobki=nieprzypisane_nagrobki )


@app.route('/kostnica/', methods=['GET', 'POST'])
def kostnica():
    kostnice = pobierz_kostnice()
    print(kostnice)
    form = KostnicaForm()
    if form.validate_on_submit():
        wstaw_kostnice(form.nazwa_kostnicy.data)
        flash(f'Kostnica została dodana', 'success')
        return redirect(url_for('kostnica'))
    return render_template('kostnica.html', title="Kostnica", form=form, kostnice=kostnice)


@app.route('/krematorium/', methods=['GET', 'POST'])
def krematorium():
    krematoria = pobierz_krematoria()
    print(krematoria)
    form = KrematoriumForm()
    if form.validate_on_submit():
        wstaw_krematorium(form.nazwa_krematorium.data)
        flash(f'Krematorium zostało dodane', 'success')
        return redirect(url_for('krematorium'))
    return render_template('krematorium.html', title="Krematorium", form=form, krematoria=krematoria)


#Below are the routes that you need to be logged in to get access to
@app.route('/trumna/', methods=['GET', 'POST'])
@login_required
def trumna():
    trumny = pobierz_nieprzypisane_trumny()
    print(trumny)
    puste_trumny = pobierz_puste_trumny()
    print("Puste trumny")
    print(puste_trumny)
    form_krypta = PrzypiszTrumneKrypcieForm()
    form_nagrobek = PrzypiszTrumneNagrobkowiForm()
    form_nieboszczyk = PrzypiszTrumneNieboszczykowiForm()
    form_nowa_trumna = DodajTrumneForm()
    if form_nieboszczyk.validate_on_submit():
        przypisz_nieboszczyka_do_trumny(form_nieboszczyk.id_nieboszczyka.data, form_nieboszczyk.id_trumny.data )
        return redirect(url_for('trumna'))
    elif form_krypta.validate_on_submit():
        przypisz_trumnie_krypte(form_krypta.id_trumny.data, form_krypta.id_krypty.data )
        return redirect(url_for('trumna'))
    elif form_nagrobek.validate_on_submit():
        przypisz_trumnie_nagrobek(form_nagrobek.id_trumny.data, form_nagrobek.id_nagrobka.data )
        return redirect(url_for('trumna'))
    elif form_nowa_trumna.validate_on_submit():
        dodaj_trumne(form_nowa_trumna.material.data, form_nowa_trumna.id_kostnicy.data)
        return redirect(url_for('trumna'))
    return render_template('trumna.html', title="Trumny", form_krypta=form_krypta,\
     form_nagrobek =form_nagrobek, form_nieboszczyk=form_nieboszczyk, \
     form_nowa_trumna=form_nowa_trumna,
     trumny=trumny, puste_trumny=puste_trumny)


@app.route('/urna/', methods=['GET', 'POST'])
@login_required
def urna():
    urny = pobierz_nieprzypisane_urny()
    print(urny)
    puste_urny = pobierz_puste_urny()
    print("Puste urny")
    print(puste_urny)
    form_krypta = PrzypiszUrneKrypcieForm()
    form_nieboszczyk = PrzypiszUrneNieboszczykowiForm()
    form_nowa_urna = DodajUrneForm()
    if form_krypta.validate_on_submit():
        przypisz_urnie_krypte(form_krypta.id_urny.data, form_krypta.id_krypty.data )
        return redirect(url_for('urna'))
    elif form_nieboszczyk.validate_on_submit():
        przypisz_nieboszczyka_do_urny(form_nieboszczyk.id_nieboszczyka.data, form_nieboszczyk.id_urny.data )
        return redirect(url_for('urna'))
    elif form_nowa_urna.validate_on_submit():
        dodaj_urne(form_nowa_urna.material.data, form_nowa_urna.id_krematorium.data)
        return redirect(url_for('urna'))
    return render_template('urna.html', title="Urny", form_krypta=form_krypta,\
    form_nieboszczyk=form_nieboszczyk, urny=urny, puste_urny=puste_urny,
    form_nowa_urna=form_nowa_urna)


@app.route('/pracownik/', methods=['GET', 'POST'])
@login_required
def pracownik():
    trumniarze = pobierz_trumniarzy()
    urniarze = pobierz_urniarzy()
    sprzatacze = pobierz_sprzataczy()
    trumniarz_form = DodajTrumniarzaForm()
    urniarz_form = DodajUrniarzaForm()
    sprzatacz_form = DodajSprzataczaForm()
    print(trumniarze)
    if trumniarz_form.validate_on_submit():
        dodaj_trumniarza(trumniarz_form.imie_trumniarza.data)
        return redirect(url_for('pracownik'))
    if urniarz_form.validate_on_submit():
        dodaj_urniarza(urniarz_form.imie_urniarza.data)
        return redirect(url_for('pracownik'))
    if sprzatacz_form.validate_on_submit():
        dodaj_sprzatacza(sprzatacz_form.imie_sprzatacza.data)
        return redirect(url_for('pracownik'))
    return render_template('pracownik.html', title='Pracownik',\
    trumniarz_form=trumniarz_form, urniarz_form=urniarz_form, \
    sprzatacz_form=sprzatacz_form, trumniarze = trumniarze, \
    urniarze=urniarze, sprzatacze=sprzatacze)


@app.route("/register/", methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('home'))
    form = RegistrationForm()
    if form.validate_on_submit():
        hashed_password = bcrypt.generate_password_hash(form.password.data).decode('utf-8')
        user = User(username=form.username.data, email=form.email.data, password=hashed_password)
        db.session.add(user)
        db.session.commit()
        flash(f'Your account has been created, you can log in now.', 'success')
        return redirect(url_for('login'))
    return render_template('register.html', title='Register', form=form)


@app.route("/login/", methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('home'))
        set_admin_role()
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()
        if user and bcrypt.check_password_hash(user.password, form.password.data):
            login_user(user, remember=form.remember.data)
            next_page = request.args.get('next')
            set_admin_role()
            return redirect(next_page) if next_page else redirect(url_for('about'))
        else:
            flash('Login Unsuccessful. Please check email and password', 'danger ')
    return render_template('login.html', title='Login', form=form)


@app.route("/logout/")
def logout():
    logout_user()
    set_client_role()
    return redirect(url_for('about'))


def save_picture(form_picture):
    random_hex = secrets.token_hex(8)
    _, f_ext = os.path.splitext(form_picture.filename) #Underscore is for the variable we dont use
    picture_fn = random_hex + f_ext
    picture_path = os.path.join(app.root_path, 'static/profile_pics', picture_fn)
    output_size = (125, 125)
    i = Image.open(form_picture)
    i.thumbnail(output_size) #resizing the image
    i.save(picture_path)
    return picture_fn


@app.route("/account/ ", methods=['GET', 'POST'])
@login_required
def account():
    form = UpdateAccountForm()
    if form.validate_on_submit():
        if form.picture.data:
            picture_file = save_picture(form.picture.data)
            current_user.image_file = picture_file
        current_user.username = form.username.data
        current_user.email = form.email.data
        db.session.commit()
        flash('Your account has been updated!', 'success')
        return redirect(url_for('account'))
    elif request.method == 'GET':
        form.username.data = current_user.username
        form.email.data = current_user.email
    image_file = url_for('static', filename='profile_pics/' + current_user.image_file)
    return render_template('account.html', title='Account',
                            image_file=image_file, form=form)
