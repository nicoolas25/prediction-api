Feature: Give the potential winning for a prediction

  Scenario: There is an open question to display
    Given I am an authenticated user: "nickname"
    And an user "player1" is already registered
    And the user "player1" have "100" cristals
    And an user "player2" is already registered
    And the user "player2" have "50" cristals
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And there is the following participations for the question "1":
      | nickname | 10  | 1:1 |
      | player1  | 100 | 1:0 |
      | player2  | 10  | 1:1 |
    When I send a GET request to "/v1/questions/fr/1"
    Then the response status should be "200"
    And the JSON response should have 2 "$.predictions[*]"
    And the JSON response should have "$.winnings" with the text "60"
    And the JSON response should have "$.predictions[1].statistics.winnings" with the text "6.0"
