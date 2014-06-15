Feature: List all the matches depending on the question and their tags

  Background:
    Given I accept JSON

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/matches"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: There is no question, there is no matches
    Given I am an authenticated user
    When I send a GET request to "/v1/matches"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*].*"

  Scenario: There some question with no tags, there is no matches
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    When I send a GET request to "/v1/matches"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*].*"

 Scenario: There some expired question with tags, there is no matches
    Given I am an authenticated user
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing tags:
      | 1 | tag1 | 1 |
    When I send a GET request to "/v1/matches"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*].*"

  Scenario: There some question with tags, there is matches
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing tags:
      | 1 | tag1 | 1 |
    When I send a GET request to "/v1/matches"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"

  Scenario: There more than one question occuring a the same time with the same tags, there is only one match
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
    When I send a GET request to "/v1/matches"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"
    And show me the response

  Scenario: There more than one question occuring a different time with the same tags, there is multiple matches
    Given I am an authenticated user
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
    When I send a GET request to "/v1/matches"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*].*"
    And show me the response
