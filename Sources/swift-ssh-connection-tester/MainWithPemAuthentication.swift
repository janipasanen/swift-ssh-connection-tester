//
//  MainWithPemAuthentication.swift
//
//
//  Created by Jani Pasanen on 2024-05-28.
//

/*
import Dispatch
import NIO
import NIOSSH
import Crypto

final class ErrorHandler: ChannelInboundHandler {
    typealias InboundIn = Any

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error in pipeline: \(error)")
        context.close(promise: nil)
    }
}

final class AcceptAllHostKeysDelegate: NIOSSHClientServerAuthenticationDelegate {
    func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
        validationCompletePromise.succeed(())
    }
}

struct PEMPrivateKey {
    let key: String
}

func loadPEMPrivateKey() throws -> PEMPrivateKey {
    // Ensure that the file is added to the Xcode project and bundled correctly
    guard let pemFilePath = Bundle.main.path(forResource: "jumphost", ofType: "pem") else {
        throw NSError(domain: "File not found", code: -1, userInfo: nil)
    }
    
    let pemData = try String(contentsOfFile: pemFilePath, encoding: .utf8)
    return PEMPrivateKey(key: pemData)
}

func parseED25519PrivateKey(pem: String) throws -> Curve25519.Signing.PrivateKey {
    let keyString = pem
        .split(separator: "\n")
        .filter { !$0.contains("-----") }
        .joined()
    
    guard let keyData = Data(base64Encoded: keyString) else {
        throw NSError(domain: "Invalid PEM format", code: -1, userInfo: nil)
    }
    
    return try Curve25519.Signing.PrivateKey(rawRepresentation: keyData)
}

final class PEMPrivateKeyDelegate: NIOSSHClientUserAuthenticationDelegate {
    let username: String
    let privateKey: NIOSSHPrivateKey
    
    init(username: String, privateKey: NIOSSHPrivateKey) {
        self.username = username
        self.privateKey = privateKey
    }
    
    func nextAuthenticationType(
        availableMethods: NIOSSHAvailableUserAuthenticationMethods,
        nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>
    ) {
        let privateKeyOffer = NIOSSHUserAuthenticationOffer(
            username: self.username,
            serviceName: "",
            offer: .privateKey(.init(privateKey: self.privateKey))
        )
        
        nextChallengePromise.succeed(privateKeyOffer)
    }
}

let parser = SimpleCLIParser()
let parseResult = parser.parse()

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
defer {
    try! group.syncShutdownGracefully()
}

do {
    let privateKeyData = try loadPEMPrivateKey().key
    let ed25519Key = try parseED25519PrivateKey(pem: privateKeyData)
    let sshPrivateKey = NIOSSHPrivateKey(ed25519Key: ed25519Key)
    
    let bootstrap = ClientBootstrap(group: group)
        .channelInitializer { channel in
            channel.pipeline.addHandlers([
                NIOSSHHandler(
                    role: .client(.init(
                        userAuthDelegate: PEMPrivateKeyDelegate(username: parseResult.user, privateKey: sshPrivateKey),
                        serverAuthDelegate: AcceptAllHostKeysDelegate()
                    )),
                    allocator: channel.allocator,
                    inboundChildChannelInitializer: nil
                ),
                ErrorHandler()
            ])
        }
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)

    let channel = try bootstrap.connect(host: parseResult.host, port: parseResult.port).wait()

    if let listen = parseResult.listen {
        let server = PortForwardingServer(group: group,
                                          bindHost: listen.bindHost ?? "localhost",
                                          bindPort: listen.bindPort) { inboundChannel in
            channel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
                let promise = inboundChannel.eventLoop.makePromise(of: Channel.self)
                let directTCPIP = SSHChannelType.DirectTCPIP(targetHost: String(listen.targetHost),
                                                             targetPort: listen.targetPort,
                                                             originatorAddress: inboundChannel.remoteAddress!)
                sshHandler.createChannel(promise,
                                         channelType: .directTCPIP(directTCPIP)) { childChannel, channelType in
                    guard case .directTCPIP = channelType else {
                        return channel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                    }
                    let (ours, theirs) = GlueHandler.matchedPair()
                    return childChannel.pipeline.addHandlers([SSHWrapperHandler(), ours, ErrorHandler()]).flatMap {
                        inboundChannel.pipeline.addHandlers([theirs, ErrorHandler()])
                    }
                }
                return promise.futureResult.map { _ in }
            }
        }
        try! server.run().wait()
    } else {
        let exitStatusPromise = channel.eventLoop.makePromise(of: Int.self)
        let childChannel: Channel = try! channel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
            let promise = channel.eventLoop.makePromise(of: Channel.self)
            sshHandler.createChannel(promise) { childChannel, channelType in
                guard channelType == .session else {
                    return channel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                }
                return childChannel.pipeline.addHandlers([
                    ExampleExecHandler(command: parseResult.commandString, completePromise: exitStatusPromise),
                    ErrorHandler()
                ])
            }
            return promise.futureResult
        }.wait()
        try childChannel.closeFuture.wait()
        let exitStatus = try! exitStatusPromise.futureResult.wait()
        try! channel.close().wait()
        exit(Int32(exitStatus))
    }
} catch {
    print("Error: \(error)")
}

*/
