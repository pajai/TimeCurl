#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

function selectTab(nb) {
  window.tabBar().buttons()[nb].tap();
  target.delay(1);
}

//window.logElementTree();


target.delay(3);
captureLocalizedScreenshot("1-LandingScreen");


selectTab(1);
captureLocalizedScreenshot("3-Report");


selectTab(2);
captureLocalizedScreenshot("5-Projects");


selectTab(0);
window.tableViews()[0].cells()[0].tap();
target.delay(3);

captureLocalizedScreenshot("4-Activity-Detail");


window.scrollViews()[0].buttons()["TimeButton"].tap();
target.delay(3);

captureLocalizedScreenshot("2-TimeSlot");


window.navigationBar().buttons()["Back"].tap();
target.delay(3);
window.navigationBar().buttons()["Back"].tap();
target.delay(3);



