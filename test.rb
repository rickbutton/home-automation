require "./lib/ipl_power_fetcher"
require "./lib/ipl_csv_parser"

csv = IPLPowerFetcher.new.fetch
rows = IPLCSVParser.new(csv).parse
puts rows
