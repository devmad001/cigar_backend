namespace :parse do
  desc 'Update resource products'
  task update: :environment do
    if ENV['PARSER'].blank?
      puts 'Please set ENV["PARSER"]'
      return
    end

    puts ENV['PARSER']
    puts 'ENV variables:'
    %w(PARSER OLDEST QUERY).each do |i|
      puts " *#{ i }"
    end

    begin
      parser = ENV['PARSER'].constantize
      resource = parser.resource

      if resource
        scope = Product.where(resource_id: resource.id).includes(:attachments, :reviews)
        oldest = nil
        oldest ||= parser.parse_datetime ENV['OLDEST'] if ENV['OLDEST'].present?
        oldest ||= ProductUpdater::UPDATE_INTERVAL.ago
        scope = scope.where('refreshed_at < ?', oldest) if oldest.present?
        scope = scope.where(ENV['QUERY']) if ENV['QUERY'].present?

        ProductUpdater.update_all! scope
      end

      parser.store_products!
    rescue => e
      puts e.message
    end
  end

  desc 'Update all products'
  task update_all: :environment do
    ProductUpdater.update_all!
  end

  desc 'Parse resource products'
  task store: :environment do
    if ENV['PARSER'].blank?
      puts 'Please set ENV["PARSER"]'
      return
    end

    puts ENV['PARSER']

    begin
      parser = ENV['PARSER'].constantize
      resource = parser.resource
      parser.store_products!
    rescue => e
      puts e.message
    end
  end
end
