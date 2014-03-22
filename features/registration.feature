Feature: Registration

  #Scenario: Register a new player normally with real tokens
  #  Given I accept JSON
  #  When I send a POST request to "/v1/registrations" with the following:
  #    | oauth2Provider | twitter   |
  #    | oauth2Token    | 2345385277-G6EfBxaENGHqhR6994FalULrQIsJdDqKtXasS7x~l1FAotKhKSbt1yiSLhCaXkQYR7iFn4ex1oQSkLm6A2Bkv |
  #    | nickname       | nickname   |
  #  Then the response status should be "201"
  #  And the JSON response should have "$.token"

  Scenario: Register a new player normally
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "201"
    And the JSON response should have "$.token"

  Scenario: Register a new player with an empty nickname
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       |            |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "nickname_taken"

  Scenario: Register a new player with an existing nickname
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider
    And an user "nickname" is already registered
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "nickname_taken"
    But the only registered players are:
      | nickname |

  Scenario: Register a new player with an existing social account
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And an user "nickname" is already registered
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | nickname2  |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "social_account_taken"

  Scenario: Register a new player with an existing social account and nickname
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And an user "nickname" is already registered
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "social_account_taken"

  Scenario: Register a new player with an invalid provider
    Given I accept JSON
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | unknown    |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "invalid_oauth2_provider"

  Scenario: Register a new player with an invalid token
    Given I accept JSON
    And an invalid OAuth2 token for the "facebook" provider
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
      | nickname       | nickname   |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "invalid_oauth2_token"

  Scenario: Register a new player with a missing parameter
    Given I accept JSON
    When I send a POST request to "/v1/registrations" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "400"
    And the JSON response should have "$.code" with the text "bad_parameters"
