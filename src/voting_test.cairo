%lang starknet
%builtins test

use core::traits::Into;
use starknet::testing::test_case;
use starknet::contract::ContractAddress;
use starknet::test_utils::start_prank;
use voting::Voting;

#[test_case]
fn test_voting_flow() {
    // Mock addresses
    let admin = 0x1111;
    let user = 0x2222;

    // Deploy contract
    let voting_contract = Voting::deploy(@admin);

    // Admin adds proposals
    start_prank(@admin);
    voting_contract.create_proposal('ProposalA');
    voting_contract.create_proposal('ProposalB');

    // Check proposal count
    assert(voting_contract.get_proposals_len() == 2, 'Proposal count should be 2');

    // User votes
    start_prank(@user);
    voting_contract.vote(0);

    // Check proposal 0 vote count
    let proposal = voting_contract.get_proposal(0);
    assert(proposal.vote_count == 1, 'Vote count should be 1');

    // Check winner
    let (winner_name, votes) = voting_contract.get_winner();
    assert(winner_name == 'ProposalA', 'Winner should be ProposalA');
    assert(votes == 1, 'Vote count should be 1');
}
