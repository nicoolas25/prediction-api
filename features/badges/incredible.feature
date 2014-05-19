Feature: The user get a badge when he wins win 5*stakes predictions

  Background:
    Given I send and accept JSON
    And I am an authenticated user: "nickname"
    And an user "player_1" is already registered
    And the user "player_1" have "100" cristals
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |

  Scenario: The user win 5*stakes a prediction
    Given there is the following participations for the question "1":
      | nickname | 10 | 1:0 |
      | player_1 | 40 | 1:1 |
    When I send a PUT request to "/v1/admin/questions/1/answer" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 0.0
      }
    }
    """
    Then the response status should be "200"
    And the question "1" should have been answered
    And a "incredible" badge for the user "nickname" should exist

  Scenario: The user win 4*stakes a prediction
    Given there is the following participations for the question "1":
      | nickname | 10 | 1:0 |
      | player_1 | 30 | 1:1 |
    When I send a PUT request to "/v1/admin/questions/1/answer" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 0.0
      }
    }
    """
    Then the response status should be "200"
    And the question "1" should have been answered
    And a "incredible" badge for the user "nickname" should not exist
