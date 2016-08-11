class InitializationController < ActionController::Base
  def auth 
  end

  def connection_auth_complete
    puts "auth complete for Organization uid: #{params[:id]}"
    org = Organization.find params[:id].to_i

    puts "Enqueuing mapping worker for org #{org.name} (sfdc id: #{org.org_id})"
    ImportMappingConfigWorker.perform_async org.connection_id 

    render :json => "Heroku Connect authentication complete!"
  end
end