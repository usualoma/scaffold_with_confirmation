module ActionController
  module Resources
    def resources_with_confirmation(*entities, &block)
      options = entities.extract_options!

      entities.each { |entity|
        resource = Resource.new(entity, options)
        with_options :controller => resource.controller do |map|
          map_resource_routes(
            map, resource, :preview_creation,
            resource.path + '/preview',
            "preview_#{resource.name_prefix}#{resource.singular}",
            :post
          )
          map_resource_routes(
            map, resource, :preview_update,
            "#{resource.member_path}#{resource.action_separator}preview",
            "preview_#{resource.name_prefix}#{resource.singular}",
            :put
          )
        end
      }

      entities << options
      resources(*entities, &block)
    end
  end
end
