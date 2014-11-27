class app.core.controllers.AdminViewController

  constructor: ->
    _info("AdminViewController initialized")
    @userController = window.controllers.user
    @auth = new app.core.Authorization()
    @dh = new app.core.helpers.DataHelper(@)
    @api = window.api
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
      form = $("#admin-auth")
      @auth.authorize($("#login", form).val().trim(), $("#password", form).val().trim()).then(
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

  startAdmin: =>
    $("#admin-icons").show()
    $(".fa-times").hide()

  onCloseSolverClick: =>
    @killAdmin()

  killAdmin: =>
    $("#login").val("")
    $("#password").val("")
    $("#admin-icons").hide()
    $(".fa-times").show()


  onToggleAdminToolsClick: ()=>
    $("#admin-tools").toggleClass("visible")
    if $("#admin-tools").hasClass("visible")
      $("#loader-layer").show()
      wGet = @api.getExampleNames()
      wGet.then(
        (data)=>
          bag1 = $("#update .dropdown ul", @node)
          bag2 = $("#delete .dropdown ul", @node)
          bag1.empty()
          bag2.empty()
          for example in data.example
            bag1.append(
                      """
                  <li data-id='#{example.id}' data-action='update-selected-example' data-context='admin'>#{example.name}</li>
              """
            )
            bag2.append(
                       """
                  <li data-id='#{example.id}' data-action='delete-selected-example' data-context='admin'>#{example.name}</li>
              """
            )
          $("#loader-layer").hide()
      ).fail(
        ()=>
          alert "Couldn't load examples. Try again later."
          $("#loader-layer").hide()
      )


  onSaveAsClick: ()=>
    name = $("#save-as-name").val().trim()
    json = window.uvc.p
    if name.length is 0
      alert "Name must be at least 1 char long"
      return
    unless @dh.isSimulationDataValid(window.uvc.p)
      alert "Invalid data"
      return
    $("#loader-layer").show()
    wAdd = @api.addExample(name, json)
    wAdd.then(
      (example)=>
        console.warn example
        $("#update .dropdown ul", @node).append(
          """
            <li data-id='#{example.id}' data-action='update-selected-example' data-context='admin'>#{example.name}</li>
          """
        )
        $("#delete .dropdown ul", @node).append(
          """
            <li data-id='#{example.id}' data-action='delete-selected-example' data-context='admin'>#{example.name}</li>
          """
        )
        $("#loader-layer").hide()
        alert "Example updated successfully!"
    ).fail(
      ()=>
        $("#loader-layer").hide()
        alert "Couldn't update example. Try again later."
    )

  onUpdateSelectedExampleClick: (target)=>
    id = target.data("id")
    name = target.text()
    alert name
    json = window.uvc.p
    if name.length is 0
      alert "Name must be at least 1 char long"
      return
    unless @dh.isSimulationDataValid(window.uvc.p)
      alert "Invalid data"
      return
    $("#loader-layer").show()
    wUpdate = @api.updateExample(id, name, json)
    wUpdate.then(
      ()=>
        $("#loader-layer").hide()
        alert "Example updated successfully!"
    ).fail(
      ()=>
        $("#loader-layer").hide()
        alert "Couldn't update example. Try again later."
    )

  onDeleteSelectedExampleClick: (target)=>
    id = target.data("id")
    $("#loader-layer").show()
    wDelete = @api.deleteExample(id)
    wDelete.then(
      ()=>
        $("#loader-layer").hide()
        target.remove()
        $("[data-action='update-selected-example'][data-id='#{id}']").remove()
        alert "Example deleted successfully!"
    ).fail(
      ()=>
        $("#loader-layer").hide()
        alert "Couldn't delete example. Try again later."
    )


