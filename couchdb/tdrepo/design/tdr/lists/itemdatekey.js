module.exports = function(head, req) {
  send("[");
  var row = getRow();
  if (row) {
    send('"' + row.key[4] + '"');
    while ((row = getRow())) {
      send(',"' + row.key[4] + '"');
    }
  }
  send("]\n");
};
