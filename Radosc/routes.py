import os
import secrets
from PIL import Image #for resizing uploaded images
from flask import render_template, url_for, flash, redirect, request, abort
from Radosc import app, db, bcrypt
from Radosc.forms import RegistrationForm, LoginForm, UpdateAccountForm, PostForm, \
NieboszczykForm, KryptaForm, KostnicaForm, KrematoriumForm, WyszukajNieboszczykaForm
from Radosc.database import wstaw_krypte, wstaw_kostnice, wstaw_krematorium, wstaw_nieboszczyka, \
pobierz_krypty, pobierz_kostnice, pobierz_krematoria, pobierz_nieboszczykow, \
pobierz_sredni_wiek, wyszukaj_nieboszczyka, mieszkancy_odrodzenia, mieszkancy_krypty, \
set_admin_role, set_client_role

from Radosc.models import User, Post
from flask_login import login_user, logout_user, current_user, login_required

from flask import jsonify
import datetime

@app.route("/home")
def home():
    posts = Post.query.all()
    return render_template('home.html', posts=reversed(posts))

@app.route("/")
@app.route("/about")
def about():
    return render_template('about.html', title='About')

@app.route("/easteregg")
def egg():
    return "<h1> 🥚💕! </h1>"

#just checking some functionalities - to dump
#wooo is it using get method??? And returning nice and neat json?
@app.route("/dydej/")
def hello():
    return jsonify({'name':'Antoni', 'surname':'Dydej'})

@app.route('/nieboszczyk/', methods=['GET', 'POST'])
def nieboszczyk():
    nieboszczycy = pobierz_nieboszczykow()
    print(nieboszczycy)
    form = NieboszczykForm()
    wyszukaj_form = WyszukajNieboszczykaForm()
    sredni_wiek = round(pobierz_sredni_wiek()[0][0], 2)
    search_result = ()
    #formularz do wprowadzania nieboszczyków
    if form.validate_on_submit():
        # TODO: Make some frontend validation here!!!
        print('**************************************************************')
        print(wstaw_nieboszczyka(form.username.data, form.data_urodzenia.data, form.data_zgonu.data))
        print('**************************************************************')
        flash(f'Twoje zgłoszenie zostało odnotowane', 'success')
        nieboszczycy = pobierz_nieboszczykow()
        sredni_wiek = round(pobierz_sredni_wiek()[0][0], 2)

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
        sredni_wiek=sredni_wiek, search_result=search_result)


# Te 3 routy poniżej powinny być dostępne po zalogowaniu
@app.route('/krypta/', methods=['GET', 'POST'])
def krypta():
    krypty = pobierz_krypty()
    print(krypty)
    print()
    form = KryptaForm()
    #UWAGA będę teraz robił skomplikowaną operację!
    #Dla każdej krypty pobieram jej mieszkańców i zapisuję w zmiennej!
    mieszkancy = [ mieszkancy_krypty(krypta[1]) for krypta in krypty]
    print("Zmienna mieszkancy: " + str(mieszkancy) )
    print()
    krypty = list(zip(krypty,mieszkancy))
    if form.validate_on_submit():
        #print(f"Nazwa: {form.nazwa_krypty.data} Pojemnosc: {form.pojemnosc.data}")
        wstaw_krypte(form.nazwa_krypty.data, form.pojemnosc.data)
        flash(f'Krypta została dodana', 'success')
        krypty = pobierz_krypty()
        print("Przed referencją: " + str(krypty) )
        mieszkancy = [ mieszkancy_krypty(krypta[1]) for krypta in krypty]
        krypty = list(zip(krypty,mieszkancy))
        print("Zmienna krypty: " + str(krypty) )
    return render_template('krypta.html', title="Krypta", form=form, \
            krypty=krypty, mieszkancy=mieszkancy)


@app.route('/kostnica/', methods=['GET', 'POST'])
def kostnica():
    kostnice = pobierz_kostnice()
    print(kostnice)
    form = KostnicaForm()

    if form.validate_on_submit():
        wstaw_kostnice(form.nazwa_kostnicy.data)
        flash(f'Kostnica została (prawie) dodana', 'success')
        kostnice = pobierz_kostnice()
    return render_template('kostnica.html', title="Kostnica", form=form, kostnice=kostnice)


@app.route('/krematorium/', methods=['GET', 'POST'])
def krematorium():
    krematoria = pobierz_krematoria()
    print(krematoria)
    form = KrematoriumForm()
    if form.validate_on_submit():
        wstaw_krematorium(form.nazwa_krematorium.data)
        flash(f'Krematorium zostało (prawie) dodane', 'success')
        krematoria = pobierz_krematoria()
    return render_template('krematorium.html', title="Krematorium", form=form, krematoria=krematoria)


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


@app.route("/post/new", methods=['GET', 'POST'])
@login_required
def new_post():
    form = PostForm()
    if form.validate_on_submit():
        post = Post(title=form.title.data, content=form.content.data, author=current_user)
        db.session.add(post)
        db.session.commit()
        flash("The post has been created!", 'success')
        return redirect(url_for('home'))
    return render_template('create_post.html', title='New Post', form=form, legend='New Post')

@app.route("/post/<int:post_id>")
def post(post_id):
    post = Post.query.get_or_404(post_id)
    return render_template('post.html', title=post.title, post=post)

@app.route("/post/<int:post_id>/update", methods=['GET', 'POST'])
@login_required
def update_post(post_id):
    post = Post.query.get_or_404(post_id)
    if post.author != current_user:
        abort(403)
    form = PostForm()
    if form.validate_on_submit():
        post.title = form.title.data
        post.content = form.content.data
        db.session.commit()
        flash('Your post has been updated!', 'success')
        return redirect(url_for('post', post_id=post.id))
    elif request.method == 'GET':
        form.title.data = post.title
        form.content.data = post.content
    return render_template('create_post.html', title='Update Post', form=form, legend='Update Post')

@app.route("/post/<int:post_id>/delete", methods=['POST'])
@login_required
def delete_post(post_id):
    post = Post.query.get_or_404(post_id)
    if post.author != current_user:
        abort(403)
    db.session.delete(post)
    db.session.commit()
    flash('Your post has been deleted!', 'success')
    return redirect(url_for('home'))
