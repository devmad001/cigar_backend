every 1.day, at: '12:00 am' do
  if ENV['RUN_DAEMONS'] == 'true'
    runner 'ProductUpdater.update_all!'
    runner 'ProductUpdater.store_new!'
    runner 'ClickLinksSetter.set_click_links!'
  end

  runner 'Sitemap::Generator.generate!'

  # %w[BrandsService CountryService ShapeService StrengthService WrapperService].each do |service|
  #   runner "#{ service }.merge!"
  # end
end
