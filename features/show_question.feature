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

  Scenario: The question displayed normally
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    When I send a GET request to "/v1/questions/fr/1"
    Then the response status should be "200"
    And the JSON response should have "$.label" with the text "Qui va gagner ?"
    And the JSON response should have 2 "$.components[*].choices[*].*"
    And the JSON response should have "$.components[0].choices[0].label" with the text "France"
    And the JSON response should have "$.components[0].choices[0].position" with the text "0"
