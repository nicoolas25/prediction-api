Feature: The administrator can merge two players

  Scenario: The players are merged
    Given I send and accept JSON
    And an user "nickname1" is already registered
    And an user "nickname2" is already registered
    And a social account for "facebook" with "nickname1-id" id is linked to "nickname1"
    And a social account for "facebook" with "nickname2-id" id is linked to "nickname2"
    When I send a PUT request to "/v1/admin/players/nickname1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "merge_target": "nickname2"
    }
    """
    Then the response status should be "200"
    Then the id for the "facebook" social association of "nickname1" is "nickname2-id"
