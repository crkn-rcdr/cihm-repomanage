module.exports = {
  map: function (doc) {
    // Create per-repository sorted map of verified dates
    if (doc.type && doc.type === "item_repository" && !doc["replicate"]) {
      emit([doc.repository, doc["verified date"]], doc.owner);
    }
  },
  reduce: "_count",
};
