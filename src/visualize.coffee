graph_data = {}
graph_data["1"] = ["2", "3"]
graph_data["2"] = ["1", "4", "a"]
graph_data["3"] = ["1"]
graph_data["4"] = ["2"]
graph_data["a"] = ["2"]

graph = new Graph(graph_data, 1)

ed = new ExplorerDirector(graph, {})

# create an arr#ay with nodes
nodes = new vis.DataSet([
    {id: "1", label: '', color: {background: "limegreen", border: "black"}},
    {id: "2", label: '', color: {background: "white", border: "black"}},
    {id: "3", label: '', color: {background: "white", border: "black"}},
    {id: "4", label: '', color: {background: "white", border: "black"}},
    {id: "a", label: '', color: {background: "white", border: "black"}}
])

# create an array with edges
edges = new vis.DataSet([
    {id: "1-3", from: "1", to: "3"},
    {id: "1-2", from: "1", to: "2"},
    {id: "2-4", from: "2", to: "4"},
    {id: "2-a", from: "2", to: "a"}
])

# create a network
container = document.getElementById('mynetwork')

# provide the data in the vis format
data =
    nodes: nodes,
    edges: edges

edits = false

options = 
    edges: {color: "black", width: 3, chosen: false}
    #physics: {enabled: false}
    nodes: 
        borderWidth: 5
        borderWidthSelected: 1
        chosen: false
        #shape: "circle"
        font: {'face': 'Monospace', align: 'middle'}
    manipulation:
        addNode: ((data, callback)->
            # filling in the popup DOM elements
            data.label = ""
            callback(data)
            ed.updateGraph()
            ed.defaultBorderColor()
            ed.recolorUnvisitedNodes())
        editNode: ((data, callback)->
            # filling in the popup DOM elements
            callback(data)
            ed.updateGraph()
            ed.defaultBorderColor()
            ed.recolorUnvisitedNodes())
        addEdge: ((data, callback)->
            if data.from != data.to
                callback(data)
                ed.updateGraph())
    interaction: {hover: true, zoomView: false, navigationButtons: true}

# initialize your network!
network = new vis.Network(container, data, options)

network.on('click', (properties)->
    ids = properties.nodes
    clickedNodes = nodes.get(ids)
    handleClick(clickedNodes[0]))

network.on("hoverNode", (params)->
    network.canvas.body.container.style.cursor = 'pointer')
network.on("hoverEdge", (params)->
    network.canvas.body.container.style.cursor = 'pointer')
network.on("blurNode", (params)->
    network.canvas.body.container.style.cursor = 'default')
network.on("blurEdge", (params)->
    network.canvas.body.container.style.cursor = 'default')
init = ()->
    setDefaultLocale();
    draw();

ed.network = network
ed.updateGraph()
        
network.on('click', (properties)->
    ed.updateGraph()
    ed.defaultBorderColor()
    ed.recolorUnvisitedNodes()
    ids = properties.nodes
    clickedNodes = nodes.get(ids)
    handleClick(clickedNodes[0]))

nodeSelected = undefined
moveToken = false
handleClick = (clickedNode)->
    # This means we're double clicking
    
    if nodeSelected is undefined or clickedNode is undefined
        nodeSelected = clickedNode
    else if clickedNode.id is nodeSelected.id
        console.log("Double click: v" + nodeSelected.id)
        if moveToken
            setToken(nodeSelected.id, true)
    else
        nodeSelected = clickedNode

setToken = (dest, inGame=false)->
    unless dest?
        document.getElementById("selectNode").innerHTML = "Click a node to move the token"
        moveToken = true
    else
        document.getElementById("selectNode").innerHTML = ""
        moveToken = false
        ed.moveToken(dest, inGame)
    
