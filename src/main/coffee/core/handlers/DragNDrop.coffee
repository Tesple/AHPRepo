class app.core.handlers.DragNDrop

  constructor: (vc)->
    @vc = vc
    @

  init: ()=>
    holder = document.getElementById("holder")
    holder.ondragover = ->false
    holder.ondragend  = ->false

    holder.ondrop = (e) =>
      e.preventDefault()
      file = e.dataTransfer.files[0]
      reader = new FileReader()
      reader.onload = (event) =>
        if file.type isnt "text/plain" then alert "Only plain text files are allowed!"
        else
          fileString = event.target.result
          unless isJSONString(fileString)
            alert "Only JSON structure is allowed!"
          else
            jsonData = JSON.parse(fileString)
            if @vc.isSimulationDataValid(jsonData)
              @vc.loadDataFromJson(jsonData)
            else alert "Invalid data structure!"
        return
      reader.readAsText file
      false