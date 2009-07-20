module ActionController
  module Resources
    def resources_with_confirmation(*entities, &block)
      options = entities.extract_options!

      {
        :collection => {
          :create_confirm => :post,
        },
        :member => {
          :update_confirm => :put,
        }
      }.each {|type, hash|
        options[type] ||= {}
        hash.each{|action, method|
          options[type][action] ||= method
        }
      }

      entities << options

      resources(*entities, &block)
    end
  end
end
