window.scheme_conf =
    dot:
      radius:
        min: 2.6
        max: 5
      color: 0x009000
      color2: 0x000090
      border:
        color: 0x004000
        color2: 0x000040
        size: 0.7
      hover_color: 0xCC0000
      indent: 5
      offset: 5
      hubex:
        color: 0xff5555
        border:
          color: 0xaa0000
      getdataex:
        color: 0x5555ff
        border:
          color: 0x0000aa

    grid:
      indient: 10
    element:
      border:
        color: 0xAAAAAA
        size: 1
      size: 32
      opacity: .25
      hover:
        opacity: .5
        time: 300
      color: 0xffffff
      glow:
        enable: true
        color: 0x00F000
        width: 5
        opacity: 0.5
      selected:
        color: 0xFFFF00

    icon:
      path: "hiasm/delphi/icon/"
      size: 24

    conf:
      path: "delphi_utf/conf/"


    link:
      color:
        vars: 0x0000FF
        events: 0xFF0000
        new_var: 0x3399FF
        new_event: 0xFF6600
        random: false
      glow:
        enable: true
        color: 0x00F000
        width: 5
        opacity: 0.5
      size: 1.5
      active_size: 3
      opacity: 0.7
      new_link_opacity: 1
      min_random_color: 0x777777
      pathArray: (start_x, start_y, stop_x, stop_y, type) ->

        xx = stop_x - start_x
        yy = stop_y - start_y

        x = Math.round(Math.abs(xx)/2)
        y = Math.round(Math.abs(yy)/2)

        if type <3
          if start_x > stop_x
            return [start_x,start_y, start_x+x,start_y, start_x+x, start_y+yy/2, start_x+xx-x,start_y+yy/2, stop_x-x, stop_y, stop_x, stop_y]
          else
            return [start_x, start_y, start_x+x, start_y, start_x+x, start_y, stop_x-x, stop_y, stop_x-10, stop_y, stop_x, stop_y]
        else
          if stop_y > start_y
            return [start_x, start_y, start_x,start_y-y,start_x+xx/2,start_y-y,start_x+xx/2,stop_y+yy/2,stop_x,stop_y+y,stop_x,stop_y]
          else
            return [start_x,start_y,start_x,start_y-y,stop_x,stop_y+y,stop_x,stop_y]
    paper:
      offset:
        x: 229
        y: 56
      size:
        width: 1019
        heigth: 895
      id: "scheme"
      contextmenu: false

    helper:
      color:
        fill: "khaki"
        text: "black"
    log:
      color: (backgroud = '#fff', color = '#000')-> "background: #{backgroud}; color: #{color};"

