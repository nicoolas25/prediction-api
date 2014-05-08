Feature: Display the delta in the ranking

  Scenario: The delta of ranking should appear
    Given an user "player" is already registered
    And I am an authenticated user: "nickname"
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And there is the following participations for the question "1":
      | nickname | 10 | 1:0 |
      | player   | 10 | 1:1 |
    When the solution to the question "1" is:
    """
    {
      "1": 0.0
    }
    """
    When I send a GET request to "/v1/ladders/global/me"
    Then the response status should be "200"
    And the JSON response should have "$.[0].delta" with the text "1"
    And the JSON response should have "$.[1].delta" with the text "-1"
