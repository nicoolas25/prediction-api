Feature: Give the total participations for an open question

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
    And the user "player1" has answered the question "1" staking "100" with:
      | id | value |
      | 1  | 0     |
    And the user "player2" has answered the question "1" staking "50" with:
      | id | value |
      | 1  | 0     |
    When I send a GET request to "/v1/questions/fr/global/open"
    Then the response status should be "200"
    And the JSON response should have "$.[0].statistics.participations" with the text "2"
