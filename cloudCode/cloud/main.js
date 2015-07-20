// Takes in User's current PFGeopoint and distance bound 
// as parameters and outputs a list of User IDs that are
// within the area.
Parse.Cloud.define("findUsers", function(request, response) {
  var currloc = request.params.loc;
  var bound = request.params;

  var profileQuery = new Parse.Query("Profiles");
  profileQuery.limit(1000);

  var nearbyUserIDList = [];

  profileQuery.find({
  	success: function(results) {
  		// returns a list of all current users		
  		for (var i = 0; i < results.length; i++) {
  			var object = results[i];

  			var geopoint = results.get("Location"); // PFGeoPoint of other user's most recent location
  			var dist = currloc.kilometersTo(geopoint);

  			if (dist <= bound){
  				nearbyUserIDList.push(object.id);
  			}

  		}
  	},
  	error: function(error) {
         alert("Error: " + error.code + " " + error.message);
    }
  });
});
