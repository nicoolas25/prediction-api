module Workers
  class QuestionAnswerer
    include Sidekiq::Worker

    def perform(question_id, components)
      question = Domain::Question.find_for_answer(question_id)
      question.answer_with(components)
    rescue Domain::Error
      LOGGER.error("Unexpected error during async QuestionAnswerer.perform: #{$!.message}")
    end
  end
end
