Feature: Display the potential winnings related to bonus

  Background:
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

  Scenario: There is some answered questions to display and a bonus blind was used
    Given there is the following bonuses for the question "2":
      | nickname | blind |
    When I send a GET request to "/v1/questions/fr/global/answered"
    Then the response status should be "200"
    And the JSON response should have "$.[0].winnings" with the text "26"
    And the JSON response should have "$.[0].bonus_winnings" with the text "0"
    And the JSON response should have "$.[0].bonus" with the text "blind"

  Scenario: There is some solved questions to display and a bonus blind was used
    Given there is the following bonuses for the question "2":
      | nickname | blind |
    And it is currently 5 days from now
    And the solution to the question "2" is:
    """
    {
      "2": 0.0
    }
    """
    And the user "nickname" have a valid token: "12345"
    When I send a GET request to "/v1/questions/fr/global/outdated"
    Then show me the response
    Then the response status should be "200"
    And the JSON response should have "$.[0].winnings" with the text "0"
    And the JSON response should have "$.[0].bonus_winnings" with the text "20"
    And the JSON response should have "$.[0].bonus" with the text "blind"

  Scenario: There is some answered questions to display and a bonus cresus was used
    Given there is the following bonuses for the question "2":
      | nickname | cresus |
    When I send a GET request to "/v1/questions/fr/global/answered"
    Then the response status should be "200"
    And the JSON response should have "$.[0].winnings" with the text "26"
    And the JSON response should have "$.[0].bonus_winnings" with the text "20"
    And the JSON response should have "$.[0].bonus" with the text "cresus"

  Scenario: There is some answered questions to display and a bonus double was used
    Given there is the following bonuses for the question "2":
      | nickname | double |
    When I send a GET request to "/v1/questions/fr/global/answered"
    Then the response status should be "200"
    And the JSON response should have "$.[0].winnings" with the text "26"
    And the JSON response should have "$.[0].bonus_winnings" with the text "26"
    And the JSON response should have "$.[0].bonus" with the text "double"

  Scenario: There is some answered questions to display and a bonus cresus was used
    Given there is the following bonuses for the question "2":
      | nickname | lucky |
    When I send a GET request to "/v1/questions/fr/global/answered"
    Then the response status should be "200"
    And the JSON response should have "$.[0].winnings" with the text "26"
    And the JSON response should have "$.[0].bonus_winnings" with the text "0"
    And the JSON response should have "$.[0].bonus" with the text "lucky"
