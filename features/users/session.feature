Feature: Session

  Scenario: Authenticate an existing user normally
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And an user "nickname" is already registered
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    When I send a POST request to "/v1/sessions" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "201"
    And the JSON response should have "$.token"
    And the "nickname" user should have a valid token equal to "$.token"
    And show me the response

  Scenario: Authenticate an non-existing user
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    When I send a POST request to "/v1/sessions" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "social_account_unknown"

  Scenario: Authenticate a new user with an invalid provider
    Given I accept JSON
    When I send a POST request to "/v1/sessions" with the following:
      | oauth2Provider | unknown    |
      | oauth2Token    | test-token |
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "invalid_oauth2_provider"

  Scenario: Authenticate a new user with an invalid token
    Given I accept JSON
    And an invalid OAuth2 token for the "facebook" provider
    When I send a POST request to "/v1/sessions" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "invalid_oauth2_token"

  Scenario: Authenticate a new user with a missing parameter
    Given I accept JSON
    When I send a POST request to "/v1/sessions" with the following:
      | oauth2Provider | facebook   |
    Then the response status should be "400"
    And the JSON response should have "$.code" with the text "bad_parameters"
