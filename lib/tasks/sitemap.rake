namespace :sitemap do
  desc 'Generate sitemap'
  task generate: :environment do
    Sitemap::Generator.generate!
  end
end
