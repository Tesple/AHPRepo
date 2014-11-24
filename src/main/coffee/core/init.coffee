class app.core.Init

  controllers:
    user: null
    admin: null

  constructor: ->
    window.controllers = @controllers
    @controllers.user  = new app.core.controllers.UserViewController()
    @controllers.admin = new app.core.controllers.AdminViewController()
    @controllers.user.onInitSolverClick()

    @initDataActionHandlers()

  initDataActionHandlers: ()=>
    $("[data-action!=''][data-action]").on("click",
      (event)=>
        event.preventDefault()
        target = $(event.target)
        action = target.data("action")
        context = target.data("context")

        methodName = "on"
        for part in action.split("-")
          methodName += _capitalize(part)

        methodName += "Click"

        handlers = []
        if context?
          contextArray = context.split(",")
          for element in contextArray
            handlers.push(@controllers[element])
        else return

        for handler in handlers
          if (handler? and action = handler[methodName])?
            console.info "Handling: #{methodName}"
            action(target, event)
          else console.info "#{handler} Couldn't find registered handler for: #{methodName}"
    )

$().ready(
  =>
    new app.core.Init()
)