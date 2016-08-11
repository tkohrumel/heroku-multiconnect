require 'httparty'

class ConnectionConfigWorker
  include Sidekiq::Worker

  def perform(connection_id, org_id, admin_email)
    logger.info "Perfoming configuration of Heroku Connect connection (#{connection_id}) db key and schema for org: #{org_id}..."

    r = ::HerokuConnectAPI.new.configure_db_key_and_schema_for_connection(connection_id, org_id)

    # Note: 200 is false positive indication of successful configuration, hence the 202 check
    if r.response.code.to_i == 202
      logger.info 'Configuration successful'

      org = Organization.find_by org_id: org_id
      response = ::HerokuConnectAPI.new.get_authorize_url(org.connection_id, org.environment, org.id)
      body = response.parsed_response

      org.connection_configured = true
      org.authorize_url = body["redirect"]
      org.schema_name = "salesforce#{org_id.downcase}"

      AdminMailer.delay.authorize_with_rails(admin_email) if org.save!

      logger.info  "Emailing #{admin_email} instructions to authenticate both web process and Heroku Connect"
    else      
      ConnectionConfigWorker.perform_in(2.minutes, connection_id, org_id, admin_email) unless r.response.code.to_i == 202

      logger.info "Heroku Connect did not return 202 for configuration request. Retrying in 2 minutes..."
    end
  end
end