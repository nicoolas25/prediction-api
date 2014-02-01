Feature: An registered user can participate once to an open question

  Scenario: The user doesn't give a valid auth token
    When I send a POST request to "/v1/participations"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: The quesion doesn't exist
    Given I am an authenticated user
    And I send and accept JSON
    When I send a POST request to "/v1/participations" with the following:
    """
    {
      "id": "1",
      "stakes": 10,
      "components": []
    }
    """
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "question_not_found_or_expired"

  Scenario: The quesion already expired
    Given I am an authenticated user
    And existing expired questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And I send and accept JSON
    When I send a POST request to "/v1/participations" with the following:
    """
    {
      "id": "1",
      "stakes": 10,
      "components": [
        {
          "id": "1",
          "value": "0"
        }
      ]
    }
    """
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "question_not_found_or_expired"

  Scenario: The quesion have already been answered by the user
    Given I am an authenticated user: "nickname"
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And the user "nickname" has answered the question "1" with:
      | id | value |
      | 1  | 0     |
    And I send and accept JSON
    When I send a POST request to "/v1/participations" with the following:
    """
    {
      "id": "1",
      "stakes": 10,
      "components": [
        {
          "id": "1",
          "value": "0"
        }
      ]
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "participation_exists"
