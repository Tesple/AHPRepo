class app.core.Authorization

  constructor:->
    @

  authorize:=>
    #TODO: write full authorization with Slim Framework
    dfd = new $.Deferred()
    setTimeout((=>dfd.resolve({token: "TOJESTAUTHTOKEN"})), 1000) #resolve | reject
    dfd