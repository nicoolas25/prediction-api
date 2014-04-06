require './app/domain/prediction_answer'
require './app/domain/bonus'

module Domain
  class MalformedComponentError < Error ; end

  class Prediction < ::Sequel::Model
    unrestrict_primary_key

    many_to_one  :question
    one_to_many  :bonuses, class: '::Domain::Bonus'
    one_to_many  :answers, class: '::Domain::PredictionAnswer'
    one_to_many  :participations
    many_to_many :players, join_table: :participations

    def right?
      answers.all?(&:right?)
    end

    def winnings_per_cristal
      earning_service = Services::Earning.new(question)
      earning_service.earning_for({
        amount: amount,
        players: players_count,
        stakes: 1,
      }, false)
    end

    def update_with_participation!(participation)
      Prediction.dataset.where(id: self.id).update({
        amount: Sequel.expr(:amount) + participation.stakes,
        players_count: Sequel.expr(:players_count) + 1
      })
    end

    class << self
      def first_or_create_from_raw_answers(raw_answers, question)
        unless valid_raw_answers?(raw_answers, question)
          raise MalformedComponentError.new(:invalid_components)
        end

        components_sum = sum_from_raw_answers(raw_answers)
        first_or_create_from_cksum(components_sum, question)
      end

      def first_or_create_from_cksum(cksum, question)
        prediction = question.predictions_dataset.where(cksum: cksum).first
        return prediction if prediction
        create_from_cksum(cksum, question)
      end

    private

      def create_from_cksum(cksum, question)
        prediction = create(question: question, cksum: cksum)
        answers = cksum.split('&').each_with_object({}) do |p, h|
          id, value = p.split(':')
          h[id.to_i] = value.to_f
        end
        question.components.map do |component|
          value = answers[component.id]
          value = value.abs if component.have_choices?
          prediction.add_answer(component: component, value: value)
        end
        prediction
      end

      def sum_from_raw_answers(raw_answers)
        raw_answers.map do |answer|
          [answer['id'].to_i, answer['value'].to_f].join(':')
        end.sort.join('&')
      end

      def valid_raw_answers?(raw_answers, question)
        question.components.all? do |component|
          raw_answers.any? do |answer|
            answer['value'].present? &&
              answer['id'] == component.id.to_s &&
              ( !component.have_choices? ||
                ( component.choices_count > answer['value'].to_i ) &&
                ( answer['value'].to_i >= 0 )
              )
          end
        end
      end
    end

    # The following methods are maintainance

    def refresh_amount!
      update(amount: participations_dataset.select{sum(:stakes)}.first[:sum])
    end

    def refresh_players!
      update(players_count: participations_dataset.count)
    end
  end
end
