#$.get 'assets/schemes/test.sha', (data)->
#  console.log ShaParser.getInstance().Parse data

# Sha Parser
# C# fork

class _Property
  name = null
  value = null

class _Method
  Name = null
  Params = null


class _Element
  Name = null
  Id = null
  X = null
  Y = null
  Property = []
  Methods = []


class SDK
  PackageName: "delphi"
  version: ''
  Elements: []


class ParserService
  @PosData = {}
  @StringScheme = ""
  @sdk = null
  instance = null

  constructor: ->
  @getInstance: ->
    instance ?= new ShaParser()


  # Проверяет является ли Sub подстрокой Схемы начиная с StartPos

  SubIs: (Sub, StartPos)->
    SubLength = Sub.length
    StartPos + SubLength <= @StringScheme.length  &&  @StringScheme.substr(StartPos, SubLength) == Sub


  # Проверяет является ли Sub подстрокой Схемы начиная с StartPos
  # и записывает позицию если да

  SetPosIf: (Sub, StartPos)->
    SubLength = Sub.length
    Result = StartPos + SubLength <= this.StringScheme.length   &&   this.StringScheme.substr(StartPos, SubLength) == Sub
    if Result
      this.PosData ?= {}
      if this.PosData[Sub] # last
        this.PosData['_'+Sub] = this.PosData[Sub]
      this.PosData[Sub] = StartPos + SubLength
    Result

  # Возвращяет подстроку между 2 символами найденными ранее

  getSub: (Prop1, Prop2)->
    if @PosData[Prop1] && @PosData[Prop2]
      StartPos = @PosData[Prop1]
      SubLength = @PosData[Prop2] - StartPos - 1
      return @StringScheme.substr(StartPos, SubLength)


  # Проверяет найдена ли позиция символа
  hasPos: (Prop1)->
    @PosData[Prop1]

  # Возвращяет найденую позицию или undefined
  getPos: (Prop1)->
    @PosData[Prop1]

  # Удаляет позицию по имени
  deletePos: (Prop)->
    delete @PosData[Prop]


  #  Добавляет или удалет свойство в @PosData
  # Вохвращяет true если сущесвует свойство

  ToggleProp: (Prop)->
    Prop = "is" + Prop

    Result = @PosData[Prop]
    if Result
      delete @PosData[Prop]
    else
      @PosData.Add(Prop, 1)

    !Result



class window.ShaParser extends ParserService
  parseExp: (str)->

    array = str.split(',', 2)
    # parse coodinars
    if array.length > 1
      json = str.substr(str.indexOf('[')).replace(/\(/gmi,'[').replace(/\)/gmi,']').replace(/\]\[/gmi,'],[')
      array.push JSON.parse(json)

    array

  #Парсит схему из строки

  Parse: (SHA)->
    @StringScheme = SHA.replace /\*.*[\r\n]/, '' # fix
    @sdk = new SDK()
    @sortedElements = []
    IsQuote = false
    @thisProp = ""
    thisElementNum = 0
    lastElementNum = 0

    for i in [0..SHA.length]
      if @SubIs("\"", i)
        IsQuote = !IsQuote;

      if IsQuote
        continue;

      @SetPosIf "Make", i
      @SetPosIf "Add", i
      @SetPosIf "ver", i

      @SetPosIf "BEGIN_SDK", i

      if @SetPosIf("END_SDK", i)
        @deletePos "BEGIN_SDK"


      if @SetPosIf("}", i)
        lastElementNum = thisElementNum
        thisElementNum = 0
        @deletePos "{"
        @deletePos "Add"


      @SetPosIf "{", i

      if @SetPosIf("\n", i)
        if @hasPos("=") && @hasPos("{") && @getPos("=") < @getPos("\n") && @thisProp != ""

          trim = [' ', '\t', '\r', '\n' ]
          value = @getSub("=", "\n").trim(trim)

          Prop = new _Property()
          Prop.Name = @thisProp
          Prop.Value = value

          Element = this.sdk.Elements[thisElementNum]
          Element.Property ?= []
          Element.Property[Prop.Name] = Prop

          @thisProp = ""

      if @SetPosIf("=", i)
        if @hasPos("Add") && @hasPos("{")
          trim = [' ', '\t', '\r', '\n' ]
          name = @getSub("\n", "=").trim(trim)
          @thisProp = name




      @SetPosIf("(", i)


      if @SetPosIf(")", i)
        if @hasPos("Make")
          @sdk.PackageName = @getSub("(", ")")
          @deletePos("Make")

        if @hasPos("ver")
          @sdk.version = @getSub("(", ")")
          @deletePos("ver")


        if @hasPos("Add") && !@hasPos("{") && @getPos('Add') < @getPos(')') #fixed
          Head = @getSub("(", ")").split(',')

          El = new _Element()
          El.Name = Head[0]
          El.Id = Head[1] * 1
          El.X = Head[2] * 1
          El.Y = Head[3] * 1
          El._ = {}

          if @hasPos("BEGIN_SDK") # Todo: check
            if @sdk.Elements[lastElementNum]._Root
              console.log 'paprser pre set root', El,El.Name, @sdk.Elements[lastElementNum]._Root
              El._Root = @sdk.Elements[lastElementNum]._Root
            else
              console.log 'paprser set root', El, El.Name, @sdk.Elements[lastElementNum]
              El._Root = @sdk.Elements[lastElementNum]

          if @hasPos("BEGIN_SDK") and @last_element.Id == El._Root.Id
            El._Root._Container = El


          @last_element = El
          @sdk.Elements[El.Id] = El
          @sortedElements.push El

          thisElementNum = El.Id # fixed

          @deletePos(")") # fixed


      if @hasPos("{") && @hasPos("Add") && @hasPos("(") && @getPos("Add") < @getPos("(") && @getPos("\n") > @getPos(")")
        str = @getSub("_\n", "\n").trim "\n "
        Method = new _Method()
        params = str.substr str.indexOf('(') + 1 # del (
        params = params.substr(0, params.length-1) # del )
        params = @parseExp(params)
        [Method.Name, Method.to, Method.path] = params

        Element = @sdk.Elements[thisElementNum]
        Element.Methods ?= []
        Element.Methods[params[0]] = Method


        @deletePos("(")
        @deletePos(")")


    {sdk: @sdk, sortedElements: @sortedElements}
