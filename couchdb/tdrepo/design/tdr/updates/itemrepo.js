module.exports = function(doc, req) {
  var nowdate = new Date();
  // Javascript toISOString() includes parts of a second, which we strip.
  var nowdates = nowdate.toISOString().replace(/\..*Z/, "Z");
  var updated = false;
  if (!doc) {
    if ("id" in req && req["id"]) {
      // create new document
      doc = {};
      myid = req["id"];
      var idsplit = myid.split("|item_repository.");
      doc["owner"] = idsplit[0];
      doc["repository"] = idsplit[1];
      if (!doc["repository"] || !doc["owner"]) {
        return [null, '{"error": "Bad ID: ' + myid + '"}\n'];
      }
      doc["_id"] = req["id"];
      doc["type"] = "item_repository";
      doc["document date"] = nowdates;
      updated = true;
    } else {
      // change nothing in database
      return [null, '{"error": "Missing ID"}\n'];
    }
  }
  if ("form" in req) {
    var updatedoc = req.form;
    if ("verified date" in updatedoc) {
      doc["verified date"] = updatedoc["verified date"];
      updated = true;
    }
    if ("verified" in updatedoc) {
      doc["verified date"] = nowdates;
      updated = true;
    }
    if ("filesize" in updatedoc) {
      doc["filesize"] = updatedoc["filesize"];
      updated = true;
    }
    if ("pool" in updatedoc) {
      doc["pool"] = updatedoc["pool"];
      updated = true;
    }
    if ("manifest date" in updatedoc) {
      doc["manifest date"] = updatedoc["manifest date"];
      doc["add date"] = nowdates;
      updated = true;
    }
    if ("manifest md5" in updatedoc) {
      doc["manifest md5"] = updatedoc["manifest md5"];
      doc["add date"] = nowdates;
      delete doc["replicate"];
      delete doc["replicatepriority"];
      // transitional
      delete doc["priority"];
      updated = true;
    }
    // Replicate parameter is also the priority
    if ("replicate" in updatedoc) {
      if (updatedoc["replicate"] === "false") {
        delete doc["replicate"];
        delete doc["replicatepriority"];
      } else {
        // Only change priority if unset or 'force' set
        if ("force" in updatedoc || !("replicatepriority" in doc)) {
          doc["replicatepriority"] = updatedoc["replicate"].concat(
            ":",
            nowdates
          );
        }
        doc["replicate"] = "true";
      }
      updated = true;
    }
    // We are transitioning from an older field to a new...
    // Setting of priority was separate
    if ("priority" in updatedoc) {
      doc["priority"] = updatedoc["priority"];
      updated = true;
    }
  }
  if (updated) {
    return [doc, '{"return": "update"}\n'];
  } else {
    return [null, '{"return": "no update"}\n'];
  }
};
