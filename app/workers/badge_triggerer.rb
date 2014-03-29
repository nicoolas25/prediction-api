module Workers
  # Performs the badge hooks for a given question
  class BadgeTriggerer
    include Sidekiq::Worker

    def perform(question_id)
      question = Domain::Question.where(id: question_id).first
      question.run_pending_hooks!
    rescue Domain::Error
      LOGGER.error("Unexpected error during async QuestionAnswerer.perform: #{$!.message}")
    end
  end
end
