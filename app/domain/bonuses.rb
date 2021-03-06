require 'active_support/concern'
require 'active_support/core_ext/module/attribute_accessors'

module Domain
  module Bonuses
    HOOK_KINDS = [
      :none,
      :after_solving,
      :after_winning,
      :after_loosing
    ].freeze

    @@modules = {}
    mattr_accessor :modules

    # Initialize and create accessors for each hook
    HOOK_KINDS.each do |hook_kind|
      instance_eval "@@#{hook_kind} = []"
      mattr_accessor hook_kind
    end

    def self.run_hooks(hook_kinds, participation)
      hook_kinds = [hook_kinds] unless hook_kinds.kind_of?(Array)
      hook_kinds.each do |hook_kind|
        run_hook(hook_kind, participation)
      end
    end

    def self.run_hook(hook_kind, participation)
      raise "Kind #{hook_kind} isn't in #{HOOK_KINDS}" if HOOK_KINDS.exclude?(hook_kind)
      return unless (bonus = participation.bonus)
      hooks = __send__(hook_kind)
      hooks.each do |bonus_module|
        if bonus.identifier == bonus_module.identifier
          bonus_module.apply_to!(participation, bonus)
        end
      end
    end

    def self.register_bonus(bonus_module)
      modules[bonus_module.identifier] = bonus_module
      hooks = __send__(bonus_module.kind)
      hooks << bonus_module unless hooks.include?(bonus_module)
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

        def apply_to!(*arguments, &procedure)
          @procedure = procedure if procedure
          @procedure.call(*arguments) if arguments.any?
        end

        def participation_options(&block)
          block ? (@participation_options = block) : @participation_optionsi.try(:call)
        end

        def when_used(*arguments, &block)
          @when_used = block if block
          @when_used.call(*arguments) if arguments.any?
        end

        def when_used?
          !!@when_used
        end

        def expected_winnings(*arguments, &block)
          @expected_winnings = block if block
          @expected_winnings.call(*arguments) if arguments.any?
        end

        def labels(hash=nil)
          return @labels unless hash
          @labels = hash
        end
      end
    end
  end

  # Require the available badges here
  require './app/domain/bonuses/blind'
  require './app/domain/bonuses/cresus'
  require './app/domain/bonuses/double'
  require './app/domain/bonuses/lucky'
end
