class LazyMode
  class Date
    attr_accessor :date

    def initialize(date)
      @date = date
    end

    def year
      @date[0..3].to_i
    end

    def month
      @date[5..6].to_i
    end

    def day
      @date[8..9].to_i
    end

    def to_s
      @date
    end
  end

  def self.create_file(name, &block)
    File.new(name, &block)
  end

  class File
    attr_accessor :name, :notes

    def initialize(name, &block)
      @name = name
      @notes = Array.new
      instance_eval &block
    end

    def note(header, *tags, &block)
      notes << Note.new(@name, header, *tags, &block)
      block.call &block
    end

    def status(symbol)
      notes.last.status = symbol
    end

    def body(string)
      notes.last.body = string
    end

    def scheduled(date)
      notes.last.date = Date.new(date)
    end

    def daily_agenda(date)
      notes.select { |note| note.date.to_s == date.to_s }
    end
  end

  class Note
    attr_accessor :header, :file_name, :body, :status, :tags, :date

    def initialize(file_name, header, *tags, &block)
      @header = header
      @tags = tags
      @file_name = file_name
      @body = String.new
      @status = :topostpone
    end
  end
end
