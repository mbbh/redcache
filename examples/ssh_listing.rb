# Example: Demonstrate timeout/caching functionality using net-ssh and a given
# remove host/user.
# Usage: ssh_listing.rb bob some.machine.org

require 'net/ssh'
require 'readline'
load 'redcache.rb'

$user, $hostname = ARGV

def update_ssh_listing(path)
  Net::SSH.start($hostname, $user, :config => true) do |ssh|
    stdout = ""
    ssh.exec!("ls -l #{path}") do |channel, stream, data|
      stdout << data if stream == :stdout
    end
    return stdout
  end
end

def print_selection(paths)
  puts "Choose path to execute remote select from (cached)"
  paths.each_with_index do |p, i|
    puts "#{i+1}: #{p}"
  end
  puts "^D to end the example"
end

rcl = RedCache::Collector.new

paths = ["/home/#{$user}/test", "/var/run", "/etc/"]
paths.each do |p|
  rcl.register("/net/host/#{$hostname}/#{p}", true, -> {update_ssh_listing(p)})
  rcl.temporary("/net/host/#{$hostname}/#{p}", 50)
end

print_selection(paths)
while s = Readline.readline("% ")
  if s.to_i > 0 && p=paths[s.to_i-1]
    puts rcl.get("/net/host/#{$hostname}/#{p}")
    puts "="*79
  end
  print_selection(paths)
end
