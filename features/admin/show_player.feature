Feature: Display a specific player

  Scenario: No admin token is given
    Given I accept JSON
    When I send a GET request to "/v1/admin/players/nickname"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The player doesn't exist
    Given I accept JSON
    When I send a GET request to "/v1/admin/players/nickname" with the following:
      | token | xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB |
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The detailled player is returned
    Given I accept JSON
    And an user "nickname" is already registered
    And the user "nickname" have "50" cristals
    When I send a GET request to "/v1/admin/players/nickname" with the following:
      | token | xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB |
    Then the response status should be "200"
    And the JSON response should have "$.statistics.cristals" with the text "50"
