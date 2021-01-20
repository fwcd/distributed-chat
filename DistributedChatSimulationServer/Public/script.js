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

    const container = document.getElementById("graph");
    const data = { nodes, edges };
    const options = {};

    new vis.Network(container, data, options);
}

window.addEventListener("load", () => {
    setUpGraph();
});
