require 'httparty'

class HerokuConnectAPI
  include HTTParty
  format :json
  base_uri 'https://connect-us.heroku.com/api/v3'
  debug_output $stdout

  def import_mapping_configuration(connection_id)
    path = "/connections/#{connection_id}/actions/import"

    mapping = File.read(File.join('lib', 'mapping.json'))

    self.class.post(path,
      :body => mapping,
      :headers => {
        'Content-Type' => 'application/json',
        'Authorization' => auth
      }
     )
  end

  def link_connection_to_account
    path = "/users/me/apps/#{ENV['APP_NAME']}/auth"

    self.class.post(path,
      :headers => {
        #'Content-Type' => 'application/json',
        'Authorization' => auth
      }
    )
  end

  def configure_db_key_and_schema_for_connection(connection_id, org_id)
    path = "/connections/#{connection_id}"

    body = {
      :schema_name => "salesforce#{org_id.downcase}",
      :db_key => 'DATABASE_URL'
    }.to_json

    self.class.patch(path,
      :body => body,
      :headers => {
        'Content-Type' => 'application/json',
        'Authorization' => auth
      }
    )
  end

  def get_authorize_url(connection_id, org_environment, org_uid)
    path = "/connections/#{connection_id}/authorize_url"

    ########################################
    # optional params:
    # * environment - production, sandbox, or custom [defaults to production]
    # * domain: specify custom login domain
    # * api_version
    # * next: final URL to redirect the user
    ########################################
    body = {
      :environment => org_environment,
      :next => "https://#{ENV['APP_NAME']}.herokuapp.com/connection_auth_complete/#{org_uid}"
    }.to_json

    self.class.post(path,
      :body => body,
      :headers => {
        'Content-Type' => 'application/json',
        'Authorization' => auth
      }
    )
  end

  private

  def auth
    "Bearer #{ENV['HEROKU_API_TOKEN']}"
  end

end