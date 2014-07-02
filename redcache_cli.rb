load 'redcache.rb'
load 'redcache_color.rb'
require 'readline'

def do_write(rc, val, key)
  rc.set_path(key, val)
end

def do_read(rc, file)
  result = rc.get_path(file)
  return puts "#{file}: No Such File." if result.nil?
  puts result
end

def do_remove(rc, files)
  files.split(" ").each {|f| rc.purge_nodes_at(f)}
end

def display_nodes(rc, buf)
  match = buf.sub(/^ls\s*/, '')
  nodes = []
  rc.get_nodes_at(match).each do |node|
    case node
    when %r{^/?#{match}/?[^/]+$}
      node.sub!(%r{/?#{match}/?},'') unless nodes.include?(green(node))
      nodes << green(node)
    when /^\/?#{match}\/[^\/]+\/.*$/
      node.sub!(%r{/?#{match}/([^/]+)/.*$}, '\1')
      nodes << blue(node) unless nodes.include?(blue(node))
    end
  end
  puts nodes.join("\n")
end

rc = RedCache.new

while buf = Readline.readline("% ", true)
  exit 0 if buf == "exit"
  case buf
  when /^ls/ then display_nodes(rc, buf)
  when /^echo.*>/ then do_write(rc, *buf.sub(/^echo\s+/, '').split(/\s*>\s*/))
  when /^cat / then do_read(rc, buf.sub(/^cat\s+/, ''))
  when /^rm .*/ then do_remove(rc, buf.sub(/^rm /, ''))
  end
end

