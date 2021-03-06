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
        match, players, *extra_args = badge_module.matches?(*arguments)
        next unless match
        new_badges = ::Domain::Badge.increase_counts_for(players, badge_module, *extra_args)
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

        def earning_cristals
          @earning_cristals ||= steps.map { |count| if count == 1 then 10 else count * 2.5 end }
        end

        def earning_bonuses
          @earning_bonuses ||= steps.map { |count| if count == 1 then 1 else count * 0.2 end }
        end

        def earning_bonus_frequencies
          # This will be badge specific later and should not be a constant
          [
            {'blind' => 0.8, 'cresus' => 1.0,  'double' => 0.0},
            {'blind' => 0.8, 'cresus' => 0.9,  'double' => 1.0},
            {'blind' => 0.6, 'cresus' => 0.8,  'double' => 1.0},
            {'blind' => 0.5, 'cresus' => 0.75, 'double' => 1.0},
            {'blind' => 0.5, 'cresus' => 0.7,  'double' => 1.0},
            {'blind' => 0.5, 'cresus' => 0.7,  'double' => 1.0},
            {'blind' => 0.5, 'cresus' => 0.7,  'double' => 1.0}
          ]
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
  require './app/domain/badges/chicken'
  require './app/domain/badges/glutton'
  require './app/domain/badges/god'
  require './app/domain/badges/incredible'
  require './app/domain/badges/looser'
  require './app/domain/badges/visionary'
  require './app/domain/badges/participation'
end
