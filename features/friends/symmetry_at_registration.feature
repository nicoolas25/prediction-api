Feature: Fetch the friends of a new user and try to get the symmetry out of it

  Scenario: Register a new friend with an asymmetric relation
    Given I accept JSON
    And a valid OAuth2 token for the "twitter" provider which returns the id "friend-1-social-id"
    And there is the following friend_ids results for "twitter" over time:
      | 1 | friend-2-social-id |
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | twitter    |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "201"
    And the player "nickname" should have "0" friends
    Given a valid OAuth2 token for the "twitter" provider which returns the id "friend-2-social-id"
    And there is the following friend_ids results for "twitter" over time:
      | 1 | friend-1-social-id |
      | 2 | friend-2-social-id |
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | twitter    |
      | oauth2Token    | test-token |
      | nickname       | nickname2  |
    Then the response status should be "201"
    And the player "nickname" should have "1" friends
    And the player "nickname2" should have "1" friends

