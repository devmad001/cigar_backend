namespace :set_links do
  desc 'Set impact.com links'
  task impact: :environment do
    ImpactLinksSetter.new.set_click_links!
  end
end
