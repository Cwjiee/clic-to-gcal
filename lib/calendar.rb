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

  def insert_event(summary, start_time, end_time, location)
    time_zone = "Asia/Kuala_Lumpur"
    send_updates = "all"

    event = Google::Apis::CalendarV3::Event.new(
      summary:,
      start: {
        date_time: start_time,
        time_zone:
      },
      end: {
        date_time: end_time,
        time_zone:
      },
      location:
    )

    spinner = TTY::Spinner.new(format: :bouncing)
    spinner.auto_spin
    service.insert_event(calendar_id, event, send_updates:)
    spinner.stop("successfully added event")
  rescue Google::Apis::ClientError => e
    puts "Error occured: #{e}"
  end

  def import_to_calendar(data)
    dates = get_dates_of_week
    data.each_pair do |day, classes|
      date =
        case day
        when "Mo" then dates[0]
        when "Tu" then dates[1]
        when "We" then dates[2]
        when "Th" then dates[3]
        when "Fr" then dates[4]
        when "Sa" then dates[5]
        when "Su" then dates[6]
        end

      classes.each do |c|
        start_time = convert_to_rfc3339(date, c[:start_time])
        end_time = convert_to_rfc3339(date, c[:end_time])
        insert_event(c[:section], start_time, end_time, c[:venue])
      end
    end
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

  def get_dates_of_week
    date = Date.today
    start_of_week = date.monday? ? date : date - date.cwday
    end_of_week = start_of_week + 6

    (start_of_week..end_of_week).to_a
  end

  def convert_to_rfc3339(date, time)
    time = Time.parse("#{date} #{time}")
    time.iso8601
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
