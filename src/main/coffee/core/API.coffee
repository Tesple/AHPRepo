class app.core.API
  # IN SOME CASES IT'S BETTER TO USE rootURL: "http://localhost/backend/api/index.php/"
  rootURL: "http://localhost/backend/api/"

  constructor:->
    @

  getExamples:=>
    $.ajax(
      {
        type: 'GET',
        url: @rootURL + "examples",
        dataType: "json"
      }
    )

  getExampleNames:=>
    $.ajax(
      {
        type: 'GET',
        url: @rootURL + "example-names",
        dataType: "json"
      }
    )


  getExampleById: (id)=>
    $.ajax(
      {
        type: 'GET',
        url: @rootURL + "examples/" + id,
        dataType: "json"
      }
    )

  addExample: (name, json)=>
    $.ajax(
      {
        type: 'POST',
        contentType: 'application/json',
        url: @rootURL + "examples",
        dataType: "json",
        data: {name: name, json: json}
      }
    )

  updateExample: (id, name, json)=>
    $.ajax(
      {
        type: 'PUT',
        contentType: 'application/json',
        url: @rootURL + 'examples/' + id,
        dataType: "json",
        data: {name: name, json: json}
      }
    )

  deleteExample: (id)=>
    $.ajax(
      {
        type: 'DELETE',
        url: @rootURL + 'examples/' + id
      }
    )