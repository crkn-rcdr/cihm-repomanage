module.exports = {
  map: function(doc) {
    // For now looking for item_repository documents for 'toma' (Repo in Toronto), but once HammerTime will look at item documents
    if (
      doc.type &&
      doc.type === "item_repository" &&
      doc.repository &&
      doc.repository === "toma" &&
      doc["manifest date"]
    ) {
      // Seems that Date.parse doesn't support this RFC 3339 date format, so using regexp
      var mandateParse = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z$/;
      var parsedate = mandateParse.exec(doc["manifest date"]);
      if (parsedate) {
        // first element is the string again, so get rid of it and emit array with each matched element
        parsedate.shift();
        emit(parsedate, null);
      }
    }
  }
};
