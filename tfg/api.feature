Feature: HTTP API to work with Lyncex

Scenario: GET with an empty database
    Given I have an empty Lyncex instance
    When I do a GET request
    Then I get a 200 status code
    And I get an empty response

Scenario: POST with an empty database
    Given I have an empty Lyncex instance
    When I do a POST request with 'features/test1.ttl' data
    Then I get a 200 status code
    And I get a 'OK' response

Scenario: GET with a non-empty database
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test1.ttl' data
    When I do a GET request
    Then I get a 200 status code
    And I get the contents of 'features/test1.ttl'

Scenario: GET with filter
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test1.ttl' data
    When I do a filtered (subject='https://lyncex.com/lyncex#quijote') GET request
    Then I get a 200 status code
    And I get the contents of 'features/test1_filtered2.ttl'

Scenario: DELETE a non-empty database
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test1.ttl' data
    When I do a DELETE request
    Then I get a 200 status code
    And I get a 'OK' response

Scenario: DELETE with filter
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test1.ttl' data
    When I do a filtered (subject='https://lyncex.com/lyncex#quijote') DELETE request
    Then I get a 200 status code
    And I get a 'OK' response
    And I do a GET request
    And I get the contents of 'features/test1_filtered.ttl'

Scenario: RDF Schema validation
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test1.ttl' data
    When I do a POST request with 'features/test1_bad.ttl' data
    Then I get a 'NOT VALID' response
    #And I get a 401 status code
    And I do a GET request
    And I get the contents of 'features/test1.ttl'