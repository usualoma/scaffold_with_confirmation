require 'rails/generators/rails/resource/resource_generator'

module Rails
  module Generators
    class ScaffoldWithConfirmationGenerator < ResourceGenerator #metagenerator
      remove_hook_for :resource_controller
      remove_class_option :actions

      hook_for :stylesheets

      invoke :scaffold_with_confirmation_controller

      def add_resource_route
        return if options[:actions].present?
        route_config =  class_path.collect{|namespace| "namespace :#{namespace} do " }.join(" ")
        route_config << "resources_with_confirmation :#{file_name.pluralize}"
        route_config << " end" * class_path.size
        route route_config
      end
    end
  end
end
