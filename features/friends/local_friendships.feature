Feature: Add and remove friendships

  Scenario: The user add a local friend
    Given I am an authenticated user
    And an user "player" is already registered with the id "2"
    When I send a POST request to "/v1/users/2/follow"
    Then the response status should be "201"
    Then the player "nickname" should have "1" friends

  Scenario: The user add a local friend that already exists
    Given I am an authenticated user
    And an user "player" is already registered with the id "2"
    When I send a POST request to "/v1/users/2/follow"
    When I send a POST request to "/v1/users/2/follow"
    Then the response status should be "403"
    Then the player "nickname" should have "1" friends

  Scenario: The user add an remove a friend (that could also be a social friend)
    Given I am an authenticated user
    And an user "player" is already registered with the id "2"
    When I send a POST request to "/v1/users/2/follow"
    When I send a POST request to "/v1/users/2/unfollow"
    Then the response status should be "201"
    Then the player "nickname" should have "0" friends

