class Debug
  def call(var_name, var)
    var_location = caller_locations(1, 1)[0].path
    var_name = var_name.upcase
    puts "DEBUG: #{var_location}: #{var_name} = #{var}"
  end
end
