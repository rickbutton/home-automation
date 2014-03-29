require "csv"
require "date"

class Power::Ipl::CsvParser

  DATA_START = 5

  def initialize(str)
    @str = str
  end

  def parse
    rows = []
    i = -1
    CSV.parse(@str) do |row|
      i += 1
      next if i < DATA_START
      rows << {
        kind: "power",
        date: Date.strptime(row[1], "%Y-%m-%d"),
        usage: row[2].to_i,
        cost_cents: (row[4].tr("$", "").to_f * 100).to_i
      } 
    end
    rows
  end
end
