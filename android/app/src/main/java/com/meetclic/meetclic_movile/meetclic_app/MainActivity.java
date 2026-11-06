package com.meetclic.meetclic_movile;
import android.Manifest;
import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.location.LocationManager;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "YapitaBluetooth";
    private static final String CHANNEL =
            "pos/printer_bluetooth_classic";

    private static final long SCAN_TIMEOUT_MS = 12000;
    private static final long PAIR_TIMEOUT_MS = 60000;

    private final Handler handler =
            new Handler(Looper.getMainLooper());

    private final Map<String, BluetoothDevice> discoveredDevices =
            new LinkedHashMap<>();

    private MethodChannel.Result scanResult;
    private MethodChannel.Result pairResult;
    private String pairingAddress;

    private boolean receiverRegistered = false;
    private boolean scanStarted = false;
    private Runnable pendingScanStart;

    private final Runnable scanTimeout = () -> {
        if (scanResult != null) {
            Log.w(TAG, "SCAN_TIMEOUT found=" + discoveredDevices.size());
            stopDiscoverySafely();
            finishScan();
        }
    };

    private final Runnable pairTimeout = () -> {
        if (pairResult != null) {
            finishPairError(
                    "PAIR_TIMEOUT",
                    "Se agotó el tiempo de emparejamiento"
            );
        }
    };

    // ==========================================
    // BLUETOOTH RECEIVER
    // ==========================================

    private final BroadcastReceiver bluetoothReceiver =
            new BroadcastReceiver() {

                @Override
                public void onReceive(
                        Context context,
                        Intent intent
                ) {
                    String action = intent.getAction();

                    if (BluetoothDevice.ACTION_FOUND.equals(action)) {

                        BluetoothDevice device =
                                getIntentDevice(intent);

                        if (device != null && scanResult != null && scanStarted) {
                            Log.d(TAG, "ACTION_FOUND address=" + device.getAddress());
                            discoveredDevices.put(
                                    device.getAddress(),
                                    device
                            );
                        }

                    } else if (
                            BluetoothAdapter.ACTION_DISCOVERY_FINISHED
                                    .equals(action)
                    ) {
                        Log.d(TAG, "ACTION_DISCOVERY_FINISHED started=" + scanStarted
                                + " pending=" + (scanResult != null));
                        if (scanResult != null && scanStarted) {
                            finishScan();
                        }

                    } else if (
                            BluetoothDevice.ACTION_BOND_STATE_CHANGED
                                    .equals(action)
                    ) {
                        handleBondStateChanged(intent);
                    }
                }
            };

    // ==========================================
    // FLUTTER ENGINE
    // ==========================================

    @Override
    public void configureFlutterEngine(
            @NonNull FlutterEngine flutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine);

        registerBluetoothReceiver();

        new MethodChannel(
                flutterEngine.getDartExecutor()
                        .getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {

            Log.d(TAG, "METHOD_CALL method=" + call.method);
            try {
                switch (call.method) {

                    case "getBluetoothStatus":
                        result.success(getBluetoothStatus());
                        break;

                    case "openBluetoothSettings":
                        Log.d(TAG, "OPEN_BLUETOOTH_SETTINGS");
                        startActivity(new Intent(Settings.ACTION_BLUETOOTH_SETTINGS));
                        result.success(true);
                        break;

                    case "openLocationSettings":
                        Log.d(TAG, "OPEN_LOCATION_SETTINGS");
                        startActivity(new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS));
                        result.success(true);
                        break;

                    case "openAppSettings":
                        Intent appSettings = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                        appSettings.setData(android.net.Uri.parse("package:" + getPackageName()));
                        Log.d(TAG, "OPEN_APP_SETTINGS");
                        startActivity(appSettings);
                        result.success(true);
                        break;

                    case "scan":
                        startScan(result);
                        break;

                    case "getBondedDevices":
                        result.success(getBondedDevices());
                        break;

                    case "pair":
                        String pairAddress =
                                call.argument("address");

                        if (pairAddress == null ||
                                pairAddress.trim().isEmpty()) {
                            result.error(
                                    "INVALID_ADDRESS",
                                    "Dirección Bluetooth requerida",
                                    null
                            );
                        } else {
                            pairDevice(pairAddress, result);
                        }
                        break;

                    case "details":
                        String detailsAddress =
                                call.argument("address");

                        if (detailsAddress == null ||
                                detailsAddress.trim().isEmpty()) {
                            result.error(
                                    "INVALID_ADDRESS",
                                    "Dirección Bluetooth requerida",
                                    null
                            );
                        } else {
                            result.success(
                                    getDeviceDetails(detailsAddress)
                            );
                        }
                        break;

                    default:
                        result.notImplemented();
                }

            } catch (SecurityException e) {
                Log.e(TAG, "METHOD_PERMISSION_ERROR method=" + call.method, e);
                result.error(
                        "PERMISSION_DENIED",
                        e.getMessage(),
                        null
                );

            } catch (Exception e) {
                Log.e(TAG, "METHOD_ERROR method=" + call.method, e);
                result.error(
                        "BLUETOOTH_ERROR",
                        e.getMessage(),
                        null
                );
            }
        });
    }

    // ==========================================
    // RECEIVER
    // ==========================================

    private void registerBluetoothReceiver() {
        if (receiverRegistered) return;

        Log.d(TAG, "REGISTER_RECEIVER");
        IntentFilter filter = new IntentFilter();

        filter.addAction(BluetoothDevice.ACTION_FOUND);
        filter.addAction(
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED
        );
        filter.addAction(
                BluetoothDevice.ACTION_BOND_STATE_CHANGED
        );

        if (Build.VERSION.SDK_INT >= 33) {
            registerReceiver(
                    bluetoothReceiver,
                    filter,
                    Context.RECEIVER_EXPORTED
            );
        } else {
            registerReceiver(bluetoothReceiver, filter);
        }

        receiverRegistered = true;
    }

    // ==========================================
    // PERMISSIONS
    // ==========================================

    private void checkConnectPermission() {
        if (Build.VERSION.SDK_INT >= 31 &&
                checkSelfPermission(
                        Manifest.permission.BLUETOOTH_CONNECT
                ) != PackageManager.PERMISSION_GRANTED) {

            throw new SecurityException(
                    "Se requiere BLUETOOTH_CONNECT"
            );
        }
    }

    private void checkScanPermission() {
        if (Build.VERSION.SDK_INT >= 31) {

            if (checkSelfPermission(
                    Manifest.permission.BLUETOOTH_SCAN
            ) != PackageManager.PERMISSION_GRANTED) {

                throw new SecurityException(
                        "Se requiere BLUETOOTH_SCAN"
                );
            }

        } else {

            if (checkSelfPermission(
                    Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED) {

                throw new SecurityException(
                        "Se requiere permiso de ubicación"
                );
            }
        }
    }

    // ==========================================
    // ADAPTER
    // ==========================================

    @SuppressLint("MissingPermission")
    private BluetoothAdapter requireAdapter() {
        checkConnectPermission();

        BluetoothManager manager =
                (BluetoothManager) getSystemService(
                        Context.BLUETOOTH_SERVICE
                );

        BluetoothAdapter adapter =
                manager != null
                        ? manager.getAdapter()
                        : null;

        if (adapter == null) {
            throw new IllegalStateException(
                    "Este dispositivo no tiene Bluetooth"
            );
        }

        if (!adapter.isEnabled()) {
            throw new IllegalStateException(
                    "Bluetooth está desactivado"
            );
        }

        return adapter;
    }
    private boolean isLocationEnabled() {
        LocationManager manager =
                (LocationManager) getSystemService(
                        Context.LOCATION_SERVICE
                );

        if (manager == null) {
            return false;
        }

        if (Build.VERSION.SDK_INT >= 28) {
            return manager.isLocationEnabled();
        }

        return manager.isProviderEnabled(
                LocationManager.GPS_PROVIDER
        ) || manager.isProviderEnabled(
                LocationManager.NETWORK_PROVIDER
        );
    }
    // ==========================================
    // ESTADO CENTRALIZADO (NO SOLICITA PERMISOS)
    // ==========================================
    private Map<String, Object> getBluetoothStatus() {
        Map<String, Object> status = new HashMap<>();
        BluetoothAdapter adapter = getBluetoothAdapter();
        boolean bluetoothEnabled = false;
        try {
            bluetoothEnabled = adapter != null && adapter.isEnabled();
        } catch (SecurityException e) {
            Log.w(TAG, "STATUS_CONNECT_PERMISSION_MISSING", e);
        }
        status.put("sdk", Build.VERSION.SDK_INT);
        status.put("bluetoothAvailable", adapter != null);
        status.put("bluetoothEnabled", bluetoothEnabled);
        status.put("locationEnabled", isLocationEnabled());
        status.put("scanPermissionGranted", Build.VERSION.SDK_INT >= 31
                ? hasPermission(Manifest.permission.BLUETOOTH_SCAN)
                : hasPermission(Manifest.permission.ACCESS_FINE_LOCATION));
        status.put("connectPermissionGranted", Build.VERSION.SDK_INT >= 31
                ? hasPermission(Manifest.permission.BLUETOOTH_CONNECT) : true);
        Log.d(TAG, "BLUETOOTH_STATUS " + status);
        return status;
    }

    // ==========================================
    // SCAN
    // ==========================================


    @SuppressLint("MissingPermission")
    private void startScan(MethodChannel.Result result) {
        Log.d(TAG, "SCAN_REQUEST sdk=" + Build.VERSION.SDK_INT
                + " scanGranted=" + hasPermission(Manifest.permission.BLUETOOTH_SCAN)
                + " connectGranted=" + hasPermission(Manifest.permission.BLUETOOTH_CONNECT)
                + " locationGranted=" + hasPermission(Manifest.permission.ACCESS_FINE_LOCATION));

        checkScanPermission();
        Log.d(TAG, "SCAN_LOCATION_ENABLED=" + isLocationEnabled());
        if (Build.VERSION.SDK_INT < 31 && !isLocationEnabled()) {
            Log.e(TAG, "SCAN_BLOCKED_LOCATION_DISABLED");
            result.error("LOCATION_DISABLED",
                    "Activa la ubicación del teléfono para buscar dispositivos Bluetooth", null);
            return;
        }
        BluetoothAdapter adapter = requireAdapter();

        if (scanResult != null || pairResult != null) {
            Log.w(TAG, "SCAN_BUSY scanPending=" + (scanResult != null)
                    + " pairPending=" + (pairResult != null));
            result.error("BLUETOOTH_BUSY", "Ya existe una operación Bluetooth activa", null);
            return;
        }

        Log.d(TAG, "SCAN_ADAPTER enabled=" + adapter.isEnabled()
                + " state=" + adapter.getState()
                + " discovering=" + adapter.isDiscovering());

        discoveredDevices.clear();
        scanResult = result;
        scanStarted = false;

        if (adapter.isDiscovering()) {
            boolean cancelled = adapter.cancelDiscovery();
            Log.d(TAG, "CANCEL_PREVIOUS_DISCOVERY result=" + cancelled);
            if (!cancelled) {
                failScan("SCAN_CANCEL_FAILED", "No se pudo cancelar la búsqueda anterior");
                return;
            }
        }

        pendingScanStart = () -> {
            pendingScanStart = null;
            if (scanResult == null) return;

            try {
                BluetoothAdapter current = requireAdapter();
                boolean alreadyDiscovering = current.isDiscovering();
                Log.d(TAG, "SCAN_BEFORE_START enabled=" + current.isEnabled()
                        + " state=" + current.getState()
                        + " discovering=" + alreadyDiscovering);

                if (alreadyDiscovering) {
                    failScan("BLUETOOTH_BUSY", "Bluetooth continúa realizando una búsqueda");
                    return;
                }

                boolean started = current.startDiscovery();
                Log.d(TAG, "START_DISCOVERY_RESULT=" + started
                        + " discoveringAfter=" + current.isDiscovering());

                if (!started) {
                    failScan("SCAN_FAILED", "Android rechazó startDiscovery() (resultado false)");
                    return;
                }

                scanStarted = true;
                handler.postDelayed(scanTimeout, SCAN_TIMEOUT_MS);
            } catch (SecurityException e) {
                Log.e(TAG, "SCAN_PERMISSION_EXCEPTION", e);
                failScan("PERMISSION_DENIED", e.getMessage());
            } catch (Exception e) {
                Log.e(TAG, "SCAN_EXCEPTION", e);
                failScan("SCAN_ERROR", e.getMessage() != null ? e.getMessage() : "Error desconocido");
            }
        };
        Log.d(TAG, "SCAN_SCHEDULED delayMs=800");
        handler.postDelayed(pendingScanStart, 800);
    }

    private boolean hasPermission(String permission) {
        return Build.VERSION.SDK_INT < 23
                || checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED;
    }

    private void cancelPendingScanStart() {
        if (pendingScanStart != null) {
            handler.removeCallbacks(pendingScanStart);
            pendingScanStart = null;
        }
    }

    private void failScan(String code, String message) {
        Log.e(TAG, "SCAN_FAILED code=" + code + " message=" + message);
        cancelPendingScanStart();
        handler.removeCallbacks(scanTimeout);
        scanStarted = false;
        if (scanResult == null) return;
        MethodChannel.Result pending = scanResult;
        scanResult = null;
        pending.error(code, message, null);
    }

    @SuppressLint("MissingPermission")
    private void finishScan() {
        if (scanResult == null) return;

        MethodChannel.Result pending = scanResult;
        scanResult = null;

        handler.removeCallbacks(scanTimeout);
        cancelPendingScanStart();
        scanStarted = false;
        Log.d(TAG, "SCAN_FINISHED found=" + discoveredDevices.size());

        try {
            List<Map<String, Object>> devices =
                    new ArrayList<>();

            for (BluetoothDevice device :
                    discoveredDevices.values()) {

                devices.add(deviceToMap(device));
            }

            pending.success(devices);

        } catch (Exception e) {
            pending.error(
                    "SCAN_RESULT_ERROR",
                    e.getMessage(),
                    null
            );
        }
    }

    @SuppressLint("MissingPermission")
    private void stopDiscoverySafely() {
        try {
            checkScanPermission();

            BluetoothAdapter adapter =
                    getBluetoothAdapter();

            if (adapter != null) {
                adapter.cancelDiscovery();
            }
        } catch (Exception ignored) {
        }
    }

    private BluetoothAdapter getBluetoothAdapter() {
        BluetoothManager manager =
                (BluetoothManager) getSystemService(
                        Context.BLUETOOTH_SERVICE
                );

        return manager != null
                ? manager.getAdapter()
                : null;
    }

    // ==========================================
    // BONDED DEVICES
    // ==========================================

    @SuppressLint("MissingPermission")
    private List<Map<String, Object>> getBondedDevices() {
        BluetoothAdapter adapter = requireAdapter();
        Log.d(TAG, "BONDED_DEVICES_REQUEST");

        List<Map<String, Object>> devices =
                new ArrayList<>();

        for (BluetoothDevice device :
                adapter.getBondedDevices()) {

            devices.add(deviceToMap(device));
        }

        Log.d(TAG, "BONDED_DEVICES_RESULT count=" + devices.size());
        return devices;
    }

    // ==========================================
    // PAIR
    // ==========================================

    @SuppressLint("MissingPermission")
    private void pairDevice(
            String address,
            MethodChannel.Result result
    ) {
        Log.d(TAG, "PAIR_REQUEST address=" + address);
        checkConnectPermission();

        BluetoothAdapter adapter = requireAdapter();

        if (scanResult != null || pairResult != null) {
            result.error(
                    "BLUETOOTH_BUSY",
                    "Existe una operación Bluetooth activa",
                    null
            );
            return;
        }

        BluetoothDevice device =
                adapter.getRemoteDevice(address);

        if (device.getBondState() ==
                BluetoothDevice.BOND_BONDED) {

            Log.d(TAG, "PAIR_ALREADY_BONDED address=" + address);
            result.success(deviceToMap(device));
            return;
        }

        stopDiscoverySafely();

        pairResult = result;
        pairingAddress = address;

        boolean started = device.createBond();
        Log.d(TAG, "PAIR_CREATE_BOND_RESULT=" + started);

        if (!started) {
            finishPairError(
                    "PAIR_FAILED",
                    "No se pudo iniciar el emparejamiento"
            );
            return;
        }

        handler.postDelayed(
                pairTimeout,
                PAIR_TIMEOUT_MS
        );
    }

    // ==========================================
    // BOND STATE
    // ==========================================

    @SuppressLint("MissingPermission")
    private void handleBondStateChanged(Intent intent) {
        BluetoothDevice device =
                getIntentDevice(intent);

        if (device == null || pairResult == null) {
            return;
        }

        if (!device.getAddress().equalsIgnoreCase(
                pairingAddress
        )) {
            return;
        }

        int state = intent.getIntExtra(
                BluetoothDevice.EXTRA_BOND_STATE,
                BluetoothDevice.BOND_NONE
        );

        int previousState = intent.getIntExtra(
                BluetoothDevice.EXTRA_PREVIOUS_BOND_STATE,
                BluetoothDevice.BOND_NONE
        );

        Log.d(TAG, "PAIR_BOND_STATE address=" + device.getAddress() + " state=" + state + " previous=" + previousState);
        if (state == BluetoothDevice.BOND_BONDED) {

            MethodChannel.Result pending = pairResult;

            pairResult = null;
            pairingAddress = null;

            handler.removeCallbacks(pairTimeout);

            Log.d(TAG, "PAIR_SUCCESS address=" + device.getAddress());
            pending.success(deviceToMap(device));

        } else if (
                state == BluetoothDevice.BOND_NONE &&
                        previousState ==
                                BluetoothDevice.BOND_BONDING
        ) {

            finishPairError(
                    "PAIR_FAILED",
                    "Emparejamiento cancelado o rechazado"
            );
        }
    }

    private void finishPairError(
            String code,
            String message
    ) {
        if (pairResult == null) return;

        MethodChannel.Result pending = pairResult;

        pairResult = null;
        pairingAddress = null;

        handler.removeCallbacks(pairTimeout);

        Log.e(TAG, "PAIR_ERROR code=" + code + " message=" + message);
        pending.error(code, message, null);
    }

    // ==========================================
    // DETAILS
    // ==========================================

    @SuppressLint("MissingPermission")
    private Map<String, Object> getDeviceDetails(
            String address
    ) {
        Log.d(TAG, "DETAILS_REQUEST address=" + address);
        BluetoothAdapter adapter = requireAdapter();

        BluetoothDevice device =
                adapter.getRemoteDevice(address);

        return deviceToMap(device);
    }

    // ==========================================
    // MAPPER
    // ==========================================

    @SuppressLint("MissingPermission")
    private Map<String, Object> deviceToMap(
            BluetoothDevice device
    ) {
        checkConnectPermission();

        Map<String, Object> map = new HashMap<>();

        map.put("id", device.getAddress());

        map.put(
                "name",
                device.getName() != null
                        ? device.getName()
                        : "Dispositivo Bluetooth"
        );

        map.put("address", device.getAddress());

        map.put(
                "bonded",
                device.getBondState() ==
                        BluetoothDevice.BOND_BONDED
        );

        map.put("connected", false);
        map.put("bluetoothType", "classic");

        if (device.getBluetoothClass() != null) {
            map.put(
                    "deviceClass",
                    device.getBluetoothClass()
                            .getDeviceClass()
            );
        }

        return map;
    }

    // ==========================================
    // INTENT DEVICE
    // ==========================================

    @SuppressWarnings("deprecation")
    private BluetoothDevice getIntentDevice(
            Intent intent
    ) {
        if (Build.VERSION.SDK_INT >= 33) {
            return intent.getParcelableExtra(
                    BluetoothDevice.EXTRA_DEVICE,
                    BluetoothDevice.class
            );
        }

        return intent.getParcelableExtra(
                BluetoothDevice.EXTRA_DEVICE
        );
    }

    // ==========================================
    // CLEANUP
    // ==========================================

    @Override
    protected void onDestroy() {

        handler.removeCallbacks(scanTimeout);
        handler.removeCallbacks(pairTimeout);
        cancelPendingScanStart();
        scanStarted = false;

        stopDiscoverySafely();

        if (scanResult != null) {
            scanResult.error(
                    "CANCELLED",
                    "Actividad cerrada",
                    null
            );
            scanResult = null;
        }

        if (pairResult != null) {
            pairResult.error(
                    "CANCELLED",
                    "Actividad cerrada",
                    null
            );
            pairResult = null;
        }

        pairingAddress = null;

        if (receiverRegistered) {
            try {
                unregisterReceiver(bluetoothReceiver);
            } catch (Exception ignored) {
            }

            receiverRegistered = false;
        }

        super.onDestroy();
    }
}


