Feature: The player earns cristals at each connection

  Background:
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And an user "nickname" is already registered
    And a social account for "facebook" with "fake-id" id is linked to "nickname"

  Scenario: The user asks for a session and get 2 cristals
    Given the last auto-earned cristals for "nickname" are "2 hours" from now
    When I send a POST request to "/v1/sessions" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "201"
    And the JSON response should have "$.statistics.cristals" with the text "22"

  Scenario: The user can't do the same too soon
    Given the last auto-earned cristals for "nickname" are "5 minutes" from now
    When I send a POST request to "/v1/sessions" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "201"
    And the JSON response should have "$.statistics.cristals" with the text "20"


