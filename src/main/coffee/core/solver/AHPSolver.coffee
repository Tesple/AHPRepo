class app.core.solver.AHPSolver
  weights:
    "1/9": (1 / 9)
    "1/7": (1 / 7)
    "1/5": (1 / 5)
    "1/3": (1 / 3)
    "1":   (1)
    "3":   (3)
    "5":   (5)
    "7":   (7)
    "9":   (9)


  criteriaData:     null
  optionsDataArray: []
  variantRanks:    []

  CONSISTENCY_RATIO: 0.1
  CCI: 0
  OCI: 0

  constructor: (vc)->
    @vc = vc
    @node = @vc.n.solverContainer
    console.info "AHPSolver initialized"
    @

  startAhpSolver: (cCI, oCI)=>
    $(".solver #solver-bag", @node).empty()
    @clearData()
    @CCI = cCI
    @OCI = oCI
    @numberizeAndNormalizeData()
    @calculateVariants()
    @sortRanking()
    @visualizeResults()

  numberizeAndNormalizeData: ()=>
    @criteriaData = @getNumberizedAndNormalizedMatrixData(@vc.p.criteriaComparisonArray)

    for OCM in @vc.p.optionComparisonArrays
      @optionsDataArray.push(
        {
          criteriaId: OCM.criteriaId,
          data: @getNumberizedAndNormalizedMatrixData(OCM.array)
        }
      )


  getNumberizedAndNormalizedMatrixData: (array)=>
    targetArray = []
    columnArray = []
    vectorArray = []
    for row, idr in array
      targetArray[idr] = []
      for cell, idc in row
        columnArray[idc] = 0 unless columnArray[idc]?
        columnArray[idc] += @weights[cell]
        targetArray[idr][idc] = @weights[cell]
    size = targetArray.length

    for row, idr in targetArray
      for cell, idc in row
        targetArray[idr][idc] /= columnArray[idc]
        vectorArray[idr] = 0 unless vectorArray[idr]?
        vectorArray[idr] += targetArray[idr][idc] / size

    lambda = 0
    lambda += vectorArray[i] * columnArray[i] for i in [0..size-1]
    CI     = (lambda - size) / (size - 1)
    RI     = @CONSISTENCY_RATIO
    CR     = CI / RI

    {
      matrix: targetArray,
      c_vector: columnArray,
      s_vector: vectorArray,
      lambda: lambda,
      CI: CI,
      CR: CR,
      isConsistent: CR < @CONSISTENCY_RATIO
    }


  calculateVariants: ()=>
    size = @vc.p.options.length
    @variantRanks = []
    c_s_vector = @criteriaData.s_vector

    for option,idx in @optionsDataArray
      for i in [0..size-1]
        @variantRanks[i] = {id: @vc.p.options[i].id, value: 0} unless @variantRanks[i]?
        @variantRanks[i].value += c_s_vector[idx] * option.data.s_vector[i]


  sortRanking: ()=>
    @variantRanks.sort((a, b)=> -(a.value - b.value))

  clearData: ()=>
    @criteriaData    = null
    @optionsDataArray = []
    @variantRanks = []
    @CONSISTENCY_RATIO = 0.1

  visualizeResults: ()=>
    bag = $(".solver #solver-bag", @node)
    bag.append("<h1>Ranking</h1>")
    @printRanking(bag, @variantRanks)
    bag.append("<hr/>")
    bag.append("<h1>Results - criteria</h1>")
    @generateAndAppendVector(bag, @criteriaData.s_vector, "S vector for criteria:")
    @generateAndAppendVector(bag, @criteriaData.c_vector, "C vector for criteria:")
    @generateAndAppendMatrix(bag, @criteriaData.matrix,   "Matrix:")
    @generateAndAppendMatrix(bag, @prepareCICRCONSISTANCELAMBDAArray(@criteriaData), "Consistence details:")
    bag.append("<hr/>")
    bag.append("<h1>Results - options</h1>")
    for data,idx in @optionsDataArray
      data = data.data
      @generateAndAppendVector(bag, data.s_vector, "S vector for criteria \"#{@vc.p.criteria[idx].name}\":")
      @generateAndAppendVector(bag, data.c_vector, "C vector for criteria \"#{@vc.p.criteria[idx].name}\":")
      @generateAndAppendMatrix(bag, data.matrix,   "Matrix for criteria \"#{@vc.p.criteria[idx].name}\":")
      @generateAndAppendMatrix(bag, @prepareCICRCONSISTANCELAMBDAArray(data), "Consistence details for criteria \"#{@vc.p.criteria[idx].name}\":")
      bag.append("<hr/>")





  generateAndAppendVector: (bag, data, legend)=>
    tableContainer = $("<div class='table-container'></div>")
    tableContainer.append("<legend>#{legend}</legend>")
    table = $("<table class='pure-table pure-table-bordered'></table>")
    tbody = $("<tbody></tbody>")
    currentRow = $("<tr></tr>")

    for cell in data
      currentRow.append("<td>#{cell.toFixed(2)}</td>")
    tbody.append(currentRow)

    table.append(tbody)
    tableContainer.append(table)
    bag.append(tableContainer)

  generateAndAppendMatrix: (bag, data, legend)=>
    tableContainer = $("<div class='table-container'></div>")
    tableContainer.append("<legend>#{legend}</legend>")
    table = $("<table class='pure-table pure-table-bordered'></table>")
    tbody = $("<tbody></tbody>")

    for row in data
      currentRow = $("<tr></tr>")
      for cell in row
        currentRow.append("<td>#{if isNumber(cell) then cell.toFixed(2) else cell}</td>")
      tbody.append(currentRow)

    table.append(tbody)
    tableContainer.append(table)
    bag.append(tableContainer)

  prepareCICRCONSISTANCELAMBDAArray: (data)=>
    [
      ["Lambda","Consistency index","Consistency ratio", "Is consistent?"]
      [data.lambda,data.CI,data.CR, data.isConsistent]
    ]

  printRanking: (bag, rank)=>
    list = $("<ol></ol>")

    for opt in rank
      list.append("<li>#{@getOptionNameById(opt.id)} (#{opt.value.toFixed(2)})</li>")
    bag.append(list)

  getOptionNameById: (id)=>
    for opt in @vc.p.options
      if opt.id is id
        return opt.name
    return "-------"



