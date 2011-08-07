require 'field'
require 'cell'

field_file = File.open 'field.txt'
field_str = field_file.read
field = Field.new field_str
field.start
