require 'httparty'

class LinkConnectionWorker
  include Sidekiq::Worker

  def perform(id)
    org = Organization.find id

    logger.info "Linking HC connection: #{org.connection_id} for org: #{org.org_id} to Heroku account..." 
    response = ::HerokuConnectAPI.new.link_connection_to_account

    if response.success?
      logger.info "Link successful"
      ConnectionConfigWorker.perform_in(2.minutes, org.connection_id, org.org_id, org.admin_email)
    else
      logger.info "Failure to link the HC connection"
      logger.info response.response
      LinkConnectionWorker.perform_in(2.minutes, org.id)
    end
  end
end