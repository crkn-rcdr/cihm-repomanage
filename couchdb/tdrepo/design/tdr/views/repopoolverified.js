module.exports = {
  map: function(doc) {
    // Create per-repository,per-pool sorted map of verified dates
    if (doc.type && doc.type === "item_repository") {
      emit([doc.repository, doc.pool, doc["verified date"]], doc.owner);
    }
  }
};
