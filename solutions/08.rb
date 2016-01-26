class Spreadsheet
  attr_accessor :table, :row, :column

  def initialize(string = nil)
    if(string)
      @table = edit(string)
    else
      @table = Array.new
    end
  end

  def empty?
    @table.empty?
  end

  def cell_at(cell_index)
    if( ! /^[A-Z]+\d+$/.match(cell_index) )
      raise Spreadsheet::Error, "Invalid cell index '#{cell_index}'"
    end

    calculate(cell_index)

    if( ! @table[@row] || ! @table[@row][@column] )
      raise Spreadsheet::Error, "Cell '#{cell_index}' does not exist"
    end

    @table[@row][@column]
  end

  def calculate(cell_index)
    @row = /\d+/.match(cell_index).to_s.to_i - 1
    @column = fix( /[A-Z]+/.match(cell_index).to_s ) - 1
  end

  def [](cell_index)
    cell_at(cell_index)
  end

  def to_s
    @table.map { |x| x.join("\t") }.join("\n")
  end

  def fix(string)
    alphabet = ('A'..'Z').to_a.each_with_index.to_h
    sum = 0
    string.split("").reverse.each_with_index do |letter, index|
      sum += (alphabet[letter] + 1) * (26 ** index)
    end

    sum
  end

  def edit(string)
    array = string.split /\n+/
    array.map! { |x| x.split(/(\t|  +)/) }
    array.each{ |x| x.delete_if(&:empty?) }
    array.each{ |x| x.delete_if{ |x| /^\s+$/.match x}}
    array.each{ |x| x.map!(&:strip) }
    array.delete_if(&:empty?)
  end
end

class Spreadsheet::Error < Exception
end
