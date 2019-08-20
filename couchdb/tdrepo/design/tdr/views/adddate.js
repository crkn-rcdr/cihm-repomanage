module.exports = {
  map: function(doc) {
    if (doc.type && doc.type === "item_repository" && doc["add date"]) {
      // Seems that Date.parse doesn't support this RFC 3339 date format, so using regexp
      var adddateParse = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(\..*|Z)$/;
      var parsedate = adddateParse.exec(doc["add date"]);
      if (parsedate) {
        // first element is the string again, so get rid of it and emit array with each matched element
        parsedate.shift();
        // Only keep day, month, year, hour
        // (Remove minutes, seconds, Timezone character/parts of seconds)
        parsedate.splice(4, 3);
        // Add in the uid, so we can get a list of these starting from a time
        parsedate.push(doc.owner);
        emit(parsedate, null);
      }
    }
  }
};
