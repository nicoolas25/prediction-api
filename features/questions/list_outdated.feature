Feature: Display lists of outdated questions

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/questions/fr/global/outdated"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: There is no open questions to display
    Given I am an authenticated user
    When I send a GET request to "/v1/questions/fr/global/outdated"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*].*"

  Scenario: There is some outdated and unsolved questions to display
    Given I am an authenticated user
    And existing expired questions:
      | 1 | Qui va gagner ?  |
      | 2 | Qui va marquer ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | 2 | choices | Chosir le bon joueur | Zidane,Zlatan |
    And the user "nickname" has answered the question "2" with:
      | id | value |
      | 2  | 1     |
    When I send a GET request to "/v1/questions/fr/global/outdated"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"
    And the JSON response should have "$.[0].expires_at"
    And the JSON response should have "$.[0].label" with the text "Qui va marquer ?"
    And the JSON response should have "$.[0].winnings" with the text "10"

  Scenario: There is some outdated and solved questions to display
    Given I am an authenticated user
    And existing expired questions:
      | 1 | Qui va gagner ?  |
      | 2 | Qui va marquer ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | 2 | choices | Chosir le bon joueur | Zidane,Zlatan |
    And the user "nickname" has answered the question "2" with:
      | id | value |
      | 2  | 1     |
    When the solution to the question "2" is:
    """
    {
      "2": 1.0
    }
    """
    And I send a GET request to "/v1/questions/fr/global/outdated"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"
    And the JSON response should have "$.[0].expires_at"
    And the JSON response should have "$.[0].label" with the text "Qui va marquer ?"
    And the JSON response should have "$.[0].winnings" with the text "10"
