# Bridgefy example

Demonstrates how to use the bridgefy plugin.

## Getting Started
To create a Bridgefy API KEY, follow these general steps:

* **Register for a Bridgefy account:** If you haven't already, sign up for a Bridgefy account on their website (https://developer.bridgefy.me).

* **Log in to the developer dashboard:** After registering, log in to your Bridgefy account and access the developer dashboard. The dashboard is where you can manage your API KEY and access other developer-related resources.

* **Generate an API KEY:** Once you've created a project, you should be able to generate an API KEY specific to that project. The API KEY is a unique identifier that allows you to use Bridgefy's services.

  **Only for this sample project**
  * Add the application id `me.bridgefy.android.sample` for Android.
  * Add the bundleId `me.bridgefy.ios.sample` for iOS.

* **Integrate the API KEY:** After generating the API KEY, you'll typically receive a KEY string. Integrate this KEY into your application or project to start using Bridgefy's messaging services.

  **Only for this sample project**

  Replace the text "YOUR_APIKEY" with a key generated from your account, the paths where it should be replaced are as follows:
>     example/android/app/src/main/AndroidManifest.xml
>
>     example/lib/config/environment.dart

* **Review the documentation:** As you integrate the API into your application, refer to the Bridgefy documentation and guides for information on how to use their API effectively. The documentation should include details on available endpoints, usage limits, and best practices.
  * Documentation: https://docs.bridgefy.me/
  * Github
    * [Android](https://github.com/bridgefy/sdk-android)
    * [iOS](https://github.com/bridgefy/sdk-ios)

___


This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
