Feature: The user get a badge when he uses bonuses

  Scenario: The user answers a question
    Given I am an authenticated user: "nickname" with "20" cristals
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And the player "nickname" have the following bonuses:
      | blind |
    And I send and accept JSON
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
    Then the response status should be "201"
    And the JSON response should have 2 "$.badges[*]"
    And a "god" badge for the user "nickname" should exist
