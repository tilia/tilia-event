module Tilia
  module Event
    # This exception is thrown when the user tried to reject or fulfill a promise,
    # after either of these actions were already performed.
    class PromiseAlreadyResolvedException < StandardError
    end
  end
end
