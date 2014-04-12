Feature: The player earns cristals when he pings

  Background:
    Given I accept JSON
    And I am an authenticated user

  Scenario: The user pings and get 2 cristals
    Given the last auto-earned cristals for "nickname" are "2 hours" from now
    When I send a GET request to "/v1/ping" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "200"
    And the JSON response should have "$.statistics.cristals" with the text "22"

  Scenario: The user can't do the same too soon
    Given the last auto-earned cristals for "nickname" are "5 minutes" from now
    When I send a GET request to "/v1/ping" with the following:
    Then the response status should be "200"
    And the JSON response should have "$.statistics.cristals" with the text "20"


