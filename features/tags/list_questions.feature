Feature: Display the list of questions matching a certain tag

  Background:
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing tags:
      | 1 | tag1 | 1 |
      |   | tag2 | 2 |

  Scenario: The given tag does not exists
    When I send a GET request to "/v1/questions/fr/global/open/tags/3"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "tag_not_found"

  Scenario: There is no question with the given tag
    When I send a GET request to "/v1/questions/fr/global/open/tags/2"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*]"

  Scenario: There is some question with the given tag
    When I send a GET request to "/v1/questions/fr/global/open/tags/1"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*]"
