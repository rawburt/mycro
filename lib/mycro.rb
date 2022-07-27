module Mycro
  module Registry
    RegistryError = Class.new(StandardError)
    AlreadyRegisteredError = Class.new(RegistryError)
    EmptyImportError = Class.new(RegistryError)
    InvalidImportError = Class.new(RegistryError)

    @registry = {}

    def self.register(name, item)
      raise AlreadyRegisteredError, name.to_s if @registry[name]

      @registry[name] = item
    end

    def self.clear!
      @registry = {}
    end

    def self.[](name)
      @registry[name]
    end

    module Import
      class Importer < Module
        InstanceMethods = Class.new(Module)

        # deps: [[name, value]]
        def initialize(deps)
          @deps = deps
          @instance_methods = InstanceMethods.new
        end

        def included(klass)
          define_attr_readers
          define_initialize
          klass.send(:include, @instance_methods)
        end

        private

        def define_attr_readers
          attr_readers = @deps.map { |n, _| ":#{n}" }.join(", ")

          @instance_methods.class_eval("attr_reader #{attr_readers}")
        end

        def define_initialize
          @instance_methods.class_exec(@deps) do |deps|
            define_method(:initialize) do |**kwargs|
              deps.each do |name, value|
                value = kwargs[name] if kwargs && kwargs[name]
                instance_variable_set(:"@#{name}", value)
              end
              super()
            end
          end
        end
      end

      @deps = []

      def self.[](*names)
        raise EmptyImportError if names.empty?
        # reset @deps every call to clean the slate
        @deps = []
        names.each do |name|
          value = Registry[name]
          raise InvalidImportError, name.to_s unless value
          @deps << [name, value]
        end
        self
      end

      def self.included(mod)
        mod.send(:include, Importer.new(@deps))
        # reset @deps after injecting metaprogram to clean the slate
        @deps = []
      end
    end
  end

  module Result
    WrongResultError = Class.new(StandardError)

    class Ok
      def initialize(value)
        @value = value
      end
      def ok?; true; end
      def get_ok; @value; end
      def error?; false; end
      def get_error; raise WrongResultError, "is Ok expected Error"; end
    end

    class Error
      def initialize(value)
        @value = value
      end
      def ok?; false; end
      def get_ok; raise WrongResultError, "is Error expected Ok"; end
      def error?; true; end
      def get_error; @value; end
    end

    def self.Ok(value)
      Mycro::Result::Ok.new(value)
    end

    def self.Error(value)
      Mycro::Result::Error.new(value)
    end

    def Ok(value)
      Mycro::Result::Ok.new(value)
    end

    def Error(value)
      Mycro::Result::Error.new(value)
    end
  end
end
