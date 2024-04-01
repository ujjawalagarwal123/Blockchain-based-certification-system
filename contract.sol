// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
contract CertificationAdmin {
    address public owner;
    mapping(address => bool) public authorities;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerAuthority(address _authority) public onlyOwner {
        authorities[_authority] = true;
    }

    function revokeAuthority(address _authority) public onlyOwner {
        authorities[_authority] = false;
    }
}

// Certification Contract
contract Certification {
    address public adminContractAddress;
    mapping(address => CertificationInfo) public certifications;

    struct CertificationInfo {
        address certifier;
        address organization;
        string courseName;
        bool isValid;
        uint256 dateOfIssue;
        uint256 dateOfExpiration;
        string ipfsLink;
    }

    modifier onlyAuthority() {
        require(CertificationAdmin(adminContractAddress).authorities(msg.sender), "Only authorities can call this function");
        _;
    }

    constructor(address _adminContractAddress) {
        adminContractAddress = _adminContractAddress;
    }

    event CertificationIssued(address indexed user, address indexed certifier, address indexed organization, string courseName, uint256 dateOfIssue, uint256 dateOfExpiration, string ipfsLink);
    event CertificationRevoked(address indexed user, address indexed revoker);

    function issueCertification(address user, address organization, string memory courseName, uint256 dateOfIssue, uint256 dateOfExpiration, string memory ipfsLink) public onlyAuthority {
        certifications[user] = CertificationInfo(msg.sender, organization, courseName, true, dateOfIssue, dateOfExpiration, ipfsLink);
        emit CertificationIssued(user, msg.sender, organization, courseName, dateOfIssue, dateOfExpiration, ipfsLink);
    }

    function revokeCertification(address user) public onlyAuthority {
        delete certifications[user];
        emit CertificationRevoked(user, msg.sender);
    }
}