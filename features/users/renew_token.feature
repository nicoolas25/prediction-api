Feature: Get a new token while creating a session

  Scenario: Authenticate an existing user that have already a valid token
    Given I accept JSON
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And an user "nickname" is already registered
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And the user "nickname" have a valid token: "123456-fake-token"
    When I send a POST request to "/v1/sessions" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "201"
    And the JSON response should have "$.token" with the text "123456-fake-token"
    And the "nickname" user should have a valid token equal to "$.token"
