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

    let network = undefined;
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
                network.addEdgeMode();
            }
        }
    };

    network = new vis.Network(container, data, options);
    network.enableEditMode();
}

window.addEventListener("load", () => {
    setUpGraph();
});
