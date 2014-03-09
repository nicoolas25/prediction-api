Feature: An user can share a participation via a social network

  Background:
    Given I am an authenticated user: "nickname"
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And the "facebook" provider will share the messages correctly
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And there is the following participations for the question "1":
      | nickname | 10 | 1:1 |
    And I accept JSON

  Scenario: The user share the participation correctly
    When I send a POST request to "/v1/shares/fr/facebook/participation/1"
    Then the response status should be "201"
    And the last share should be in "fr" with an id containing "-participation-1"

  Scenario: The user share the participation correctly in english
    When I send a POST request to "/v1/shares/en/facebook/participation/1"
    Then the response status should be "201"
    And the last share should be in "en" with an id containing "-participation-1"
