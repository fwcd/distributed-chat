function setUpGraph() {
    const nodes = new vis.DataSet([]);
    const edges = new vis.DataSet([]);

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

    return [nodes, graph];
}

function updateDynamically(nodes, graph) {
    // Connects to the /messaging WebSocket endpoint to
    // dynamically update the graph with nodes.
    const ws = new WebSocket(`ws://${location.host}/messaging`);
    ws.addEventListener("message", ev => {
        const message = JSON.parse(ev.data);
        console.log(`Got ${JSON.stringify(message)}.`);

        switch (message.type) {
        case "helloNotification":
            nodes.add({ id: message.data.uuid, label: message.data.name });
            break;
        case "goodbyeNotification":
            nodes.remove(message.data.uuid);
            break;
        default:
            break;
        }
    });
}

window.addEventListener("load", () => {
    const [nodes, graph] = setUpGraph();
    updateDynamically(nodes, graph);
});
