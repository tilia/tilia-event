require 'test_helper'

module Tilia
  module Event
    class ContinueCallbackTest < Minitest::Test
      def test_continue_call_back
        ee = EventEmitter.new

        handler_counter = 0
        bla = lambda do
          handler_counter += 1
        end

        ee.on('foo', bla)
        ee.on('foo', bla)
        ee.on('foo', bla)

        continue_counter = 0
        r = ee.emit(
          'foo',
          [],
          lambda do
            continue_counter += 1
            true
          end
        )

        assert(r)
        assert_equal(3, handler_counter)
        assert_equal(2, continue_counter)
      end

      def test_continue_call_back_break
        ee = EventEmitter.new

        handler_counter = 0
        bla = lambda do
          handler_counter += 1
        end

        ee.on('foo', bla)
        ee.on('foo', bla)
        ee.on('foo', bla)

        continue_counter = 0
        r = ee.emit(
          'foo',
          [],
          lambda do
            continue_counter += 1
            false
          end
        )

        assert(r)
        assert_equal(1, handler_counter)
        assert_equal(1, continue_counter)
      end

      def test_continue_call_back_break_by_handler
        ee = EventEmitter.new

        handler_counter = 0
        bla = lambda do
          handler_counter += 1
          false
        end

        ee.on('foo', bla)
        ee.on('foo', bla)
        ee.on('foo', bla)

        continue_counter = 0
        r = ee.emit(
          'foo',
          [],
          lambda do
            continue_counter += 1
            false
          end
        )

        refute(r)
        assert_equal(1, handler_counter)
        assert_equal(0, continue_counter)
      end
    end
  end
end
