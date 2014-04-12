Feature: The user double its earnings or he loose it's stakes another time

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
      | nickname | double |

  Scenario: The user looses a prediction but loose nothing more
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
    And the player "nickname" should have "10" cristals

  Scenario: The user wins a prediction and win 2 times
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
    And the player "nickname" should have "30" cristals
