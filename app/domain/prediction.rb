require './app/domain/prediction_answer'

module Domain
  class MalformedComponentError < Error ; end

  class Prediction < ::Sequel::Model
    unrestrict_primary_key

    many_to_one  :question
    one_to_many  :answers, class: '::Domain::PredictionAnswer'
    one_to_many  :participations
    many_to_many :players, join_table: :participations

    def right?
      answers.all?(&:right?)
    end

    def update_with_participation!(participation)
      Prediction.dataset.where(id: self.id).update({
        amount: Sequel.expr(:amount) + participation.stakes,
        players_count: Sequel.expr(:players_count) + 1
      })
    end

    def refresh_amount!
      update(amount: participations_dataset.select{sum(:stakes)}.first[:sum])
    end

    def refresh_players!
      update(players_count: participations_dataset.count)
    end

    class << self
      def first_or_create_from_raw_answers(raw_answers, question)
        unless valid_raw_answers?(raw_answers, question)
          raise MalformedComponentError.new(:invalid_components)
        end

        components_sum = sum_from_raw_answers(raw_answers)
        prediction = question.predictions_dataset.where(cksum: components_sum).first
        return prediction if prediction
        create_from_raw_answers(raw_answers, components_sum, question)
      end

    private

      def create_from_raw_answers(raw_answers, cksum, question)
        prediction = create(question: question, cksum: cksum)
        question.components.map do |component|
          answer = raw_answers.find{ |answer| answer['id'] == component.id.to_s }
          prediction.add_answer(component: component, value: answer['value'].to_f)
        end
        prediction
      end

      def sum_from_raw_answers(raw_answers)
        raw_answers.map do |answer|
          [answer['id'].to_i, answer['value'].to_f].join('|')
        end.sort.join('&')
      end

      def valid_raw_answers?(raw_answers, question)
        question.components.all? do |component|
          raw_answers.any? do |answer|
            answer['value'].present? &&
              answer['id'] == component.id.to_s &&
              (!component.have_choices? || component.choices_count > answer['value'].to_i)
          end
        end
      end
    end
  end
end
