module.exports = {
  map: function(doc) {
    if (doc.type) {
      if (doc.type === "item_repository")
        emit(doc.owner, [doc["manifest date"], doc.repository]);
      else if (doc.type === "item")
        emit(doc._id, [doc["manifest date"], "item"]);
    }
  },
  reduce: function(keys, values) {
    var maxdate;
    for (i = 0; i < values.length; i++) {
      if (!values[i] || values[i][0] === undefined) continue;
      if (!maxdate || values[i][0] > maxdate) {
        maxdate = values[i][0];
      }
    }
    if (maxdate) {
      var repolist = [];
      for (i = 0; i < values.length; i++) {
        if (!values[i] || values[i][0] === undefined) continue;
        if (values[i][0] === maxdate) repolist.push(values[i][1]);
      }
      if (repolist) return [maxdate, repolist];
    }
  }
};
