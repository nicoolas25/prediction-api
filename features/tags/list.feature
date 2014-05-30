Feature: Display the list of the tags

  Scenario: There is some tags to list
    Given I am an authenticated user
    And existing tags:
      | 0 | tag1 |
      | 0 | tag2 |
    When I send a GET request to "/v1/tags"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*]"
    And the JSON response should have "$.[0].keyword" with the text "tag1"
    And the JSON response should have "$.[0].questions_count" with the text "0"

  Scenario: There is some tags to list associated with expired questions
    Given I am an authenticated user
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing tags:
      | 1 | tag1 | 1 |
      | 0 | tag2 | 2 |
    When I send a GET request to "/v1/tags"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*]"
    And the JSON response should have "$.[0].keyword" with the text "tag1"
    And the JSON response should have "$.[0].questions_count" with the text "0"

  Scenario: There is some tags to list associated with answered questions
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing tags:
      | 1 | tag1 | 1 |
      | 0 | tag2 | 2 |
    And there is the following participations for the question "1":
      | nickname | 10 | 1:1 |
    When I send a GET request to "/v1/tags"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*]"
    And the JSON response should have "$.[0].keyword" with the text "tag1"
    And the JSON response should have "$.[0].questions_count" with the text "0"

  Scenario: There is some tags to list associated with visible questions
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing tags:
      | 1 | tag1 | 1 |
      | 0 | tag2 | 2 |
    When I send a GET request to "/v1/tags"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*]"
    And the JSON response should have "$.[0].keyword" with the text "tag1"
    And the JSON response should have "$.[0].questions_count" with the text "1"
