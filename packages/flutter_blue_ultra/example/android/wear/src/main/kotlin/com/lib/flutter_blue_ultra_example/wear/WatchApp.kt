package com.lib.flutter_blue_ultra_example.wear

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.wear.compose.navigation.SwipeDismissableNavHost
import androidx.wear.compose.navigation.composable
import androidx.wear.compose.navigation.rememberSwipeDismissableNavController
import com.lib.flutter_blue_ultra_example.wear.ble.BleViewModel
import com.lib.flutter_blue_ultra_example.wear.ble.ui.BleDeviceDetailScreen
import com.lib.flutter_blue_ultra_example.wear.ble.ui.BleDeviceListScreen
import com.lib.flutter_blue_ultra_example.wear.design.WatchTheme

object Routes {
    const val BLE_DEVICES = "ble/devices"
    const val BLE_DETAIL = "ble/detail"
}

@Composable
fun WatchApp() {
    WatchTheme {
        val navController = rememberSwipeDismissableNavController()
        val bleViewModel: BleViewModel = viewModel(factory = BleViewModel.factory(LocalContext.current))
        SwipeDismissableNavHost(navController = navController, startDestination = Routes.BLE_DEVICES) {
            composable(Routes.BLE_DEVICES) {
                BleDeviceListScreen(bleViewModel, onDeviceSelected = { device ->
                    bleViewModel.connect(device)
                    navController.navigate(Routes.BLE_DETAIL)
                })
            }
            composable(Routes.BLE_DETAIL) {
                BleDeviceDetailScreen(bleViewModel)
            }
        }
    }
}
