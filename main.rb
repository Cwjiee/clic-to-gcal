require_relative "lib/calendar"
require_relative "lib/cli"

cal = GoogleCalendar.new
wc = WebCrawler.new

SchedulerCli.start(ARGV, {cal: cal, wc: wc})
