Feature: Add a new question

  Scenario: No admin token is given
    Given I send and accept JSON
    When I send a POST request to "/v1/questions"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "not_found"

  Scenario: The question parameters are invalids
    Given I send and accept JSON
    When I send a POST request to "/v1/questions" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014",
        "labels": { "fr": "Qui sera le vainceur ?" },
        "components": [ ]
      }
    }
    """
    Then the response status should be "400"
    And the JSON response should have "$.code" with the text "bad_parameters"

  Scenario: The components parameters are empty
    Given I send and accept JSON
    When I send a POST request to "/v1/questions" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014-01-26 20:00:00 +0000",
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
    When I send a POST request to "/v1/questions" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014-01-26 20:00:00 +0000",
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
    When I send a POST request to "/v1/questions" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014-01-26 20:00:00 +0000",
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

  Scenario: The question parameters are valids
    Given I send and accept JSON
    When I send a POST request to "/v1/questions" with the following:
    """
    {
      "token": "xVgDSZt0yidgzVkzWZ7sWAevUehZgqeB",
      "question": {
        "expires_at": "2014-01-26 20:00:00 +0000",
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
    Then the response status should be "201"
    And a question with label_fr set to "Qui sera le vainceur ?" should exist
