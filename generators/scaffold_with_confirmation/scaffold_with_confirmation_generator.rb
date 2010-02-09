require File.dirname(__FILE__) + '/../default_values'

module Rails
  module Generator
    module Commands

      module MakeRouteAdd
        def make_route_add(resource_list)
          resources_method = 'resources'
          if ! options[:skip_confirmation]
            resources_method = 'resources_with_confirmation'
          end

          ns = (namespace || []).reverse
          route_add = "  " * (ns.size+1) + "map.#{resources_method} #{resource_list}"
          route_add_log = "map.#{resources_method} #{resource_list}"
          while ns.any?
            n = ns.shift.underscore
            route_add =
              "  " * (ns.size+1) + "map.namespace :#{n} do |#{n}|\n" +
              route_add.sub(/(\s+)[^\.]+/) {|w| $1 + n} + "\n" +
              "  " * (ns.size+1) + "end"
              route_add_log =
              "map.namespace :#{n} do |#{n}| " + route_add_log + " end"
          end

          return route_add, route_add_log
        end
      end

      class Create
        include MakeRouteAdd

        def route_resources_with_confirmation(*resources)
          resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
          sentinel = 'ActionController::Routing::Routes.draw do |map|'
          route_add, route_add_log = make_route_add resource_list

          logger.route route_add_log
          unless options[:pretend]
            gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
                "#{match}\n#{route_add}\n"
            end
          end
        end
      end

      class Destroy
        include MakeRouteAdd

        def route_resources_with_confirmation(*resources)
          resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
          route_add, route_add_log = make_route_add resource_list

          look_for = "\n" + Regexp.escape(route_add).gsub('\\n', "\n") + "\n"
          logger.route route_add_log
          gsub_file 'config/routes.rb', /(#{look_for})/mi, ''
        end
      end

      class List
        include MakeRouteAdd

        def route_resources_with_confirmation(*resources)
          resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
          route_add, route_add_log = make_route_add resource_list

          logger.route route_add_log
        end
      end

    end
  end
end

class ScaffoldWithConfirmationGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :skip_migration => false, :force_plural => false, :namespace => nil, :skip_confirmation => false, :rspec => false

  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name,
                :singular_path,
                :plural_path,
                :namespace,
                :default_file_extension
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super

    if @name == @name.pluralize && !options[:force_plural]
      logger.warning "Plural version of the model detected, using singularized version.  Override with --force-plural."
      @name = @name.singularize
    end

    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name=base_name.singularize
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end

    @plural_path = table_name
    @singular_path = table_name.singularize
    if options[:namespace]
      @namespace = options[:namespace]
      @namespace = @namespace.include?('/') ?
        @namespace.split('/') : @namespace.split('::')
      @controller_class_path = (@namespace + @controller_class_path).
        map do |n|
          n.underscore
        end

      @controller_file_path =
        (@controller_class_path + [@controller_file_path]).join('/')
      @controller_class_name =
        (@controller_class_path + [@controller_class_name]).map do |n|
          n.camelize
        end.join('::')

      path_prefix = @controller_class_path.join('_')
      @plural_path = path_prefix + '_' + @plural_path
      @singular_path = path_prefix + '_' + @singular_path
    end

    @default_file_extension = "html.erb"
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions("#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_name)

      # Controller, helper, views, test and stylesheets directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('app/views/layouts', controller_class_path))
      if ! options[:rspec]
        m.directory(File.join('test/functional', controller_class_path))
        m.directory(File.join('test/unit', class_path))
        m.directory(File.join('test/unit/helpers', controller_class_path))
      else
        m.directory(File.join('spec/controllers', controller_class_path))
        m.directory(File.join('spec/routing', controller_class_path))
        m.directory(File.join('spec/models', class_path))
        m.directory(File.join('spec/helpers', class_path))
        m.directory File.join('spec/fixtures', class_path)
        m.directory File.join('spec/views', controller_class_path, controller_file_name)
        m.directory File.join('spec/integration', class_path)
      end
      m.directory(File.join('public/stylesheets', class_path))

      for action in scaffold_views
        m.template(
          "view_#{action}.html.erb",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end

      for partial in partials
        m.template(
          "view_#{partial}.html.erb",
          File.join('app/views', controller_class_path, controller_file_name, "_#{partial}.html.erb")
        )
      end

      # Layout and stylesheet.
      m.template('layout.html.erb', File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.html.erb"))
      m.template('style.css', 'public/stylesheets/scaffold.css')

      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )
      m.template(
        'helper.rb', File.join('app/helpers', controller_class_path, "#{controller_file_name}_helper.rb")
      )

      if ! options[:rspec]
        m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
        m.template('helper_test.rb',     File.join('test/unit/helpers',    controller_class_path, "#{controller_file_name}_helper_test.rb"))
      else
        # Controller spec, class, and helper.
        m.template 'routing_spec.rb',
          File.join('spec/routing', controller_class_path, "#{controller_file_name}_routing_spec.rb")

        m.template 'controller_spec.rb',
          File.join('spec/controllers', controller_class_path, "#{controller_file_name}_controller_spec.rb")

        m.template 'helper_spec.rb',
          File.join('spec/helpers', class_path, "#{controller_file_name}_helper_spec.rb")

        # unit test, and fixtures.
        m.template 'model:fixtures.yml',        File.join('spec/fixtures', class_path, "#{table_name}.yml")
        m.template 'rspec_model:model_spec.rb', File.join('spec/models', class_path, "#{file_name}_spec.rb")

        # View specs
        m.template "edit_erb_spec.rb",
          File.join('spec/views', controller_class_path, controller_file_name, "edit.#{default_file_extension}_spec.rb")
        m.template "index_erb_spec.rb",
          File.join('spec/views', controller_class_path, controller_file_name, "index.#{default_file_extension}_spec.rb")
        m.template "new_erb_spec.rb",
          File.join('spec/views', controller_class_path, controller_file_name, "new.#{default_file_extension}_spec.rb")
        m.template "show_erb_spec.rb",
          File.join('spec/views', controller_class_path, controller_file_name, "show.#{default_file_extension}_spec.rb")

        # Integration
        m.template 'integration_spec:integration_spec.rb', File.join('spec/integration', class_path, "#{table_name}_spec.rb")
      end

      m.route_resources_with_confirmation controller_file_name

      m.dependency 'model', [name] + @args, :collision => :skip
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} scaffold ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--skip-migration",
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--force-plural",
             "Forces the generation of a plural ModelName") { |v| options[:force_plural] = v }

      opt.on("--namespace [Namespace]",
             "Set namespace") { |v| options[:namespace] = v }
      opt.on("--skip-confirmation",
             "Don't generate confirmation page") { |v| options[:skip_confirmation] = v }
      opt.on("--rspec",
             "Generate the spec of Rspec instead of the test.") { |v| options[:rspec] = v }
    end

    def scaffold_views
      views = %w[ index show new edit ]
      if ! options[:skip_confirmation]
        views += %w[ preview_creation preview_update ]
      end

      views
    end

    def partials
      partials = %w[ form ]
      if ! options[:skip_confirmation]
        partials += %w[ confirm ]
      end

      partials
    end

    def model_name
      class_name.demodulize
    end
end

module Rails
  module Generator
    class GeneratedAttribute
      def input_type
        @input_type ||= case type
          when :text                        then "textarea"
          else
            "input"
        end      
      end
    end
  end
end
