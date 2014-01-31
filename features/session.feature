Feature: Session

  Scenario: Authenticate an existing user normally
    Given I accept JSON
    And I have a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And an user named "nickname" is already registered
    And a social account for "facebook"  with "fake-id" id is linked to "nickname"
    When I send a POST request to "/v1/sessions" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the response status should be "201"
    And the JSON response should have "$.token"
    And the "nickname" user should have a valid token equal to "$.token"


