class app.core.handlers.ClickHandlers

  constructor: (node, vc)->
    @node = node
    @vc = vc
    @

  initSolver:=>
    @node.css("top", 0).addClass("visible").attr("data-selected", "0")
    @vc.stepHandler(0)

  closeSolver:=>
    @node.removeAttr("style").removeClass("visible")

  toggleOpen: (target)=>
    target.toggleClass("open")

  selectStep: (target, step)=>
    selectedStep = @node.attr("data-selected")
    $(".solver-step[data-step='#{selectedStep}']", @node).fadeOut(250,
      => @node.attr("data-selected", step).find(".solver-step[data-step='#{step}']").fadeIn(250)
    )

  getExampleFromDb: (target)=>
    target.closest("#examples").removeClass("open")
    id = target.data("id")
    wGet = @vc.api.getExampleById(id)
    wGet.then(
      (data)=>
        fileString = data.json
        unless isJSONString(fileString)
          alert "Only JSON structure is allowed!"
        else
          jsonData = JSON.parse(fileString)
          if @vc.isSimulationDataValid(jsonData)
            @vc.loadDataFromJson(jsonData)
          else alert "Invalid data structure!"
    ).fail(
      => alert "Couldn't load example from database!"
    )

  downloadDataFile: ()=>
    blob = new Blob([JSON.stringify(@p, undefined, "\t")], {type: "text/plain;charset=utf-8"})
    saveAs(blob, "AHPSolver_#{new Date().getTime()}.txt")