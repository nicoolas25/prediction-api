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
      badges = []
      hooks = __send__(hook_kind)
      hooks.each do |badge_module|
        match, players = badge_module.matches?(*arguments)
        next unless match
        new_badges = ::Domain::Badge.increase_counts_for(players, badge_module)
        badges += new_badges
      end
      badges
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

        def level_for(count)
          @steps.reduce(0){ |level, step| step <= count ? level + 1 : level }
        end

        def matches?(*arguments, &matcher)
          @matcher = matcher if matcher
          @matcher.call(*arguments) if arguments.any?
        end

        def labels(hash=nil)
          return @labels unless hash
          @labels = hash
        end
      end
    end
  end

  # Require the available badges here
  require './app/domain/badges/participation'
  require './app/domain/badges/looser'
end
