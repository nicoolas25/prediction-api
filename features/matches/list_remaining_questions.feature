Feature: List remaining questions inside a match

  Background:
    Given I am an authenticated user
    And time is frozen at now
    And existing questions:
      | 1 | Qui va gagner ? |
      | 2 | Qui va marquer ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | 2 | choices | Chosir le bon joueur | Zidane,Zlatan |
    And existing tags:
      | 1 | tag1 | 1 |
      | 1 | tag2 | 2 |
      | 2 | tag1 | 1 |
      | 2 | tag2 | 2 |
    And we return to the present

  Scenario: The player answered none of two questions about the match
    When I send a GET request to "/v1/matches"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"
    And the JSON response should have "$.[0].total" with the text "2"
    And the JSON response should have "$.[0].remaining" with the text "2"

  Scenario: The player answered one of two questions about the match
    Given there is the following participations for the question "2":
      | nickname | 10 | 2:1 |
    When I send a GET request to "/v1/matches"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"
    And the JSON response should have "$.[0].total" with the text "2"
    And the JSON response should have "$.[0].remaining" with the text "1"
