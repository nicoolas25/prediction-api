Feature: Add and update social associations

  Scenario: Add a social association to an existing account
    Given I accept JSON
    And I am an authenticated user
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    When I send a POST request to "/v1/registrations/social" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "201"
    And the JSON response should have "$.social[0].id" with the text "fake-id"

  Scenario: Fails to add an association beacause it's already in user
    Given I accept JSON
    And I am an authenticated user
    And an user "player" is already registered
    And a social account for "facebook" with "fake-id" id is linked to "player"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    When I send a POST request to "/v1/registrations/social" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "social_account_taken"

  Scenario: Replace an existing association for an existing provider
    Given I accept JSON
    And I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id2"
    When I send a POST request to "/v1/registrations/social" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "201"
    And the JSON response should have "$.social[0].id" with the text "fake-id2"
    And the JSON response should have 1 "$.social[*]"
