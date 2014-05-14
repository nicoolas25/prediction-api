Feature: An user can share the application via a social network

  Scenario: The user doesn't give a valid auth token
    When I send a POST request to "/v1/shares/fr/application/0" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: The user has no social association
    Given I am an authenticated user
    And I accept JSON
    When I send a POST request to "/v1/shares/fr/application/0" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "201"
    And the JSON response should have 0 "$.shares[*]"

  Scenario: The user has an outdated token
    Given I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And an invalid OAuth2 token for the "facebook" provider
    And I accept JSON
    When I send a POST request to "/v1/shares/fr/application/0" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "201"
    And the JSON response should have "$.shares.facebook" with the text "not_shared"

  Scenario: The user can't share the application two times
    Given I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And the "facebook" provider will share the messages correctly
    And I accept JSON
    When I send a POST request to "/v1/shares/fr/application/0" with the following:
      | oauth2TokenFacebook    | test-token |
    When I send a POST request to "/v1/shares/fr/application/0" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "already_shared"

  Scenario: The user sharing fails for an unknown reason
    Given I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And the "facebook" provider will not share the messages correctly
    And I accept JSON
    When I send a POST request to "/v1/shares/fr/application/0" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the JSON response should have "$.shares.facebook" with the text "not_shared"

  Scenario: The user share the application correctly
    Given I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And the "facebook" provider will share the messages correctly
    And I accept JSON
    When I send a POST request to "/v1/shares/fr/application/0" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "201"
    And the last share should be in "fr" with an id containing "-application"
    And the "shared_at" attr of "nickname" should be defined
    Then the JSON response should have "$.cristals" with the text "70"

  Scenario: The user share the application correctly in english
    Given I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And the "facebook" provider will share the messages correctly
    And I accept JSON
    When I send a POST request to "/v1/shares/en/application/0" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "201"
    And the last share should be in "en" with an id containing "-application"
    And the "shared_at" attr of "nickname" should be defined
    And the player "nickname" should have "70" cristals
