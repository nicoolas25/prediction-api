Feature: Display the friends

  Background:
    Given I accept JSON
    And I am an authenticated user: "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "nickname-id"
    And a social account for "facebook" with "nickname-id" id is linked to "nickname"
    And there are already registered players via "facebook" friends to the id "nickname-id":
      | friend_1 | facebook-friend-id-1 |
      | friend_2 | facebook-friend-id-2 |
    Given the user "nickname" have the following "facebook" friends:
      | friend_1 |

  Scenario: There is some friends to display
    When I send a POST request to "/v1/users/me/friends/refresh"
    Then the response status should be "201"
    And the player "nickname" should have "2" friends

  Scenario: The user's token is expired, nothing is done
    Given an invalid OAuth2 token for the "facebook" provider
    When I send a POST request to "/v1/users/me/friends/refresh"
    Then the response status should be "201"
    And the player "nickname" should have "1" friends
