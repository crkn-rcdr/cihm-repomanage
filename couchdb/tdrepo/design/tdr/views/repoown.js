module.exports = {
  map: function(doc) {
    if (doc.type && doc.type === "item_repository")
      emit([doc.repository, doc.owner], null);
  }
};
