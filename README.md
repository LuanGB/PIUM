# Postgres Interactive User Manager  (PIUM)

#### Running:

> bundle

and

> ruby main.rb

## Using:
* add: Adds User to specified database

* rem: Removes User from specified database

* lu: Lists all Users from specified database and respective attributes

* ld: Lists all Databases currently managed by PUMI

* cmd: displays this message

* help: displays commands usage

* exit: Quit PIUM"

## Commands Usage:

- add \<username> \<password> \<database> \<options>

* options list: 
  
	SUPERUSER | NOSUPERUSER | 
  
	CREATEDB | NOCREATEDB | 
  
	CREATEROLE | NOCREATEROLE | 
  
	INHERIT | NOINHERIT |
  
	REPLICATION | NOREPLICATION

- rem \<username> \<database>

- lu \<database>