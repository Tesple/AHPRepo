class app.core.helpers.DataHelper

  keysArray: ["criteria", "criteriaComparisonArray", "optionComparisonArrays", "options"]
  valuesArray: ["1/9","1/7","1/5","1/3","1","3","5","7","9"]

  constructor: (node, vc)->
    @node = node
    @vc = vc
    @

  isSimulationDataValid: (json)=>
    keys = Object.keys(json)
    unless keys.sort().equals(@keysArray)
      return false
    unless json.criteria.length isnt 0 and json.options.length isnt 0
      return false
    unless json.criteria.length is json.optionComparisonArrays.length
      return false
    unless json.criteria.length is json.criteriaComparisonArray.length
      return false
    for ctr,index in json.criteria
      if ctr.id isnt "C#{index + 1}" or ctr.name.length is 0
        return false
    for opt,index in json.options
      if opt.id isnt "O#{index + 1}" or opt.name.length is 0
        return false

    unless @isValidMatrix(json.criteriaComparisonArray, json.criteria.length)
      return false
    for OpC, idx in json.optionComparisonArrays
      if OpC.criteriaId isnt "C#{idx + 1}" or not @isValidMatrix(OpC.array, json.options.length)
        return false
    true

  isValidMatrix: (array, size)=>
    if array.length isnt size
      return false
    for row in array
      if row.length isnt size
        return false
      for cell in row
        if @valuesArray.indexOf(cell) is -1
          return false
    true

  collectDataFromMatrix: (array, matrix, size)=>
    array.length = 0
    i = 1
    j = 1
    while i <= size
      array[i - 1] = []
      j = 1
      while j <= size
        element = $("td[data-i='#{i}'][data-j='#{j}']", matrix)
        if element.has("select").length is 0
          array[i - 1][j - 1] = element.text().trim()
        else
          array[i - 1][j - 1] = $("select", element).val().trim()
        j++
      i++
    null

  collectDataFromFieldsets: (array, bag)=>
    array.length = 0
    inputs = $("fieldset input", bag)
    for input in inputs
      id = $(input).data("id")
      value = $(input).val().trim()
      array.push({
        id: id
        name: (if value.length > 0 then value else id)
      })

  generateAndAppendFieldsets:(bag, number, symbol)=>
    i = 1
    while i <= number
      bag.append(
                """
          <fieldset class='name-fieldset'>
            <label>#{symbol + i} name:</label>
            <input class='des pull-right' type='text' placeholder='#{symbol + i}' data-id='#{symbol + i}'>
          </fieldset>
        """
      )
      i++

  generateAndAppendComparisonTable: (bag, number, tcClass, matrixId, symbol, legend)=>
    tableContainer = $("<div class='#{tcClass}'></div>")
    if legend?
      tableContainer.append("<legend>#{legend}</legend>")
    table = $("<table class='pure-table pure-table-bordered'></table>")
    thead = $("<thead><tr><th>#</th></tr>")
    tbody = $("<tbody id='#{matrixId}'></tbody>")
    selectTemplate = """
      <select><option>1/9</option><option>1/7</option><option>1/5</option><option>1/3</option>
      <option selected='selected'>1</option><option>3</option><option>5</option><option>7</option><option>9</option></select>
    """

    i = 1
    j = 0

    while i <= number
      $("tr", thead).append("<th>#{symbol + i}</th>")
      j = 0
      currentRow = $("<tr></tr>")
      while j <=number
        cell =
          if j is 0
            "<td data-i='#{i}' data-j='#{j}'>#{symbol + i}</td>"
          else if i is j
            "<td data-i='#{i}' data-j='#{j}'> 1 </td>"
          else if i < j
            "<td data-i='#{i}' data-j='#{j}'>#{selectTemplate}</td>"
          else "<td data-i='#{i}' data-j='#{j}'>1</td>"
        currentRow.append(cell)
        j++
        null
      tbody.append(currentRow)
      i++

    table.append(thead, tbody)
    tableContainer.append(table)

    bag.append(tableContainer)

  getExampleNamesAndAppendOptions: ()=>
    wGet = @vc.api.getExampleNames()
    wGet.then(
      (data)=>
        bag = $("#examples .dropdown ul", @node)
        bag.empty()
        for example in data.example
          bag.append(
            """
                <li data-id='#{example.id}' data-action='get-example-from-db' data-context='user'>#{example.name}</li>
            """
          )
    ).fail(
      ()=> alert "Couldn't load examples. Try again later."
    )

  printJSON:()=>
    $("#preview-container pre", @node).html(syntaxHighlight(@vc.p))

  fillFieldsetsWithData: (bag, data)=>
    for element in data
      $("input[data-id='#{element.id}']", bag).val(element.name)

  fillMatrixWithData: (matrix, data)=>
    i = 1
    j = 1
    number = data.length

    while i <= number
      j = i
      while j <=number
        cell = $("[data-i='#{i}'][data-j='#{j}']", matrix)
        if i is j
          cell.text("1")
        else if i < j
          $('option:selected', cell).removeAttr('selected')
          $("option:contains('#{data[i - 1][j - 1]}')", cell).attr("selected",true).trigger("change");
        j++
      i++