function setUpGraph() {
    const nodes = new vis.DataSet([
        { id: 1, label: "Node 1" },
        { id: 2, label: "Node 2" },
        { id: 3, label: "Node 3" },
    ]);
    const edges = new vis.DataSet([
        { from: 1, to: 2 },
        { from: 2, to: 3 },
        { from: 3, to: 1 },
    ]);

    let graph = undefined;
    const container = document.getElementById("graph");
    const data = { nodes, edges };
    const options = {
        manipulation: {
            enabled: true,
            addNode: false,
            deleteNode: false,
            addEdge: (data, callback) => {
                if (data.from !== data.to) {
                    callback(data);
                }
                graph.addEdgeMode();
            }
        }
    };

    graph = new vis.Network(container, data, options);
    graph.enableEditMode();

    return graph;
}

function updateDynamically(graph) {
    // Connects to the /messaging WebSocket endpoint to
    // dynamically update the graph with nodes.
    const ws = new WebSocket(`ws://${location.host}/messaging`);
    ws.addEventListener("message", ev => {
        const data = JSON.parse(ev.data);
        console.log(`Got ${JSON.stringify(data)}.`);
    });
}

window.addEventListener("load", () => {
    const graph = setUpGraph();
    updateDynamically(graph);
});
