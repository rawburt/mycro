require_relative "../lib/mycro"
require "minitest/autorun"

class TestMycroResult < Minitest::Test
  class ResultTest
    include Mycro::Result

    def ok_result
      Ok(:test_value)
    end

    def error_result
      Error(:bad_value)
    end
  end

  def test_include_ok_result
    result = ResultTest.new.ok_result
    assert result.ok?
    assert result.get_ok, :test_value
    begin
      result.get_error
      assert false, "WrongResultError not thrown"
    rescue Mycro::Result::WrongResultError
      assert true
    end
  end

  def test_include_error_result
    result = ResultTest.new.error_result
    assert result.error?
    assert result.get_error, :bad_value
    begin
      result.get_ok
      assert false, "WrongResultError not thrown"
    rescue Mycro::Result::WrongResultError
      assert true
    end
  end

  def test_ok_result
    result = Mycro::Result::Ok(:testing)
    assert result.ok?
    assert result.get_ok, :testing
    begin
      result.get_error
      assert false, "WrongResultError not thrown"
    rescue Mycro::Result::WrongResultError
      assert true
    end
  end

  def test_error_result
    result = Mycro::Result::Error(:no_good)
    assert result.error?
    assert result.get_error, :no_good
    begin
      result.get_ok
      assert false, "WrongResultError not thrown"
    rescue Mycro::Result::WrongResultError
      assert true
    end
  end
end
