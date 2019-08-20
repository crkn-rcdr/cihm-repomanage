module.exports = function(head, req) {
  var row = getRow();
  if (!row) {
    return "no ingredients";
  }
  send(row.key + "\n");
  while ((row = getRow())) {
    send(row.key + "\n");
  }
};
