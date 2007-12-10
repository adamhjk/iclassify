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
runit_service_dir: /var/service
application_name: iclassify
user: www-data
group: www-data
env_vars:
  PATH: /var/lib/gems/1.8/bin:$PATH
"
      )
    end
    if ENV["SOLR_RUNIT"] != "no"
      write_file("examples/solr-run",
        "#!/bin/sh
export JAVA_HOME=/usr/lib/jvm/java-6-sun
cd #{ENV["ICBASE"]}/vendor/plugins/acts_as_solr/solr
exec 2>&1
exec \
  chpst -u #{ENV["ICUSER"]} /usr/bin/java -Dsolr.data.dir=#{ENV["ICBASE"]}/vendor/plugins/acts_as_solr/solr/solr/data/production -Djetty.port=8983 -jar #{ENV["ICBASE"]}/vendor/plugins/acts_as_solr/solr/start.jar"
      )
      write_file("examples/solr-log", "#!/bin/sh
exec svlogd -tt ./main"
      )
    end
    if ENV["DATABASE_YAML"] != "no"
      write_file("config/database.yml",
        "production:
  adapter: mysql
  database: #{ENV["DBNAME"]}
  username: #{ENV["DBUSER"]}
  password: #{ENV["DBPASS"]}
  hostname: localhost",
    true
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
  
  def write_file(file, contents, force=false)
    file_path = File.join(ENV["ICBASE"], file)
    if ! FileTest.exists?(file_path) || force
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