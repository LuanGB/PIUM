# Postgres Interactive User Manager  (PIUM)

#### Running:

> bundle

and

> ruby main.rb

## Using:
* add: Adds User to specified database

* rm: Removes User from specified database

* aru: Assign Role to User: assigns one of the presetted roles to a user on a given database

* lu: Lists all Users from specified database and respective attributes

* ld: Lists all Databases currently managed by PUMI

* cmd: displays this message

* help: displays commands usage

* exit: Quit PIUM"

## Commands Usage:

- add \<username> \<password> \<database> \[options]

	* options list: 
  
		* SUPERUSER | NOSUPERUSER | 
  
		* CREATEDB | NOCREATEDB | 
  
		* CREATEROLE | NOCREATEROLE | 
  
		* INHERIT | NOINHERIT |
  
		* REPLICATION | NOREPLICATION
	
	
- aru \<username> \< ADMIN | READ_ONLY | READ_WRITE > \<database>
	
	* ADMIN: User has total access to database, including the permission to create|drop tables;
	
	* READ_WRITE: User have total access to database values, but not the permission to create|drop tables;
	
	* READ_ONLY: User can only use SELECT command within the database;

- rm \<username> \<database>

- lu \<database>
