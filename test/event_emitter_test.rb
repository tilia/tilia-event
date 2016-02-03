require 'test_helper'

module Tilia
  module Event
    class ContinueCallbackTest < Minitest::Test
      def test_init
        ee = EventEmitter.new
        assert_instance_of(EventEmitter, ee)
      end

      def test_listeners
        ee = EventEmitter.new
        callback1 = -> {}
        callback2 = -> {}
        ee.on(:foo, callback1, 200)
        ee.on(:foo, callback2, 100)

        assert_equal([callback2, callback1], ee.listeners(:foo))
      end

      def test_handle_event
        arg_result = nil

        ee = EventEmitter.new
        ee.on(:foo, ->(arg) { arg_result = arg })

        assert(ee.emit(:foo, ['bar']))
        assert_equal('bar', arg_result)
      end

      def test_cancel_event
        arg_result = 0

        ee = EventEmitter.new
        ee.on(
          :foo,
          lambda do |_|
            arg_result = 1
            false
          end
        )
        ee.on(:foo, ->(_) { arg_result = 2 })

        refute(ee.emit(:foo, ['bar']))
        assert_equal(1, arg_result)
      end

      def test_priority
        arg_result = 0

        ee = EventEmitter.new
        ee.on(
          :foo,
          lambda do |_|
            arg_result = 1
            false
          end
        )
        ee.on(
          :foo,
          lambda do |_|
            arg_result = 2
            false
          end,
          1
        )

        refute(ee.emit(:foo, ['bar']))
        assert_equal(2, arg_result)
      end

      def test_priority2
        result = []
        ee = EventEmitter.new

        ee.on(:foo, -> { result << 'a' }, 200)
        ee.on(:foo, -> { result << 'b' }, 50)
        ee.on(:foo, -> { result << 'c' }, 300)
        ee.on(:foo, -> { result << 'd' })

        ee.emit(:foo)
        assert_equal(%w(b d a c), result)
      end

      def test_remove_listener
        result = false

        call_back = -> { result = true }

        ee = EventEmitter.new

        ee.on(:foo, call_back)
        ee.emit(:foo)

        assert(result)
        result = false

        assert(ee.remove_listener(:foo, call_back))

        ee.emit(:foo)
        refute(result)
      end

      def test_remove_unknown_listener
        result = false

        call_back = -> { result = true }

        ee = EventEmitter.new

        ee.on(:foo, call_back)
        ee.emit(:foo)

        assert(result)
        result = false

        refute(ee.remove_listener('bar', call_back))

        ee.emit(:foo)
        assert(result)
      end

      def test_remove_listener_twice
        result = false

        call_back = -> { result = true }

        ee = EventEmitter.new

        ee.on(:foo, call_back)
        ee.emit(:foo)

        assert(result)
        result = false

        assert(ee.remove_listener(:foo, call_back))
        refute(ee.remove_listener(:foo, call_back))

        ee.emit(:foo)
        refute(result)
      end

      def test_remove_all_listeners
        result = false

        call_back = -> { result = true }

        ee = EventEmitter.new

        ee.on(:foo, call_back)
        ee.emit(:foo)

        assert(result)
        result = false

        ee.remove_all_listeners(:foo)

        ee.emit(:foo)
        refute(result)
      end

      def test_remove_all_listeners_no_arg
        result = false

        call_back = -> { result = true }

        ee = EventEmitter.new

        ee.on(:foo, call_back)
        ee.emit(:foo)

        assert(result)
        result = false

        ee.remove_all_listeners

        ee.emit(:foo)
        refute(result)
      end

      def test_once
        result = 0

        call_back = -> { result += 1 }

        ee = EventEmitter.new
        ee.once(:foo, call_back)

        ee.emit(:foo)
        ee.emit(:foo)

        assert_equal(1, result)
      end

      def test_priority_once
        arg_result = 0

        ee = EventEmitter.new
        ee.once(
          :foo,
          lambda do |_|
            arg_result = 1
            false
          end
        )
        ee.once(
          :foo,
          lambda do |_|
            arg_result = 2
            false
          end,
          1
        )

        refute(ee.emit(:foo, ['bar']))
        assert_equal(2, arg_result)
      end
    end
  end
end
