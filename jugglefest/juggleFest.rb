#! ruby
require 'optparse'


class JugglerFest

  def initialize 
    @filename = ""
    @outputname = ""
    @jugglerPerCircuit = 0
    # {:name => {:h => 0, :e => 0, }}
    @jugglers = Hash.new 
    # {:juggler => [:c1, :c2, etc]
    @matches_queue = Hash.new
    # keep a track of who is allocated and who is not
    # {:jugler => true/false}
    @matches_allocated = Hash.new
    # {:name =>  {:h => 0, :e => 0, :circuit => []}}
    @circuits = Hash.new 
    # {:circuit_ name => [:name1, :name2,..]}}
    @matchs = Hash.new
  end

  def setFilenames (input, output)
    @filename = input
    @outputname = output
  end



  # dot product of 3 dimension arrays x and y
  # result is typed in float
  def dotProduct(x, y)
    res = 0.0
    x.each_index { |i|
      res += x[i].to_f * y[i].to_f
    }
    return res
  end


  # Generate the lineup
  # parse, fill the data structures, then compute dot products
  # Compute line up and pretty print the output
  def generate
    if !File.file?(@filename) and !File.readable?(@filename)
      puts "Incorrect file name or insufficient rights for " + @filename
    else
      file = File.new @filename, "r"
      #begin
        self.parseAndFill(file)
        self.fillMatches
        self.generateOutput
      #rescue
        #puts "Line up generation aborted because an exception was raised!"
      #end
    end  
  end

  # relaunch the lineup algorithm as long as there is jugglers 
  # in the waiting queue
  def fillMatches
    matchFistPass
    while !@matches_queue.empty?
      if !@matches_allocated.has_value?(false)
        break
      end
        matchRecursive(getHashCopy @matches_queue)
    end
  end

  # get a copy of the waiting queue hash
  def getHashCopy hashToCopy
    newHash = Hash.new
    newHash.update(hashToCopy)
    return newHash
  end

  # Delete a circuit from the circuit list of a specific juggler
  # remove it from the jugglers waiting list if in it
  def refreshJugglersQueue juggler, circuit
    if !@matches_queue.include? juggler
      @matches_queue[juggler] = @jugglers[juggler][:circuits].keys   
    end
     @matches_queue[juggler].delete(circuit)
     @matches_allocated[juggler] = false
    if @matches_queue[juggler].empty?
      @matches_queue.delete(juggler)
      @matches_allocated.delete(juggler)
    end
  end

  # Compute the lineup
  def matchFistPass
    @jugglers.each do |k, v|
      keys = v[:circuits].keys
      i = 0
      while i < keys.count
        if @matchs[keys[i]].nil?
          @matchs[keys[i]] = Array.new()
          @matchs[keys[i]]  = @matchs[keys[i]] << [k, @jugglers[k][:circuits][keys[i]]]
          break 
        elsif @matchs[keys[i]].count < @jugglerPerCircuit
          @matchs[keys[i]] = @matchs[keys[i]] << [k, @jugglers[k][:circuits][keys[i]]]
          break 
        else
          @matchs[keys[i]].sort! do |a, b|
            b[1] <=> a[1]
           end
           array_size =  @matchs[keys[i]].count
          if @matchs[keys[i]][array_size - 1][1] < @jugglers[k][:circuits][keys[i]] 
            refreshJugglersQueue @matchs[keys[i]][array_size - 1][0], keys[i]
            @matchs[keys[i]][array_size - 1][1] = @jugglers[k][:circuits][keys[i]] 
            @matchs[keys[i]][array_size - 1][0] = k
            @matches_allocated[k] = true
            @matchs[keys[i]].sort! do |a, b|
            b[1] <=> a[1]
            end
            break 
          else
            refreshJugglersQueue k, keys[i]
          end
        end
      i = i + 1
      end 
    end
  end

  def matchRecursive matches
    matches.each do |k, keys|
      i = 0
      while i < keys.count and (@matches_allocated[k] == false)
          
         if @matchs[keys[i]].nil?
          @matchs[keys[i]] = Array.new()
          @matchs[keys[i]]  = @matchs[keys[i]] << [k, @jugglers[k][:circuits][keys[i]]]
          @matches_allocated[k] = true
          break 
        elsif @matchs[keys[i]].count < @jugglerPerCircuit
          @matchs[keys[i]] = @matchs[keys[i]] << [k, @jugglers[k][:circuits][keys[i]]]
          @matches_allocated[k] = true
          break 
          #puts "Still place in array"
        else
          @matchs[keys[i]].sort! do |a, b|
            b[1] <=> a[1]
           end
           array_size =  @matchs[keys[i]].count
          if @matchs[keys[i]][array_size - 1][1] < @jugglers[k][:circuits][keys[i]]
            
            refreshJugglersQueue @matchs[keys[i]][array_size - 1][0], keys[i]
            @matchs[keys[i]][array_size - 1][1] = @jugglers[k][:circuits][keys[i]] 
            @matchs[keys[i]][array_size - 1][0] = k
            @matches_allocated[k] = true
            @matchs[keys[i]].sort! do |a, b|
            b[1] <=> a[1]
            end
            break 
          else
            refreshJugglersQueue k, keys[i]
          end
        end
      i = i + 1
      end 
    end
  end

    def generateOutput
    file  = File.new( @outputname, "w")
    @matchs.each do |k, v|
      line = ""
      line = k.to_s + " "
      v.each do |name, value|
        line += name.to_s + " "
        i = 1
        circuit_list = @jugglers[name][:circuits]
        circuit_list.each { |c_name, dot|
          line += c_name.to_s + ":" + dot.to_i.to_s
          if i < @jugglers[name][:circuits].length
            line += " "
          elsif !(name == v.last[0])
            line += ", "
          end
          i = i + 1
         }
      end
      file.puts line
    end
    file.close
  end

  def parseAndFill(file)
    begin
      line_num = 1
      temp = Array.new
      file.readlines.each do |line|
        if line =~ (/C *\w+ *H:\d+ *E:\d+ *P:\d+ *$/)
          temp = line.split(" ")
          @circuits[temp[1].to_sym]= {:h => temp[2].split(":")[1], :e => temp[3].split(":")[1], :p => temp[4].split(":")[1]}
        elsif line =~ (/J *\w+ *H:\d+ *E:\d+ *P:\d+ *(\w+,)*\w+ *$/)
          temp = line.split(" ")
          p_name = temp[1].to_sym
          @jugglers[p_name] = {:h => temp[2].split(":")[1], :e => temp[3].split(":")[1], :p => temp[4].split(":")[1], :circuits => {}}
          
          # iterate the circuit array and compute match 
          # score to store it with each circuit
          temp[5].split(",").each { |c|
            name = c.to_sym
            x = [@jugglers[p_name][:h], @jugglers[p_name][:e], @jugglers[p_name][:p]]
            y = [@circuits[name][:h], @circuits[name][:e], @circuits[name][:p]]
            @jugglers[p_name][:circuits][c.to_sym] =  dotProduct(x, y)
          }
        elsif line.match(/([\w+])\n$/)
          raise "The file \"#{@filename}\" is not properly formatted\nline: #{line_num}\n\"#{line}\""
        end
      line_num += 1
      end
      file.close
  rescue => err
    file.close
    puts "File Syntax Exception: #{err}"
    raise 
  end
  @jugglerPerCircuit = @jugglers.count / @circuits.count
  puts "#{@jugglerPerCircuit} jugglers per circuit detected in file '#{@filename}'."
 end
end

# Will hold the options parsed from comand line
options = {}

optparse = OptionParser.new do |opts|
  # Help screen
  opts.banner = "jugglefest generator V0.1, proudly made by Francois Neveu"
  opts.banner += " for Yodle :)\nTake a look at my resume  http://linkd.in/K6rv0T\n"
  opts.banner += "Usage: jugglefest.rb options inputFile ouputFile"
  
  # This displays the help screen
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

lineupGenerator = JugglerFest.new


# Set input file and output file name
if (!ARGV[0].nil? and !ARGV[1].nil?)
  lineupGenerator.setFilenames(ARGV[0].to_s, ARGV[1].to_s)
  lineupGenerator.generate
  puts "JuggleFest lineup successfully generated in the file '#{ARGV[1].to_s}'"
elsif ARGV.length != 2
    puts "WARNING: wrong number of argument"
    puts "use -h option for usage"
else

end

