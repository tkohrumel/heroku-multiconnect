class NotifyAdminToAuthConnectWorker 
  include Sidekiq::Worker

  def perform(contact_email)
    logger.info "Admin has authenticated Rails with Subscriber Org. Notifying #{contact_email} to authenticate Heroku Connect."
    AdminMailer.delay.authenticate_heroku_connect(contact_email)
  end
end