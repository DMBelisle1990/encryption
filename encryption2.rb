class Decrypter

  attr_accessor :master_key, :message, :msg_as_pattern, :words_as_patterns, :matches, :pattern_map

  def initialize
    @dictionary = File.readlines("most_common.txt")
    @dictionary.map! { |line| line.split(" ")[0] }
    @dictionary.shift
	  @master_key = {} 
	  @words_as_patterns, @msg_as_pattern, @message, @matches = [], [], [], []
    @pattern_map = word_pattern_hash
	  start
  end

  def start
  	puts "Hello! Enter your encrypted message: "
	  input = gets.chomp

	  #forms the master_key
	  input.gsub(/\s+/, "").each_byte { |char| master_key[char.chr] = "?" }

	  #forms all the necessary arrays 
    temp = convert_to_pattern(input.split("")).join.split("_")
    temp.each { |word| msg_as_pattern << word.split("") }
    words = input.split(" ")
	  words.each do |word| 
      words_as_patterns << convert_to_pattern(word.split("")) 
      message << word.split("")
    end
    matches << match_pattern(words_as_patterns[0]) 
    if decode 
      message.each do |word|
        word.each { |letter| print master_key[letter] }
        print " "
      end
      puts ""
    else
      puts "no match found"
    end
  end

  def decode(idx = 0)
    return true if idx == @msg_as_pattern.length
    reset_key = @master_key.dup
    @matches[idx].each do |match|    
        @master_key = reset_key.dup
        @message[idx].each_with_index do |char, i| 
          @master_key[char] = match[i] if @master_key[char] == '?'
        end
        @matches << match_pattern(@message[idx + 1]) if idx < @msg_as_pattern.length - 1
        if @matches.last.length == 0
          @matches.pop
          next
        end
        return true if decode(idx + 1)
        @matches.pop
    end
    false
  end

  #returns all the words that match the specified pattern_ary
  def match_pattern(pattern_ary, key = master_key.dup)
    words = []
    pattern_map.each do |word, ary|
      add = true 
      if ary == convert_to_pattern(pattern_ary)
        temp = pattern_ary.dup
        temp.each_with_index do |num, i| 
          temp[i] = key[num] if key.keys.include?(num) && key[num] != "?"   
        end
        word.split("").each_with_index do |letter, i|
          if letter?(temp[i])
            add = false if letter != temp[i] 
          elsif key.values.include?(letter)
            add = false unless key[temp[i]] == letter
          end
        end
        words << word if add
      end
    end
    words
  end

  def convert_to_pattern(array)
    return if array == nil
      hash, i = {}, 1
      array.map do |char|
        if char == " "
      	  "_"
  	    elsif hash.keys.include?(char)
  	      hash[char]
  	    else
  	      hash[char] = i.to_s
  	      i += 1
  	      hash[char]
  	    end
      end
  end

  def num_matches(pattern_ary, key = master_key)
  	match_pattern(pattern_ary, key).length
  end

  def word_pattern_hash
  	key = {}
    @dictionary.each do |word| 
      key[word] = convert_to_pattern(word.split("")) 
    end
    key
  end

  def letter?(lookAhead)
  	lookAhead =~ /[A-Za-z]/
  end

end

d = Decrypter.new
#p d.match_pattern(['1','5','6','6'],{"1"=>"t", "2"=>"h", "3"=>"r", "4"=>"o", "5"=>"a"})
