Feature: In response to a participation, the player have a small chance to get a bonus

  Background:
    Given I am an authenticated user: "nickname" with "20" cristals
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And I send and accept JSON


  Scenario: The player get a bonus after a participation
    Given the percentage of change to get a bonus after a participation is "100"
    When I send a POST request to "/v1/participations" with the following:
    """
    {
      "id": "1",
      "stakes": 10,
      "components": [
        {
          "id": "1",
          "value": "0"
        }
      ]
    }
    """
    Then the response status should be "201"
    And the player "nickname" should have "1" available bonus
    And the JSON response should have 1 "$.earned_bonus.identifier"

  Scenario: The player does not get a bonus after a participation
    Given the percentage of change to get a bonus after a participation is "0"
    When I send a POST request to "/v1/participations" with the following:
    """
    {
      "id": "1",
      "stakes": 10,
      "components": [
        {
          "id": "1",
          "value": "0"
        }
      ]
    }
    """
    Then the response status should be "201"
    And the player "nickname" should have "0" available bonus
    And the JSON response should have 0 "$.earned_bonus.identifier"
