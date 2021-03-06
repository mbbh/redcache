#!/usr/bin/env ruby
require 'redcache'
require 'readline'

include RedCache::Color

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

def get_nodes_on_level(rc, match)
  match = rc.get_namespace if match.empty? && rc.get_namespace != "/"
  match = "" if match == "/"

  nodes, vnodes = rc.get_nodes_at(match).reduce([[],[]]) do |(n,vn),node|
    case node
    when %r{^/?#{match}/?[^/]+$}
      n << node.sub(%r{/?#{match}/?},'')
    when %r{^/?#{match}/[^/]+/.*$}
      vn << node.sub(%r{/?#{match}/([^/]+)/.*$}, '\1')
    end
    next [n,vn]
  end
  return [vnodes, nodes]
end

def do_namespace_change(rc, namespace)
  vnodes, nodes = get_nodes_on_level(rc, rc.get_namespace)
  if namespace == ".." && rc.get_namespace != rc.delim
    rc.pop_namespace
  elsif vnodes.include?(namespace) || namespace == "/"
    rc.add_namespace(namespace)
  else
    puts "#{namespace}: No such directory"
  end
end

def display_nodes(rc, buf)
  match = buf.sub(/^ls\s*/, '')
  vnodes, nodes = get_nodes_on_level(rc, match)
  puts vnodes.map {|n| blue(n)}.join("\n") unless vnodes.empty?
  puts nodes.map {|n| green(n)}.join("\n") unless nodes.empty?
end

rc = RedCache::Connector.new

while buf = Readline.readline("% ", true)
  exit 0 if buf == "exit"
  case buf
  when /^ls/ then display_nodes(rc, buf)
  when /^echo.*>/ then do_write(rc, *buf.sub(/^echo\s+/, '').split(/\s*>\s*/))
  when /^cat / then do_read(rc, buf.sub(/^cat\s+/, ''))
  when /^rm .*/ then do_remove(rc, buf.sub(/^rm /, ''))
  when /^cd .*/ then do_namespace_change(rc, buf.sub(/^cd /,''))
  end
end

