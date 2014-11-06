class Init

  constructor: ->
    @initDataActionHandlers()

  initDataActionHandlers: ()=>
    $("[data-action!=''][data-action]").on("click",
      (event)=>
        target = $(event.target)
        action = target.data("action")
        eventType =  event.type

        methodName = null


    )


$().ready(
  => new Init()
)