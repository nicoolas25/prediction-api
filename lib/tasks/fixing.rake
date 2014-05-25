namespace :fixing do
  desc "Update the amount and the player count"
  task :amounts_and_players do
    require './api'

    Domain::Question.all.each do |q|
      q.refresh_players!
      q.refresh_amount!
    end

    Domain::Prediction.all.each do |p|
      p.refresh_players!
      p.refresh_amount!
    end
  end

  desc "Run hooks to get badges"
  task :badges_hooks do
    require './api'

    # Destroy all badges - be careful
    Domain::Badge.dataset.destroy

    Domain::Participation.all.each do |participation|
      Domain::Badges.run_hooks(:after_participation, participation)
      unless participation.winnings.nil?
        if participation.win?
          Domain::Badges.run_hooks(:after_winning, participation)
        else
          Domain::Badges.run_hooks(:after_loosing, participation)
        end
      end
    end
  end
end
