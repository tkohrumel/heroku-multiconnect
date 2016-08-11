require 'httparty'

class HerokuPlatformAPI
  include HTTParty
  format :json
  base_uri 'https://api.heroku.com'
  debug_output $stdout

  def initialize
    p "initializing..."
    @app_name = ENV['APP_NAME']
  end

  def provision_hc_connection(org_id)
    p "preparing request to provision new HC connection..."
    plan_name = 'herokuconnect'
    name = "hc_#{org_id}"
    body = {
      :plan => plan_name,
      :attachment => {
        :name => name 
      }
    }.to_json

    self.class.post("/apps/#{@app_name}/addons",
      :body => body,
      :headers => {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{ENV['HEROKU_API_TOKEN']}",
        'Accept' => 'application/vnd.heroku+json; version=3'
      }
    )
  end

end