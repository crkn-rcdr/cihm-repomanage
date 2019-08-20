module.exports = {
  map: function(doc) {
    if (doc.type && doc.type === "item_repository" && doc["manifest md5"]) {
      emit([doc.owner, doc["manifest md5"], doc.repository], null);
    }
  }
};
