Feature: Add local friendships using nicknames

  Background:
    Given I am an authenticated user
    And I send and accept JSON
    And an user "player" is already registered with the id "2"

  Scenario: The user add a friend by its nickname
    When I send a POST request to "/v1/users/find_friend" with the following:
    """
    { "nickname": "player" }
    """
    Then the response status should be "201"
    And the player "nickname" should have "1" friends

  Scenario: The user add a friend by its nickname but it is not found
    When I send a POST request to "/v1/users/find_friend" with the following:
    """
    { "nickname": "player2" }
    """
    Then the response status should be "403"
    And the player "nickname" should have "0" friends
    And the JSON response should have "$.code" with the text "player_not_found"

  Scenario: The user add a friend by its nickname and give its own nickname
    When I send a POST request to "/v1/users/find_friend" with the following:
    """
    { "nickname": "nickname" }
    """
    Then the response status should be "403"
    And the player "nickname" should have "0" friends
    And the JSON response should have "$.code" with the text "failed"
