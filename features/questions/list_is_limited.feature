Feature: The lists of OPEN question are size-limited

  Background:
    Given existing questions:
      | 1 | Qui va gagner ?  |
      | 2 | Qui va marquer ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | 2 | choices | Chosir le bon joueur | Zidane,Zlatan |
    And I am an authenticated user: "nickname"

  Scenario: All the questions are fitting in the list
    When I send a GET request to "/v1/questions/fr/global/open"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*].*"

  Scenario: All the questions arn't fitting in the list
    Given the maximum question displayed is "1"
    When I send a GET request to "/v1/questions/fr/global/open"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"

  Scenario: The list is the answered questions, no limit is applied
    Given the maximum question displayed is "1"
    And there is the following participations for the question "1":
      | nickname | 10 | 1:0 |
    And there is the following participations for the question "2":
      | nickname | 10 | 2:1 |
    When I send a GET request to "/v1/questions/fr/global/answered"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*].*"

