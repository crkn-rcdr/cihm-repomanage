module.exports = {
  map: function(doc) {
    if (doc.type) {
      if (doc.type === "item_repository")
        emit(doc.owner, [doc["manifest date"], doc.repository]);
      else if (doc.type === "item")
        emit(doc._id, [doc["manifest date"], "item"]);
    }
  },
  reduce: function(keys, values, rereduce) {
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
        if (values[i][0] === maxdate) {
          var myvalue=values[i][1];
          // If this is a rereduce, then the value will already be an array
          if (Array.isArray(myvalue)) {
            repolist=repolist.concat(myvalue);
          } else {
            repolist.push(myvalue);
          };
        }
      }
      if (repolist) return [maxdate, repolist];
    }
  }
};
