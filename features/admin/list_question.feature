Feature: List all the questions

  Scenario: No admin token is given
    Given I accept JSON
    When I send a GET request to "/v1/admin/questions"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The opened question are listed
    Given I accept JSON
    And existing questions:
      | 1 | Qui va gagner ?  |
      | 2 | Qui va marquer ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | 2 | choices | Chosir le bon joueur | Zidane,Zlatan |
    When I send a GET request to "/v1/admin/questions" with the following:
      | token | xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB |
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*].*"
