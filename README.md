# drivesafe

This is the submission app for the 2022 Congressional App Challenge Distric 03 Arkansas

## Getting Started

In order to excute this project you will need to have the following requirements :  <br />
      &emsp;- Flutter 2.0 SDK installed <br />
      &emsp;- Android Device <br />
        &emsp;- Application will not work on emulators <br />
      &emsp;- Required API Keys :  <br />
        &emsp;- Google Maps API Key <br />
        &emsp;- Firebase API Key <br />
        &emsp;- TomTom API Key <br />
          &emsp;- Enabled Services :  <br />
            &emsp;- Reverse GeoCoding <br />
            &emsp;- Traffic Flow Monitoring <br />
        &emsp;- OpenWeatherMap API Key <br />
          &emsp;- Note : API Key for the "5 Day / 3 Hour Forecast" API <br />
        &emsp;- GeoApify API Key <br />
      &emsp;- The API Keys have to be updated in the following files :  <br />
        &emsp;- android/app/src/main/AndroidManifest.xml <br />
        &emsp;- lib/chooseCurrentLocation2.dart <br />
        &emsp;- lib/pages/addLocation.dart <br />
        &emsp;- lib/pages/chooseCurrentLocation.dart <br />
        &emsp;- lib/pages/drivingScreen.dart <br />
        &emsp;- lib/pages/sendNotification.dart <br />
        &emsp;- NOTE : Replace text "Insert API Key Here" with your API Key in code <br />

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

<a href="https://www.freepik.com/free-vector/red-triangle-warning-sign-vector-art-illustration_18379821.htm#query=warning&position=6&from_view=search">Image by mamewmy</a> on Freepik<a href="https://www.flaticon.com/free-icons/mask" title="mask icons">Mask icons created by Freepik - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/eye" title="eye icons">Eye icons created by Flat Icons - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/speed" title="speed icons">Speed icons created by Freepik - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/road-closed" title="road closed icons">Road closed icons created by Freepik - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/museum" title="museum icons">Museum icons created by Freepik - Flaticon</a><a href="https://www.flaticon.com/free-icons/accelerate" title="accelerate icons">Accelerate icons created by Smashicons - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/later" title="later icons">Later icons created by Flat Icons - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/village" title="village icons">Village icons created by Freepik - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/finish" title="finish icons">Finish icons created by Freepik - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/start" title="start icons">Start icons created by Freepik - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/autonomous-car" title="autonomous car icons">Autonomous car icons created by srip - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/breaks" title="breaks icons">Breaks icons created by Smashicons - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/slow" title="slow icons">Slow icons created by Freepik - Flaticon</a>
<a href="https://www.flaticon.com/free-icons/accident" title="accident icons">Accident icons created by itim2101 - Flaticon</a>

problem causing area key map

Drowsy = 1
Blinking = 2
Speeding = 3
Decleration = 4
Crash = 5

TO-DO

fix the time error on the map screen
