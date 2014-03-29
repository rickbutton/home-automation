class Power::Ipl
  def self.fetch(options)
    csv = PowerFetcher.new(options).fetch
    rows = CsvParser.new(csv).parse
  end
end
