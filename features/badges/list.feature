Feature: The user can list its badges

  Scenario: The user have no badges
    Given I am an authenticated user: "nickname" with "20" cristals
    And I accept JSON
    When I send a GET request to "/v1/badges"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*]"

  Scenario: The user earned some badge
    Given I accept JSON
    And I am an authenticated user: "nickname"
    And existing badges for "nickname":
      | participation | 5 |
    When I send a GET request to "/v1/badges"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*]"
    And show me the response
