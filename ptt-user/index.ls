main = ($scope, $sce) ->
  $scope.open = (href) ->
    $scope.iframehref = $sce.trustAsResourceUrl "http://ptt.cc/bbs/Gossiping/#{href}.html"
    console.log $scope.iframehref
    #console.log \ok
    set-timeout (-> $(\#postcontent)modal \show), 0
  $scope.click = (id) ->
    $scope.target = id
    $scope.post = $scope.data.relate[id]
  (d) <- d3.json \suspect.json
  <- $scope.$apply
  $scope.data = d 
  $scope.suspect = d.suspect.filter(-> it.1 > 100)sort (a,b) -> b.1 - a.1

