Feature: The distribution of the earnings are done when the question is answered

  Scenario: There is no winner to the question
    Given I send and accept JSON
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And "4" registered users with "nickname" as nickname prefix
    And there is the following participations for the question "1":
      | nickname_0 | 10 | 1:0 |
      | nickname_1 | 10 | 1:0 |
      | nickname_2 | 10 | 1:0 |
      | nickname_3 | 10 | 1:0 |
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 1.0
      }
    }
    """
    Then the question "1" should have been answered
    And the winnings for the question "1" are the following:
      | nickname_0 | 0 |
      | nickname_1 | 0 |
      | nickname_2 | 0 |
      | nickname_3 | 0 |

  Scenario: There is a winner to the question
    Given I send and accept JSON
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And "4" registered users with "nickname" as nickname prefix
    And there is the following participations for the question "1":
      | nickname_0 | 10 | 1:0 |
      | nickname_1 | 10 | 1:0 |
      | nickname_2 | 10 | 1:0 |
      | nickname_3 | 10 | 1:1 |
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 1.0
      }
    }
    """
    Then the question "1" should have been answered
    And the winnings for the question "1" are the following:
      | nickname_3 | 40 |

  Scenario: There is multiple winners to the question
    Given I send and accept JSON
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And "5" registered users with "nickname" as nickname prefix
    And there is the following participations for the question "1":
      | nickname_0 | 10 | 1:0 |
      | nickname_1 | 10 | 1:0 |
      | nickname_2 | 10 | 1:0 |
      | nickname_3 | 10 | 1:1 |
      | nickname_4 | 10 | 1:1 |
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 1.0
      }
    }
    """
    Then the question "1" should have been answered
    And the winnings for the question "1" are the following:
      | nickname_3 | 25 |
      | nickname_4 | 25 |

  Scenario: The stakes are differents
    Given I send and accept JSON
    And existing expired questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And "5" registered users with "nickname" as nickname prefix
    And there is the following participations for the question "1":
      | nickname_0 | 10 | 1:0 |
      | nickname_1 | 10 | 1:0 |
      | nickname_2 | 10 | 1:0 |
      | nickname_3 | 20 | 1:1 |
      | nickname_4 | 10 | 1:1 |
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "components": {
        "1": 1.0
      }
    }
    """
    Then the question "1" should have been answered
    And the winnings for the question "1" are the following:
      | nickname_3 | 40 |
      | nickname_4 | 20 |
