require 'test_helper'

module Tilia
  module Event
    class PromiseTest < Minitest::Test
      def test_success
        final_value = 0
        promise = Promise.new
        promise.fulfill(1)

        promise.then(->(value) { final_value = value + 2 })

        assert_equal(3, final_value)
      end

      def test_fail
        final_value = 0
        promise = Promise.new
        promise.reject(1)

        promise.then(nil, ->(value) { final_value = value + 2 })
      end

      def test_chain
        final_value = 0
        promise = Promise.new
        promise.fulfill(1)

        promise.then(
          ->(value) { final_value = value + 2 }
        ).then(
          ->(value) { final_value = value + 4 }
        )

        assert_equal(7, final_value)
      end

      def test_chain_promise
        final_value = 0
        promise = Promise.new
        promise.fulfill(1)

        sub_promise = Promise.new

        promise.then(
          ->(_) { sub_promise }
        ).then(
          ->(value) { final_value = value + 4 }
        )

        sub_promise.fulfill(2)

        assert_equal(6, final_value)
      end

      def test_pending_result
        final_value = 0
        promise = Promise.new

        promise.then(->(value) { final_value = value + 2 })

        promise.fulfill(4)
        assert_equal(6, final_value)
      end

      def test_pending_fail
        final_value = 0
        promise = Promise.new

        promise.then(nil, ->(value) { final_value = value + 2 })

        promise.reject(4)
        assert_equal(6, final_value)
      end

      def test_executor_success
        real_result = ''
        Promise.new(
          ->(success, _failing) { success.call('hi') }
        ).then(
          ->(result) { real_result = result }
        )

        assert_equal('hi', real_result)
      end

      def test_executor_fail
        real_result = ''
        Promise.new(
          ->(_success, failing) { failing.call('hi') }
        ).then(
          ->(_result) { real_result = 'incorrect' },
          ->(reason) { real_result = reason }
        )

        assert_equal('hi', real_result)
      end

      def test_fulfill_twice
        promise = Promise.new
        promise.fulfill(1)
        assert_raises(PromiseAlreadyResolvedException) { promise.fulfill(1) }
      end

      def test_reject_twice
        promise = Promise.new
        promise.reject(1)
        assert_raises(PromiseAlreadyResolvedException) { promise.reject(1) }
      end

      def test_from_failure_handler
        ok = 0
        promise = Promise.new
        promise.error(
          lambda do |reason|
            assert_equal(:foo, reason)
            fail 'hi'
          end
        ).then(
          ->(_) { ok = -1 },
          ->(_) { ok = 1 }
        )

        assert_equal(0, ok)
        promise.reject(:foo)
        assert_equal(1, ok)
      end

      def test_all
        promise1 = Promise.new
        promise2 = Promise.new

        final_value = 0
        Promise.all([promise1, promise2]).then(
          ->(value) { final_value = value }
        )

        promise1.fulfill(1)
        assert_equal(0, final_value)
        promise2.fulfill(2)
        assert_equal([1, 2], final_value)
      end

      def test_all_reject
        promise1 = Promise.new
        promise2 = Promise.new

        final_value = 0
        Promise.all([promise1, promise2]).then(
          lambda do |_value|
            final_value = :foo
            'test'
          end,
          ->(value) { final_value = value }
        )

        promise1.reject(1)
        assert_equal(1, final_value)
        promise2.reject(2)
        assert_equal(1, final_value)
      end
    end
  end
end
