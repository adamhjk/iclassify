require 'fileutils'
require 'erb'

namespace "iclassify" do
  task :install do |t|
    must_have_keys = [ "ICBASE", "ICUSER", "ICGROUP", "DBUSER", "DBPASS" ]
    ENV["MONGREL_RUNIT"] ||= "yes"
    ENV["DATABASE_YAML"] ||= "yes"
    ENV["MIGRATE"]       ||= "yes"
    ENV["DBNAME"]        ||= "iclassify_production"
    
    unless check_keys(must_have_keys)
      raise "You must supply: #{must_have_keys.join(", ")}"
    end
    mkdir_p(ENV["ICBASE"]) unless FileTest.directory?(ENV["ICBASE"])
    if FileTest.directory?(ENV["ICBASE"])
      puts "* Creating #{ENV["ICBASE"]}"
      FileUtils.mkdir_p ENV["ICBASE"]
    end
    copy_iclassify_files()

    if ENV["MONGREL_RUNIT"] != "no"
      write_file(
      "examples/mongrel_runit_iclassify.yml", 
      "---
port: 5000
servers: 5
environment: production
cwd: #{ENV["ICBASE"]}
runit_sv_dir: /etc/sv
runit_service_dir: #{File.join(ENV["ICBASE"], "service")}
application_name: iclassify
user: www-data
group: www-data
env_vars:
PATH: /var/lib/gems/1.8/bin:$PATH
"
      )
    end
    if ENV["DATABASE_YAML"] != "no"
      write_file("config/database.yml",
      "production:
  adapter: mysql
  database: #{ENV["DBNAME"]}
  username: #{ENV["DBUSER"]}
  password: #{ENV["DBPASS"]}
  hostname: localhost"
      )
    end
    
    run_migrations() if ENV["MIGRATE"] == "yes"
  end
  
  task :icagent do |t|
    
  end
  
  task :upgrade do |t|
    must_have_keys = [ "ICBASE", "ICUSER", "ICGROUP" ]
    unless check_keys(must_have_keys)
      raise "You must supply: #{must_have_keys.join(", ")}"
    end
    copy_iclassify_files()
    ENV["MIGRATE"] ||= "yes"
    run_migrations if ENV["MIGRATE"] == "yes"
  end
  
  def run_migrations 
    FileUtils.cd(ENV["ICBASE"]) do |dir|
      system("rake db:migrate RAILS_ENV=production")
    end
  end
  
  def write_file(file, contents)
    file_path = File.join(ENV["ICBASE"], file)
    if FileTest.exists?(file_path) 
      puts "* Writing #{file_path}"
      File.open(file_path, "w") do |file|
        file.puts(contents)
      end
    else
      puts "* File #{file_path} exists, not writing again."
    end
  end
  
  def check_keys(keys)
    keys.each do |key|
      return false unless ENV.has_key?(key)
    end
    return true
  end
  
  def copy_iclassify_files
    to_copy = [
      "app",
      "bin",
      "components",
      "config",
      "db",
      "lib",
      "log",
      "public",
      "script",
      "tmp",
      "vendor",
      "Rakefile"
    ]
    to_copy.each do |dir|
      puts "* Copying #{dir}"
      FileUtils.cp_r(
        File.join(File.dirname(__FILE__), '..', '..', dir), 
        File.join(ENV["ICBASE"])
      )
    end
    own_by_www_user = [
      "tmp", 
      "log", 
      "vendor/plugins/acts_as_solr/solr/tmp", 
      "vendor/plugins/acts_as_solr/solr/logs" 
    ]
    own_by_www_user.each do |dir|
      puts "* Setting ownership on #{dir}"
      FileUtils.chown_R(ENV["ICUSER"], ENV["ICGROUP"], File.join(ENV["ICBASE"], dir))
    end
    examples_dir = File.join(ENV["ICBASE"], "examples")
    FileUtils.mkdir_p(examples_dir)
  end

end