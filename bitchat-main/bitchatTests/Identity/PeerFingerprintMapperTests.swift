import XCTest
@testable import bitchat

final class PeerFingerprintMapperTests: XCTestCase {
    private let suiteName = "io.echo.identity.tests"
    private var defaults: UserDefaults! = nil

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    func testMappingAndPersistence() {
        var mapper = PeerFingerprintMapper(defaults: defaults)
        mapper.setMapping(peerID: "peer1", fingerprint: "fp1")
        mapper.setMapping(peerID: "peer2", fingerprint: "fp1")
        mapper.setMapping(peerID: "peer3", fingerprint: "fp2")

        XCTAssertEqual(mapper.fingerprint(forPeerID: "peer1"), "fp1")
        XCTAssertEqual(Set(mapper.peerIDs(forFingerprint: "fp1")), Set(["peer1", "peer2"]))

        mapper.removePeerID("peer1")
        XCTAssertNil(mapper.fingerprint(forPeerID: "peer1"))
        XCTAssertEqual(mapper.peerIDs(forFingerprint: "fp1"), ["peer2"])

        mapper.removeAll(forFingerprint: "fp1")
        XCTAssertTrue(mapper.peerIDs(forFingerprint: "fp1").isEmpty)
        XCTAssertEqual(mapper.fingerprint(forPeerID: "peer3"), "fp2")

        mapper = PeerFingerprintMapper(defaults: defaults)
        XCTAssertEqual(mapper.fingerprint(forPeerID: "peer3"), "fp2")
        XCTAssertTrue(mapper.peerIDs(forFingerprint: "fp1").isEmpty)
    }
}
