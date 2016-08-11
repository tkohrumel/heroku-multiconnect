class UpdateSubscriberSettingsWorker 
  include Sidekiq::Worker

  def perform(oauth_token, refresh_token, instance_url, connection_id, authorize_url)
    path = "/services/apexrest/" + (ENV['FORCE_NAMESPACE'].nil? ? "AuthConnection" : "/#{ENV['FORCE_NAMESPACE']}/AuthConnection")

    logger.info "Perfoming HTTP request to subscriber's Salesforce org to update custom setting with connection info" 

    force = UpdateSubscriberSettingsWorker.restforce_client(oauth_token, refresh_token, instance_url) 
    resp = force.post path, :connectionId => connection_id, :authorizeUrl => authorize_url

    logger.info "Response from Salesforce: #{resp}"
  end

  def self.restforce_client(oauth_token, refresh_token, instance_url)
    Restforce.new :oauth_token => oauth_token,
      :refresh_token => refresh_token,
      :instance_url => instance_url,
      :client_id => ENV['SALESFORCE_KEY'],
      :client_secret => ENV['SALESFORCE_SECRET']
  end
end