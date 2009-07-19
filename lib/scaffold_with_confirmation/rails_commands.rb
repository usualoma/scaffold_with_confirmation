Rails::Generator::Commands::Create.class_eval do
  def route_resources(*resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    sentinel = 'ActionController::Routing::Routes.draw do |map|'

    logger.route "map.resources_with_confirmation #{resource_list}"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
              "#{match}\n  map.resources_with_confirmation #{resource_list}\n"
      end
    end
  end
end

Rails::Generator::Commands::Destroy.class_eval do
  def route_resources(*resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    look_for = "\n  map.resources_with_confirmation #{resource_list}\n"
    logger.route "map.resources_with_confirmation #{resource_list}"
    gsub_file 'config/routes.rb', /(#{look_for})/mi, ''
  end
end

Rails::Generator::Commands::List.class_eval do
  def route_resources(*resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    logger.route "map.resources_with_confirmation #{resource_list}"
  end
end
