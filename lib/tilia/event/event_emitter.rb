module Tilia
  module Event
    # EventEmitter object.
    #
    # Instantiate this class, or subclass it for easily creating event emitters.
    class EventEmitter
      include EventEmitterInterface
      include EventEmitterTrait
    end
  end
end
