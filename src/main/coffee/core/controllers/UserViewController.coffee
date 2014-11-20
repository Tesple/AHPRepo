class app.core.controllers.UserViewController
  n: {}

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



