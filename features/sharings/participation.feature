Feature: An user can share a participation via a social network

  Background:
    Given I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And the "facebook" provider will share the messages correctly
    And existing questions:
      | 1 | Qui va gagner ? |
      | 2 | Qui va perdre ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | 2 | choices | Chosir la bonne équipe | France,Belgique |
    And there is the following participations for the question "1":
      | nickname | 10 | 1:1 |
    And I accept JSON

  Scenario: The user share a participation to a question he doesn't answered
    When I send a POST request to "/v1/shares/fr/participation/2" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "unknown_share"

  Scenario: The user can't share the participation two times
    When I send a POST request to "/v1/shares/fr/participation/1" with the following:
      | oauth2TokenFacebook    | test-token |
    When I send a POST request to "/v1/shares/fr/participation/1" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "already_shared"

  Scenario: The user share the participation correctly
    When I send a POST request to "/v1/shares/fr/participation/1" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "201"
    And the last share should be in "fr" with an id containing "-participation-1"
    And the "shared_at" attr for participation to the question "1" of "nickname" should be defined
    And the JSON response should have "$.cristals" with the text "12"
    And the player "nickname" should have "12" cristals

  Scenario: The user share the participation correctly in english
    When I send a POST request to "/v1/shares/en/participation/1" with the following:
      | oauth2TokenFacebook    | test-token |
    Then the response status should be "201"
    And the last share should be in "en" with an id containing "-participation-1"
    And the "shared_at" attr for participation to the question "1" of "nickname" should be defined
