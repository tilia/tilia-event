module Tilia
  module Event
    # Event Emitter Interface
    #
    # Anything that accepts listeners and emits events should implement this
    # interface.
    module EventEmitterInterface
      # Subscribe to an event.
      #
      # @param [String] _event_name
      # @param [Proc, Method] _call_back
      # @param [Fixnum] _priority
      # @return [void]
      def on(_event_name, _call_back, _priority = 100)
      end

      # Subscribe to an event exactly once.
      #
      # @param [String] _event_name
      # @param [Proc, Method] _call_back
      # @param [Fixnum] _priority
      # @return [void]
      def once(_event_name, _call_back, _priority = 100)
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
      # @param [String] _event_name
      # @param [Array] _arguments
      # @param [Proc, Method] _continue_call_back
      # @return [Boolean]
      def emit(_event_name, _arguments = [], _continue_call_back = nil)
      end

      # Returns the list of listeners for an event.
      #
      # The list is returned as an array, and the list of events are sorted by
      # their priority.
      #
      # @param [String] _event_name
      # @return [Array<Proc, Method>]
      def listeners(_event_name)
      end

      # Removes a specific listener from an event.
      #
      # If the listener could not be found, this method will return false. If it
      # was removed it will return true.
      #
      # @param [String] _event_name
      # @param [Proc, Method] _listener
      # @return [Boolean]
      def remove_listener(_event_name, _listener)
      end

      # Removes all listeners.
      #
      # If the eventName argument is specified, all listeners for that event are
      # removed. If it is not specified, every listener for every event is
      # removed.
      #
      # @param [String] _event_name
      # @return [void]
      def remove_all_listeners(_event_name = nil)
      end
    end
  end
end
