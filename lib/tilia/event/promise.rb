module Tilia
  module Event
    # An implementation of the Promise pattern.
    #
    # Promises basically allow you to avoid what is commonly called 'callback
    # hell'. It allows for easily chaining of asynchronous operations.
    class Promise
      # Pending promise. No result yet.
      PENDING = 0

      # The promise has been fulfilled. It was successful.
      FULFILLED = 1

      # The promise was rejected. The operation failed.
      REJECTED = 2

      protected

      # The current state of this promise.
      #
      # @return [Fixnum]
      attr_accessor :state

      # A list of subscribers. Subscribers are the callbacks that want us to let
      # them know if the callback was fulfilled or rejected.
      #
      # @return [Array]
      attr_accessor :subscribers

      # The result of the promise.
      #
      # If the promise was fulfilled, this will be the result value. If the
      # promise was rejected, this is most commonly an exception.
      attr_accessor :value

      public

      # Creates the promise.
      #
      # The passed argument is the executor. The executor is automatically
      # called with two arguments.
      #
      # Each are callbacks that map to self.fulfill and self.reject.
      # Using the executor is optional.
      #
      # @param [Proc, Method] executor
      # @return [void]
      def initialize(executor = nil)
        @state = PENDING
        @subscribers = []
        @value = nil

        executor.call(method(:fulfill), method(:reject)) if executor
      end

      # This method allows you to specify the callback that will be called after
      # the promise has been fulfilled or rejected.
      #
      # Both arguments are optional.
      #
      # This method returns a new promise, which can be used for chaining.
      # If either the onFulfilled or onRejected callback is called, you may
      # return a result from this callback.
      #
      # If the result of this callback is yet another promise, the result of
      # _that_ promise will be used to set the result of the returned promise.
      #
      # If either of the callbacks return any other value, the returned promise
      # is automatically fulfilled with that value.
      #
      # If either of the callbacks throw an exception, the returned promise will
      # be rejected and the exception will be passed back.
      #
      # @param [Proc, Method] on_fulfilled
      # @param [Proc, Method] on_rejected
      # @return [Promise]
      def then(on_fulfilled = nil, on_rejected = nil)
        sub_promise = self.class.new
        case @state
        when PENDING
          @subscribers << [sub_promise, on_fulfilled, on_rejected]
        when FULFILLED
          invoke_callback(sub_promise, on_fulfilled)
        when REJECTED
          invoke_callback(sub_promise, on_rejected)
        end
        sub_promise
      end

      # Add a callback for when this promise is rejected.
      #
      # I would have used the word 'catch', but it's a reserved word in PHP, so
      # we're not allowed to call our function that.
      #
      # @param [Proc, Method] on_rejected
      # @return [Promise]
      def error(on_rejected)
        self.then(nil, on_rejected)
      end

      # Marks this promise as fulfilled and sets its return value.
      #
      # @param value
      # @return [void]
      def fulfill(value = nil)
        unless @state == PENDING
          fail PromiseAlreadyResolvedException, 'This promise is already resolved, and you\'re not allowed to resolve a promise more than once'
        end
        @state = FULFILLED
        @value = value
        @subscribers.each do |subscriber|
          invoke_callback(subscriber[0], subscriber[1])
        end
      end

      # Marks this promise as rejected, and set it's rejection reason.
      #
      # @param reason
      # @return [void]
      def reject(reason = nil)
        unless @state == PENDING
          fail PromiseAlreadyResolvedException, 'This promise is already resolved, and you\'re not allowed to resolve a promise more than once'
        end
        @state = REJECTED
        @value = reason
        @subscribers.each do |subscriber|
          invoke_callback(subscriber[0], subscriber[2])
        end
      end

      # It's possible to send an array of promises to the all method. This
      # method returns a promise that will be fulfilled, only if all the passed
      # promises are fulfilled.
      #
      # @param [Array<Promise>] promises
      # @return [Promise]
      def self.all(promises)
        new(
          lambda do |success, failing|
            success_count = 0
            complete_result = []

            promises.each_with_index do |sub_promise, promise_index|
              sub_promise.then(
                lambda do |result|
                  complete_result[promise_index] = result
                  success_count += 1

                  success.call(complete_result) if success_count == promises.size

                  return result
                end
              ).error(
                lambda do |reason|
                  failing.call(reason)
                end
              )
            end
          end
        )
      end

      protected

      # This method is used to call either an onFulfilled or onRejected callback.
      #
      # This method makes sure that the result of these callbacks are handled
      # correctly, and any chained promises are also correctly fulfilled or
      # rejected.
      #
      # @param [Promise] sub_promise
      # @param [Proc, Method] call_back
      # @return [void]
      def invoke_callback(sub_promise, call_back = nil)
        if call_back.is_a?(Proc) || call_back.is_a?(Method)
          begin
            result = call_back.call(@value)
            if result.is_a?(self.class)
              result.then(sub_promise.method(:fulfill), sub_promise.method(:reject))
            else
              sub_promise.fulfill(result)
            end
          rescue => e
            sub_promise.reject(e.to_s)
          end
        else
          if @state == FULFILLED
            sub_promise.fulfill(@value)
          else
            sub_promise.reject(@value)
          end
        end
      end
    end
  end
end
