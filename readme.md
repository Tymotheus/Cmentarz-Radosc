<h2>Databases 1 project </h2>
<h4>For AGH UST university classes </h4>


* <b>Frontend:</b> HTML + Bootstrap
* <b>Backend:</b> Python & Flask 🐍
* <b>Database:</b> PostgreSQL
* <b>Python + Postgres connection:</b> psycopg2 package

<h3>Notes</h3>

<b>Running app notes:</b>
Before running the app, a proper database should be created. Scripts for it should be run in the following order.
<ol>
<li> creates.sql</li>
<li> triggers.sql</li>
<li> views.sql</li>
<li> inserts.sql</li>
</ol>

After that you just need to run app.py script using command:
```python
python app.py
```
<b>Notes:</b>
* Script 5, roles.sql preferably should not be run. It is redundant and was added only to meet
the requirements of the project for the roles.
* Another requirement was to make the app and all its functions in Polish language - I might rewrite it to English one day.

<b>Note 18.02.2021:</b>
<b>Note concerning the deploy</b>
I was deploying the base to ElephantSQL. I came across the following problem:
I had to rewrite inserts, more precisely the date to other format:
FROM '30.04.1892' TO '1892-04-30'

<b>Note 17.02.2021:</b>
Added a lot. Pretty much. Additional tables and triggers and backend validation.

<b>Note 16.02.2021:</b>
I have added basic search by the name of the client.

<b>Note 15.02.2021:</b>
For my database I have now working form for posting new data
and showing data downloaded from the db.

<b>Note 14.02.2021:</b>
Forms are now valid also for the backend db side.

<b>Note 13.02.2021:</b>
Added valid forms on the frontend site.

<b>Note 10.02.2021:</b>
Watched Correy's flask tutorials and have working skeleton; created basic logic and ERD diagram.


<h3>Further development:</h3>

* Rewriting postgres decorators in database.py. Making 1 universal decorator instead of the current 2.
* Adding appropriate feedback when the searched deadman does not exist (error/warning prompt)
* In general fixing prompts that user receives - they can be confusing rn
* Adding constraints to the database (so one deadman can have only a tombstone OR a crypt and a coffin OR an urn)
* Adding proper authorisation and access levels for customers/workers
* Clean the project (in general) - there is some dead code, also from the blog-like skeleton - for example .js script and mechanics of blogposts
* Not exactly sure if granting client/admin role in current model shouldn't be done before every query - this one right now is a bit messy and done only to meet general criteria of the project
* Making the forms to automatically clean whenever they are sent
* There are a lot of prints around which, I believe, could be changed to system.logs - and displayed only when the appropriate flag is set
* Check out all HTML files and correct the indentations :/
