class OrganizationsController < ApplicationController

  def create
    @organization = Organization.new
    @organization.org_id = params["org_id"]
    @organization.name = params["org_name"]
    @organization.admin_email = params["admin_email"]

    if @organization.save
      render json: {
        status: 202,
        message: "Configuration in-progress the '#{@organization.name}' Salesforce Organization"
      }
    else
      render json: {
        status: 409,
        message: "Conflict. Organization is already on record"
      }
    end
  end

  def auth
    auth = env["omniauth.auth"]

    if Organization.exists? org_id: auth["extra"]["organization_id"]
      Organization.update_from_omniauth(auth, auth["extra"]["organization_id"])
      render json: {
        status: 200,
        message: "You have successfully authenticated Screeningforce with your org."
      }
    else
      render json: {
        status: 200,
        message: "Your SFDC Organization ID is not in our records. Ensure you are authenticating from the appropriate org."
      }
    end
  end

end