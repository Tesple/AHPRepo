class app.core.controllers.UserViewController
  n: {}
  p: {
    criteria: []
    criteriaComparisonArray: []
    options: []
    optionComparisonArrays: []
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
    selectedStep = @n.solverContainer.attr("data-selected")
    console.warn selectedStep
    $(".solver-step[data-step='#{selectedStep}']",@n.solverContainer).fadeOut(250,
      => @n.solverContainer.attr("data-selected", step).find(".solver-step[data-step='#{step}']").fadeIn(250)
    )
    #@n.solverContainer.attr("data-selected", step);
    @stepHandler(step)

  stepHandler: (step)=>
    switch step
      when 1
        null
        #console.warn "Switched to step #{step}"
      when 2
        null
        #console.warn "Switched to step #{step}"
      when 3
        $("#preview-container pre", @n.solverContainer).html(syntaxHighlight(@p))
      when 4
        null
        #console.warn "Switched to step #{step}"
      when 5
        null
        #console.warn "Switched to step #{step}"

  onDownloadDataFileClick:=>
    blob = new Blob([JSON.stringify(@p, undefined, "\t")], {type: "text/plain;charset=utf-8"})
    saveAs(blob, "AHPSolver_#{new Date().getTime()}.txt")

  onGenerateCriteriaClick: (target)=>
    form = target.closest("form")
    number = $("#numOfCriteria", form).val().trim()
    bag = $("#criteria-bag", @n.solverContainer)
    bag.fadeOut(200,=>
      bag.empty()
      @generateAndAppendFieldsets(bag, number, "C")
      @generateAndAppendComparisonTable(bag, number,"criteria-comparison-table-container", "criteria-comparison-matrix", "C")
      $accept = $("<a class='pure-button pure-button-primary stretched'>Accept and go to next step</a>")
      bag.append($accept)
      @clearAllCriteriaData()
      @clearAllOptionsData()
      $("#options-bag", @n.solverContainer).empty()
      @registerElementHandler($accept, "click", @onAcceptCriteriaAndGoToOptionsClick)
      @registerElementHandler($("#criteria-comparison-matrix", bag), "change", @handleMatrixValueChange)
      bag.fadeIn(200)
    )

  onGenerateOptionsClick: (target)=>
    bag = $("#options-bag", @n.solverContainer)
    bag.fadeOut(200,=>
      bag.empty()
      if(@p.criteria.length is 0)
        bag.append("<p class='exception-message'><i class='fa fa-exclamation-triangle'></i>Please define and accept criteria!</p>")
      else
        form = target.closest("form")
        number = $("#numOfOptions", form).val().trim()
        @generateAndAppendFieldsets(bag, number, "O")
        for crt in @p.criteria
          @generateAndAppendComparisonTable(bag, number,"options-comparison-table-container", "options-comparison-matrix-#{crt.id}", "O", crt.name)
          @registerElementHandler($("#options-comparison-matrix-#{crt.id}", bag), "change", @handleMatrixValueChange)
        $accept = $("<a class='pure-button pure-button-primary stretched'>Accept and go to next step</a>")
        bag.append($accept)
        @clearAllOptionsData()
        @registerElementHandler($accept, "click", @onAcceptOptionsAndGoToPreviewClick)
      bag.fadeIn(200)
    )

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

  registerElementHandler: (element, event, callback)=>
    $(element).on(event,callback)

  onAcceptCriteriaAndGoToOptionsClick:()=>
    @collectDataFromFieldsets(@p.criteria, $("#criteria-bag", @n.solverContainer))
    console.warn @p.criteria
    @collectDataFromMatrix(@p.criteriaComparisonArray, $("#criteria-comparison-matrix", @n.solverContainer), @p.criteria.length)
    console.warn @p.criteriaComparisonArray
    @goToStep(2)

  onAcceptOptionsAndGoToPreviewClick:()=>
    @collectDataFromFieldsets(@p.options, $("#options-bag", @n.solverContainer))
    console.warn @p.options
    for ctr, index in @p.criteria
      console.warn ctr
      @p.optionComparisonArrays[index] = {criteriaId: ctr.id, array:[]}
      array = @p.optionComparisonArrays[index].array
      @collectDataFromMatrix(array, $("#options-comparison-matrix-#{ctr.id}", @n.solverContainer), @p.options.length)
    console.warn @p.optionComparisonArrays
    @goToStep(3)

  handleMatrixValueChange: (event)=>
    target = $(event.target)
    value = target.val()
    opposite = if value.length is 1 and value isnt "1" then "1/#{value}" else value.slice(-1)
    cls = target.closest("td")
    dataI = cls.data("i")
    dataJ = cls.data("j")
    matrix = target.closest("tbody")
    $("td[data-i='#{dataJ}'][data-j='#{dataI}']", matrix).text(opposite)


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


  goToStep: (number)=>
    $("[data-step='#{number}'][data-action='select-step']", @n.solverContainer).trigger("click")

  clearAllCriteriaData: ()=>
    @p.criteria = []
    @p.criteriaComparisonArray = []

  clearAllOptionsData: ()=>
    @p.options = []
    @p.optionComparisonArrays = []

  validateSimulationData: ()=>
