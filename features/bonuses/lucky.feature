Feature: The user uses a custom chances rate to get a bonus when he uses a luck bonus

  Scenario: The user wins an extra bonus
    Given I send and accept JSON
    And I am an authenticated user: "nickname" with "30" cristals
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And the player "nickname" have the following bonuses:
      | lucky  |
      | double |
    And the percentage of change to get a bonus after a participation is "0"
    And the lucky bonus give "100" percent of chance of getting a bonus
    When I send a POST request to "/v1/participations" with the following:
    """
    {
      "id": "1",
      "stakes": 10,
      "bonus": "lucky",
      "components": [
        {
          "id": "1",
          "value": "1"
        }
      ]
    }
    """
    Then the response status should be "201"
    And the player "nickname" should have "20" cristals
    And the player "nickname" should have "2" bonus
    And the player "nickname" should have "1" available bonus
