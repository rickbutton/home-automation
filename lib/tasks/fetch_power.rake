namespace :home do
  namespace :power do
    
    desc "Fetch the latest power usage data"
    task fetch: :environment do
      provider = Rails.application.config.power_provider
      provider.fetch(Rails.application.config.power_provider_options).each do |row|
        Usage.create(row) unless Usage.where(date: row[:date]).any?
      end
    end
  end
end
