Feature: The player can use a bonus with its participation

  Background:
    Given I am an authenticated user: "nickname" with "20" cristals
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And the player "nickname" have the following bonuses:
      | cresus |
    And I send and accept JSON

  Scenario: The user send a valid answer with a valid bonus
    When I send a POST request to "/v1/participations" with the following:
    """
    {
      "id": "1",
      "stakes": 10,
      "bonus": "cresus",
      "components": [
        {
          "id": "1",
          "value": "0"
        }
      ]
    }
    """
    Then the response status should be "201"
    And a participation for the user "nickname" to the question "1" should exists
    And the player "nickname" should have "10" cristals
    And the player "nickname" should have "0" available bonus

  Scenario: The user send a valid answer with an invalid bonus
    When I send a POST request to "/v1/participations" with the following:
    """
    {
      "id": "1",
      "stakes": 10,
      "bonus": "blind",
      "components": [
        {
          "id": "1",
          "value": "0"
        }
      ]
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "bonus_not_available"
    And the player "nickname" should have "20" cristals
    And the player "nickname" should have "1" available bonus

