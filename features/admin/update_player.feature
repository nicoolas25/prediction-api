Feature: The administrator can update the cristals of a given player

  Scenario: No admin token is given
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/players/nickname"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The given nickname doesn't exists
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/players/nickname" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "cristals": 400
    }
    """
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The players is updated
    Given I send and accept JSON
    And an user "nickname" is already registered
    And the user "nickname" have "50" cristals
    When I send a PUT request to "/v1/admin/players/nickname" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "cristals": 400
    }
    """
    Then the response status should be "200"
    And the player "nickname" should have "400" cristals
