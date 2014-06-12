Feature: Registration is case insensitive

  Scenario: Register a new player with an existing nickname (case insensitive)
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider
    And an user "nickname" is already registered
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | Nickname   |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "nickname_taken"
    But the only registered players are:
      | nickname |


