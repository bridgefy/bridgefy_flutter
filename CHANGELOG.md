# Bridgefy Flutter 1.1.8
### BLUETOOTH MESH NETWORKS

Devices running your app create Bluetooth Low-Energy mesh networks, which work in large crowds, during and after natural disasters, and whenever else your users lose access to the Internet.

### SMART AND QUICK DISTRIBUTION

The Bridgefy algorithm makes sure information is distributed using the broadcast method, which increases the chances of content being delivered successfully, as opposed to the shortest-route method, which 
is fragile and unstable.

### SEAMLESS AND RESOURCE-EFFICIENT

All of your users participate in the mesh networks without having to provide any extra permissions, perform any actions, or even be aware of participating in traffic. Battery, storage, and processor are 
all taken

### Change Log Version 1.1.8

### Updated
- Upgraded Bridgefy SDK from 1.2.0 to 1.2.2.
- Added required Bluetooth permissions to support Android 12+ properly.
#### Changes in Android Manifest
Added missing permissions to ensure Bluetooth functionality:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

### Bug Fixes
- Fixed a crash related to missing **BLUETOOTH_ADMIN** permission reported in Play Store console.
