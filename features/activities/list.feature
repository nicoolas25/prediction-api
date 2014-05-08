Feature: Display the activity feed

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/activities/fr"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: There is no events in the feed
    Given I am an authenticated user
    When I send a GET request to "/v1/activities/fr"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*].*"

  Scenario: There is some activities in the feed
    Given I am an authenticated user: "nickname"
    And an user "friend_1" is already registered
    And an user "friend_2" is already registered
    And the user "nickname" have the following "facebook" friends:
      | friend_1 |
    And existing questions:
      | 1 | Qui va gagner ? |
      | 2 | Qui va perdre ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | 2 | choices | Chosir la bonne équipe | France,Belgique |
    And the user "nickname" has answered the question "1" with:
      | id | value |
      | 1  | 0     |
    And the user "friend_1" has answered the question "2" with:
      | id | value |
      | 2  | 0     |
    And existing badges for "nickname":
      | participation | 5 | 1 |
    When the solution to the question "1" is:
    """
    {
      "1": 0.0
    }
    """
    And I send a GET request to "/v1/activities/fr"
    Then the response status should be "200"
    And the JSON response should have 6 "$.[*].*"
    And the JSON response should have "$.[0].kind" with the text "solution"
    And the JSON response should have "$.[0].question.id" with the text "1"
    And the JSON response should have "$.[0].question.made_prediction" with the text "true"
    And the JSON response should have "$.[1].kind" with the text "badge"
    And the JSON response should have "$.[1].level" with the text "1"
    And the JSON response should have "$.[2].kind" with the text "badge"
    And the JSON response should have "$.[2].level" with the text "1"
    And the JSON response should have "$.[3].kind" with the text "answer"
    And the JSON response should have "$.[3].question.id" with the text "2"
    And the JSON response should have "$.[3].question.made_prediction" with the text "false"
    And the JSON response should have "$.[4].kind" with the text "answer"
    And the JSON response should have "$.[4].question.id" with the text "1"
    And the JSON response should have "$.[4].question.made_prediction" with the text "true"
    And the JSON response should have "$.[5].kind" with the text "friend"
    And the JSON response should have "$.[5].players[0].nickname" with the text "friend_1"
    And the JSON response should have 6 "$.[*].players[*].social"

  Scenario: The looses aren't displayed
    Given I am an authenticated user: "nickname"
    And an user "friend_1" is already registered
    And an user "friend_2" is already registered
    And the user "nickname" have the following "facebook" friends:
      | friend_1 |
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And the user "nickname" has answered the question "1" with:
      | id | value |
      | 1  | 0     |
    When the solution to the question "1" is:
    """
    {
      "1": 1.0
    }
    """
    And I send a GET request to "/v1/activities/fr"
    Then the response status should be "200"
    And the JSON response should have 4 "$.[*].*"
    And the JSON response should have "$.[0].kind" with the text "badge"
    And the JSON response should have "$.[0].identifier" with the text "looser"
    And the JSON response should have "$.[0].level" with the text "1"
    And the JSON response should have "$.[1].kind" with the text "badge"
    And the JSON response should have "$.[1].level" with the text "1"
    And the JSON response should have "$.[1].identifier" with the text "participation"
    And the JSON response should have "$.[2].kind" with the text "answer"
    And the JSON response should have "$.[2].question.id" with the text "1"
    And the JSON response should have "$.[3].kind" with the text "friend"
    And the JSON response should have "$.[3].players[*].nickname" with the text "friend_1"
    And the JSON response should have 4 "$.[*].players[*].social"
