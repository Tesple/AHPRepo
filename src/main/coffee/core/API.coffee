class app.core.API

  rootURL: "http://localhost/aphbackend/api/"

  constructor:->
    @

  getExamples:=>
    $.ajax(
      {
        type: 'GET',
        url: @rootURL + "examples",
        dataType: "json",
        success: ()=>
      }
    )

  getExampleNamess:=>
    $.ajax(
      {
        type: 'GET',
        url: @rootURL + "example-names",
        dataType: "json",
        success: ()=>
      }
    )


  getExampleById: (id)=>
    $.ajax(
      {
        type: 'GET',
        url: @rootURL + "examples/" + id,
        dataType: "json",
        success: (data)=> console.warn data

      }
    )

  addExample: (name, json)=>
    $.ajax(
      {
        type: 'POST',
        contentType: 'application/json',
        url: @rootURL + "examples",
        dataType: "json",
        data: {name: name, json: json},
        success: (data, textStatus, jqXHR)=> console.warn data,
        error:   (jqXHR, textStatus, errorThrown)=> console.warn textStatus
      }
    )

  updateExample: (id, name, json)=>
    $.ajax(
      {
        type: 'PUT',
        contentType: 'application/json',
        url: @rootURL + 'examples/' + id,
        dataType: "json",
        data: {name: name, json: json},
        success: (data, textStatus, jqXHR)=> console.warn data,
        error:   (jqXHR, textStatus, errorThrown)=> console.warn textStatus
      }
    )

  deleteExample: (id)=>
    $.ajax(
      {
        type: 'DELETE',
        url: @rootURL + 'examples/' + id,
        success: (data, textStatus, jqXHR)=> console.warn data,
        error: (jqXHR, textStatus, errorThrown)=> console.warn textStatus
      }
    )