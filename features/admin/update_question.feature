Feature: Add a new question

  Background:
    Given existing questions:
      | 1 | Qui va gagner ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |

  Scenario: No admin token is given
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/questions/1"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The question parameters are invalids
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014",
        "reveals_at": "2014-01-26 19:00:00 +0000",
        "labels": { "fr": "Qui sera le vainceur ?" },
        "components": [ ]
      }
    }
    """
    Then the response status should be "400"
    And the JSON response should have "$.code" with the text "bad_parameters"

  Scenario: The components parameters are empty
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014-01-26 20:00:00 +0000",
        "reveals_at": "2014-01-26 19:00:00 +0000",
        "labels": {
          "fr": "Qui sera le vainceur ?",
          "en": "Who will be the winner?"
        },
        "components": [ ]
      }
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "empty_question"

  Scenario: The components parameters are invalids
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014-01-26 20:00:00 +0000",
        "reveals_at": "2014-01-26 19:00:00 +0000",
        "labels": {
          "fr": "Qui sera le vainceur ?",
          "en": "Who will be the winner?"
        },
        "components": [
          {
            "kind": "0",
            "labels": {
              "fr": "Choisir une équipe",
              "en": "Pick a team"
            }
          }
        ]
      }
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "invalid_component"

  Scenario: The question's locale are invalid
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014-01-26 20:00:00 +0000",
        "reveals_at": "2014-01-26 19:00:00 +0000",
        "labels": {
          "de": "Qui sera le vainceur ?"
        },
        "components": [
          {
            "kind": "0",
            "labels": {
              "fr": "Choisir une équipe"
            },
            "choices": {
              "fr": "France,Belgique"
            }
          }
        ]
      }
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "invalid_question"

  Scenario: A locale is added to the question
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014-01-26 20:00:00 +0000",
        "reveals_at": "2014-01-26 19:00:00 +0000",
        "labels": {
          "fr": "Qui va gagner ?",
          "en": "Who will be the winner?"
        },
        "components": [
          {
            "id": "1",
            "kind": "0",
            "labels": {
              "fr": "Choisir la bonne équipe",
              "en": "Pick the right team"
            },
            "choices": {
              "fr": "France,Belgique",
              "en": "France,Belgium"
            }
          }
        ]
      }
    }
    """
    Then the response status should be "200"
    And a question with label_en set to "Who will be the winner?" should exist

  Scenario: A label is updated
    Given I send and accept JSON
    When I send a PUT request to "/v1/admin/questions/1" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014-01-26 20:00:00 +0000",
        "reveals_at": "2014-01-26 19:00:00 +0000",
        "labels": {
          "fr": "Qui va perdre ?"
        },
        "components": [
          {
            "id": "1",
            "kind": "0",
            "labels": {
              "fr": "Choisir la bonne équipe"
            },
            "choices": {
              "fr": "France,Belgique"
            }
          }
        ]
      }
    }
    """
    Then the response status should be "200"
    And a question with label_fr set to "Qui va perdre ?" should exist

