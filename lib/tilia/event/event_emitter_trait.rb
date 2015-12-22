module Tilia
  module Event
    # Event Emitter Trait
    #
    # This trait contains all the basic functions to implement an
    # EventEmitterInterface.
    #
    # Using the trait + interface allows you to add EventEmitter capabilities
    # without having to change your base-class.
    module EventEmitterTrait
      # The list of listeners
      #
      # @return [Hash]
      attr_accessor :listeners

      # Subscribe to an event.
      #
      # @param [String] event_name
      # @param [Proc, Method] call_back
      # @param [Fixnum] priority
      # @return [void]
      def on(event_name, call_back, priority = 100)
        @listeners[event_name] ||= [false, [], []]

        @listeners[event_name][0] = @listeners[event_name][1].size == 0
        @listeners[event_name][1] << priority
        @listeners[event_name][2] << call_back
      end

      # Subscribe to an event exactly once.
      #
      # @param [String] event_name
      # @param [Proc, Method] call_back
      # @param [Fixnum] priority
      # @return [void]
      def once(event_name, call_back, priority = 100)
        wrapper = nil
        wrapper = lambda do |*arguments|
          remove_listener(event_name, wrapper)
          call_back.call(*arguments)
        end

        on(event_name, wrapper, priority)
      end

      # Emits an event.
      #
      # This method will return true if 0 or more listeners were succesfully
      # handled. false is returned if one of the events broke the event chain.
      #
      # If the continueCallBack is specified, this callback will be called every
      # time before the next event handler is called.
      #
      # If the continueCallback returns false, event propagation stops. This
      # allows you to use the eventEmitter as a means for listeners to implement
      # functionality in your application, and break the event loop as soon as
      # some condition is fulfilled.
      #
      # Note that returning false from an event subscriber breaks propagation
      # and returns false, but if the continue-callback stops propagation, this
      # is still considered a 'successful' operation and returns true.
      #
      # Lastly, if there are 5 event handlers for an event. The continueCallback
      # will be called at most 4 times.
      #
      # @param [String] event_name
      # @param [Array] arguments
      # @param [Proc, method] continue_call_back
      # @return [Boolean]
      def emit(event_name, arguments = [], continue_call_back = nil)
        if !continue_call_back.is_a?(Proc)

          listeners(event_name).each do |listener|
            result = listener.call(*arguments)
            return false if result == false
          end
        else
          my_listeners = listeners(event_name)
          counter = my_listeners.size

          my_listeners.each do |listener|
            counter -= 1
            result = listener.call(*arguments)

            return false if result == false

            break if counter > 0 && !continue_call_back.call
          end
        end

        true
      end

      # Returns the list of listeners for an event.
      #
      # The list is returned as an array, and the list of events are sorted by
      # their priority.
      #
      # @param [String] event_name
      # @return [Array<Proc, Method>]
      def listeners(event_name)
        return [] unless @listeners.key? event_name

        # The list is not sorted
        unless @listeners[event_name][0]
          # Sorting
          # array_multisort with ruby
          joined = (0...@listeners[event_name][1].size).map do |i|
            [@listeners[event_name][1][i], @listeners[event_name][2][i]]
          end
          sorted = joined.sort do |a, b|
            a[0] <=> b[0]
          end
          sorted.each_with_index do |data, i|
            @listeners[event_name][1][i] = data[0]
            @listeners[event_name][2][i] = data[1]
          end

          # Marking the listeners as sorted
          @listeners[event_name][0] = true
        end

        @listeners[event_name][2]
      end

      # Removes a specific listener from an event.
      #
      # If the listener could not be found, this method will return false. If it
      # was removed it will return true.
      #
      # @param [String] event_name
      # @param [Proc, Method] listener
      # @return [Boolean]
      def remove_listener(event_name, listener)
        return false unless @listeners.key?(event_name)

        @listeners[event_name][2].each_with_index do |check, index|
          next unless check == listener

          @listeners[event_name][1].delete_at(index)
          @listeners[event_name][2].delete_at(index)
          return true
        end
        false
      end

      # Removes all listeners.
      #
      # If the eventName argument is specified, all listeners for that event are
      # removed. If it is not specified, every listener for every event is
      # removed.
      #
      # @param [String] event_name
      # @return [void]
      def remove_all_listeners(event_name = nil)
        if !event_name.nil?
          @listeners.delete(event_name)
        else
          @listeners = {}
        end
      end

      # TODO: document
      def initialize_event_emitter_trait
        @listeners = {}
      end
    end
  end
end
