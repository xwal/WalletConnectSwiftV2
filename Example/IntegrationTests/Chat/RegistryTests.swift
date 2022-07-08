import XCTest
import WalletConnectRelay
import WalletConnectKMS
import WalletConnectUtils
@testable import Chat

final class RegistryTests: XCTestCase {

    func testRegistry() async throws {
        let client = HTTPClient(host: "159.65.123.131")
        let registry = KeyserverRegistryProvider(client: client)
        let account = Account("eip155:1:" + Data.randomBytes(count: 16).toHexString())!
        let pubKey = SigningPrivateKey().publicKey.hexRepresentation
        try await registry.register(account: account, pubKey: pubKey)
        let resolvedKey = try await registry.resolve(account: account)
        XCTAssertEqual(resolvedKey, pubKey)
    }
}