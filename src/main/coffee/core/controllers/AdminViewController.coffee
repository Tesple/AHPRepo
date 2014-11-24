class app.core.controllers.AdminViewController

  constructor: ->
    _info("AdminViewController initialized")
    @userController = window.controllers.user
    @auth = new app.core.Authorization()
    @

  onAdminUserClick:=>
      $("#admin-auth p").text("")
      $("#splash-buttons-bar").hide( 400, =>
        $("#admin-auth").show(400)
      )

  onCancelAuthClick:=>
    $("#admin-auth").hide( 400, =>
      $("#splash-buttons-bar").show(400)
    )

  onAuthClick:=>
    $("#admin-auth").hide(400, =>
      $("#auth-spinner").show()
      @auth.authorize().then(
        =>
          @userController.onInitSolverClick()
          $("#admin-auth").hide( 400, =>
            $("#splash-buttons-bar").show(400)
            $("#auth-spinner").hide()
            @startAdmin()
          )
      ).fail(
        =>
          $("#auth-spinner").hide(400, =>
            $("#admin-auth").show()
            $("#admin-auth p").text("Authorization failed - try again.")
          )
      )
    )

  onUnauthClick: ()=>
    @killAdmin()

  startAdmin: =>
    console.warn "Hello Admin! Nice to meet you :)"

  killAdmin: =>
    console.warn "BANG BANG motherfucker !"