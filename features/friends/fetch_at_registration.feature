Feature: Fetch the friends of a new user and link him to the existing player.

  Scenario: Regiter a new player
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider which returns the id "nickname-id"
    And there are already registered players via "facebook" friends to the id "nickname-id":
      | friend_1 | facebook-friend-id-1 |
      | friend_2 | facebook-friend-id-2 |
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "201"
    And the player "nickname" should have "2" friends


