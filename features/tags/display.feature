Feature: Display the tags of a question

  Scenario: The question have no tags
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    When I send a GET request to "/v1/questions/fr/1"
    Then the response status should be "200"
    And the JSON response should have 1 "$.tags"

  Scenario: The question have some tags
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing tags:
      | 1 | tag1 |
      | 1 | tag2 |
      |   | tag3 |
    When I send a GET request to "/v1/questions/fr/1"
    Then the response status should be "200"
    And the JSON response should have 2 "$.tags[*]"
    And the JSON response should have "$.tags[0]" with the text "tag1"
    And the JSON response should have "$.tags[1]" with the text "tag2"
