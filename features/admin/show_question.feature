Feature: Display a specific question

  Scenario: No admin token is given
    Given I accept JSON
    When I send a GET request to "/v1/admin/questions/1"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The question doesn't exist
    Given I accept JSON
    When I send a GET request to "/v1/admin/questions/1" with the following:
      | token | xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB |
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The details of the question are returned
    Given I send and accept JSON
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    When I send a GET request to "/v1/admin/questions/1" with the following:
      | token | xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB |
    Then the response status should be "200"
    And the JSON response should have "$.labels.fr" with the text "Qui va gagner ?"
