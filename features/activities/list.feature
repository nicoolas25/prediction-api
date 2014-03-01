Feature: Display the activity feed

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/activities/fr"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: There is no events in the feed
    Given I am an authenticated user
    When I send a GET request to "/v1/activities/fr"
    Then the response status should be "200"
    And the JSON response should have 0 "$.answers[*].*"
    And the JSON response should have 0 "$.solutions[*].*"
    And the JSON response should have 0 "$.friends[*].*"

  Scenario: There is some activities in the feed
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And the user "nickname" has answered the question "1" with:
      | id | value |
      | 1  | 0     |
    When I send a GET request to "/v1/activities/fr"
    Then the response status should be "200"
    And show me the response
    And the JSON response should have 1 "$.answers[*].*"
    And the JSON response should have 0 "$.solutions[*].*"
    And the JSON response should have 0 "$.friends[*].*"
