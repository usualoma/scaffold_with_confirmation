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

          map_associations(resource, options)

          if block_given?
            with_options(options.slice(*INHERITABLE_OPTIONS).merge(:path_prefix => resource.nesting_path_prefix, :name_prefix => resource.nesting_name_prefix), &block)
          end

          map_collection_actions(map, resource)
          map_default_collection_actions(map, resource)
          map_new_actions(map, resource)
          map_member_actions(map, resource)
        end
      }
    end
  end
end
