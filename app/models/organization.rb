class Organization < ActiveRecord::Base
  attr_encrypted :oauth_token, key: ENV['SECRET']

  validates :org_id, presence: true
  validates :org_id, uniqueness: true
  validates :name, presence: true

  after_create :provision_and_link_connection

  def self.update_from_omniauth(auth, org_id)
    org = self.find_by org_id: org_id
    org.oauth_uid = auth[:uid]
    org.oauth_provider = auth[:provider]
    org.oauth_name = auth[:extra][:username]
    org.oauth_token = auth[:credentials][:token]
    org.oauth_refresh_token = auth[:credentials][:refresh_token]
    org.oauth_instance_url = auth[:credentials][:instance_url]
    org.web_authenticated = true

    if org.save!
      p "#{org.name}'s org just authenticated by #{org.oauth_name}"
      UpdateSubscriberSettingsWorker.perform_async(org.oauth_token, org.oauth_refresh_token, org.oauth_instance_url, org.connection_id, org.authorize_url)
      NotifyAdminToAuthConnectWorker.perform_async(org.admin_email)
    end
  end

  private

  def provision_and_link_connection
    p "Enqueuing job to provisioning Heroku Connect connection for org #{self.org_id}..."
    ProvisionConnectionWorker.perform_async(self.org_id, self.id)
    p "done."
  end
end