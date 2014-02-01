Feature: Registration

  Scenario: Register a new user normally
    Given I accept JSON
    And I have a valid OAuth2 token for the "facebook" provider
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "201"
    And the JSON response should have "$.token"

  Scenario: Register a new user with an existing nickname
    Given I accept JSON
    And I have a valid OAuth2 token for the "facebook" provider
    And an user named "nickname" is already registered
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "nickname_taken"
    But the only registered players are:
      | nickname |

  Scenario: Register a new user with an existing social account
    Given I accept JSON
    And I have a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And an user named "nickname" is already registered
    And a social account for "facebook"  with "fake-id" id is linked to "nickname"
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | nickname2  |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "social_account_taken"

  Scenario: Register a new user with an invalid provider
    Given I accept JSON
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | unknown    |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "invalid_oauth2_provider"

  Scenario: Register a new user with an invalid token
    Given I accept JSON
    And I have an invalid OAuth2 token for the "facebook" provider
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "invalid_oauth2_token"

  Scenario: Register a new user with a missing parameter
    Given I accept JSON
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "400"
    And the JSON response should have "$.code" with the text "bad_parameters"