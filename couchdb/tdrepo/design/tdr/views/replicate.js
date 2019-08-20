module.exports = {
  map: function(doc) {
    // For now looking for item_repository documents which need to be replicated
    if (doc.type && doc.type === "item_repository" && doc["replicate"]) {
      emit([doc.repository, doc.replicatepriority, doc.owner], null);
    }
  }
};
