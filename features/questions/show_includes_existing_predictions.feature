Feature: Give the repartition of the stakes for the existing predictions

  Background:
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

  Scenario: There is an open question to display
    When I send a GET request to "/v1/questions/fr/1"
    Then the response status should be "200"
    And the JSON response should have 2 "$.predictions[*]"
    And the JSON response should have "$.winnings" with the text "60"
    And the JSON response should have "$.bonus_winnings" with the text ""
    And the JSON response should have "$.predictions[0].mine" with the text "false"
    And the JSON response should have "$.predictions[1].mine" with the text "true"


  Scenario: There is an open question to display with a related bonus the bonus winnings are set
    Given there is the following bonuses for the question "1":
      | nickname | double |
    When I send a GET request to "/v1/questions/fr/1"
    Then the response status should be "200"
    And the JSON response should have "$.winnings" with the text "60"
    And the JSON response should have "$.bonus_winnings" with the text "60"


