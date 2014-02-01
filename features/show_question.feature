Feature: Display the details of a question

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/questions/fr/1"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: The question doesn't exist
    Given I am an authenticated user
    When I send a GET request to "/v1/questions/fr/1"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "question_not_found"
