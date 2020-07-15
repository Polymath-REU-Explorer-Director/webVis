# Basic class to implement graphs and graph operations
class Graph
    constructor: (@adjList = {})->
        @distMatrix = {}
        @floydWarshall()
    
    # clears the graph
    clear: ()->
        @adjList = {}
    
    # Returns an array of each vertex
    vertices: -> (key for key of @adjList)
    
    # Returns true if v1--v2 is an edge, false otherwise.
    isEdge: (v1, v2) ->
        return (v2 in @adjList[v1])
    
    # Adds a vertex if it is not already in the vertex set
    addVertex: (vertex) ->
        if not @adjList[vertex]?
            @adjList[vertex] = []
            # We have to update the distances matrix
            @floydWarshall()
            
    # Adds an edge if it is not already in the edge set
    addEdge: (v1, v2) ->
        if (v1 isnt v2) and @adjList[v1]? and @adjList[v2]?
            @adjList[v1].push(v2) unless v2 in @adjList[v1]
            @adjList[v2].push(v1) unless v1 in @adjList[v2]
            # We have to update the distances matrix
            @floydWarshall()
    
    # Removes an edge from the graph
    removeEdge: (v1, v2) ->
        index1 = @adjList[v1].indexOf(v2)
        if index1 isnt -1
            @adjList[v1].splice(index1, 1)
        index2 = @adjList[v2].indexOf(v1)
        if index isnt -1
            @adjList[v2].splice(index2, 1)
        if index1 isnt -1 or index2 isnt -1
            # We have to update the distances matrix
            @floydWarshall()
            
    # Removes a vertex from the graph and all edges which were adj to
    # that vertex
    removeVertex: (vertex) ->
        @adjList[vertex] = undefined
        delete @adjList[vertex]
        for v of @adjList
            index = @adjList[v].indexOf(vertex)
            if index isnt -1
                console.log(v)
                @adjList[v].splice(index, 1)
        # We have to update the distances matrix
        @floydWarshall()
    
    # performs the Floyd-Warshal algorithm. No longer in use.
    floydWarshall: ()->
        @distMatrix = {}
        for v1 of @adjList
            @distMatrix[v1] ?= {}
            for v2 of @adjList
                if v1 is v2
                    @distMatrix[v1][v2] = 0
                else if @adjList[v1].indexOf(v2) isnt -1
                    @distMatrix[v1][v2] = 1
                else
                    @distMatrix[v1][v2] = Infinity
        for v1 of @adjList
            for v2 of @adjList
                for v3 of @adjList
                    if @distMatrix[v2][v3] > @distMatrix[v2][v1] + @distMatrix[v1][v3] 
                        @distMatrix[v2][v3] = @distMatrix[v2][v1] + @distMatrix[v1][v3]
        return null
    
    # Uses Dijkstra's algorithm to get the list of distances
    distances: (start) ->
        dist = {}
        prev = {}
        
        Q = []
        
        for vertex of @adjList
            dist[vertex] = Infinity
            # prev[vertex] = undefined
            Q.push(vertex)
        dist[start] = 0
        
        while Q.length > 0
            # Get current closest vertex in Q
            cIndex = 0
            for index in Q
                if dist[Q[index]] < dist[Q[cIndex]]
                    cIndex = index
            
            # remove cIndex from Q 
            u = Q[cIndex]
            Q.splice(cIndex, 1)
            
            for vertex in @adjList[u]
                if true
                    alt = dist[u] + 1
                    if alt < dist[vertex]               
                        dist[vertex] = alt
                        # prev[vertex] = u
        return dist
