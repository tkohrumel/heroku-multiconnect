desc "This task is called by the Heroku Scheduler add-on"
task :get_tweets_for_all_orgs_accounts => :environment do
  puts "Getting recent tweets for each organization's accounts..."

  client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['TWITTER_API_KEY']
    config.consumer_secret = ENV['TWITTER_API_SECRET']
    config.access_token = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end

  Organization.all.where("schema_name IS NOT NULL").each do |org|
    PgTools.set_search_path(org.schema_name, true)

    accounts = ActiveRecord::Base.connection.execute "SELECT hcpoc__twitter__c, sfid FROM account WHERE hcpoc__twitter__c IS NOT NULL;"

    accounts.each do |account|
      values = account.values
      tweet_inserts = []
      twitter_account, account_id = values[0], values[1]
      client.search(twitter_account, :count => 50, :result_type => "mixed").take(50).collect do |tweet|
        tweet_inserts.push "('#{account_id}', '#{tweet.text.gsub("'", "''")}', '#{tweet.user.name.gsub("'", "''")}', '#{tweet.created_at}')"
      end
      sql = "INSERT INTO \"#{org.schema_name}\".\"hcpoc__tweet__c\"(hcpoc__account__c, hcpoc__body__c, hcpoc__author_username__c, hcpoc__time__c) VALUES #{tweet_inserts.join(", ")}"
      ActiveRecord::Base.connection.execute(sql)
    end

    PgTools.restore_default_search_path
  end

  puts 'done.'
end