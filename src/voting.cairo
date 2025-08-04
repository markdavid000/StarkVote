// SPDX-License-Identifier: MIT
%lang starknet

from starknet::contract import contract
from starknet::context import get_caller_address
from starknet::storage import Storage
from starknet::array::ArrayTrait
from starknet::syscalls import require
use array::ArrayTrait;

@contract
mod Voting {
    struct Proposal {
        name: felt252,
        vote_count: u32,
    }

    // Storage variables
    @storage_var
    fn proposals(index: usize) -> Proposal {}

    @storage_var
    fn proposals_len() -> usize {}

    @storage_var
    fn has_voted(user: felt252) -> bool {}

    @storage_var
    fn admin() -> felt252 {}

    #[constructor]
    fn constructor(admin_address: felt252) {
        admin::write(admin_address);
    }

    #[external]
    fn create_proposal(name: felt252) {
        let caller = get_caller_address();
        require(caller == admin::read(), 'Only admin can create proposals');

        let len = proposals_len::read();
        proposals::write(len, Proposal { name, vote_count: 0 });
        proposals_len::write(len + 1);
    }

    #[external]
    fn vote(proposal_index: usize) {
        let voter = get_caller_address();

        require(!has_voted::read(voter), 'Already voted');

        let mut proposal = proposals::read(proposal_index);
        proposal.vote_count += 1;
        proposals::write(proposal_index, proposal);

        has_voted::write(voter, true);
    }

    #[view]
    fn get_proposal(index: usize) -> Proposal {
        proposals::read(index)
    }

    #[view]
    fn get_proposals_len() -> usize {
        proposals_len::read()
    }

    #[view]
    fn get_winner() -> (felt252, u32) {
        let mut max_votes = 0_u32;
        let mut winner_name = 0;

        let len = proposals_len::read();
        let mut i = 0;
        while i < len {
            let proposal = proposals::read(i);
            if proposal.vote_count > max_votes {
                max_votes = proposal.vote_count;
                winner_name = proposal.name;
            }
            i += 1;
        }

        (winner_name, max_votes)
    }
}
