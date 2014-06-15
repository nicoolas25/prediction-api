Feature: Display the list of questions matching multiple tags

  Background:
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
      | 2 | tag2 | 2 |

  Scenario: There is some question with the given tag
    When I send a GET request to "/v1/questions/fr/global/open/tags/1,2"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*]"
    And the JSON response should have "$.[0].id" with the text "1"
