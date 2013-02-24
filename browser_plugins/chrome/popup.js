// Copyright (c) 2013 Notion LLC. All rights reserved.

var fulfilist = {

 /**
  * Helper method to debug the window we're searching
  *
  * To view output Right-Click browers plugin and Inspect Popup
  *
  * @param {Tab}
  * @private
  */
  debug_: function() {
    var debugDiv = document.createElement("div");
    var debugContent = document.createTextNode(JSON.stringify(this), "hello");
    console.log(this);

    debugDiv.appendChild(debugContent);
    var taco = document.getElementById("taco");
    document.body.insertBefore(debugDiv, taco);
  },

  /**
   * Start the party
   *
   * @public
   */
  searchForProducts: function() {
    chrome.tabs.getCurrent(this.debug_)
  }

};

document.addEventListener('DOMContentLoaded', function () {
  fulfilist.searchForProducts();
});
