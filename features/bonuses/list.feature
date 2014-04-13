Feature: The user can list its bonuses

  Scenario: The user have no bonuses
    Given I am an authenticated user: "nickname" with "20" cristals
    And I accept JSON
    When I send a GET request to "/v1/bonus/me"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*]"

  Scenario: The user have some bonuses
    Given I am an authenticated user: "nickname"
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And there is the following participations for the question "1":
      | nickname | 10 | 1:0 |
    And the player "nickname" have the following bonuses:
      | blind  |
      | cresus |
    And the player "nickname" have the following used bonuses:
      | blind  |
    And I accept JSON
    When I send a GET request to "/v1/bonus/me"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*]"
    And the JSON response should have "$.[0].identifier" with the text "blind"
    And the JSON response should have "$.[0].remaining" with the text "1"
    And the JSON response should have "$.[0].used" with the text "1"
    And the JSON response should have "$.[1].identifier" with the text "cresus"
    And the JSON response should have "$.[1].remaining" with the text "1"
    And the JSON response should have "$.[1].used" with the text "0"
