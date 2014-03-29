Feature: Display the friends

  Scenario: There is some friends to display
    Given I accept JSON
    And I am an authenticated user: "nickname"
    And a social account for "facebook" with "nickname-id" id is linked to "nickname"
    And there are already registered players via "facebook" friends to the id "nickname-id":
      | friend_1 | facebook-friend-id-1 |
      | friend_2 | facebook-friend-id-2 |
    When I send a GET request to "/v1/users/me/friends/refresh"
    Then the response status should be "302"
    And the player "nickname" should have "2" friends
