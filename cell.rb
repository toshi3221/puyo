class Cell

  attr_reader :color, :status, :bottom, :row, :column

  def initialize(row,column,color)
    @row = row
    @column = column
    @color = color
    @status = :exist
  end

  def set_neighbors neighbors, bottom
    @neighbors = neighbors
    @bottom = bottom
  end

  def check_union(unit_cells=nil)
    return unit_cells unless @status == :exist
    return unit_cells if !unit_cells.nil? and unit_cells.first.color != @color
    if unit_cells.nil?
      @status = :booster
      unit_cells = Array.new
    else
      @status = :unit
    end
    unit_cells.push self
    @neighbors.each do |neighbor|
      next unless neighbor.status == :exist
      unit_cells = neighbor.check_union unit_cells
    end
    if @status == :booster and unit_cells.size >= 4
       unit_cells.each {|c| c.bomb}
    elsif @status == :booster
       unit_cells.each {|c| c.devide}
    end
    unit_cells
  end

  def bomb
    @status = :bomb
  end

  def devide
    @status = :exist
  end

  def refresh
    if @status != :bomb and !@bottom.nil? and @bottom.status == :bomb
      @bottom = @bottom.bottom
      @status = :drop
      @row += 1
      @neighbors.each {|neighbor| if neighbor.row == @row-2 then neighbor.refresh end}
      refresh
    elsif @status != :bomb and !@bottom.nil? and @bottom.status == :drop
      @row += 1
      @status = :drop
      @neighbors.each {|neighbor| if neighbor.row == @row-2 then neighbor.refresh end}
    end
  end
end
