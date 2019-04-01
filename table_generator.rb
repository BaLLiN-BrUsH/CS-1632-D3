require 'sinatra'
require 'sinatra/reloader'

# **************************
# HELPER METHODS START HERE
# **************************

# This method creates a stringified table based on the truth symbol, false symbol, and table size
def generate_table(t_sym, f_sym, size)
    table_output = ""
    0.upto(2**size.to_i - 1).each do |n|
        num = ("%0#{size}b" % n)
        # Format the binary string with the user's true/false symbols
        f_num = format_num t_sym, f_sym, num
        # Execute boolean operations on each binary string
        num_and = op_and t_sym, f_sym, num
        num_or = op_or t_sym, f_sym, num
        num_nand = op_nand t_sym, f_sym, num_and
        num_nor = op_nor t_sym, f_sym, num_or
        num_xor = op_xor t_sym, f_sym, num
        num_single = op_single t_sym, f_sym, num
        # Return the value for each row
        table_output += "#{f_num} #{num_and}    #{num_or}   #{num_nand}     #{num_nor}    #{num_xor}    #{num_single}\n"
    end
    table_output
end

# This method formats the binary value 'num' (composed of 1's and 0's) into the user's selected truth and false symbols
def format_num(t_sym, f_sym, num)
    chars = num.split('')
    form_num = ""
    chars.each do |c|
        if c == "0"
            form_num += f_sym
        elsif c == "1"
            form_num += t_sym
        end
    end
    return form_num
end

# This method perfoms the AND operation between the bits on the binary value 'num'
def op_and(t_sym, f_sym, num)
    chars = num.split('')
    is_false = 0
    chars.each do |c|
        if c == "0"
            is_false = 1
            break
        end
    end
    if is_false == 0
        return t_sym
    else
        return f_sym
    end
end

# This method perfoms the OR operation between the bits on the binary value 'num'
def op_or(t_sym, f_sym, num)
    chars = num.split('')
    is_true = 0
    chars.each do |c|
        if c == "1"
            is_true = 1
            break
        end
    end
    if is_true == 1
        return t_sym
    else
        return f_sym
    end
end

# This method perfoms the NAND operation between the bits on the binary value 'num'
def op_nand(t_sym, f_sym, num_and)
    if num_and == t_sym
        return f_sym
    elsif num_and == f_sym
        return t_sym
    end
end

# This method perfoms the NOR operation between the bits on the binary value 'num'
def op_nor(t_sym, f_sym, num_or)
    if num_or == t_sym
        return f_sym
    elsif num_or == f_sym
        return t_sym
    end
end

# This method perfoms the XOR operation between the bits on the binary value 'num'
# => if 'num' contains an odd amount of truth characters, return true
def op_xor(t_sym, f_sym, num)
    chars = num.split('')
    num_of_trues = 0
    chars.each do |c|
        if c == "1"
            num_of_trues += 1
        end
    end

    if num_of_trues.to_i.even?
        return f_sym
    else
        return t_sym
    end
end

# This method perfoms the SINGLE operation between the bits on the binary value 'num'
# => if 'num' contains only one truth character, return true
def op_single(t_sym, f_sym, num)
    chars = num.split('')
    num_of_trues = 0
    chars.each do |c|
        if c == "1"
            num_of_trues += 1
        end
    end

    if num_of_trues == 1
        return t_sym
    else
        return f_sym
    end
end

def is_valid(t_sym, f_sym, t_size)
    invalid = 0
    # If either of the true/false symbols have a length larger than 1 or are the same value
    # =>  set inv = 1
    if t_sym.length > 1 || f_sym.length > 1 || t_sym == f_sym
        invalid = 1
    end
    # If the table size is not an integer or it is an integer that is less than 2
    # => set inv = 1
    if !( t_size.match(/^(\d)+$/) ) || t_size.to_i < 2
        invalid = 1
    end
    invalid
end

# ************************
# GET REQUESTS START HERE
# ************************

# What to do if we can't find the route
not_found do
    status 404
    erb :error
end

# If a request comes in for /
# => display main.erb
get '/' do
    # Display main.erb
    erb :main
end

# If a request comes in for /display
# => check the params to see if they are valid and then display display.erb
get '/display' do
    # Get the submitted parameters
    t_sym = params['truth_sym']
    f_sym = params['false_sym']
    t_size = params['table_size']
    # Initialize inv and table to nil
    inv = nil
    table = nil
    # If any of the submitted parameters are nil,
    # => set t_sym = "T", f_sym = "F", t_size = 3 (default values)
    if t_sym == ""
        t_sym = "T"
    end
    if f_sym == ""
        f_sym = "F"
    end
    if t_size == ""
        t_size = "3"
    end
    # Check to see if the parameters are valid
    inv = is_valid t_sym, f_sym, t_size
    if inv == 1
        erb :display, :locals => { truth_sym: t_sym, false_sym: f_sym, table_size: t_size, invalid: inv, show_table: table }
    else
        ### AT THIS POINT THE PARAMETERS SHOULD BE VALID ###
        table = generate_table t_sym, f_sym, t_size
        inv = 0
        # Display display.erb
        erb :display, :locals => { truth_sym: t_sym, false_sym: f_sym, table_size: t_size, invalid: inv, show_table: table }
    end
end
