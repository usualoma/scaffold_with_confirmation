module ScaffoldWithConfirmationHelper
  include ActionView::Helpers::FormHelper

  alias original_form_for form_for
  def form_for(record_or_name_or_array, *args, &block)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.extract_options!

    case record_or_name_or_array
    when String, Symbol
      object = args.first
    else
      object = record_or_name_or_array
    end
    class_name =
      ActionController::RecordIdentifier.singular_class_name(object.class)

    if object.new_record?
      options.merge!(:url => __send__("create_confirm_#{class_name}_path"))
    else
      options.merge!(:url => __send__("update_confirm_#{class_name}_path", object))
    end
    args << options

    original_form_for(record_or_name_or_array, *args) {|f|
      f.extend(ConfirmBuilderMethods)
      block.call f
    }
  end

  def confirm_for(record_or_name_or_array, *args, &proc)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.extract_options!
    args << options.merge(:builder => ConfirmBuilder)

    case record_or_name_or_array
    when String, Symbol
      object_name = record_or_name_or_array
    else
      object_name = ActionController::RecordIdentifier.singular_class_name(
        record_or_name_or_array
      )
    end

    original_form_for(record_or_name_or_array, *args) {|f|
      params[object_name.to_sym].each {|k,v|
        concat(%Q(<input type="hidden" name="#{object_name}[#{k}]" value="#{h v}" />))
      }
      proc.call f
    }
  end

  module ConfirmBuilderMethods
    def value(method, options = {})
      @object.send method
    end

    def edit(value = "Save changes", options = {})
      options[:name] = 'edit'
      submit value, options
    end

    def reset(value = "Save changes", options = {})
      options[:name] = 'reset'
      submit value, options
    end
  end

  class ConfirmBuilder < ActionView::Helpers::FormBuilder
    include ConfirmBuilderMethods
  end

end
