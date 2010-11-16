# usage:
# netstat -I bond0 -w 1 -b | ruby throughput.rb

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
  units = %w(b\  KB MB GB TB)
  while unit = units.shift
    if val_in_bytes < 1024
      break
    end
    
    val_in_bytes /= 1024.0
  end
  
  "%.2f%s/s" % [val_in_bytes, unit]
end

def parse_input(input)
  while line = input.readline
    #puts "parsing: #{line}"
    next unless line.match /(\s+\d+){7}/
  
    line = parse_line(line)
  
    puts "#{Time.now} --  UP:  %s\t | DOWN:  %s" % [ hr_unit(line[:bytes_out]).ljust(10), hr_unit(line[:bytes_in]).ljust(10) ]
  
  end
end

parse_input(STDIN)
