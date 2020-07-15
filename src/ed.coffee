# Helper function, returns random int in the range of [0, max)
getRandomInt = (max)->
    return Math.floor(Math.random() * Math.floor(max));

# Chooses random element of array
chooseRandom = (list, startIndex=0)->
    index = getRandomInt(list.length-startIndex) + startIndex
    return list[index]


# This class helps tie toghether the Graph class and the vis.js package
# as well as add functionality
class ExplorerDirector
    constructor: (@graph = new Graph(), @network, @tokenID)->
        @tokenID ?= @graph.vertices()[0]
        @visitedList = [@tokenID]
    
    # Boolean function: returns the "visited" state of a vertex
    hasBeenVisited: (vertex)-> @visitedList.indexOf(vertex) isnt -1
    
    # For the visual representation of the ED game.
    UNVISITED_COLOR = "white"
    VISITED_COLOR = "yellow"
    CURRENT_COLOR = TOKEN_COLOR = "limegreen"
    
    BORDER_COLOR = "black"
    VISIT_COLOR = "red"
    
    # Makes sure graph coresponds with vis.js network
    updateGraph: ()->
        @graph.clear()
        for node in @network.body.data.nodes.get()
            @graph.addVertex(node.id)
        
        # Now the nodes are all here, we can add edges
        for edge in @network.body.data.edges.get()
            @graph.addEdge(edge.from, edge.to)
        
        unless @graph.adjList[@tokenID]?
            @tokenID = Object.keys(@graph.adjList)[0]
            @visitedList.push(@tokenID) unless @hasBeenVisited(@tokenID)
            @setBackgroundColor(@tokenID, CURRENT_COLOR)
    
    # Changes the border color of a node
    setBorderColor: (nodeID, color)->
        node = @network.body.data.nodes.get(nodeID)
        delete node.x if node.x?
        delete node.y if node.y?
        if not node.color?
            node.color = {}
        node.color.border = color
        @network.body.data.nodes.update(node)
     
    # Changes the background color of a node
    setBackgroundColor: (nodeID, color)->
        node = @network.body.data.nodes.get(nodeID)
        delete node.x if node.x?
        delete node.y if node.y?
        if not node.color?
            node.color = {}
        node.color.background = color
        @network.body.data.nodes.update(node)
    
    # Makes sure the display represents visited states correctly
    recolorUnvisitedNodes: ()->
        for node in @network.body.data.nodes.get()
            if not node.color?
                node.color = {}
            else unless node.id is @tokenID or node.id in @visitedList
                @setBackgroundColor(node.id, UNVISITED_COLOR)
     
    # After the seePossibleMoves function, resets node border to black
    defaultBorderColor: ->
        # Uncolor old graphs 
        for vertex in @graph.vertices()
            @setBorderColor(vertex, BORDER_COLOR)
    
    # Reads from an element to get distance and parses
    getDistInput: ->
        distance = parseInt(document.getElementById("distInput").value)
        if isNaN(distance) or not (distance > 0)
            alert "Error: distance must be a positive integer"
        return distance
    
    # Given a start virtex and a distance (taken from getDistInput) this
    # function colors the vertices which are visitable at that distance
    seePossibleMoves: (startVertex=@tokenID)->
        ed.updateGraph()
        @defaultBorderColor()
        distance = @getDistInput()
        vertices = @canMoveList(startVertex, distance)
        for v in vertices
            @setBorderColor(v, VISIT_COLOR)
    
    # Clears the game's visited nodes and starts over from current pos
    newGame: ->
        ed.updateGraph()
        # Uncolor old graphs 
        for vertex of @graph.adjList
            @setBackgroundColor(vertex, UNVISITED_COLOR)
        @setBackgroundColor(@tokenID, TOKEN_COLOR)
        @visitedList = [@tokenID]
        document.getElementById("gameWon").innerHTML = ""
    
    # Given a vertex and a distance, gives the list of where the
    # director can move
    canMoveList: (vertex, distance) ->
        distances = @graph.distMatrix[vertex]
        ans = []
        for v of distances
            if distances[v] is distance
                ans.push(v)
        return ans
    
    # Moves the token position. If inGame is set to true, we act as if
    # this is the director moving the token, otherwise, we act as if
    # we're just modifying the game board
    moveToken: (dest, inGame=false)->
        ed.updateGraph()
        if inGame
            @setBackgroundColor(@tokenID, VISITED_COLOR)
        else
            @setBackgroundColor(@tokenID, UNVISITED_COLOR)
            @newGame()
        @tokenID = dest
        @visitedList.push(@tokenID) unless @hasBeenVisited(@tokenID)
        @setBackgroundColor(dest, CURRENT_COLOR)
        if @gameFinished()
            document.getElementById("gameWon").innerHTML = "Game Over"
        else
            document.getElementById("gameWon").innerHTML = ""
    
    # The director makes a random move based on the distance given in
    # getDistInput. If basicLogic is true, the director will never visit
    # a new vertex in one move unless forced.
    directorMoveRandom: (basicLogic=false)->
        ed.updateGraph()
        @defaultBorderColor()
        distance = @getDistInput()
        vertices = @canMoveList(@tokenID, distance)
        if vertices.length is 0 or not vertices.length?
            throw "Invalid distance"
        destination = chooseRandom(vertices)
        if basicLogic # Try to limit move to vertices already visited
            for vertex in vertices
                if @hasBeenVisited(vertex)
                    destination = vertex
        @moveToken(destination, true)
    
    # Essentially the explorer gives a random (valid) distance for the
    # director. Currently unfinished, basicLogic currently does nothing.
    explorerChooseRandom: (basicLogic=false)->
        ed.updateGraph()
        @defaultBorderColor()
        distances = @graph.distances(@tokenID)
        options = []
        for vertex of distances
            currentDist = distances[vertex]
            if currentDist isnt 0
                if options.indexOf(currentDist) is -1
                    options.push(currentDist)
        distance = chooseRandom(options)
        return distance
    
    # Checks if, in one move, the explorer can force the director from
    # some node in a given set (nodesVisited) to an unvisited node.
    canForceNode: (nodesVisited = @visitedList, tokenPos = @tokenID)->
        distances = @graph.distMatrix[tokenPos]
        for dist in Object.values(distances)
            if dist isnt 0
                moveList = @canMoveList(tokenPos, dist, distances)
                canForce = true
                index = 0
                while index < moveList.length and canForce
                    if moveList[index] in nodesVisited
                        canForce = false
                    index++
                if canForce
                    return true
        return false
    
    # Checks if the explorer can increase the score if both players are
    # at optimal gameplay from this point on
    gameFinished: (nodesVisited = @visitedList.slice(), tokenPos = @tokenID)->
        if @canForceNode(nodesVisited, tokenPos)
            return false
        for node in nodesVisited
            if node isnt tokenPos and @canForceNode(nodesVisited, node)
                nodesVisited.splice(nodesVisited.indexOf(node), 1)
                return @gameFinished(nodesVisited, tokenPos)
        return true
    
    # BROKEN: uses the minimax algorithm to determine the end score of
    # the game under optimal play. It works okay-ish now, but I need to
    # implement a method of restricting duplicate game states.
    minimax: (nodesVisited, tokenID, expChoice=0, maxDepth, maxPlayer)->
        if maxDepth is 0
            return (new Set(nodesVisited)).size
        if maxPlayer and @gameFinished(nodesVisited.slice(), tokenID)
            return (new Set(nodesVisited)).size
        if maxPlayer
            value = -Infinity
            distances = @graph.distMatrix[tokenID]
            for dist in Object.values(distances)
                value = Math.max(value, @minimax(nodesVisited, tokenID, dist, maxDepth-1, false))
            return value
        else # minPlayer
            value = Infinity
            for node in @canMoveList(tokenID, expChoice)
                nodesVisited.push(node) 
                value = Math.min(value, @minimax(nodesVisited, node, expChoice, maxDepth-1, true))
                nodesVisited.pop() 
            return value
    
                
