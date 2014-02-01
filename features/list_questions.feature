Feature: Display lists of questions

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/questions/fr/global/open"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: There is no open questions to display
    Given I am an authenticated user
    When I send a GET request to "/v1/questions/fr/global/open"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*].*"

  Scenario: There is some open questions to display
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ?  |
      | 2 | Qui va marquer ? |
    And existing components for the question "1":
      | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | choices | Chosir le bon joueur | Zidane,Zlatan |
    When I send a GET request to "/v1/questions/fr/global/open"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*].*"
    And the JSON response should have "$.[0].expires_at"
    And the JSON response should have "$.[0].label" with the text "Qui va gagner ?"
