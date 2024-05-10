ActiveAdmin.setup do |config|
  config.root_to = 'users#index'
  config.site_title = 'Cigar Finder'
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_admin_user
  config.logout_link_path = :destroy_admin_user_session_path
  config.comments = false
  config.batch_actions = true
  config.filter_attributes = %i(encrypted_password password password_confirmation)
  config.localize_format = :long
  config.register_javascript 'ckeditor/init.js'
end
