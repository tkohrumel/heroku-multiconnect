class AdminMailer < ApplicationMailer
  default from: ENV['DEV_EMAIL'] 

  def authorize_with_rails(admin)
    @admin = admin
    @app_name = ENV['APP_NAME'] 
    @authentication_url = "https://#{@app_name}.herokuapp.com/authenticate"
    mail(to: @admin, subject: "ACTION REQUIRED: Authenticate #{@app_name} for Salesforce Org")
  end

  def authenticate_heroku_connect(admin_email)
    mail(to: admin_email, subject: 'ACTION REQUIRED: Authenticate Heroku Connect to Your Salesforce Org')
  end
end