class Browser
  include LogHelper

  attr_reader :profile, :browser

  def initialize(tor: true)
    @tor = tor.present?
    browser
  rescue => e
    log_error self.class.name, __method__, e.message
  end

  def profile
    return @profile if @profile.present?
    @profile = Selenium::WebDriver::Firefox::Profile.new

    if tor?
      run_tor!
      @profile['signon.autologin.proxy'] = true
      @profile['network.proxy.type'] = 1
      @profile['network.proxy.socks'] = Proxies::TorProxy::LOCALHOST
      @profile['network.proxy.no_proxy'] = Proxies::TorProxy::LOCALHOST
      @profile['network.proxy.socks_port'] = Proxies::TorProxy.listen_port
    end

    @profile
  end

  def options
    return @options if @options.present?
    @options = { profile: profile }
  end

  def browser
    @browser ||= new_watir_browser
  end

  def close!
    @browser&.close
  end

  def reload!
    close!
    @browser = new_watir_browser
  end

  def run_tor!
    Proxies::TorProxy.tor_process
  end

  def cookies(domain)
    return if browser.blank?
    browser
        &.driver
        &.manage
        &.all_cookies
        &.select { |i| i[:domain]&.include?(domain) }
  end

  def cookies_str(domain)
    cookies(domain)&.map { |i| "#{ i[:name] }=#{ i[:value] }" }.join(', ')
  end

  def user_agent
    browser&.driver&.execute_script('return navigator.userAgent;')
  end

  def tor?
    @tor
  end

  private

  def new_watir_browser
    system 'sudo /etc/init.d/xvfb start' if Rails.env.production?
    Watir::Browser.new :firefox, options: options
  end
end
