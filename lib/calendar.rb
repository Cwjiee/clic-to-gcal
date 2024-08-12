require "google/apis/calendar_v3"
require "googleauth"
require "tty-spinner"

class GoogleCalendar
  attr_reader :service

  def initialize
    authorize
  end

  def events(reload = false)
    @events = nil if reload
    @events ||= service.list_events(calendar_id, max_results: 2000).items
  end

  def delete_event(event_id)
    service.delete_event(calendar_id, event_id)
    puts "successfully deleted event"
  rescue Google::Apis::ClientError => e
    puts "Error occured: #{e}"
  end

  def insert_event(summary, start_date, end_date)
    time_zone = "Asia/Kuala_Lumpur"
    send_updates = "all"

    event = Google::Apis::CalendarV3::Event.new(
      summary:,
      start: {
        date: start_date,
        time_zone:
      },
      end: {
        date: end_date,
        time_zone:
      }
    )

    spinner = TTY::Spinner.new(format: :bouncing)
    spinner.auto_spin
    service.insert_event(calendar_id, event, send_updates:)
    spinner.stop("successfully added event")
  rescue Google::Apis::ClientError => e
    puts "Error occured: #{e}"
  end

  private

  def calendar_id
    @calendar_id ||= ENV["CALENDAR_ID"]
  end

  def authorize
    calendar = Google::Apis::CalendarV3::CalendarService.new
    calendar.client_options.application_name = "Schedule Import"
    # calendar.client_options.application_version = 'App Version'

    ENV["GOOGLE_APPLICATION_CREDENTIALS"] = "#{Dir.pwd}/google_api.json"
    scopes = [Google::Apis::CalendarV3::AUTH_CALENDAR]
    calendar.authorization = Google::Auth.get_application_default(scopes)

    @service = calendar
  end
end

# cal.events.each do |ev|
#   puts ev.summary
#   print "delete this event?: [y/n]: "
#   choice = gets.chomp
#   cal.delete_event(ev.id) if choice == "y"
#   puts
# end

#   events = calendar.list_events('primary',
#                        max_results: 10,
#                        single_events: true,
#                        order_by: 'startTime',
#                        time_min: now
#                       )
