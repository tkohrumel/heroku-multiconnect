class ImportMappingConfigWorker 
  include Sidekiq::Worker

  def perform(connection_id)
    r = ::HerokuConnectAPI.new.import_mapping_configuration(connection_id)
    logger.info "response from mapping resource: #{r}"
  end
end