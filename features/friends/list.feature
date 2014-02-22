Feature: Display the friends

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/users/me/friends"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: The user has no friends
    Given I am an authenticated user
    When I send a GET request to "/v1/users/me/friends"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*].*"

  Scenario: There is some friends to display
    Given I accept JSON
    And I am an authenticated user: "nickname"
    And an user "friend_1" is already registered
    And an user "friend_2" is already registered
    And the user "nickname" have the following "facebook" friends:
      | friend_1 |
    When I send a GET request to "/v1/users/me/friends"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"
    And show me the response
