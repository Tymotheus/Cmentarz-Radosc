Note 17.02.2021:
Added a lot. Pretty much. Additional tables and triggers and backend validation.

Note 16.02.2021:
I have added basic search by the name of the client.

Note 15.02.2021:
For my database I have now working form for posting new data
and showing data downloaded from the db.

Note 14.02.2021:
Forms are now valid also for the backend db side.

Note 13.02.2021:
Added valid forms on the frontend site.

Note 10.02.2021:
Watched Correy's flask tutorials and have working skeleton; created basic logic and ERD diagram.

<h2>Databases 1 course project </h2>

* <b>Frontend:</b> HTML + Bootstrap
* <b>Backend:</b> Python & Flask
* <b>Database:</b> PostgreSQL
* <b>Python + Postgres connection:</b> psycopg2 package


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
