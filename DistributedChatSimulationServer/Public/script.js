function lookupEdge(from, to, edges) {
    return edges.get().find((({ from: f, to: t }) => (f === from && t === to) || (t === from && f == to)));
}

function updateDynamically(nodes, edges) {
    // Connects to the /messaging WebSocket endpoint to
    // dynamically update the graph with nodes.
    const ws = new WebSocket(`ws://${location.host}/messaging`);

    ws.addEventListener("open", () => {
        ws.send(JSON.stringify({type: "observe"}));
    });

    ws.addEventListener("message", ev => {
        const message = JSON.parse(ev.data);
        console.log(`Got ${JSON.stringify(message)}.`);

        switch (message.type) {
        case "helloNotification":
            const angle = 2 * Math.PI * Math.random();
            const radius = 0.2;
            nodes.add({ id: message.data.uuid, label: message.data.name, x: Math.cos(angle) * radius, y: Math.sin(angle) * radius });
            break;
        case "goodbyeNotification":
            nodes.remove(message.data.uuid);
            break;
        case "addLinkNotification":
            edges.add({ from: message.data.fromUUID, to: message.data.toUUID });
            break;
        case "removeLinkNotification":
            const edge = lookupEdge(message.data.fromUUID, message.data.toUUID, edges);
            if (edge) {
                edges.remove(edge.id);
            }
            break;
        case "broadcast":
            // TODO
            break;
        default:
            break;
        }
    });

    return ws;
}

function setUpGraph() {
    const nodes = new vis.DataSet([]);
    const edges = new vis.DataSet([]);

    const ws = updateDynamically(nodes, edges);

    let graph = undefined;
    const container = document.getElementById("graph");
    const data = { nodes, edges };
    const options = {
        manipulation: {
            enabled: true,
            addNode: false,
            deleteNode: false,
            addEdge: (edge, callback) => {
                const exists = lookupEdge(edge.from, edge.to, edges);
                if (edge.from !== edge.to && !exists) {
                    // We add the edge first once the server has confirmed it
                    // callback(data);
                    ws.send(JSON.stringify({
                        type: "addLink",
                        data: {
                            fromUUID: edge.from,
                            toUUID: edge.to
                        }
                    }));
                }
            },
            deleteEdge: (data, callback) => {
                // We remove the edge first once the server has confirmed it
                // callback(data);
                for (const id of data.edges) {
                    const edge = edges.get(id);
                    ws.send(JSON.stringify({
                        type: "removeLink",
                        data: {
                            fromUUID: edge.from,
                            toUUID: edge.to
                        }
                    }));
                }
            }
        },
        physics: {
            solver: "forceAtlas2Based",
            forceAtlas2Based: {
                damping: 0.4
            }
        }
    };

    graph = new vis.Network(container, data, options);
    graph.enableEditMode();

    edges.on("*", () => {
        graph.enableEditMode();
    });
}

window.addEventListener("load", () => {
    setUpGraph();
});