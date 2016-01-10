module Tilia
  module Event
    # EventEmitter object.
    #
    # Instantiate this class, or subclass it for easily creating event emitters.
    class EventEmitter
      include EventEmitterInterface
      include EventEmitterTrait

      # Initializes the Event emitter
      #
      # Initializes the instance variables of the EventEmitterTrait
      def initialize
        initialize_event_emitter_trait
      end
    end
  end
end
