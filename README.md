# Postgres Interactive User Manager  (PIUM)

#### Running:

> bundle

and

> ruby main.rb

## Using:
* create: Create User to specified database

* rm: Removes User from specified database

* add: Add Role to User: assigns one of the presetted roles to a user on a given database

* list: Lists all Users and respective attributes or lists all Databases currently managed by PIUM

* help: displays commands usage

* exit: Quit PIUM

## Commands Usage:

- create \<username> \<password> \<database> \[options]

	* options list: 
  
		* SUPERUSER | NOSUPERUSER | 
  
		* CREATEDB | NOCREATEDB | 
  
		* CREATEROLE | NOCREATEROLE | 
  
		* INHERIT | NOINHERIT |
  
		* REPLICATION | NOREPLICATION

- add \<username> \< ADMIN | READ_ONLY | READ_WRITE > \<database>
	
	* ADMIN: User has total access to database, including the permission to create|drop tables;
	
	* READ_WRITE: User have total access to database values, but not the permission to create|drop tables;
	
	* READ_ONLY: User can only use SELECT command within the database;

- rm \<username> \<database>

- list \< users | databases | groups > 
