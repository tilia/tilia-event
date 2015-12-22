# Namespace for tilia project
module Tilia
  # Load active support core extensions
  require 'active_support'
  require 'active_support/core_ext'

  # Namespace of tilia-event library
  module Event
    require 'tilia/event/event_emitter_interface'
    require 'tilia/event/event_emitter_trait'
    require 'tilia/event/event_emitter'
    require 'tilia/event/promise'
    require 'tilia/event/promise_already_resolved_exception'
    require 'tilia/event/version'
  end
end
