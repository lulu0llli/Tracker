import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackersViewControllerLight() {
        let vc = TrackersViewController()
        vc.loadViewIfNeeded()
        
        let snapshotsDir = NSTemporaryDirectory() + "__Snapshots__"
        
        let failure = verifySnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            snapshotDirectory: snapshotsDir
        )
        
        if let failure = failure {
            XCTFail(failure)
        }
    }
    
    func testTrackersViewControllerDark() {
        let vc = TrackersViewController()
        vc.loadViewIfNeeded()
        
        let snapshotsDir = NSTemporaryDirectory() + "__Snapshots__"
        
        let failure = verifySnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            snapshotDirectory: snapshotsDir
        )
        
        if let failure = failure {
            XCTFail(failure)
        }
    }
}
