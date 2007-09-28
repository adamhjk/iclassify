#!/usr/local/bin/ruby 

1000.times do |t|
  uuid = `uuidgen`.chomp!
  puts "INSERT INTO nodes (uuid, description) values ('#{uuid}', 'host_#{t.to_s}');"
end
