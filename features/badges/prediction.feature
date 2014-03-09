Feature: The user get a badge when he made predictions

  Scenario: The user send a valid answer
    Given I am an authenticated user: "nickname" with "20" cristals
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing badges for "nickname":
      | participation | 4 | 0 |
    And I send and accept JSON
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
    And the JSON response should have 1 "$.badges.*"
    And a "participation" badge for the user "nickname" should exists
