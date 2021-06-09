// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCommunicationChat
import AzureCommunicationCommon
import AzureCore
import AzureTest
import DVR
import XCTest

class ChatClientDVRTests: XCTestCase {
    /// ChatClient initialized in setup.
    private var chatClient: ChatClient!
    /// Test mode.
    private var mode = getEnvironmentVariable(withKey: "TEST_MODE", default: "playback")

    override func setUpWithError() throws {
        let endpoint = getEnvironmentVariable(withKey: "AZURE_COMMUNICATION_ENDPOINT", default: "https://endpoint")
        let token = generateToken()
        let credential = try CommunicationTokenCredential(token: token)
        let transportOptions = TransportOptions(transport: DVRSessionTransport(cassetteName: "myTesting"))
        let options = AzureCommunicationChatClientOptions(transportOptions: transportOptions)

        chatClient = try ChatClient(endpoint: endpoint, credential: credential, withOptions: options)
    }

    func test_CreateThread_WithoutParticipants() {
        let thread = CreateChatThreadRequest(
            topic: "Test topic"
        )

        let expectation = self.expectation(description: "Create thread")

        chatClient.create(thread: thread) { result, httpResponse in
            switch result {
            case let .success(response):
                let chatThread = response.chatThread
                XCTAssertNotNil(response.chatThread)
                XCTAssertEqual(chatThread?.topic, thread.topic)
                XCTAssertNotNil(httpResponse?.httpRequest?.headers["repeatability-request-id"])
                XCTAssertNil(response.invalidParticipants)

            case let .failure(error):
                XCTFail("Create thread failed with error: \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Create thread timed out: \(error)")
            }
        }
    }
}