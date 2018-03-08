require 'rubygems'
require 'bundler'

Bundler.require

######################################################################################

@databases = {
  teste1: [PG::Connection.open(host: :localhost , dbname: :teste1 , user: :luan, password: "P@55W0rdPG")],
  teste2: [PG::Connection.open(host: :localhost , dbname: :teste2 , user: :luan, password: "P@55W0rdPG")],
  APP_STAGING: [PG::Connection.open(host: :localhost , dbname: :teste3 , user: :luan, password: "P@55W0rdPG")]
}

@databases[:APP_STAGING] << @databases[:teste2][0]

######################################################################################

def add_user(name, password, db, options = nil)
	db.each do |db| 
    begin
  		res = db.exec_params("CREATE ROLE #{name} LOGIN #{options.join(" ") unless options.nil?} ENCRYPTED PASSWORD '#{password}'")
  		puts res.cmd_status
  	rescue Exception => e
  		puts e.message
  	end
  end
end

def remove_user(name, db)
  db.each do |db| 
  	begin
  		res = db.exec_params("DROP ROLE IF EXISTS #{name}")
  		puts res.cmd_status
  	rescue Exception => e
  		puts e.message
  	end
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

def assign_role(user, role, db)
  role.downcase!
	case role
	when 'read_only'
		assign_role_read_only(user, db)
	when 'read_write'
		assign_role_read_write(user, db)
	when 'admin'
		assign_role_admin(user, db)
	else
		puts "Role not found."
	end
end

###ROLES###

def assign_role_admin(user, db)
	db.each do |db| 
    begin
    	db.exec_params("GRANT USAGE ON SCHEMA public TO #{user}")
    	db.exec_params("GRANT ALL ON SCHEMA public TO #{user}")
    	db.exec_params("GRANT ALL ON ALL TABLES IN SCHEMA public TO #{user}")
    	puts "$ #{user} is now an ADMIN User."
  	rescue Exception => e
  		puts e.message
  	end
  end
end

def assign_role_read_only(user, db)
	 db.each do |db| 
    begin
    	db.exec_params("GRANT USAGE ON SCHEMA public TO #{user}")
    	db.exec_params("REVOKE CREATE ON SCHEMA public FROM public, #{user}")
    	db.exec_params("REVOKE ALL ON ALL TABLES IN SCHEMA public FROM #{user}")
    	db.exec_params("GRANT SELECT ON ALL TABLES IN SCHEMA public TO #{user}")
    	puts "$ #{user} is now a READ_ONLY User."
  	rescue Exception => e
  		puts e.message
  	end
  end
end

def assign_role_read_write(user, db)
	 db.each do |db| 
    begin
    	db.exec_params("GRANT USAGE ON SCHEMA public TO #{user}")
    	db.exec_params("REVOKE CREATE ON SCHEMA public FROM public, #{user}")
    	db.exec_params("GRANT ALL ON ALL TABLES IN SCHEMA public TO #{user}")
    	puts "$ #{user} is now a READ_WRITE User."
  	rescue Exception => e
  		puts e.message
    end
	end
end

######################################################################################

cmd_text = "Available commands:
  add: Adds User to specified database or DB Group
  rm: Removes User from specified database or DB Group
  aru: Assign Role to User: assigns one of the presetted roles to a user on a given database or DB Group
  lu: Lists all Users from specified database and respective attributes
  ld: Lists all Databases currently managed by PUMI
  cmd: displays this message
  help: displays commands usage
  exit: Quit PUMI"

help_text = "Commands Usage:
  - add <username> <password> <database> [options]
    options list: 
    SUPERUSER | NOSUPERUSER | 
    CREATEDB | NOCREATEDB | 
    CREATEROLE | NOCREATEROLE | 
    INHERIT | NOINHERIT |
    REPLICATION | NOREPLICATION >
    options parameter is opitional
	
  - aru <username> < ADMIN | READ_ONLY | READ_WRITE > <database>
    ADMIN: User has total access to database, including the permission to create|drop tables;
    READ_WRITE: User have total access to database values, but not the permission to create|drop tables;
    READ_ONLY: User can only use SELECT command within the database;

  - rm <username> <database>
  
  - lu <database>
"

puts "Postgres Interactive Users Manager (PIUM)
(type 'cmd' for list the commands and 'help' to get help)"

while true

	print '$ '
	cmd = gets.chomp.split(" ")

	case cmd[0]
		when 'add'
			begin
				if cmd.size < 4
					raise ArgumentError, "# ArgumentError: Wrong Number of Arguments (given #{cmd.size}, expected at least 3)", caller
				end
				add_user cmd[1], cmd[2], @databases[cmd[3].to_sym], cmd[4..cmd.size-1]
			rescue Exception => e
				puts e.message
			end

		when 'rm'
			begin
				if cmd.size != 3
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

		when 'aru'
      begin
        if cmd.size != 4
          raise ArgumentError, "# ArgumentError: Wrong Number of Arguments (given #{cmd.size-1}, expected 1)", caller
        end
        assign_role cmd[1], cmd[2], @databases[cmd[3].to_sym]
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