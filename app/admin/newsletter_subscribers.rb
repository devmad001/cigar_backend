ActiveAdmin.register NewsletterSubscriber do
  actions :all, except: %i(new create edit update)
end
