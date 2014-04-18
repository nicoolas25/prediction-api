Feature: An user can update its token during the share

  Scenario: The user share the application correctly
    Given I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And the "facebook" provider will share the messages correctly
    And I accept JSON
    When I send a POST request to "/v1/shares/fr/application/0" with the following:
      | oauth2TokenFacebook | test-token123 |
    Then the token for the "facebook" social association of "nickname" is "test-token123"


