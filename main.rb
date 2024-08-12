require_relative "lib/calendar"
require_relative "lib/crawler"
require_relative "lib/cli"

cal = GoogleCalendar.new
agent = Mechanize.new
wc = WebCrawler.new(agent)

SchedulerCli.start(ARGV, {cal:, wc:})
