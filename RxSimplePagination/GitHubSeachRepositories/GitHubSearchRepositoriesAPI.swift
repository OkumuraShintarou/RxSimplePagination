//
//  GitHubSearchRepositoriesAPI.swift
//  RxSimplePagination
//
//  Created by 奥村晋太郎 on 2018/04/02.
//  Copyright © 2018年 奥村晋太郎. All rights reserved.
//

import RxSwift

import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.URLRequest
import struct Foundation.NSRange
import class Foundation.HTTPURLResponse
import class Foundation.URLSession
import class Foundation.NSRegularExpression
import class Foundation.JSONSerialization
import class Foundation.NSString
import SystemConfiguration

enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}

public enum ReachabilityStatus {
    case reachable(viaWiFi: Bool)
    case unreachable
}

extension ReachabilityStatus {
    var reachable: Bool {
        switch self {
        case .reachable:
            return true
        case .unreachable:
            return false
        }
    }
}

public class Reachability {
    // typealiastとは名前に型属性をつけるもの
    public typealias NetworkReachable = (Reachability) -> ()
    public typealias NetworkUnreachable = (Reachability) -> ()

    public enum NetworkStatus: CustomStringConvertible {
        case notReachable, reachableViaWiFi, reachableViaWWAN

        public var description: String {
            switch self {
            case .reachableViaWWAN:
                return "Cellular"
            case .reachableViaWiFi:
                return "WiFi"
            case .notReachable:
                return "WiFi"
            }
        }
    }

    public var whenReachable: NetworkReachable?
    public var whenUnreachable: NetworkUnreachable?
    public var reachableOnWWAN: Bool

    public var notificationCenter: NotificationCenter = NotificationCenter.default

    public var currentReachabilityStatus: NetworkStatus {
        guard isReachable else { return .notReachable }

        if isReachableViaWiFi {
            return .reachableViaWiFi
        }

        if isRunningOnDevice {
            return .reachableViaWWAN
        }

        return .notReachable
    }

    public var currentReachabilityString: String {
        return "\(currentReachabilityStatus)"
    }

    fileprivate var isRunningOnDevice: Bool = {
        #if (arch(i386)) || (arch(x86_64)) && os(iOS)
            return false
        #else
            return true
        #endif
        }()

    fileprivate var reachabilityRef: SCNetworkReachability?

    init() {

    }
}

public extension Reachability {


    var isReachable: Bool {
        guard isReachableflagSet else { return false }

        if isConnectionRequiredAndTransientFlagSet {
            return false
        }

        if isRunningOnDevice {
            if isOnWWANFlagSet && !reachableOnWWAN {
                return false
            }
        }
        return true
    }

    var isReachableViaWWAN: Bool {
        return isRunningOnDevice && isReachableflagSet && isOnWWANFlagSet
    }

    var isReachableViaWiFi: Bool {
        guard isReachableflagSet else { return false }

        guard isRunningOnDevice else { return false }

        return !isOnWWANFlagSet
    }
}

fileprivate extension Reachability {


    var isOnWWANFlagSet: Bool {
        #if os(iOS)
            return reachabilityFlags.contains(.isWWAN)
        #else
            return false
        #endif
    }

    var isReachableflagSet: Bool {
        return reachabilityFlags.contains(.reachable)
    }

    var isConnectionRequiredAndTransientFlagSet: Bool {
        return reachabilityFlags.intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }

    var reachabilityFlags: SCNetworkReachabilityFlags {
        guard let reachabilityRef = reachabilityRef else { return SCNetworkReachabilityFlags() }

        var flags = SCNetworkReachabilityFlags()
        let gotFlags = withUnsafeMutablePointer(to: &flags) {
            SCNetworkReachabilityGetFlags(reachabilityRef, UnsafeMutablePointer($0))
        }

        if gotFlags {
            return flags
        } else {
            return SCNetworkReachabilityFlags()
        }
    }

}

protocol ReachabilityService {
    var reachability: Observable<ReachabilityStatus> { get }
}

enum ReachabilityServiceError: Error {
    case failedToCreate
}

class DefaultReachabilityService: ReachabilityService {
    // BehaviorSubjectとは
    private let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>

    var reachability: Observable<ReachabilityStatus> {
        return _reachabilitySubject.asObservable()
    }

    let _reachability: Reachability

    init() {
        
    }
}

/*`
 Parsed GitHub Repositories
 */

// Debugを表示するStringのプロトコル
struct Repository: CustomDebugStringConvertible {

    var name: String
    var url: URL

    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

extension Repository {
    var debugDescription: String {
        return "\(name) | \(url)"
    }
}

// GitHubの通信ステータス
enum GitHubServiceError: Error {
    case offline
    case githubLimitReached
    case networkError
}

// typeAliasとは
typealias SearchRepositoriesResponse = Result<(repositories: [Repository], nextURL: URL?), GitHubServiceError>

class GitHubSearchRepositoriesAPI {
    static let sharedAPI = GitHubSearchRepositoriesAPI(reachabilityService: try! DefaultReachabilityService())

    fileprivate let _reachabilityService: ReachabilityService
    private init(reachabilityService: ReachabilityService) {
        self._reachabilityService = reachabilityService
    }
}
