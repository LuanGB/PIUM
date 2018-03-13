require 'rubygems'
require 'bundler'

Bundler.require

######################################################################################

@databases = {
  teste1: [PG::Connection.open(host: :localhost , dbname: :teste1 , user: :luan, password: "P@55W0rdPG")],
  teste2: [PG::Connection.open(host: :localhost , dbname: :teste2 , user: :luan, password: "P@55W0rdPG")],
  teste3: [PG::Connection.open(host: :localhost , dbname: :teste3 , user: :luan, password: "P@55W0rdPG")]
}

@db_groups = {
  APP_STAGING: [@databases[:teste2][0], @databases[:teste1][0]],
  APP_PRODUCTION: [@databases[:teste1][0], @databases[:teste3][0]] 
}

######################################################################################

def add_user(name, password, db, options = nil)
	db.uniq{ |db| db.host }.each do |db| 
    begin
      res = db.exec_params("CREATE ROLE #{name} LOGIN #{options.join(" ") unless options.nil?} ENCRYPTED PASSWORD '#{password}'")
      puts res.cmd_status
    rescue Exception => e
      puts e.message
    end
  end
end

def remove_user(name, db)
  db.uniq{ |db| db.host }.each do |db| 
  	begin
  		res = db.exec_params("DROP ROLE IF EXISTS #{name}")
  		puts res.cmd_status
  	rescue Exception => e
  		puts e.message
  	end
  end
end

def list_users
  @databases.values.uniq{ |db| db[0].host }.each do |db|
    res = db[0].exec_params(
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
end

def list_databases
	puts @databases.keys.join(" | ")
end

def list_groups
  @db_groups.keys.each{ |group| puts "#{group}: [#{@db_groups[group].map{|db| db.db}.join(', ')}]" }
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

help_text = "Available commands:
create: Adds User to specified database or DB Group*
rm: Removes User from specified database or DB Group*
add: Assign Role to User: assigns one of the presetted roles to a user on a given database or DB Group
list: Lists all Users and respective attributes or Databases or Groups currently managed by PIUM
help: displays help text
exit: Quit PIUM

*Be aware these commands will have effect on the host of the given database(s)

Commands Usage:
- create <username> <password> <database> [options]
options list: 
SUPERUSER | NOSUPERUSER | 
CREATEDB | NOCREATEDB | 
CREATEROLE | NOCREATEROLE | 
INHERIT | NOINHERIT |
REPLICATION | NOREPLICATION >
options parameter is opitional

- rm <username> <database>

- add <username> < ADMIN | READ_ONLY | READ_WRITE > <database>
ADMIN: User has total access to database, including the permission to create|drop tables;
READ_WRITE: User have total access to database values, but not the permission to create|drop tables;
READ_ONLY: User can only use SELECT command within the database;

- list < users | databases | groups > 
"


puts "Postgres Interactive Users Manager (PIUM)
(type 'help' to get help)"


dbs = @databases.merge(@db_groups)

while true
	print '$ '
	cmd = gets.chomp.split(' ')

	case cmd[0].downcase
  when 'create'
    begin
      if cmd.size < 4 then raise ArgumentError, "# ArgumentError: Wrong Number of Arguments (given #{cmd.size-1}, expected at least 3)", caller end
      add_user cmd[1], cmd[2], dbs[cmd[3].to_sym], cmd[4..cmd.size-1]
    rescue Exception => e
      puts e.message
    end

  when 'rm'
    begin
      if cmd.size != 3 then raise ArgumentError, "# ArgumentError: Wrong Number of Arguments (given #{cmd.size-1}, expected 2)", caller end
      remove_user cmd[1], dbs[cmd[2].to_sym]
    rescue Exception => e
      puts e.message
    end

  when 'add'
    begin
      if cmd.size != 4 then raise ArgumentError, "# ArgumentError: Wrong Number of Arguments (given #{cmd.size-1}, expected 3)", caller end
      assign_role cmd[1], cmd[2], dbs[cmd[3].to_sym]
    rescue Exception => e
      puts e.message
    end

  when 'list'
    case cmd[1].downcase
    when 'users'
      list_users
    when 'databases'
      list_databases
    when 'groups'
      list_groups
    else
      puts '# No option provided. Choose between USERS, DATABASES or GROUPS'
    end
  
  when 'help'
    puts help_text
  
  when 'exit'
    break
  
  else
    puts "# Command not found."
  end

end
puts "Bye!"