require "mechanize"
require_relative "utils"

class WebCrawler
  include Utils
  attr_accessor :agent, :user, :table, :schedule_page

  def initialize(agent)
    @agent = agent
    @user = {user_id: nil, password: nil}
    parse_page
  end

  def authorize
    get_input
    form_submit
  end

  def parse_table
    navigate_to_schedule
    pp schedule_page.body
  end

  def show_table
    table_id = "WEEKLY_SCHED_HTMLAREA"
    table = schedule_page.at("table##{table_id}")

    table_rows = table.search("tr")

    table_rows.each do |row|
      cells = row.search("th, td")
      cell_values = cells.map(&:text)

      puts cell_values.join(" | ")
    end
  end

  private

  def parse_page
    agent.user_agent_alias = "Mac Firefox"
    @page = agent.get("https://clic.mmu.edu.my/psp/csprd/?cmd=login")
  end

  def form_submit
    form = @page.form_with(name: "login")
    form.field_with(name: "userid").value = @user[:user_id]
    form.field_with(name: "pwd").value = @user[:password]
    agent.submit form
  end

  def get_input
    @user[:user_id] = normal_prompt("User Id:") # 242UC2451C
    @user[:password] = secure_prompt("Password:")
  end

  def navigate_to_schedule
    url = "https://clic.mmu.edu.my/psp/csprd/EMPLOYEE/SA/c/SA_LEARNER_SERVICES.SSR_SSENRL_SCHD_W.GBL?PORTALPARAM_PTCNAV=HC_SSR_SSENRL_SCHD_W_GBL&EOPP.SCNode=SA&EOPP.SCPortal=EMPLOYEE&EOPP.SCName=CO_EMPLOYEE_SELF_SERVICE&EOPP.SCLabel=Class%20Schedule&EOPP.SCFName=N_NEW_CLASSSCH&EOPP.SCSecondary=true&EOPP.SCPTfname=N_NEW_CLASSSCH&FolderPath=PORTAL_ROOT_OBJECT.CO_EMPLOYEE_SELF_SERVICE.N_NEW_ACADEMICS.N_NEW_CRSENRL.N_NEW_CLASSSCH.HC_SSR_SSENRL_SCHD_W_GBL&IsFolder=false"
    @schedule_page = agent.get(url)
  end
end

agent = Mechanize.new
wc = WebCrawler.new(agent)
wc.authorize
wc.parse_table
# wc.show_table
