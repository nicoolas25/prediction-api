Feature: The user earns 20 cristal after a prediction

  Background:
    Given I send and accept JSON
    And I am an authenticated user: "nickname"
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And there is the following participations for the question "1":
      | nickname | 10 | 1:1 |
    And there is the following bonuses for the question "1":
      | nickname | cresus |

  Scenario: The user looses a prediction
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
    And the player "nickname" should have "30" cristals

  Scenario: The user wins a prediction
    When I send a PUT request to "/v1/admin/questions/1/answer" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 1.0
      }
    }
    """
    Then the response status should be "200"
    And the player "nickname" should have "40" cristals
