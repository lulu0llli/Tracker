import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackersViewController() {
        let vc = TrackersViewController()
        vc.loadViewIfNeeded()
        
        let snapshotsDir = NSTemporaryDirectory() + "__Snapshots__"
        
        let failure = verifySnapshot(
            of: vc,
            as: .image,
            snapshotDirectory: snapshotsDir
        )
        
        if let failure = failure {
            XCTFail(failure)
        }
    }
}
