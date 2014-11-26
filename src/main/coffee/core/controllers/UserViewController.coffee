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
    @click  = new app.core.handlers.ClickHandlers(@n.solverContainer, @)
    @dnd    = new app.core.handlers.DragNDrop(@)
    @dh     = new app.core.helpers.DataHelper(@n.solverContainer, @)
    @solver = new app.core.solver.AHPSolver(@)
    @api    = new app.core.API()
    @

  onInitSolverClick:=>
    @click.initSolver()
    @dnd.init()

  onCloseSolverClick:=> @click.closeSolver()

  onSelectStepClick: (target)=>
    step = target.data("step")
    @click.selectStep(target, step)
    @stepHandler(step)

  onToggleOpenClick:       (target)=> @click.toggleOpen(target)

  onGetExampleFromDbClick: (target)=> @click.getExampleFromDb(target)

  onDownloadDataFileClick:=>          @click.downloadDataFile()

  onGenerateCriteriaClick: (target)=> @generateCriteria(target)

  onStartAhpSolverClick:   (target)=>
    cCI = $("#critConsIdx", @n.solverContainer).val().trim()
    oCI = $("#critConsIdx", @n.solverContainer).val().trim()
    unless isNumber(oCI) and isNumber(cCI) and inScope(oCI) and inScope(cCI)
      alert("Invalid criteria consistency index and/or options consistency index!")
    else
      @solver.startAhpSolver(cCI, oCI)

  onAcceptCriteriaAndGoToOptionsClick:()=>
    @dh.collectDataFromFieldsets(@p.criteria, $("#criteria-bag", @n.solverContainer))
    @dh.collectDataFromMatrix(@p.criteriaComparisonArray, $("#criteria-comparison-matrix", @n.solverContainer), @p.criteria.length)
    @goToStep(2)

  onAcceptOptionsAndGoToPreviewClick:()=>
    @dh.collectDataFromFieldsets(@p.options, $("#options-bag", @n.solverContainer))
    for ctr, index in @p.criteria
      @p.optionComparisonArrays[index] = {criteriaId: ctr.id, array:[]}
      array = @p.optionComparisonArrays[index].array
      @dh.collectDataFromMatrix(array, $("#options-comparison-matrix-#{ctr.id}", @n.solverContainer), @p.options.length)
    @goToStep(3)

  stepHandler: (step)=>
    switch step
      when 0 then @dh.getExampleNamesAndAppendOptions()
      when 3 then @dh.printJSON()
      when 4 then @prepareSolver()

  prepareSolver: ()=>
    unless @isSimulationDataValid(@p)
      $(".solver #solver-bag, .solver #solver-options", @n.solverContainer).hide()
      $(".solver .exception-message", @n.solverContainer).show()
    else
      $(".solver #solver-bag, .solver #solver-options", @n.solverContainer).show()
      $(".solver .exception-message", @n.solverContainer).hide()


  generateCriteria: (target, skipCleanUp)=>
    form = target.closest("form")
    number = $("#numOfCriteria", form).val().trim()
    bag = $("#criteria-bag", @n.solverContainer)
    bag.fadeOut(200,=>
      bag.empty()
      @generateAndAppendFieldsets(bag, number, "C")
      @generateAndAppendComparisonTable(bag, number,"criteria-comparison-table-container", "criteria-comparison-matrix", "C")
      $accept = $("<a class='pure-button pure-button-primary stretched'>Accept and go to next step</a>")
      bag.append($accept)
      unless skipCleanUp
        @clearAllCriteriaData()
        @clearAllOptionsData()
      $("#options-bag", @n.solverContainer).empty()
      @registerElementHandler($accept, "click", @onAcceptCriteriaAndGoToOptionsClick)
      @registerElementHandler($("#criteria-comparison-matrix", bag), "change", @handleMatrixValueChange)
      bag.fadeIn(200)
    )

  onGenerateOptionsClick: (target)=>
    @generateOptions(target)

  generateOptions: (target, skipCleanUp)=>
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
        unless skipCleanUp
          @clearAllOptionsData()
        @registerElementHandler($accept, "click", @onAcceptOptionsAndGoToPreviewClick)
      bag.fadeIn(200)
    )

  generateAndAppendFieldsets:(bag, number, symbol)=>
    @dh.generateAndAppendFieldsets(bag, number, symbol)

  generateAndAppendComparisonTable: (bag, number, tcClass, matrixId, symbol, legend)=>
    @dh.generateAndAppendComparisonTable(bag, number, tcClass, matrixId, symbol, legend)

  registerElementHandler: (element, event, callback)=>
    $(element).on(event,callback)

  handleMatrixValueChange: (event)=>
    target = $(event.target)
    value = target.val()
    opposite = if value.length is 1 and value isnt "1" then "1/#{value}" else value.slice(-1)
    cls = target.closest("td")
    dataI = cls.data("i")
    dataJ = cls.data("j")
    matrix = target.closest("tbody")
    $("td[data-i='#{dataJ}'][data-j='#{dataI}']", matrix).text(opposite)

  goToStep: (number)=>
    $("[data-step='#{number}'][data-action='select-step']", @n.solverContainer).trigger("click")

  clearAllCriteriaData: ()=>
    @p.criteria = []
    @p.criteriaComparisonArray = []
    $(".solver #solver-bag", @n.solverContainer).empty()

  clearAllOptionsData: ()=>
    @p.options = []
    @p.optionComparisonArrays = []
    $(".solver #solver-bag", @n.solverContainer).empty()

  isSimulationDataValid: (json)=>
    @dh.isSimulationDataValid(json)

  loadDataFromJson: (json)=>
    @p = json
    $("input#numOfCriteria", @n.solverContainer).val(@p.criteria.length)
    $("input#numOfOptions",  @n.solverContainer).val(@p.options.length)
    $.when(
      @generateCriteria($("a[data-action='generate-criteria']"), true),
      @generateOptions($("a[data-action='generate-options']"), true)
    ).then(
      =>
        crtBag = $("#criteria-bag", @n.solverContainer)
        optBag = $("#options-bag", @n.solverContainer)
        @dh.fillFieldsetsWithData(crtBag, @p.criteria)
        @dh.fillFieldsetsWithData(optBag, @p.options)
        @dh.fillMatrixWithData($("#criteria-comparison-matrix", crtBag), @p.criteriaComparisonArray)
        for element in @p.optionComparisonArrays
          @dh.fillMatrixWithData($("#options-comparison-matrix-#{element.criteriaId}", optBag), element.array)
    )
    @goToStep(4)

