module Tilia
  module Event
    # EventEmitter object.
    #
    # Instantiate this class, or subclass it for easily creating event emitters.
    class EventEmitter
      include EventEmitterInterface
      include EventEmitterTrait

      # TODO: document
      def initialize
        initialize_event_emitter_trait
      end
    end
  end
end
