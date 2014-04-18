Feature: An user can share a badge via a social network

  Background:
    Given I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And the "facebook" provider will share the messages correctly
    And existing badges for "nickname":
      | participation | 5 | 1 |
    And I accept JSON

  Scenario: The user can't share the badge two times
    When I send a POST request to "/v1/shares/fr/badge/participation-1" with the following:
      | oauth2TokenFacebook    | test-token |
    When I send a POST request to "/v1/shares/fr/badge/participation-1" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "already_shared"

  Scenario: The user share a badge that he doesn't have
    When I send a POST request to "/v1/shares/fr/badge/participation-2" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "unknown_share"

  Scenario: The user share the badge correctly
    When I send a POST request to "/v1/shares/fr/badge/participation-1" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "201"
    And the last share should be in "fr" with an id containing "-badge-participation-1"
    And the "shared_at" attr for badge "participation" with level "1" of "nickname" should be defined
    And the player "nickname" should have "22" cristals

  Scenario: The user share the badge correctly in english
    When I send a POST request to "/v1/shares/en/badge/participation-1" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "201"
    And the last share should be in "en" with an id containing "-badge-participation-1"
    And the "shared_at" attr for badge "participation" with level "1" of "nickname" should be defined
