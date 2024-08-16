require "mechanize"
require "dotenv"
require_relative "utils"

class WebCrawler
  include Utils
  attr_accessor :agent, :user

  def initialize(agent)
    @agent = agent
    @user = {user_id: nil, password: nil}
    @days = {}
    Dotenv.load
    parse_page
  end

  def authorize
    get_input
    form_submit
  end

  def get_schedule
    navigate_to_schedule
    parse_list

    if @table.nil?
      return "No table found in the iframe content."
    end

    titles = @titles.map do |title|
      title.text.match(/- (.+)/)[1]
    end

    days = {}

    @table.each_with_index do |tb, index|
      title = titles[index]
      table_rows = tb.search("tr")

      table_rows.each do |row|
        next if table_rows.first == row

        section_cells = row.search("td div span a")
        section = section_cells.map(&:text)

        venue_cells = row.search('td div span[id^="MTG_LOC$"]')
        venue = venue_cells.map(&:text)

        date_cells = row.search('td div span[id^="MTG_DATES$"]')
        end_date = scan_date date_cells

        sched_cells = row.search('td div span[id^="MTG_SCHED$"]')
        sched_cells.each do |cell|
          day = cell.text[0] + cell.text[1]
          start_time, end_time = scan_time cell.text

          days[day] = [] if days[day].nil?
          days[day] << {start_time:, end_time:, section:, venue:, title:, end_date:}
        end
      end
    end

    days
    # pp days
  end

  def show_table # only to show schedule in terminal
    parse_table

    if @table.nil?
      return "No table found in the iframe content"
    end

    table_rows.each_with_index do |row, index|
      cells = row.search("th, td")
      puts cells.count
      cell_values = cells.map(&:text)
      puts "#{index + 1}: #{cell_values}"
    end
  end

  private

  def scan_date(contents)
    dates = []
    contents.each do |content|
      text = content.text
      dates = text.scan(/\d{2}\/\d{2}\/\d{4}/)
    end
    dates.last
  end

  def scan_time(content)
    time_regex = /(\d{1,2}:\d{2})(AM|PM)/
    content.scan(time_regex).map { |match| match.join }
  end

  def parse_list
    iframe = @schedule_page.at("iframe")

    iframe_src = iframe["src"]
    iframe_page = agent.get(iframe_src)

    form = iframe_page.form_with(name: "win0")
    form.radiobutton_with(value: "L").check
    result_page = agent.submit(form)
    @table = result_page.search("table.PSLEVEL3GRID[dir='ltr'][cols='6']")
    @titles = result_page.search("td.PAGROUPDIVIDER.PSLEFTCORNER")
  end

  def parse_page
    agent.user_agent_alias = "#{ENV["OS"]} #{ENV["BROWSER"]}"
    @page = agent.get("https://clic.mmu.edu.my/psp/csprd/?cmd=login")
  end

  def form_submit
    form = @page.form_with(name: "login")
    form.field_with(name: "userid").value = @user[:user_id]
    form.field_with(name: "pwd").value = @user[:password]
    agent.submit form
  end

  def get_input
    @user[:user_id] = ENV["USER_ID"] || normal_prompt("User Id:")
    @user[:password] = ENV["PASSWORD"] || secure_prompt("Password:")
  end

  def navigate_to_schedule
    url = "https://clic.mmu.edu.my/psp/csprd/EMPLOYEE/SA/c/SA_LEARNER_SERVICES.SSR_SSENRL_SCHD_W.GBL?PORTALPARAM_PTCNAV=HC_SSR_SSENRL_SCHD_W_GBL&EOPP.SCNode=SA&EOPP.SCPortal=EMPLOYEE&EOPP.SCName=CO_EMPLOYEE_SELF_SERVICE&EOPP.SCLabel=Class%20Schedule&EOPP.SCFName=N_NEW_CLASSSCH&EOPP.SCSecondary=true&EOPP.SCPTfname=N_NEW_CLASSSCH&FolderPath=PORTAL_ROOT_OBJECT.CO_EMPLOYEE_SELF_SERVICE.N_NEW_ACADEMICS.N_NEW_CRSENRL.N_NEW_CLASSSCH.HC_SSR_SSENRL_SCHD_W_GBL&IsFolder=false"
    @schedule_page = agent.get(url)
  end

  def parse_table
    table_id = "WEEKLY_SCHED_HTMLAREA"
    iframe = @schedule_page.at("iframe")

    if iframe
      iframe_src = iframe["src"]
      iframe_page = agent.get(iframe_src)
      @table = iframe_page.at("table##{table_id}")
    else
      puts "No iframe found on the main page."
    end
  end
end

# agent = Mechanize.new
# wc = WebCrawler.new(agent)
# wc.authorize
# wc.get_schedule
