import 'package:country_code_picker/country_code_picker.dart';
import 'package:equatable/equatable.dart';
import 'package:fusecash/models/community/community.dart';
import 'package:fusecash/models/tokens/token.dart';
import 'package:fusecash/models/transactions/transaction.dart';
import 'package:redux/redux.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/redux/actions/cash_wallet_actions.dart';
import 'package:fusecash/redux/actions/user_actions.dart';
import 'package:contacts_service/contacts_service.dart';

class HomeViewModel extends Equatable {
  final List<Transaction> feedList;
  final String accountAddress;
  final String walletAddress;
  final String communityAddress;
  final String branchAddress;
  final String isoCode;
  final bool isCommunityLoading;
  final bool isCommunityFetched;
  final bool isBalanceFetchingStarted;
  final bool isBranchDataReceived;
  final String walletStatus;
  final Function(String) switchCommunity;
  final Function() startTransfersFetching;
  final Function() listenToBranch;
  final Function(List<Contact>) syncContacts;
  final Function() branchCommunityUpdate;
  final Function() loadBusinesses;
  final Function() syncContactsRejected;
  final Function() startProcessingJobs;
  final Function() setIdentifier;
  final Function(CountryCode countryCode) setCountyCode;

  HomeViewModel({
    this.accountAddress,
    this.walletAddress,
    this.walletStatus,
    this.communityAddress,
    this.branchAddress,
    this.isoCode,
    this.isCommunityLoading,
    this.isCommunityFetched,
    this.isBalanceFetchingStarted,
    this.isBranchDataReceived,
    this.switchCommunity,
    this.startTransfersFetching,
    this.listenToBranch,
    this.syncContacts,
    this.branchCommunityUpdate,
    this.loadBusinesses,
    this.syncContactsRejected,
    this.startProcessingJobs,
    this.setIdentifier,
    this.setCountyCode,
    this.feedList,
  });

  static HomeViewModel fromStore(Store<AppState> store) {
    List<Community> communities =
        store.state.cashWalletState.communities.values.toList();

    List<Transaction> erc20TokensTxs =
        store.state.proWalletState.erc20Tokens?.values?.fold(
            [],
            (List<Transaction> previousValue, Token token) =>
                previousValue..addAll(token.transactions?.list ?? []));
    List<Transaction> communityTxs = communities?.fold(
        [],
        (List<Transaction> previousValue, Community community) =>
            previousValue..addAll(community.token.transactions?.list ?? []));
    String communityAddress = store.state.cashWalletState.communityAddress;
    bool isCommunityLoading =
        store.state.cashWalletState.isCommunityLoading ?? false;
    String branchAddress = store.state.cashWalletState.branchAddress;
    String identifier = store.state.userState.identifier;
    bool isJobProcessingStarted =
        store.state.cashWalletState.isJobProcessingStarted ?? false;
    bool isListeningToBranch =
        store.state.cashWalletState.isListeningToBranch ?? false;
    return HomeViewModel(
        isoCode: store.state.userState.isoCode,
        accountAddress: store.state.userState.accountAddress,
        walletAddress: store.state.cashWalletState.walletAddress,
        walletStatus: store.state.cashWalletState.walletStatus,
        communityAddress: communityAddress,
        branchAddress: branchAddress,
        isCommunityLoading: isCommunityLoading,
        isCommunityFetched:
            store.state.cashWalletState.isCommunityFetched ?? false,
        isBalanceFetchingStarted:
            store.state.cashWalletState.isBalanceFetchingStarted ?? false,
        isBranchDataReceived:
            store.state.cashWalletState.isBranchDataReceived ?? false,
        feedList: [...communityTxs, ...erc20TokensTxs]..sort((a, b) {
            if (a.timestamp != null && b.timestamp != null) {
              return a.timestamp.compareTo(b.timestamp);
            } else if (a.blockNumber != null && b.blockNumber != null) {
              return a.blockNumber.compareTo(b.blockNumber);
            }
            return (a?.blockNumber ?? 1).compareTo((b?.blockNumber ?? 0));
          }),
        switchCommunity: (String communityAddress) {
          store.dispatch(switchCommunityCall(communityAddress));
        },
        startTransfersFetching: () {
          store.dispatch(startTransfersFetchingCall());
        },
        listenToBranch: () {
          if (!isListeningToBranch) {
            store.dispatch(listenToBranchCall());
          }
        },
        syncContacts: (List<Contact> contacts) {
          store.dispatch(syncContactsCall(contacts));
        },
        syncContactsRejected: () {
          store.dispatch(new SyncContactsRejected());
        },
        branchCommunityUpdate: () {
          store.dispatch(switchCommunityCall(branchAddress));
        },
        loadBusinesses: () {
          store.dispatch(getBusinessListCall());
        },
        startProcessingJobs: () {
          if (!isJobProcessingStarted) {
            store.dispatch(startProcessingJobsCall());
          }
        },
        setIdentifier: () {
          if (identifier == null) {
            store.dispatch(setDeviceId(true));
          }
        },
        setCountyCode: (CountryCode countryCode) {
          store.dispatch(setCountryCode(countryCode));
        });
  }

  @override
  List<Object> get props => [
        accountAddress,
        walletAddress,
        walletStatus,
        communityAddress,
        branchAddress,
        isCommunityLoading,
        isBranchDataReceived,
        isoCode,
        feedList
      ];
}
