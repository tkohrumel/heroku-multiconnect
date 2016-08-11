class ProvisionConnectionWorker
  include Sidekiq::Worker

  def perform(sfdc_org_id, local_id)
    response = ::HerokuPlatformAPI.new.provision_hc_connection(sfdc_org_id)
    data = response.parsed_response
    org = Organization.find local_id
    org.connection_id = data["id"]

    if org.save
      logger.info "Organization #{org.id} now has a Heroku Connect connection, with connection id: #{org.connection_id}."
      LinkConnectionWorker.perform_async org.id
    else
      logger.info "Error saving organization record in Postgres: #{org.errors.messages}"
    end
  end
end