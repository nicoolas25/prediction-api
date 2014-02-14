Feature: List all the players

  Scenario: No admin token is given
    Given I accept JSON
    When I send a GET request to "/v1/admin/players"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The opened question are listed
    Given I accept JSON
    And an user "player1" is already registered
    And the user "player1" have "100" cristals
    And an user "player2" is already registered
    And the user "player2" have "50" cristals
    When I send a GET request to "/v1/admin/players" with the following:
      | token | xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB |
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*].*"
