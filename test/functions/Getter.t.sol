// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {Getter} from "bundle/textDAO/functions/Getter.sol";
import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {Schema} from "bundle/textDAO/storages/Schema.sol";

contract GetterTest is MCTest {

    function setUp() public {
        address getter = address(new Getter());
        _use(Getter.getProposal.selector, getter);
        _use(Getter.getNextProposalId.selector, getter);
        _use(Getter.getProposalsConfig.selector, getter);
        _use(Getter.getText.selector, getter);
        _use(Getter.getNextTextId.selector, getter);
        _use(Getter.getMember.selector, getter);
        _use(Getter.getNextMemberId.selector, getter);
        _use(Getter.getVRFRequest.selector, getter);
        _use(Getter.getNextVRFId.selector, getter);
        _use(Getter.getSubscriptionId.selector, getter);
        _use(Getter.getVRFConfig.selector, getter);
        _use(Getter.getConfigOverride.selector, getter);
    }

    function test_Proposals_success() public {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
    
        $.proposals[1].proposalMeta.currentScore = 1;
        $.nextProposalId = 1;
        $.config.expiryDuration = 1;

        Schema.ProposalNoTallied memory resProposalNoTallied = Getter(address(this)).getProposal(1);
        assertEq(resProposalNoTallied.proposalMeta.currentScore, 1);

        uint resNextProposalId = Getter(address(this)).getNextProposalId();
        assertEq(resNextProposalId, 1);

        Schema.ProposalsConfig memory resProposalsConfig = Getter(address(this)).getProposalsConfig();
        assertEq(resProposalsConfig.expiryDuration, 1);
    }

    function test_Texts_success() public {
        Schema.TextSaveProtectedStorage storage $ = Storage.$Texts();

        $.texts[1].id = 1;
        $.nextTextId = 1;

        Schema.Text memory resText = Getter(address(this)).getText(1);
        assertEq(resText.id, 1);
        
        uint resNextTextId = Getter(address(this)).getNextTextId();
        assertEq(resNextTextId, 1);
    }

    function test_Members_success() public {
        Schema.MemberJoinProtectedStorage storage $ = Storage.$Members();

        $.members[1].id = 1;
        $.nextMemberId = 1;

        Schema.Member memory resMember = Getter(address(this)).getMember(1);
        assertEq(resMember.id, 1);
        
        uint resNextmemberId = Getter(address(this)).getNextMemberId();
        assertEq(resNextmemberId, 1);
    }

    function test_VRF_success() public {
        Schema.VRFStorage storage $ = Storage.$VRF();

        $.requests[1].requestId = 1;
        $.nextId = 1;
        $.subscriptionId = 1;
        $.config.vrfCoordinator = address(1);

        Schema.Request memory resRequest = Getter(address(this)).getVRFRequest(1);
        assertEq(resRequest.requestId, 1);

        uint resNextVRFId = Getter(address(this)).getNextVRFId();
        assertEq(resNextVRFId, 1);

        uint resSubscriptionIdId = Getter(address(this)).getSubscriptionId();
        assertEq(resSubscriptionIdId, 1);

        Schema.VRFConfig memory resVRFConfig = Getter(address(this)).getVRFConfig();
        assertEq(resVRFConfig.vrfCoordinator, address(1));
    }

    function test_ConfigOverride_success() public {
        Schema.ConfigOverrideStorage storage $ = Storage.$ConfigOverride();

        $.overrides[bytes4(uint32(1))].quorumScore = 1;

        Schema.ConfigOverride memory resConfigOverride = Getter(address(this)).getConfigOverride(bytes4(uint32(1)));
        assertEq(resConfigOverride.quorumScore, 1);
    }    
}
