Feature: Give the number of friends that answered a question

  Scenario: There is an open question to display
    Given I am an authenticated user: "nickname"
    And an user "player1" is already registered
    And an user "player2" is already registered
    And an user "player3" is already registered
    And an user "player4" is already registered
    And the user "nickname" have the following "facebook" friends:
      | player1 |
      | player2 |
      | player3 |
      | player4 |
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And there is the following participations for the question "1":
      | nickname | 10 | 1:1 |
      | player1  | 10 | 1:1 |
      | player2  | 10 | 1:1 |
      | player3  | 10 | 1:0 |
      | player4  | 10 | 1:0 |
    When I send a GET request to "/v1/questions/fr/global/answered"
    Then the response status should be "200"
    And the JSON response should have 3 "$.[0].statistics.friends[*]"
    And the JSON response should have "$.[0].statistics.friends_count" with the text "4"
