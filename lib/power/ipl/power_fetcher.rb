require "headless"
require "selenium-webdriver"
require "cgi"
require "date"
require "zip"

class Power::Ipl::PowerFetcher

  USER_ELEMENT = "ctl00$phMainColumn$ctl00$iplLogin$UserName"
  PASS_ELEMENT = "ctl00$phMainColumn$ctl00$iplLogin$Password"
  LOGIN_ELEMENT = "ctl00$phMainColumn$ctl00$iplLogin$LoginButton"

  def initialize(options)
    @options = { headless: false }.merge(options)
    unless @options[:username] && @options[:password]
      throw "You must specify a username and password"
    end
  end

  def setup
    if @options[:headless]
      @headless = Headless.new
      @headless.start
    end
    @download_dir = "/tmp/ipl-#{Time.now.strftime("%m%d%y_%H%M%S")}"
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.folderList'] = 2
    profile['browser.download.dir'] = @download_dir
    profile['browser.helperApps.neverAsk.saveToDisk'] = "application/octet-stream"

    @driver = Selenium::WebDriver.for :firefox, profile: profile
    @driver.manage.window.resize_to 0,0
  end

  def teardown
    @driver.quit
    @headless.destroy if @options[:headless]
    system("rm -rf #{@download_dir}")
  end

  def fetch
    setup

    @driver.navigate.to "https://www.iplpower.com/account/energyreportlogin.aspx"

    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    wait.until { @driver.find_element(:name, USER_ELEMENT) }

    @driver.execute_script(
      "document.getElementsByName('#{USER_ELEMENT}')[0].value =
      '#{@options[:username]}'"
    )
    @driver.execute_script(
      "document.getElementsByName('#{PASS_ELEMENT}')[0].value =
      '#{@options[:password]}'"
    )

    @driver.execute_script("document.getElementsByName('#{LOGIN_ELEMENT}')[0].click()")
    @driver.navigate.to "https://ipl.opower.com/ei/app/myEnergyUse"

    base = "https://ipl.opower.com/ei/app/modules/customer/993961/energy/download"
    time = Time.now
    end_of_month = Date.new(time.year, time.month, -1)
    params = {
      bill: "2014-2",
      exportFormat: "CSV_AMI",
      csvFrom: "09/13/2013",
      csvTo: end_of_month.strftime("%m/%d/%Y"),
    }
    @driver.navigate.to "#{base}?#{to_query params}"

    zip = Dir.glob("#{@download_dir}/**/*").first

    contents = ""

    Zip::File.open(zip) do |file|
      entry = file.glob("*").first
      contents = file.read entry
    end
    teardown
    contents
  end

  private 

  def to_query(hash)
    hash.map { |k, v| "#{k}=#{CGI::escape v}" }.join("&")
  end
end
