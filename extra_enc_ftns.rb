def analyze_msg(message)
    first = message.max_by(&:length)
    puts first
end


def max_string_in_array(array)
	array.max_by(&:length)
end

