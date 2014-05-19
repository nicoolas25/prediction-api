Feature: Answer a specific question

  Scenario: No admin token is given
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/questions/1/answer"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The question doesn't exist
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/questions/1/answer" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 0.0
      }
    }
    """
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The question isn't expired
    Given I send and accept JSON
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    When I send a PUT request to "/v1/admin/questions/1/answer" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 0.0
      }
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "not_expired"

  Scenario: Some components are missing
    Given I send and accept JSON
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    When I send a PUT request to "/v1/admin/questions/1/answer" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {}
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "missing_component"

  Scenario: The answer of a choice component is too height
    Given I send and accept JSON
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    When I send a PUT request to "/v1/admin/questions/1/answer" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 2.0
      }
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "bad_answer"

  Scenario: The answers are correct, the question is expired
    Given I send and accept JSON
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    When I send a PUT request to "/v1/admin/questions/1/answer" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 0.0
      }
    }
    """
    Then the response status should be "200"
    And the question "1" should have been answered
