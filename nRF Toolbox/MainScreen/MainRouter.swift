//
//  MainRouter.swift
//  nRF Toolbox
//
//  Created by Nick Kibysh on 22/08/2019.
//  Copyright © 2019 Nordic Semiconductor. All rights reserved.
//

import UIKit

enum ServiceId: String, CaseIterable {
    case glucoseMonitoring
    case bloodPressureMonitoring
    case cyclingSensor
    case heartRateMonitor
    case healthThermometer
    case runningSensor
    case continuousGlucoseMonitor
    case uart
    case deviceFirmwareUpgrade
    case proximity
    case homeKit
}

protocol MainRouter {
    var rootViewController: UIViewController { get }
}

protocol ServiceRouter {
    func showServiceController(with serviceId: ServiceId)
//    func showServiceController(_ model: BLEService)
    func showLinkController(_ link: LinkService)
}

class DefaultMainRouter {
    
    private let serviceViewControllers: [ServiceId : UIViewController] = {
        return [
            .deviceFirmwareUpgrade : DFUViewController(),
            .heartRateMonitor : HeartRateMonitorTableViewController(),
            .bloodPressureMonitoring : BloodPressureTableViewController(),
            .glucoseMonitoring : GlucoseMonitorViewController(),
            .continuousGlucoseMonitor : ContinuousGlucoseMonitor(),
            .healthThermometer : HealthTermometerTableViewController(),
            
            .cyclingSensor : CyclingTableViewController(),
            
            .runningSensor : RunningTableViewController(),
            
            .proximity : ProximityViewController(),
//            .uart : UARTViewController1(),
            .homeKit : HKViewController.instance()
            ].mapValues { UINavigationController.nordicBranded(rootViewController: $0) }
        .merging([.uart : UARTTabBarController()], uniquingKeysWith: {n, _ in n})
    }()
    
    lazy private var serviceList = ServiceListViewController(serviceRouter: self)
    
    lazy private var splitViewController: UISplitViewController = {
        let nc = UINavigationController.nordicBranded(rootViewController: serviceList, prefersLargeTitles: true)
        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [nc, NoContentViewController()]
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .allVisible
        
        return splitViewController
    }()
    
}

extension DefaultMainRouter: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return serviceList.selectedService == nil
    }
}

extension DefaultMainRouter: ServiceRouter {
    func showServiceController(with serviceId: ServiceId) {
        guard let viewController = serviceViewControllers[serviceId] else {
            Log(category: .ui, type: .error).log(message: "Cannot find view controller for \(serviceId) service id")
            return
        }
        splitViewController.showDetailViewController(viewController, sender: self)
    }
    
    func showLinkController(_ link: LinkService) {
        let webViewController = WebViewController(link: link)
        let nc = UINavigationController.nordicBranded(rootViewController: webViewController)
        splitViewController.showDetailViewController(nc, sender: self)
    }
}

extension DefaultMainRouter: MainRouter {
    var rootViewController: UIViewController {
        return splitViewController
    }
}

extension DefaultMainRouter {
    static private func createAndWrappController<T>(controllerClass: T.Type) -> UIViewController where T : UIViewController & StoryboardInstantiable {
        return UINavigationController.nordicBranded(rootViewController: controllerClass.instance())
    }
}
