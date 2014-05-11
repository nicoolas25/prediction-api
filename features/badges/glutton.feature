Feature: The user get a badge when he looses a prediction with a double bonus

  Background:
    Given I send and accept JSON
    And I am an authenticated user: "nickname"
    And an user "player_1" is already registered
    And the user "player_1" have "100" cristals
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |

  Scenario: The user looses with the double bonus and gets the badge
    Given there is the following participations for the question "1":
      | nickname | 10 | 1:0 |
    And there is the following bonuses for the question "1":
      | nickname | double |
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 1.0
      }
    }
    """
    Then the response status should be "200"
    And the question "1" should have been answered
    And a "glutton" badge for the user "nickname" should exist

  Scenario: The user wins with the double bonus and does not get the badge
    Given there is the following participations for the question "1":
      | nickname | 10 | 1:0 |
    And there is the following bonuses for the question "1":
      | nickname | double |
    When I send a PUT request to "/v1/admin/questions/1" with the following:
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
    And a "glutton" badge for the user "nickname" should not exist
