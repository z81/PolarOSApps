class window.PixiAdapter
  render: =>
    @renderer.render @stage
    requestAnimationFrame @render


  constructor: (scheme_selector = '#scheme', root = true, rootId = '0')->
    elId = 'scheme' + rootId

    @renderer = new PIXI.WebGLRenderer 1000, 600, null, true, true
    $(@renderer.view).attr 'id', elId
    $(scheme_selector).append @renderer.view
    if !root
      $('#' + elId).hide()

    @stage = new PIXI.Stage 0xFFFFFF, true
    @stage.mouseup   = (e)-> Scheme.mouseup(e)
    requestAnimationFrame @render

    @stage


  @getRealDotPosition: (dot)->
    [
        dot.currentPath.points[0] + dot.worldTransform.tx,
        dot.currentPath.points[1] + dot.worldTransform.ty
    ]


  @moveElement: (el, x, y)->
    el._.visual.position = x: x, y: y

  drawElement: (el, element_size, icon_size)->
    element_color_hex = getConf().element.color
    element_hover_color_hex = getConf().element.selected.color
    element_border_color_hex = getConf().element.border.color

    rect  = new PIXI.Graphics()
    rect.beginFill element_color_hex
    rect.lineStyle getConf().element.border.size, element_border_color_hex
    rect.drawRect el.X, el.Y, element_size, element_size
    rect.hitArea = new PIXI.Rectangle el.X, el.Y, element_size, element_size

    rect.setInteractive true
    rect.mousedown = (e)->
      # dblclick
      if rect.last_click_time + 200 > Date.now()
        Scheme.elementDblclick(e, el)
        return false
      rect.last_click_time = Date.now()

      if  Scheme.selected_element
        Scheme.selected_element._.visual.tint = element_color_hex

      rect.tint = element_hover_color_hex

      Scheme.selectElement el

      position = el._.visual.position
      Scheme.drag_start_pos = [e.originalEvent.layerX - position.x, e.originalEvent.layerY - position.y]

      Scheme.mousedown(e, el)

    rect.mouseup   = (e)-> Scheme.mouseup(e, el)
    rect.mousemove = (e)-> Scheme.mousemove(e, el)


    @stage.addChild rect
    if icon_size > 0
      icon = new PIXI.Sprite   PIXI.Texture.fromImage "#{getConf().icon.path}#{el.Name}.ico" #"
      icon.position.x = el.X + (element_size - icon_size) / 2
      icon.position.y = el.Y + (element_size - icon_size) / 2
      icon.height = icon_size
      icon.width = icon_size
      rect.addChild icon

    rect


  drawDot: (dot, type, position, dot_color)->
    [x, y] = position
    dot_hover_color_hex = getConf().dot.hover_color

    circle = new PIXI.Graphics()
    draw = ->
      circle.beginFill dot_color
      circle.drawCircle x, y, getConf().dot.radius.min
      circle.hitArea = new PIXI.Circle x, y, getConf().dot.radius.min
      circle.setInteractive true

    draw()

    circle.mouseover = ->
      console.log dot.Name
      circle.beginFill dot_hover_color_hex
      circle.drawCircle x, y, getConf().dot.radius.max

    circle.mouseout = ->
      circle.clear()
      draw()

    circle.mouseup = (e)->
      Scheme.newLink e, dot

    dot._.element._.visual.addChild circle

    circle


  drawLink: (start_pos, stop_pos, color, redraw = false)=>
    [start_x, start_y] = start_pos
    [stop_x, stop_y] = stop_pos


    if redraw != false
      link = redraw
    else
      link = new PIXI.Graphics()

    link.lineStyle 1, color
    link.moveTo start_x, start_y

    path = Scheme.newPath start_x, start_y, stop_x, stop_y, color

    for e, i in path by 2
      link.lineTo path[i], path[i+1]

    link.lineTo stop_x, stop_y

    if redraw == false
      @stage.addChild link

    link
