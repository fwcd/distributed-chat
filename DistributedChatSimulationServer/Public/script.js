function lookupEdge(from, to, edges) {
    return edges.get().find((({ f, t }) => (f === from && t === to) || (t === from && f == to)));
}

function setUpGraph() {
    const nodes = new vis.DataSet([]);
    const edges = new vis.DataSet([]);

    const ws = updateDynamically(nodes);

    let graph = undefined;
    const container = document.getElementById("graph");
    const data = { nodes, edges };
    const options = {
        manipulation: {
            enabled: true,
            addNode: false,
            deleteNode: false,
            addEdge: (data, callback) => {
                const exists = lookupEdge(data.from, data.to, edges);
                if (data.from !== data.to && !exists) {
                    // We add the edge first once the server has confirmed it
                    // callback(data);
                    ws.send(JSON.stringify({
                        type: "addLink",
                        data: {
                            fromUUID: data.from,
                            toUUID: data.to
                        }
                    }));
                }
                graph.addEdgeMode();
            },
            deleteEdge: (data, callback) => {
                // We remove the edge first once the server has confirmed it
                // callback(data);
                ws.send(JSON.stringify({
                    type: "removeLink",
                    data: {
                        fromUUID: data.from,
                        toUUID: data.to
                    }
                }));
            }
        }
    };

    graph = new vis.Network(container, data, options);
    graph.enableEditMode();
}

function updateDynamically(nodes) {
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
    return ws;
}

window.addEventListener("load", () => {
    setUpGraph();
});
