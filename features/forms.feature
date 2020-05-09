Feature: Forms in Lyncex

Scenario: Save content of a form
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test4.ttl' data
    When I submit the form '/form1' with data '_id=https://app.lyncex.com/book/Quijote' and 'name=Don Quijote'
    Then I visit '/book?id=Quijote'
    And I get a 200 status code
    And I get a '<b>Name: </b>Don Quijote' response
    And I get a 'text/html' response type

#Scenario: Autogenerate form
#    Given I have an empty Lyncex instance
#    And I do a POST request with 'features/test4.ttl' data
#    When I visit '/form1'
#    And I get a 200 status code
#    And I get a '<form method="POST"><input type="url" name="_id" value="https://app.lyncex.com/"><input type="text" name="https://app.lyncex.com/name"><input type="submit"></form>' response
#    And I get a 'text/html' response type