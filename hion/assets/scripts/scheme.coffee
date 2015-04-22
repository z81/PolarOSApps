class Paper extends window.PixiAdapter


window.getConf = -> Scheme.getConf()

class ElementConf
  @getConf: (name, parse = true)->
    conf = {}

    $.ajax({url: "hiasm/delphi_utf/conf/#{name}.ini", async: false})
    .success (data)-> conf = parseINIString(data) #"

    if conf.Type and conf.Type.Inherit
      for Inherit in conf.Type.Inherit.split ','
        i_conf = @getConf Inherit, false
        conf.Property = angular.extend conf.Property, i_conf.Property
        conf.Methods = angular.extend conf.Methods, i_conf.Methods
        #console.log conf,int

    if parse
      return @parse conf
    else
      return conf


  @parse: (conf)->
    #console.log 'parse', conf

    for name of conf.Property
      prop = {}
      #console.log name
      prop.doWork = name.indexOf('@') > -1
      prop.default = name.indexOf '+' > -1
      prop.name = name.replace /[@|\+]/gmi, ''

      [prop.description, prop.type, prop.value, prop.list] = conf.Property[name].split '|'

      delete conf.Property[name]
      conf.Property[prop.name] = prop

    for name of conf.Methods
      method = {}
      method.noVisible = name.indexOf '*'
      method.Name = name.replace /[\*]/gmi, ''


      [method.description, method.type, method.value] = conf.Methods[name].split '|'
      delete conf.Methods[name]
      conf.Methods[method.Name] = method




    conf

class window.Scheme
  WORK  = "1"
  EVENT = "2"
  DATA  = "3"
  VAR   = "4"

  # static
  @getConf: ()->
    window.scheme_conf

  @newPath: (start_x, start_y, stop_x, stop_y, color)->
    path = []
    if color is Scheme.getConf().link.color.events
      if start_y - stop_y != 0
        if start_x < stop_x
          path = [
              start_x + (stop_x - start_x)/2
              start_y

              start_x + (stop_x - start_x)/2
              stop_y
          ]

        else
          path = [
              start_x + 10
              start_y

              start_x + 10
              start_y + 30 #el size

              stop_x - 10
              start_y + 30

              stop_x - 10
              stop_y
          ]

    else
      if start_x - stop_x != 0
        if start_y < stop_y
          path = [
            start_x
            start_y + (stop_y - start_y)/2

            stop_x
            start_y + (stop_y - start_y)/2
          ]

        else
          path = [
            start_x
            start_y + 10

            start_x + (stop_x - start_x) + 12
            start_y + 10

            stop_x + 12
            stop_y - (stop_y - start_y)/2

            stop_x - (stop_x - start_x)/2
            stop_y - (stop_y - start_y)/2

            stop_x - (stop_x - start_x)/2
            stop_y - 10

            stop_x
            stop_y - 10
          ]

    path



  @selectElement: (element)->
    console.log element
    Scheme.selected_element = element
    angular.element('body').scope().onSelectElement()

  @mouseup: (e)->
    @mousemove e
    Scheme.is_drag = false

  @elementDblclick: (e, el)->
    if el.Root_paper
      $('#scheme0').toggle()
      $('#scheme' + el.Id).toggle()
  @closeContainer: ()->
    $('#scheme *').hide()
    $('#scheme0').show()




  @mousemove: (e)->
    if Scheme.create_link
      @createNewLink e, Scheme.create_link.dot1

    if Scheme.is_drag
      x = e.originalEvent.layerX - Scheme.drag_start_pos[0]
      y = e.originalEvent.layerY - Scheme.drag_start_pos[1]
      el = Scheme.selected_element

      if Scheme.selected_element._.links
        #console.log Scheme.selected_element._.visual
        for link in Scheme.selected_element._.links
          #console.log 'redraw line', "#{link.dot1.Name}<-->#{link.dot2.Name}", link

          dot1 = link.dot1._.visual
          dot2 = link.dot2._.visual

          start_pos = Paper.getRealDotPosition dot1
          stop_pos = Paper.getRealDotPosition dot2

          if link.dot1.type is EVENT || link.dot1.type is WORK
            color = Scheme.getConf().link.color.events
          else
            color = Scheme.getConf().link.color.vars

          link.clear()
          Scheme.selected_element._.paper.drawLink start_pos, stop_pos, color, link


      Paper.moveElement el, x, y

  @saveNewLink: (e, dot2)->
    #dot._.paper.drawLink dot, Scheme.create_link.dot1, null
    #Scheme.create_link.clear()
    dot1 = Scheme.create_link.dot1
    class_type_dot1 = dot1.type < 3
    class_type_dot2 = dot2.type < 3
    console.log class_type_dot1, class_type_dot2

    if class_type_dot1 == class_type_dot2 && dot1.type !=  dot2.type
      Scheme.create_link.dot2 = dot2

      dot2._.element._.links.push Scheme.create_link
      dot1._.element._.links.push Scheme.create_link
      Scheme.create_link = undefined

  @createNewLink: (e, dot)->
    dot_position =  Paper.getRealDotPosition dot._.visual
    if dot.type is EVENT or dot.type is WORK
      color = Scheme.getConf().link.color.events
    else
      color = Scheme.getConf().link.color.vars

    if Scheme.create_link
      Scheme.create_link.clear()
      dot._.paper.drawLink dot_position, [e.global.x, e.global.y], color, Scheme.create_link
    else
      Scheme.create_link = dot._.paper.drawLink dot_position, [e.global.x, e.global.y], color

    Scheme.create_link.dot1 = dot

    Scheme.create_link
  @newLink: (e, dot)->
    if !Scheme.create_link
      @createNewLink e, dot
    else
      @saveNewLink e, dot


  @mousedown: (e, el)->
    Scheme.selectElement el
    Scheme.is_drag = true

  load: (sha)->
    `var stats = new Stats();
    stats.setMode(0); // 0: fps, 1: ms

    stats.domElement.style.position = 'fixed';
    stats.domElement.style.left = '0px';
    stats.domElement.style.bottom = '40px';
    document.body.appendChild( stats.domElement );

    setInterval( function () {
      stats.begin();
      stats.end();
    }, 1000 / 60 );`

    result = ShaParser.getInstance().Parse sha
    @sdk = result.sdk
    sortedElements = result.sortedElements

    @paper = new Paper()

    for element in sortedElements
      if !element._Container and !element._Root
        if old_paper && !element._Root
          @paper = old_paper
        @createElement element

      else
        if element._Container
          @createElement element
          old_paper = @paper
          @paper = new Paper('#scheme', false, element.Id)
          element.Root_paper = @paper

        else
          @paper = element._Root.Root_paper
          @createElement element


        #@paper = old_paper
        #@paper.stage.worldVisible = false
        #console.log 'stage',element.Name



    #links
    for eid of @sdk.Elements
      element = @sdk.Elements[eid]
      for method of element.Methods
        method = element.Methods[method]

        if method.to and method.noVisible
          console.info method
        if method.noVisible == -1
          if method.to
            to = {}
            [to.Id, to.Name] = method.to.split ':'
            to.Element = @sdk.Elements[to.Id]

            for method2 of to.Element.Methods
              method2 = to.Element.Methods[method2]
              if method2.Name is to.Name
                to.Method = method2
                break

            if method.type is EVENT || method.type is WORK
              color = Scheme.getConf().link.color.events
            else
              color = Scheme.getConf().link.color.vars

            @drawLink method, to, color


    console.log 'SDK',@sdk

  # create element and draw
  createElement: (element)->
    @sdk.Elements[element.Id] = element
    @addElement element

    i = [0, 0, 0, 0, 0, 0]
    for method of element.Methods
        method = element.Methods[method]

        if method.noVisible == -1
            method._ = element: element
            mtype = method.type
            x = element.X
            y = element.Y

            dot_color = Scheme.getConf().dot.color

            if mtype is EVENT
              x = x + element._.size
            if mtype is EVENT or mtype is WORK
              y = y + Scheme.getConf().dot.indent + i[method.type] * Scheme.getConf().dot.offset
            if mtype is DATA
              y = element.Y
              x = element.X + Scheme.getConf().dot.indent + i[method.type] * Scheme.getConf().dot.offset
              dot_color = Scheme.getConf().dot.color2
            if mtype is VAR
              y =  element.Y + element._.size
              x =  element.X + Scheme.getConf().dot.indent
              dot_color = Scheme.getConf().dot.color2


            #method._.i = i[method.type]
            @addDot method, 1, [x, y], dot_color
            i[method.type]++

  # draw Element
  addElement: (el)->
    size = Scheme.getConf().element.size
    icon_size = Scheme.getConf().icon.size
    conf = ElementConf.getConf el.Name

    el._ ?= {}
    el.Property ?= {}
    el.Methods ?= {}
    el._.links = []
    el._.conf = conf
    conf.Property ?= {}
    conf.Methods ?= {}


    switch el._.conf.Type.Class
      when 'MultiElement'

        if el._Container.Property.EventCount
          for i in [1..el._Container.Property.EventCount.Value]
            name = "onEvent#{i}" #"
            conf.Methods[name] = {Name: name, type: EVENT, noVisible: -1}

        if el._Container.Property.WorkCount
          for i in [1..el._Container.Property.WorkCount.Value]
            dotname = "doWork#{i}" #"
            conf.Methods[dotname] = Name: dotname, type: WORK, noVisible: -1


      when 'DPElement'
        for sub in el._.conf.Type.Sub.split ','
          if sub
            [dot, name] = sub.split '|'

            if name[0] is 'o'
              type = EVENT
            else
              type = WORK

            for i in [1..el.Property[dot].Value]
              dotname = "#{name}#{i}"
              conf.Methods[dotname] = Name: dotname, type: type, noVisible: -1 #"


      when 'Hub'
        size = 15
        icon_size = 10

        for sub in el._.conf.Type.Sub.split ','
          if sub
            [dot, name] = sub.split '|'

            if name[0] is 'o'
              type = EVENT
            else
              type = WORK


            for i in [1..el.Property[dot].Value]
              dotname = "#{name}#{i}"
              conf.Methods[dotname] = Name: dotname, type: type, noVisible: -1 #"

      when 'EditMulti'
        size = 400
        icon_size = 0


    for method of el.Methods
      conf.Methods[method] ?= {}
      conf.Methods[method].Name = el.Methods[method].Name
      conf.Methods[method].path = el.Methods[method].path
      conf.Methods[method].to = el.Methods[method].to
      conf.Methods[method].noVisible = -1 #el.Methods[method].noVisible

    for property of el.Property
      conf.Property[property] ?= {}
      conf.Property[property].path = el.Property[property].path
      conf.Property[property].to = el.Property[property].to
      conf.Property[property].noVisible = -1




    el._.visual = @paper.drawElement el, size, icon_size
    el._.size = size
    el._.paper = @paper


    el.Property = conf.Property
    el.Methods = conf.Methods
    el._.paper = @paper

    el


  addDot: (dot, method, position, color)->
    dot.Name = dot.Name.replace /%(.*)%/gmi, ''
    dot._.type ?= method

    dot._.x = position[0]
    dot._.y = position[1]
    dot._.paper = @paper

    dot._.visual = @paper.drawDot dot, method, position, color
    #console.log 'addDot', dot, position


  drawLink: (method, to, color)->
    if !to.Method || !to.Method._.x
      console.error "точка #{to.Name} остутствует в #{to.Element.Name}" #"
      return false

    #name = to.Name
    el1 = method._.element
    el2 = to.Element
   # console.log method
    start_x = method._.x - getConf().dot.radius.min / 2
    start_y = method._.y - getConf().dot.radius.min / 2
    stop_x = to.Method._.x - getConf().dot.radius.min / 2
    stop_y = to.Method._.y - getConf().dot.radius.min / 2

    console.log "draw link #{method.Name}<-->#{to.Name}" #"

    link = el1._.paper.drawLink [start_x, start_y], [stop_x, stop_y], color
    el1._.links ?= []
    el2._.links ?= []
    el1._.links.push link
    el2._.links.push link
    method._.link = link
    to.Method._.link = link
    link.dot1 = method
    link.dot2 = to.Method
    link.el1 = el1
    link.el2 = el2
