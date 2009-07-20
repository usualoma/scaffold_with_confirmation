module Rails
  module Generator
    module Commands

      module MakeRouteAdd
        def make_route_add(resource_list)
          ns = (namespace || []).reverse
          route_add = "  " * (ns.size+1) + "map.resources_with_confirmation #{resource_list}"
          route_add_log = "map.resources_with_confirmation #{resource_list}"
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
  default_options :skip_timestamps => false, :skip_migration => false, :force_plural => false, :namespace => nil

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
                :namespace
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
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('test/unit', class_path))
      m.directory(File.join('test/unit/helpers', controller_class_path))
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

      m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))
      m.template('helper_test.rb',     File.join('test/unit/helpers',    controller_class_path, "#{controller_file_name}_helper_test.rb"))

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
    end

    def scaffold_views
      %w[ index show new create_confirm edit update_confirm ]
    end

    def partials
      %w[ form confirm ]
    end

    def model_name
      class_name.demodulize
    end
end
