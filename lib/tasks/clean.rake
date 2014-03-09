namespace :connect do

  task :clean => :environment do
    threshold = 24.hours.ago
    classes = [Connect::AccessToken, Connect::Authorization, Connect::IdToken, Connect::Grant]
    classes.each do |klass|
      klass.expired(threshold).destroy_all
    end

    joins = [Connect::RequestObject, Connect::AccessTokenRequestObject, Connect::AuthorizationRequestObject, Connect::IdTokenRequestObject]
    joins.each do |klass|
      klass.orphan.readonly(false).destroy_all
    end
  end  
end