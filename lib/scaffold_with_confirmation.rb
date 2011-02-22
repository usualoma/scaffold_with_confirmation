# ScaffoldWithConfirmation
require 'action_dispatch/routing/mapper'

module ActionDispatch
  module Routing
    class Mapper
      def resources_with_confirmation(*entities, &block)
        resources *entities do
          collection do
            post :preview_creation, :as => 'preview', :path => 'preview'
          end
          member do
            put :preview_update, :as => 'preview', :path => 'preview'
          end
          block.call if block
        end
      end
    end
  end
end

require 'rails/generators'
%W(
  rails:scaffold_with_confirmation
  rails:scaffold_with_confirmation_controller
  erb:scaffold_with_confirmation
  rspec:scaffold_with_confirmation
).each do |namespace|
  Rails::Generators.hidden_namespaces << namespace
end
