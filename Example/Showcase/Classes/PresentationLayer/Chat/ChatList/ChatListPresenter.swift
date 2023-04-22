import UIKit
import Combine
import WalletConnectChat

final class ChatListPresenter: ObservableObject {

    private let interactor: ChatListInteractor
    private let router: ChatListRouter
    private let account: Account
    private var disposeBag = Set<AnyCancellable>()

    @Published private var threads: [WalletConnectChat.Thread] = []
    @Published private var receivedInvites: [ReceivedInvite] = []
    @Published private var sentInvites: [SentInvite] = []

    var threadViewModels: [ThreadViewModel] {
        return threads
            .sorted(by: { $0.topic < $1.topic })
            .map { ThreadViewModel(thread: $0) }
    }

    var receivedInviteViewModels: [InviteViewModel] {
        return receivedInvites
            .sorted(by: { $0.timestamp < $1.timestamp })
            .map { InviteViewModel(invite: $0) }
    }

    var sentInviteViewModels: [InviteViewModel] {
        return sentInvites
            .sorted(by: { $0.timestamp < $1.timestamp })
            .map { InviteViewModel(invite: $0) }
    }

    init(account: Account, interactor: ChatListInteractor, router: ChatListRouter) {
        defer { setupInitialState() }
        self.account = account
        self.interactor = interactor
        self.router = router
    }

    var showReceivedInvites: Bool {
        return !receivedInviteViewModels.isEmpty
    }

    var showSentInvites: Bool {
        return !sentInviteViewModels.isEmpty
    }

    func didPressThread(_ thread: ThreadViewModel) {
        router.presentChat(thread: thread.thread)
    }

    func didPressReceivedInvites() {
        router.presentReceivedInviteList(account: account)
    }

    func didPressSentInvites() {
        router.presentSentInviteList(account: account)
    }

    @MainActor
    func didLogoutPress() async throws {
        try await interactor.logout()
        router.presentWelcome()
    }

    @MainActor
    func didCopyPress() async throws {
        guard let account = interactor.account else { return }
        UIPasteboard.general.string = account.absoluteString

        throw AlertError(message: "Account copied to clipboard")
    }

    func didPressNewChat() {
        presentInvite()
    }
}

// MARK: SceneViewModel

extension ChatListPresenter: SceneViewModel {

    var sceneTitle: String? {
        return "Chat"
    }

    var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
        return .always
    }

    var rightBarButtonItem: UIBarButtonItem? {
        return UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(presentInvite)
        )
    }
}

// MARK: Privates

private extension ChatListPresenter {

    func setupInitialState() {
        interactor.setupSubscriptions(account: account)

        threads = interactor.getThreads(account: account)
        receivedInvites = interactor.getReceivedInvites(account: account)
        sentInvites = interactor.getSentInvites(account: account)

        interactor.threadsSubscription()
            .sink { [unowned self] threads in
                self.threads = threads
            }.store(in: &disposeBag)

        interactor.receivedInvitesSubscription()
            .sink { [unowned self] receivedInvites in
                self.receivedInvites = receivedInvites
            }.store(in: &disposeBag)

        interactor.sentInvitesSubscription()
            .sink { [unowned self] sentInvites in
                self.sentInvites = sentInvites
            }.store(in: &disposeBag)
    }

    @objc func presentInvite() {
        router.presentInvite(account: account)
    }
}
