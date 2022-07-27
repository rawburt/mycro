require_relative "../lib/mycro"
require "minitest/autorun"

class TestMycroRegistry < Minitest::Test
  def teardown
    Mycro::Registry.clear!
  end

  def test_basic
    class_a = Class.new do
      def hello
        :class_a_hello
      end
    end

    Mycro::Registry.register(:class_a, class_a.new)

    class_b = Class.new do
      include Mycro::Registry::Import[:class_a]

      def hello
        class_a.hello
      end
    end

    assert_equal class_b.new.hello, :class_a_hello
  end

  class ClassA
    def call
      :a
    end
  end

  class ClassB
    def call
      :b
    end
  end

  def test_import_many
    Mycro::Registry.register(:class_a, ClassA.new)
    Mycro::Registry.register(:class_b, ClassB.new)

    class_c = Class.new do
      include Mycro::Registry::Import[:class_a, :class_b]

      def call
        [class_a.call, class_b.call]
      end
    end

    assert class_c.new.call, [:a, :b]
  end

  def test_import_does_not_cache
    Mycro::Registry.register(:class_a, ClassA.new)
    Mycro::Registry.register(:class_b, ClassB.new)

    class_one = Class.new do
      include Mycro::Registry::Import[:class_a]

      def call
        class_a.call
      end
    end

    class_two = Class.new do
      include Mycro::Registry::Import[:class_b]

      def call
        class_b.call
      end
    end

    one = class_one.new
    two = class_two.new

    assert_equal one.call, :a
    assert_equal two.call, :b
  end

  def test_import_multiple_times
    Mycro::Registry.register(:class_a, ClassA.new)
    Mycro::Registry.register(:class_b, ClassB.new)

    class_test = Class.new do
      include Mycro::Registry::Import[:class_a]
      include Mycro::Registry::Import[:class_b]

      def call
        [class_b.call, class_a.call]
      end
    end

    assert_equal class_test.new.call, [:b, :a]
  end

  def test_dependency_injection
    Mycro::Registry.register(:class_a, ClassA.new)

    class_test = Class.new do
      include Mycro::Registry::Import[:class_a]

      def call
        class_a.call
      end
    end

    first = class_test.new.call
    second = class_test.new(class_a: lambda { :neato }).call

    assert_equal first, :a
    assert_equal second, :neato
  end

  def test_error_empty_import
    begin
      Class.new do
        include Mycro::Registry::Import[]
      end
      assert false, "EmptyImportError not thrown"
    rescue Mycro::Registry::EmptyImportError
      assert true
    end
  end

  def test_error_invalid_import
    begin
      Class.new do
        include Mycro::Registry::Import[:not_a_name]
      end
      assert false, "InvalidImportError not thrown"
    rescue Mycro::Registry::InvalidImportError
      assert true
    end
  end

  def test_error_already_registered
    Mycro::Registry.register(:class_a, ClassA.new)
    begin
      Mycro::Registry.register(:class_a, ClassA.new)
      assert false, "AlreadyRegisteredError not thrown"
    rescue Mycro::Registry::AlreadyRegisteredError
      assert true
    end
  end
end
