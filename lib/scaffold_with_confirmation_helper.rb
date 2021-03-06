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

    if object.kind_of?(ActiveRecord::Base)
      if object.new_record?
        options[:url] ||= url_for(:action => :preview_creation)
      else
        options[:url] ||= url_for(:action => :preview_update, :id => object)
      end
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
    options[:builder] ||= ConfirmBuilder

    case record_or_name_or_array
    when String, Symbol
      object_name = record_or_name_or_array
      object = args.first
    else
      object = record_or_name_or_array
      object_name = ActionController::RecordIdentifier.singular_class_name(
        object
      )
    end

    if object.kind_of?(ActiveRecord::Base)
      if object.new_record?
        options[:url] ||= url_for(:action => 'create')
      else
        options[:url] ||= url_for(:action => 'update', :id => object)
      end
    end
    args << options

    original_form_for(record_or_name_or_array, *args) {|f|
      params[object_name.to_sym].each {|k,v|
        if v.instance_of?(Array)
          v.each_with_index do |v, i|
            concat(%Q(<input type="hidden" name="#{object_name}[#{k}][#{i}]" value="#{h v}" />))
          end
        elsif v.instance_of?(Hash) || v.instance_of?(HashWithIndifferentAccess)
          v.each do |hk, v|
            concat(%Q(<input type="hidden" name="#{object_name}[#{k}][#{hk}]" value="#{h v}" />))
          end
        else
          concat(%Q(<input type="hidden" name="#{object_name}[#{k}]" value="#{h v}" />))
        end
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
