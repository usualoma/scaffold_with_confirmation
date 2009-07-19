module ActionController
  module Resources
    def resources_with_confirmation(*entities, &block)
      #resources
      options = entities.extract_options!
      entities.each { |entity|
        map_resource(entity, options.dup, &block)

        resource = Resource.new(entity, options)
        with_options :controller => resource.controller do |map|
          [:create_confirm].each do |action|
            route_path = resource.path + '/' + action.to_s
            route_name = "#{action.to_s}_#{resource.name_prefix}#{resource.singular}"

            map_resource_routes(map, resource, action, route_path, route_name, :post)
          end

          [:update_confirm].each do |action|
            route_path = "#{resource.member_path}#{resource.action_separator}" + action.to_s
            route_name = "#{action.to_s}_#{resource.name_prefix}#{resource.singular}"

            map_resource_routes(map, resource, action, route_path, route_name, :put)
          end
        end
      }
    end
  end
end
