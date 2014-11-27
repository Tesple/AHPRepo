class app.core.Authorization
  loginHash: "63a9f0ea7bb98050796b649e85481845"
  passwordHash: "5f4dcc3b5aa765d61d8327deb882cf99"

  constructor:->
    @

  authorize:(login, password)=>
    dfd = new $.Deferred()
    setTimeout(
      (=>
        if $.md5(login) is @loginHash and $.md5(password) is @passwordHash
          dfd.resolve()
        else dfd.reject()
      ), 1000
    )
    dfd