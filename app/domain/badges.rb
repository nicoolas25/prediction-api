require 'active_support/concern'
require 'active_support/core_ext/module/attribute_accessors'

module Domain
  module Badges
    HOOK_KINDS = [
      :after_participation,
      :after_winning,
      :after_loosing,
      :after_friendship,
    ].freeze

    @@modules = {}
    mattr_accessor :modules

    # Initialize and create accessors for each hook
    HOOK_KINDS.each do |hook_kind|
      instance_eval "@@#{hook_kind} = []"
      mattr_accessor hook_kind
    end

    def self.run_hooks(hook_kind, *arguments)
      raise "Kind #{hook_kind} isn't in #{HOOK_KINDS}" if HOOK_KINDS.exclude?(hook_kind)
      hooks = __send__(hook_kind)
      hooks.each do |badge_module|
        match, player_ids = badge_module.matches?(*arguments)
        next unless match && player_ids && player_ids.any?
        badges_dataset = ::Domain::Badge.prepare(player_ids, badge_module.identifier)
        badges_dataset.update(count: Sequel.expr(:count) + 1)
      end
    end

    def self.register_badge(badge_module)
      modules[badge_module.identifier] = badge_module
      hooks = __send__(badge_module.kind)
      hooks << badge_module unless hooks.include?(badge_module)
    end

    module DSL
      extend ActiveSupport::Concern

      module ClassMethods
        def identifier(ident=nil)
          ident ? (@ident = ident) : @ident
        end

        def kind(type=nil)
          raise "Kind #{type} isn't in #{HOOK_KINDS}" if type && HOOK_KINDS.exclude?(type)
          type ? (@kind = type) : @kind
        end

        def steps(*counts)
          return @steps if counts.empty?
          @steps = counts
        end

        def matches?(*arguments, &matcher)
          @matcher = matcher if matcher
          @matcher.call(*arguments) if arguments.any?
        end
      end
    end
  end

  # Require the available badges here to fill the 
  require './app/domain/badges/participation'
end
