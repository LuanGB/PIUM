require 'rubygems'
require 'bundler'

Bundler.require

######################################################################################

@databases = {
	teste1: PG::Connection.open(host: :localhost , dbname: :teste1 , user: :luan, password: "P@55W0rdPG"),
	teste2: PG::Connection.open(host: :localhost , dbname: :teste2 , user: :luan, password: "P@55W0rdPG"),
	teste3: PG::Connection.open(host: :localhost , dbname: :teste3 , user: :luan, password: "P@55W0rdPG")
}

def add_user(name, password, db, permissions)
	
	begin
		res = db.exec_params("CREATE ROLE #{name} LOGIN #{permissions.join(" ") unless permissions.nil?} ENCRYPTED PASSWORD '#{password}'")
		puts res.cmd_status
	rescue Exception => e
		puts e.message
	end
end

def remove_user(name, db)
	begin
		res = db.exec_params("DROP ROLE IF EXISTS #{name}")
		puts res.cmd_status
	rescue Exception => e
		puts e.message
	end
end

def list_users(db)
	res = db.exec_params(
		'SELECT u.usename AS "User name",
			  u.usesysid AS "User ID",
			  CASE WHEN u.usesuper AND u.usecreatedb THEN CAST(\'superuser, create
			database\' AS pg_catalog.text)
			       WHEN u.usesuper THEN CAST(\'superuser\' AS pg_catalog.text)
			       WHEN u.usecreatedb THEN CAST(\'create database\' AS
			pg_catalog.text)
			       ELSE CAST(\'\' AS pg_catalog.text)
			  END AS "Attributes"
			FROM pg_catalog.pg_user u
			ORDER BY 1')
	puts res.to_a
end

def list_databases
	puts @databases.keys.join(" | ")
end

#TODO: add and remove database

#############################################################################

cmd_text = "Available commands:
  add: Adds User to specified database
  rm: Removes User from specified database
  lu: Lists all Users from specified database and respective attributes
  ld: Lists all Databases currently managed by PUMI
  cmd: displays this message
  help: displays commands usage
  exit: Quit PUMI"

help_text = "Commands Usage:
  - add <username> <password> <database> <options>
    options list: 
    SUPERUSER | NOSUPERUSER | 
    CREATEDB | NOCREATEDB | 
    CREATEROLE | NOCREATEROLE | 
    INHERIT | NOINHERIT |
    REPLICATION | NOREPLICATION >

  - rm <username> <database>
  
  - lu <database>
"

puts "Postgres Users Manager Interactive (PUMI)
(type 'cmd' for list the commands and 'help' to get help)"

while true

	print '$ '
	cmd = gets.chomp.split(" ")

	case cmd[0]
		when 'add'
			begin
				if cmd.size < 5 
					raise ArgumentError, "# ArgumentError: Wrong Number of Arguments (given #{cmd.size}, expected 4)", caller
				end
				add_user cmd[1], cmd[2], @databases[cmd[3].to_sym], cmd[4..cmd.size-1]
			rescue Exception => e
				puts e.message
			end

		when 'rm'
			begin
				if cmd.size < 3
					raise ArgumentError, "# ArgumentError: Wrong Number of Arguments (given #{cmd.size-1}, expected 2)", caller
				end
				remove_user cmd[1], @databases[cmd[2].to_sym]
			rescue Exception => e
				puts e.message
			end

		when 'lu'
			begin
				if cmd.size != 2
					raise ArgumentError, "# ArgumentError: Wrong Number of Arguments (given #{cmd.size-1}, expected 1)", caller
				end
				list_users @databases[cmd[1].to_sym]
			rescue Exception => e
				puts e.message
			end
		when 'ld'
			list_databases
		when 'cmd'
			puts cmd_text
		when 'help'
			puts help_text
		when 'exit'
			break
		else
			puts "# Command not found."
	end

end
puts "Bye!"