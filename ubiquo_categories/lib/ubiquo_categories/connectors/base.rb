module UbiquoCategories
  module Connectors
    class Base
      
      # loads this connector. It's called if that connector is used
      def self.load!
        ::Category.reset_column_information
        if current = UbiquoCategories::Connectors::Base.current_connector
          current.unload!
        end
        return if validate_requirements == false
        prepare_mocks if Rails.env.test?
        ::ActiveRecord::Base.send(:include, self::ActiveRecord::Base)
        ::Category.send(:include, self::Category)
        ::CategorySet.send(:include, self::CategorySet)
        ::Ubiquo::Extensions::UbiquoAreaController.send(:include, self::UbiquoHelpers)
        ::Ubiquo::CategoriesController.send(:include, self::UbiquoCategoriesController)
        ::ActiveRecord::Migration.send(:include, self::Migration)
        UbiquoCategories::Connectors::Base.set_current_connector self
      end
      
      def self.current_connector
        @current_connector
      end
      
      def self.set_current_connector klass
        @current_connector = klass
      end

      # Possible cleanups to perform
      def self.unload!; end

      # Register the uhooks methods in connectors to be used in klass
      def self.register_uhooks klass, *connectors
        connectors.each do |connector|
          connector.instance_methods.each do |method|
            if method =~ /^uhook_(.*)$/
              connectorized_method = "uhook_#{self.to_s.demodulize.underscore}_#{$~[1]}"
              connector.send :alias_method, connectorized_method, method
              if klass.instance_methods.include?(method)
                klass.send :alias_method, method, connectorized_method
              else
                class << klass
                  self
                end.send :alias_method, method, connectorized_method
              end
              connector.send :undef_method, connectorized_method
            end
          end
        end
      end
      
      # Registers a uhook call and keeps a registry of this
      # 
      #   parameters: List of parameters that will be recorded along with the call
      #   replace_block: Optional block that will be called for each previous call to this function.
      #                  If it returns true, the previous call will be deleted
      def self.register_uhook_call *parameters, &replace_block
        # make sure we are registering at Base and not in a subclass
        uhook_calls = Base.instance_variable_get('@uhook_calls')
        uhook_calls ||= {}
        caller[0]=~/`(.*?)'/
        if replace_block
          (uhook_calls[$1.to_sym] ||= []).reject!{ |prev_call| replace_block.call(prev_call)}
        end
        (uhook_calls[$1.to_sym] ||= []) << parameters
        Base.instance_variable_set('@uhook_calls', uhook_calls)
      end
      
      # Returns the list of calls for this method
      def self.get_uhook_calls method
        Array((Base.instance_variable_get('@uhook_calls')||{})[method.to_sym])
      end

      # Validate here the possible connector requirements and dependencies
      def self.validate_requirements; end

      # Load any test mock needed for base tests
      # If your connector calls to a method that will be undefined in test time,
      # using this method you can mock them to allow it pass.
      def self.prepare_mocks; end

      # Prepared helper stubs for this connector
      class << self
        attr_accessor :mock_helper_stubs
      end

      # Used to add particular helper expectations from the connectors
      # Usually called from prepare_mocks
      def self.add_mock_helper_stubs(methods_with_returns)
        future_stubs = (mock_helper_stubs || {}).merge(methods_with_returns)
        self.mock_helper_stubs = future_stubs
      end

    end

    # Raised when a connector requirement is not met
    class ConnectorRequirementError < StandardError; end

  end
end 