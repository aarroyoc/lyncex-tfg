Feature: Static content on Lyncex

Scenario: Get a non-existing page
    Given I have an empty Lyncex instance
    When I visit '/'
    Then I get a 404 status code

Scenario: Load a static website
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test2.ttl' data
    When I visit '/'
    And I get a 200 status code
    And I get a '<a href=about>About</a>' response
    And I get a 'text/html' response type