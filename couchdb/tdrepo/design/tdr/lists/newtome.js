module.exports = function(head, req) {
  send("{");
  var thisrepo = "";
  var melimit;
  if (req.query && req.query.me) thisrepo = req.query.me;
  if (req.query && req.query.melimit) melimit = parseInt(req.query.melimit);
  var rowcount = 0;
  var row;
  while ((!melimit || rowcount < melimit) && (row = getRow())) {
    if ("value" in row && Array.isArray(row.value)) {
      var repos = row.value[1];
      if (Array.isArray(repos) && repos.indexOf(thisrepo) > -1) continue;
      rowcount++;
      if (rowcount === 1) send('"rows": [\n');
      else send(",\n");
      send(toJSON(row));
    }
  }
  if (rowcount !== 0) send("\n]");
  return "}\n";
};
