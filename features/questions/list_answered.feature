Feature: Display lists of answered questions

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/questions/fr/global/answered"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: There is no open questions to display
    Given I am an authenticated user
    When I send a GET request to "/v1/questions/fr/global/answered"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*].*"

  Scenario: There is some answered questions to display
    Given existing questions:
      | 1 | Qui va gagner ?  |
      | 2 | Qui va marquer ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | 2 | choices | Chosir le bon joueur | Zidane,Zlatan |
    And I am an authenticated user: "nickname"
    And an user "player1" is already registered
    And an user "player2" is already registered
    And there is the following participations for the question "2":
      | nickname | 20 | 2:1 |
      | player1  | 10 | 2:1 |
      | player2  | 10 | 2:0 |
    And there is the following bonuses for the question "2":
      | nickname | blind |
    When I send a GET request to "/v1/questions/fr/global/answered"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"
    And the JSON response should have "$.[0].expires_at"
    And the JSON response should have "$.[0].label" with the text "Qui va marquer ?"
    And the JSON response should have "$.[0].winnings" with the text "26"
    And the JSON response should have "$.[0].bonus" with the text "blind"
