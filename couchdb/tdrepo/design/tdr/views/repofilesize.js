module.exports = {
  map: function(doc) {
    // For now looking for item_repository documents which have a filesize
    if (doc.type && doc.type === "item_repository" && doc["filesize"]) {
      var filesize = parseInt(doc["filesize"]);
      if (filesize > 0) {
        var uid = doc["owner"].split(".");
        emit([doc.repository, uid[0], doc.pool, uid[1]], filesize);
      }
    }
  }
};
