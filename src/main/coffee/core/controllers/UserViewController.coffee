class app.core.controllers.UserViewController
  n: {}
  p: {
    criteria: []
    options: []
  }

  constructor: ->
    @n.solverContainer = $(".solver-container")
    @

  onInitSolverClick:=>
    @n.solverContainer.css("top", 0).addClass("visible").attr("data-selected", "1")

  onCloseSolverClick:=>
    @n.solverContainer.removeAttr("style").removeClass("visible")

  onSelectStepClick: (target)=>
    step = target.data("step")
    @n.solverContainer.attr("data-selected", step);
    @stepHandler(step)

  stepHandler: (step)=>
    null

  onGenerateCriteriaClick: (target)=>
    form = target.closest("form")
    number = $("#numOfCriteria", form).val().trim()
    bag = $("#criteria-bag", @n.solverContainer).empty()
    @generateAndAppendFieldsets(bag, number, "C")
    @generateAndAppendComparisonTable(bag, number,"criteria-comparison-table-container", "criteria-comparison-matrix", "C")
    bag.append("<a class='pure-button pure-button-primary' data-action='generate-options' data-context='user'>Accept and go to next step</a>")



  onGenerateOptionsClick: (target)=>
    bag = $("#options-bag", @n.solverContainer).empty()
    #TODO: Remove this fake criteria array
    @p.criteria = [{name: "Zdrowie"}, {name: "Dupa"}, {name: "Barabasz"}]
    if(@p.criteria.length is 0)
      bag.append("<p class='exception-message'><i class='fa fa-exclamation-triangle'></i>Please define and accept criteria!</p>")
    else
      form = target.closest("form")
      number = $("#numOfOptions", form).val().trim()
      @generateAndAppendFieldsets(bag, number, "O")
      for crt in @p.criteria
        @generateAndAppendComparisonTable(bag, number,"options-comparison-table-container", "options-comparison-matrix", "O", crt.name)
      bag.append("<a class='pure-button pure-button-primary' data-action='generate-options' data-context='user'>Accept and go to next step</a>")

  generateAndAppendFieldsets:(bag, number, symbol)=>
    i = 1
    while i <= number
      bag.append(
                """
          <fieldset class='name-fieldset'>
            <label>#{symbol + i} name:</label>
            <input class='des pull-right' type='text' placeholder='#{symbol + i}'>
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
            "<td>#{symbol + i}</td>"
          else if i is j
            "<td> 1 </td>"
          else if i < j
            "<td>#{selectTemplate}</td>"
          else "<td>1</td>"
        currentRow.append(cell)
        j++
        null
      tbody.append(currentRow)
      i++

    table.append(thead, tbody)
    tableContainer.append(table)

    bag.append(tableContainer)

