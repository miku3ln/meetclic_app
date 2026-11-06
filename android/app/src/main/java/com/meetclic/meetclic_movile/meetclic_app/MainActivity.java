
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

    private final Runnable scanTimeout = () -> {
        if (scanResult != null) {
            finishScan();
            stopDiscoverySafely();
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

                        if (device != null) {
                            discoveredDevices.put(
                                    device.getAddress(),
                                    device
                            );
                        }

                    } else if (
                            BluetoothAdapter.ACTION_DISCOVERY_FINISHED
                                    .equals(action)
                    ) {
                        finishScan();

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

            try {
                switch (call.method) {

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
                result.error(
                        "PERMISSION_DENIED",
                        e.getMessage(),
                        null
                );

            } catch (Exception e) {
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

    // ==========================================
    // SCAN
    // ==========================================

    @SuppressLint("MissingPermission")
    private void startScan(MethodChannel.Result result) {
        checkScanPermission();

        BluetoothAdapter adapter = requireAdapter();

        if (scanResult != null || pairResult != null) {
            result.error(
                    "BLUETOOTH_BUSY",
                    "Ya existe una operación Bluetooth activa",
                    null
            );
            return;
        }

        discoveredDevices.clear();
        scanResult = result;

        adapter.cancelDiscovery();

        boolean started = adapter.startDiscovery();

        if (!started) {
            scanResult = null;

            result.error(
                    "SCAN_FAILED",
                    "No se pudo iniciar el escaneo",
                    null
            );
            return;
        }

        handler.postDelayed(
                scanTimeout,
                SCAN_TIMEOUT_MS
        );
    }

    @SuppressLint("MissingPermission")
    private void finishScan() {
        if (scanResult == null) return;

        MethodChannel.Result pending = scanResult;
        scanResult = null;

        handler.removeCallbacks(scanTimeout);

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

        List<Map<String, Object>> devices =
                new ArrayList<>();

        for (BluetoothDevice device :
                adapter.getBondedDevices()) {

            devices.add(deviceToMap(device));
        }

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
        checkScanPermission();

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

            result.success(deviceToMap(device));
            return;
        }

        stopDiscoverySafely();

        pairResult = result;
        pairingAddress = address;

        boolean started = device.createBond();

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

        if (state == BluetoothDevice.BOND_BONDED) {

            MethodChannel.Result pending = pairResult;

            pairResult = null;
            pairingAddress = null;

            handler.removeCallbacks(pairTimeout);

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

        pending.error(code, message, null);
    }

    // ==========================================
    // DETAILS
    // ==========================================

    @SuppressLint("MissingPermission")
    private Map<String, Object> getDeviceDetails(
            String address
    ) {
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
