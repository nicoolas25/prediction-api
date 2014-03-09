Feature: An user can share a badge via a social network

  Background:
    Given I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And the "facebook" provider will share the messages correctly
    And existing badges for "nickname":
      | participation | 5 | 1 |
    And I accept JSON

  Scenario: The user share the badge correctly
    When I send a POST request to "/v1/shares/fr/facebook/badge/participation-1"
    Then the response status should be "201"
    And the last share should be in "fr" with an id containing "-badge-participation-1"

  Scenario: The user share the badge correctly in english
    When I send a POST request to "/v1/shares/en/facebook/badge/participation-1"
    Then the response status should be "201"
    And the last share should be in "en" with an id containing "-badge-participation-1"
