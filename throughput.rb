# usage:
#   parse stdin:
#     netstat -I bond0 -w 1 -b | ruby throughput.rb
#   interface throughput:
#     ruby throughput.rb en1

require 'pp'

def parse_line(line)
  column_titles = [ :packets_in, :errs_in, :bytes_in, :packets_out, :errs_out, :bytes_out, :colls ]
  columns = line.split(/\s+/)
  columns.shift
  columns = columns.collect { |c| c.to_i }
  
  Hash[*column_titles.zip(columns).flatten]
end

# take a value in bytes (as int) and return it as a string
# ie: 1024 => 1KB
# supports up to TB
def hr_unit(val_in_bytes)
  val_in_bytes = val_in_bytes.to_f
  units = %w(KB MB GB TB)
  
  while unit = units.shift
    val_in_bytes /= 1024.0
    
    if val_in_bytes < 1024
      break
    end
  end
    
  "%.2f%s/s" % [ val_in_bytes, unit ]
end

def parse_input(input)
  while line = input.readline
    #puts "parsing: #{line}"
    next unless line.match /(\s+\d+){7}/
  
    line = parse_line(line)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    justsize = 10 # the size of the text justification
  
    puts "#{timestamp} -- UP: %s  |  DOWN: %s" % [ hr_unit(line[:bytes_out]).rjust(justsize), hr_unit(line[:bytes_in]).rjust(justsize) ]
  
  end
end

if ARGV.length == 0
  # no input, so parse STDIN
  parse_input(STDIN)
else
  # interface was supplied, so let's take some work away from the user and construct the command ourselves
  interface = ARGV.shift
  
  command = "netstat -I #{interface} -w 1 -b"
  
  IO.popen(command) do |input|
    parse_input input
  end
end