require 'cell'
require 'stringio'

class Field

  def initialize field_text
    str_io = StringIO.new field_text
    @rows = 0
    @columns = 0
    @field = Array.new
    @cells = Array.new
    line_str = str_io.readline
    while line_str do
      @field[@rows] = Array.new
      line_str.size.times do |i|
        str = line_str[i,1]
        next if str == "\n"
        cell = str == ' ' ? nil : Cell.new(@rows, @field[@rows].size, str)
        @field[@rows][@field[@rows].size] = cell
        next if cell.nil?
        @cells.push cell
      end
      @columns = @field[@rows].size if @columns < @field[@rows].size
      @rows += 1
      begin
        line_str = str_io.readline
      rescue
        line_str = nil
      end
    end
    @rows.times do |row|
      @columns.times do |column|
        if @field[row][column]
          neighbors, bottom = neighbors_and_bottom row, column
          @field[row][column].set_neighbors neighbors, bottom
        end
      end
    end
  end

  def neighbors_and_bottom row, column
    top = row == 0 ? nil : @field[row-1][column]
    right = column == @columns-1 ? nil : @field[row][column+1]
    bottom = row == @rows-1 ? nil : @field[row+1][column]
    left = column == 0 ? nil : @field[row][column-1]
    neighbors = Array.new
    neighbors.push top unless top.nil? or top.status == :bomb
    neighbors.push right unless right.nil? or right.status == :bomb
    bottom = (bottom.nil? or bottom.status == :bomb) ? nil : bottom
    neighbors.push bottom unless bottom.nil?
    neighbors.push left unless left.nil? or left.status == :bomb
    return neighbors, bottom
  end

  def start
    @combo = 0
    display_field
    is_bomb = true
    while is_bomb do
      @cells.each do |cell|
        cell.check_union
      end
      @cells.each do |cell|
        cell.refresh
      end
      is_bomb = @cells.any? do |cell|
        cell.status == :bomb
      end
      next unless is_bomb
      @cells.delete_if {|cell| cell.status == :bomb}
      @combo += 1
      reset_field
      display_field
    end
  end

  def reset_field
    @cells.each do |cell|
      if cell.status == :drop
        @field[cell.row][cell.column] = cell
      end
    end
    @rows.times do |row|
      @columns.times do |column|
        cell = @field[row][column]
        next if cell.nil?
        @field[row][column] = nil if cell.status == :bomb or row != cell.row
        cell.devide
      end
    end
    @rows.times do |row|
      @columns.times do |column|
        cell = @field[row][column]
        next if cell.nil?
        neighbors, bottom = neighbors_and_bottom row, column
        cell.set_neighbors neighbors, bottom
      end
    end
  end

  def display_field
    puts 'combo: ' + @combo.to_s
    puts ''
    @rows.times do |row|
      @columns.times do |columns|
        print @field[row][columns].nil? ? ' ' : @field[row][columns].color
      end
      print "\n"
    end
  end
end
