Feature: Refreshing the friends update the token

  Scenario: The user send oauth2 tokens
    Given I accept JSON
    And I am an authenticated user: "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "nickname-id"
    And a social account for "facebook" with "nickname-id" id is linked to "nickname"
    And there are already registered players via "facebook" friends to the id "nickname-id":
      | friend_1 | facebook-friend-id-1 |
      | friend_2 | facebook-friend-id-2 |
    Given the user "nickname" have the following "facebook" friends:
      | friend_1 |
    When I send a POST request to "/v1/users/me/friends/refresh" with the following:
      | oauth2TokenFacebook | test-token123 |
    Then the token for the "facebook" social association of "nickname" is "test-token123"


