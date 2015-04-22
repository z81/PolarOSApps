app = angular.module 'app', ['ngCookies']

app.controller 'mainCtrl', ($scope, $http, $timeout)->
  $scope.menu =
    logo: 'assets/images/logo.png'
    items: [
      {
        name: 'Схемы'
        url: '#'
      }
      {
        name: 'Люди'
        url: '#'
      }
      {
        name: 'Сообщества'
        url: '#'
      }
      {
        name: 'Обсуждения'
        url: '#'
      }
      {
        name: 'Настройки'
        url: '#'
      }
    ]


  $scope.showMessage = (msg = '', type = 'success', time = 10000)->
    $('.message').slideDown()
    $timeout(->
      $('.message').slideUp()
    ,time)

  $timeout(->
    $scope.showMessage()
  ,3000)


  $scope.closeContainer = ()->
    Scheme.closeContainer()



  $scope.addElement = (name)->
    id = 0
    $scope.scheme.createElement {Name: name, Id: id, X: 300, Y: 100}


  $scope.$watch 'element_search', ->
    $timeout -> $scope.bindAccordionEvents()

  $http(method: 'GET', url: 'hiasm/delphi_utf/Elements_list.txt').success (data, status, headers, config)->
    $scope.elements = data;
    $timeout -> $scope.bindAccordionEvents().eq(0).click()

  $scope.bindAccordionEvents = ->
    return `jQuery('.js-accordion-trigger').not('.isbinded')
    .on('click', function(){
                                jQuery(this).parent().find('ul').slideToggle('fast');
                                jQuery(this).parent().toggleClass('is-expanded');
                                if(event)
                                  event.preventDefault();
       })
    .addClass('isbinded')
      `



  $scope.onSelectElement = ->
    $timeout ->
      console.log Scheme.selected_element.Property
      $scope.props = Scheme.selected_element.Property

  $http({method: 'GET', url: 'assets/schemes/Notepad.sha'}).success (data, status, headers, config)->
    $scope.scheme = new Scheme()
    $scope.scheme.load data

app.controller 'panelCtrl', ($scope, $cookieStore)->
  $scope.elements_panel_pin  = $cookieStore.get 'elements_panel_pin'
  $scope.elements_panel_open = $cookieStore.get 'elements_panel_open'
  $scope.props_panel_pin     = $cookieStore.get 'props_panel_pin'
  $scope.props_panel_hidden  = $cookieStore.get 'props_panel_hidden'


  $scope.elements_panel_open = true if $scope.elements_panel_pin
  $scope.props_panel_hidden  = true if $scope.props_panel_pin

  $scope.togglePanelPin = (name)->
    $scope[name] = !$scope[name]
    $cookieStore.put name, $scope[name]

  $scope.togglePanel = (name)->
    $scope[name] = !$scope[name]
    $cookieStore.put name, $scope[name]

app.directive 'navigation', -> templateUrl: 'assets/views/navigation.html'
app.directive 'footer', -> templateUrl: 'assets/views/footer.html'
app.directive 'scrollPosition', ($window)->
    scope: {scroll: '=scrollPosition'},
    link: (scope, element, attrs)->
      windowEl = angular.element($window)
      handler = ->
        scope.scroll = windowEl.scrollTop()


      windowEl.on 'scroll', scope.$apply.bind scope, handler
      handler()





angular.bootstrap document, ['app']