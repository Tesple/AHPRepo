class app.core.handlers.BasicClickHandlers
  controllers:
    userController: null
    adminController: null
    commonController: null

  constructor:->
    @controllers

  #SPLASH VIEW
  onFreeUserClick:=>
    console.info "Starting application"

  onAdminUserClick:=>
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
    )

