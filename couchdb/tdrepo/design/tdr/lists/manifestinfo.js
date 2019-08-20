module.exports = function(head, req) {
  // Filters to only send a few specific keys as value with key being AIP
  send("{\n");
  var row;
  var rowcount = 0;
  while ((row = getRow())) {
    var filtered = {
      pool: row.doc["pool"],
      "manifest date": row.doc["manifest date"],
      "manifest md5": row.doc["manifest md5"]
    };
    rowcount++;
    if (rowcount > 1) send(",\n");
    send('"' + row.doc["owner"] + '":' + toJSON(filtered));
  }
  return "\n}\n";
};
