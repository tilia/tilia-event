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
      # Initializes the instance variables of the trait
      #
      # Do not forget to call super when initializing classes including this
      # module
      def initialize(*args)
        @listeners = {}
        super
      end

      # (see EventEmitterInterface#on)
      def on(event_name, call_back, priority = 100)
        @listeners[event_name] ||= [false, [], []]

        @listeners[event_name][0] = @listeners[event_name][1].size == 0
        @listeners[event_name][1] << priority
        @listeners[event_name][2] << call_back
      end

      # (see EventEmitterInterface#once)
      def once(event_name, call_back, priority = 100)
        wrapper = nil
        wrapper = lambda do |*arguments|
          remove_listener(event_name, wrapper)
          call_back.call(*arguments)
        end

        on(event_name, wrapper, priority)
      end

      # (see EventEmitterInterface#emit)
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

      # (see EventEmitterInterface#listeners)
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

      # (see EventEmitterInterface#remove_listener)
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

      # (see EventEmitterInterface#remove_all_listeners)
      def remove_all_listeners(event_name = nil)
        if event_name
          @listeners.delete(event_name)
        else
          @listeners = {}
        end
      end
    end
  end
end
